# Linux Hard Lessons

Lessons from real incidents. Follow them before suggesting or running the related operation.

## Kernel upgrades can drop Wi-Fi

Installing a package can pull in a new kernel as a side effect. For example, `linux-modules-nvidia-580-generic-hwe-22.04` on Ubuntu 22.04 brought kernel `6.8.0-138-generic` and made it the GRUB default. The new kernel had no `linux-modules-extra-6.8.0-138-generic`, which ships the Intel `iwlwifi` driver, so the machine rebooted with no Wi-Fi. It became unreachable remotely and needed someone at the console to boot the old kernel.

Before any reboot that will boot a new kernel (whether the user asked for a kernel upgrade or another install pulled one in):

1. Check whether the machine uses Wi-Fi, especially as its only or remote-access network:

   ```bash
   nmcli -t -f DEVICE,TYPE,STATE device
   lspci -nnk | grep -iA3 "network\|wireless"   # "Kernel driver in use:" names the driver
   lsusb                                         # USB Wi-Fi adapters
   ```

2. If it does, confirm the Wi-Fi driver exists for the new kernel:
   - In-tree driver (`iwlwifi`, `mt7921e`, `rtw89`, ...): the new kernel's `linux-modules-extra-<version>` must be installed, and `modinfo -k <version> <driver>` must succeed.
   - DKMS driver: `dkms status` must list it as installed for the new kernel; otherwise run `sudo dkms autoinstall -k <version>`.
   - Prefer the matching kernel metapackage (for example `linux-generic-hwe-22.04`) so later kernel updates bring `linux-modules-extra` too.

3. Install the missing driver package for the new kernel, or ask the user to, with approval like any other `sudo` install. A wrong package can strand a headless host, so do not tell them to reboot until it is in place.

4. Before the reboot, give the recovery path: hold Shift or tap Esc at boot, then choose **Advanced options** and the previous kernel, which still has a working Wi-Fi driver. A wired Ethernet port or USB phone tethering also works as a fallback network.
