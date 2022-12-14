# nvidia-pve-hook

Make nvidia cards go to low power consumption mode when they are not passed-through to virtual machines.

This hook works with Proxmox Virtual Environment (Proxmox VE).

## Installation

Ensure that you don't blacklist nvidia drivers and don't bind nvidia cards to `vfio-pci` driver in `/etc/modprobe.d`.

### Install nvidia driver

Install nvidia DKMS driver and `nvidia-smi`.

```
$ apt install nvidia-kernel-dkms nvidia-smi
```

### Enable nvidia persistence mode on startup

```
$ crontab -e
```

and add the following line.

```
@reboot /usr/bin/nvidia-smi -pm 1
```

### Install the hook script

```
$ make install
```

> The installation script assumes you have a `local` storage under `/var/lib/vz`.

### Enable hook script for your VMs

For each VM with your nvidia card passed-through, run

```
$ qm set $VMID --hookscript local:snippets/nvidia-pm.sh
```

Replace `$VMID` with your VM ID.

## Verification

1. Start your VM with your nvidia card passed-through.
2. Check if the nvidia card works in the VM.
3. Shutdown the VM.
4. Run `nvidia-smi` in the host. Check if the perf level shown is at `P8`. It it isn't, try waiting for a few seconds before checking again.
5. Start the VM again.
6. Check if the nvidia card still works in the VM.
