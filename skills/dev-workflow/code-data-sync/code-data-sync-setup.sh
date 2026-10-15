#!/usr/bin/env bash
set -euo pipefail

# --- Paths ---

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="${SYNC_CONFIG:-$SCRIPT_DIR/sync-config.json}"

# --- Helpers ---

info()  { echo "▸ $*"; }
warn()  { echo "⚠ $*" >&2; }
error() { echo "✖ $*" >&2; exit 1; }

require_config() {
    if [ ! -f "$CONFIG_FILE" ]; then
        error "Config not found: $CONFIG_FILE — run '$(basename "$0")' (no args) to create one, or copy sync-config.json.example"
    fi
}

# Read a field from a named target: read_field <target_name> <field>
read_field() {
    python3 -c "
import json, sys
with open('$CONFIG_FILE') as f:
    cfg = json.load(f)
target = cfg.get('$1')
if target is None:
    print('__NOT_FOUND__')
    sys.exit(0)
print(target.get('$2', ''))
"
}

# List all target names
list_targets() {
    python3 -c "
import json
with open('$CONFIG_FILE') as f:
    cfg = json.load(f)
for name in cfg:
    print(name)
"
}

# List targets whose type field contains the given type keyword
targets_by_type() {
    local type_filter="$1"
    python3 -c "
import json
with open('$CONFIG_FILE') as f:
    cfg = json.load(f)
for name, t in cfg.items():
    types = [s.strip() for s in t.get('type', '').split(',')]
    if '$type_filter' in types:
        print(name)
"
}

# Build sshpass prefix if a password is set for the target: sshpass_prefix <target_name>
sshpass_prefix() {
    local pw
    pw="$(read_field "$1" password)"
    if [ -n "$pw" ]; then
        if ! command -v sshpass &>/dev/null; then
            error "Target '$1' has a password but sshpass is not installed. Install with: sudo apt install sshpass"
        fi
        echo "sshpass -p $pw"
    fi
}

# Read a boolean field from a named target: read_bool_field <target_name> <field>
read_bool_field() {
    python3 -c "
import json, sys
with open('$CONFIG_FILE') as f:
    cfg = json.load(f)
target = cfg.get('$1')
if target is None:
    print('false')
    sys.exit(0)
val = target.get('$2', False)
print('true' if val else 'false')
"
}

# --- SCP operations ---

do_upload() {
    local name="$1"
    require_config

    local ssh_host local_dir remote_dir ignore_symlinks sp
    ssh_host="$(read_field "$name" ssh_host)"
    local_dir="$(read_field "$name" local_dir)"
    remote_dir="$(read_field "$name" remote_dir)"
    ignore_symlinks="$(read_bool_field "$name" ignore_symlinks)"
    sp="$(sshpass_prefix "$name")"

    if [ "$ssh_host" = "__NOT_FOUND__" ]; then
        error "Target '$name' not found in config"
    fi

    info "Uploading '$name': $local_dir → $ssh_host:$remote_dir"
    $sp ssh "$ssh_host" "mkdir -p '$remote_dir'"
    if [ "$ignore_symlinks" = "true" ]; then
        tar -cf - --no-recursion -C "$local_dir" \
            $(cd "$local_dir" && find . -not -type l | sort) \
            | $sp ssh "$ssh_host" "tar -xf - --no-same-owner -C '$remote_dir'"
    else
        $sp scp -r "$local_dir/." "$ssh_host:$remote_dir/"
    fi
    info "Upload complete: $name"
}

do_download() {
    local name="$1"
    require_config

    local ssh_host local_dir remote_dir ignore_symlinks sp
    ssh_host="$(read_field "$name" ssh_host)"
    local_dir="$(read_field "$name" local_dir)"
    remote_dir="$(read_field "$name" remote_dir)"
    ignore_symlinks="$(read_bool_field "$name" ignore_symlinks)"
    sp="$(sshpass_prefix "$name")"

    if [ "$ssh_host" = "__NOT_FOUND__" ]; then
        error "Target '$name' not found in config"
    fi

    info "Downloading '$name': $ssh_host:$remote_dir → $local_dir"
    mkdir -p "$local_dir"
    if [ "$ignore_symlinks" = "true" ]; then
        $sp ssh "$ssh_host" "tar -cf - --no-recursion -C '$remote_dir' \
            \$(cd '$remote_dir' && find . -not -type l | sort)" \
            | tar -xf - --no-same-owner -C "$local_dir"
    else
        $sp scp -r "$ssh_host:$remote_dir/." "$local_dir/"
    fi
    info "Download complete: $name"
}

do_upload_all() {
    local type_filter="$1"
    require_config

    local targets
    targets="$(targets_by_type "$type_filter")"
    if [ -z "$targets" ]; then
        warn "No targets found with type containing '$type_filter'"
        return
    fi

    info "Uploading all '$type_filter' targets..."
    while IFS= read -r name; do
        do_upload "$name"
    done <<< "$targets"
}

do_download_all() {
    local type_filter="$1"
    require_config

    local targets
    targets="$(targets_by_type "$type_filter")"
    if [ -z "$targets" ]; then
        warn "No targets found with type containing '$type_filter'"
        return
    fi

    info "Downloading all '$type_filter' targets..."
    while IFS= read -r name; do
        do_download "$name"
    done <<< "$targets"
}

do_download_latest() {
    local name="$1"
    local pattern="${2:-}"
    local ckpt_every="${3:-}"
    require_config

    local ssh_host local_dir remote_dir ignore_symlinks sp
    ssh_host="$(read_field "$name" ssh_host)"
    local_dir="$(read_field "$name" local_dir)"
    remote_dir="$(read_field "$name" remote_dir)"
    ignore_symlinks="$(read_bool_field "$name" ignore_symlinks)"
    sp="$(sshpass_prefix "$name")"

    if [ "$ssh_host" = "__NOT_FOUND__" ]; then
        error "Target '$name' not found in config"
    fi

    info "Finding latest training run in $ssh_host:$remote_dir ..."

    local latest_run
    latest_run="$($sp ssh "$ssh_host" "python3 -c \"
import os, re, sys

base = '$remote_dir'
pattern = '$pattern'
event_prefix = 'events.out.tfevents.'

candidates = []
for root, dirs, files in os.walk(base):
    has_event = any(f.startswith(event_prefix) for f in files)
    if not has_event:
        continue
    rel = os.path.relpath(root, base)
    if pattern and not re.search(pattern, rel):
        continue
    mtime = max(os.path.getmtime(os.path.join(root, f)) for f in files if f.startswith(event_prefix))
    candidates.append((mtime, rel))

if not candidates:
    sys.exit(1)

candidates.sort(key=lambda x: x[0], reverse=True)
print(candidates[0][1])
\"")"

    if [ -z "$latest_run" ]; then
        if [ -n "$pattern" ]; then
            error "No training run matching '$pattern' found in $ssh_host:$remote_dir"
        else
            error "No training run found in $ssh_host:$remote_dir (looked for events.out.tfevents.* files)"
        fi
    fi

    local remote_run_dir="$remote_dir/$latest_run"
    local local_run_dir="$local_dir/$latest_run"

    info "Latest run: $latest_run"

    # Build rsync exclude filter for checkpoint thinning
    local exclude_args=""
    if [ -n "$ckpt_every" ]; then
        info "Checkpoint thinning: keeping every ${ckpt_every}th iteration + first + last"
        exclude_args="$($sp ssh "$ssh_host" "python3 -c \"
import os, re, sys

run_dir = '$remote_run_dir'
every = int('$ckpt_every')
ckpt_re = re.compile(r'^model_(\d+)\.pt\$')

nums = []
for f in os.listdir(run_dir):
    m = ckpt_re.match(f)
    if m:
        nums.append(int(m.group(1)))
if not nums:
    sys.exit(0)

nums.sort()
first, last = nums[0], nums[-1]
for n in nums:
    if n == first or n == last or n % every == 0:
        continue
    print('--exclude=model_' + str(n) + '.pt')
\"")"
        if [ -n "$exclude_args" ]; then
            local skip_count
            skip_count="$(echo "$exclude_args" | wc -l)"
            info "Skipping $skip_count checkpoint files"
        fi
    fi

    info "Downloading: $ssh_host:$remote_run_dir → $local_run_dir"
    mkdir -p "$local_run_dir"
    local rsync_ssh_arg=()
    local pw
    pw="$(read_field "$name" password)"
    if [ -n "$pw" ]; then
        rsync_ssh_arg=(-e "sshpass -p $pw ssh")
    fi
    # shellcheck disable=SC2086
    rsync -az --progress "${rsync_ssh_arg[@]+"${rsync_ssh_arg[@]}"}" $exclude_args "$ssh_host:$remote_run_dir/" "$local_run_dir/"
    info "Download complete: $name ($latest_run)"
}

# --- List & status ---

do_list() {
    require_config
    python3 -c "
import json
with open('$CONFIG_FILE') as f:
    cfg = json.load(f)
fmt = '  {:<20s} {:<12s} {:<15s} {:<10s} {:<6s} {}'
print(fmt.format('NAME', 'TYPE', 'SSH HOST', 'NO SYMLNK', 'PASS', 'LOCAL DIR → REMOTE DIR'))
print('  ' + '-' * 105)
for name, t in cfg.items():
    no_sym = 'yes' if t.get('ignore_symlinks', False) else 'no'
    has_pw = 'yes' if t.get('password') else 'no'
    print(fmt.format(name, t.get('type',''), t.get('ssh_host',''), no_sym, has_pw,
          t.get('local_dir','') + ' → ' + t.get('remote_dir','')))
"
}

do_status() {
    require_config

    local targets
    targets="$(list_targets)"

    info "Testing SSH connectivity..."
    local tested_hosts=""
    while IFS= read -r name; do
        local host sp
        host="$(read_field "$name" ssh_host)"
        # Skip hosts already tested (without password)
        if echo "$tested_hosts" | grep -qxF "$host"; then
            continue
        fi
        sp="$(sshpass_prefix "$name")"
        if [ -z "$sp" ]; then
            tested_hosts="${tested_hosts}${host}"$'\n'
        fi
        if $sp ssh -o ConnectTimeout=5 ${sp:+-o PubkeyAuthentication=no} ${sp:-"-o BatchMode=yes"} "$host" "echo ok" &>/dev/null; then
            info "  ✓ $host — reachable"
        else
            warn "  ✗ $host — unreachable (check ~/.ssh/config)"
        fi
    done <<< "$targets"
}

# --- Interactive setup ---

do_setup() {
    if [ -f "$CONFIG_FILE" ]; then
        info "Config already exists: $CONFIG_FILE"
        do_list
        read -rp "Overwrite? [y/N] " ans
        if [[ ! "$ans" =~ ^[Yy] ]]; then
            info "Keeping existing config."
            return
        fi
    fi

    local targets_json="{"
    local first=true

    info "Configure sync targets (enter empty name to finish)"
    while true; do
        echo ""
        read -rp "Target name (e.g. instinctlab): " name
        [ -z "$name" ] && break

        read -rp "Type (code / data / code,data): " type
        read -rp "SSH host (from ~/.ssh/config): " ssh_host
        read -rp "Local directory: " local_dir
        read -rp "Remote directory: " remote_dir
        read -rp "Ignore symlinks? [y/N]: " ignore_sym
        local ignore_symlinks_val="false"
        [[ "$ignore_sym" =~ ^[Yy] ]] && ignore_symlinks_val="true"

        read -rp "Password (leave empty for key-based auth): " target_password

        if [ "$first" = true ]; then
            first=false
        else
            targets_json+=","
        fi

        targets_json+="$(python3 -c "
import json
entry = {
    'type': '$type',
    'ssh_host': '$ssh_host',
    'local_dir': '$local_dir',
    'remote_dir': '$remote_dir',
    'ignore_symlinks': $ignore_symlinks_val
}
pw = '$target_password'
if pw:
    entry['password'] = pw
print(json.dumps({'$name': entry})[1:-1])
")"
    done

    targets_json+="}"

    # Pretty-print and write
    python3 -c "
import json, sys
cfg = json.loads('''$targets_json''')
with open('$CONFIG_FILE', 'w') as f:
    json.dump(cfg, f, indent=2)
    f.write('\n')
"

    info "Config written to $CONFIG_FILE"
    do_list
}

# --- Usage ---

usage() {
    cat << 'EOF'
Usage: code-data-sync-setup.sh [COMMAND]

Sync code and training data between local and remote machines via scp.

Commands:
  (none)              Interactive setup — create sync-config.json
  --upload <name>     Upload a specific target to remote
  --download <name>   Download a specific target from remote
  --download-latest <name> [pattern] [--ckpt-every N]
                      Download the most recent training run folder (by mtime
                      of events.out.tfevents.* files). Optional regex pattern
                      filters matching run directory paths.
                      --ckpt-every N skips model_*.pt files whose iteration
                      is not a multiple of N, keeping the first and last.
  --upload-all <type> Upload all targets matching type (code|data)
  --download-all <type>
                      Download all targets matching type (code|data)
  --list              Show configured targets
  --status            Test SSH connectivity to all configured hosts
  --help              Show this help message

Environment variables:
  SYNC_CONFIG         Path to config file (default: <script-dir>/sync-config.json)
EOF
}

# --- Main ---

main() {
    local cmd="${1:-setup}"
    case "$cmd" in
        --upload)
            [ -z "${2:-}" ] && error "Usage: --upload <target-name>"
            do_upload "$2"
            ;;
        --download)
            [ -z "${2:-}" ] && error "Usage: --download <target-name>"
            do_download "$2"
            ;;
        --download-latest)
            [ -z "${2:-}" ] && error "Usage: --download-latest <target-name> [pattern] [--ckpt-every N]"
            local dl_name="$2"
            local dl_pattern=""
            local dl_ckpt_every=""
            shift 2
            while [ $# -gt 0 ]; do
                case "$1" in
                    --ckpt-every)
                        [ -z "${2:-}" ] && error "--ckpt-every requires a number"
                        dl_ckpt_every="$2"
                        shift 2
                        ;;
                    *)
                        dl_pattern="$1"
                        shift
                        ;;
                esac
            done
            do_download_latest "$dl_name" "$dl_pattern" "$dl_ckpt_every"
            ;;
        --upload-all)
            [ -z "${2:-}" ] && error "Usage: --upload-all <type>"
            do_upload_all "$2"
            ;;
        --download-all)
            [ -z "${2:-}" ] && error "Usage: --download-all <type>"
            do_download_all "$2"
            ;;
        --list)
            do_list
            ;;
        --status)
            do_status
            ;;
        --help|-h)
            usage
            ;;
        setup)
            do_setup
            ;;
        *)
            echo "Unknown command: $cmd"
            usage
            exit 1
            ;;
    esac
}

main "$@"
