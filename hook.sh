#!/bin/bash

VMID="$1"
ACTION="$2"

if [ "$ACTION" = "pre-start" ]; then
    echo "I: Stopping nvidia-persistenced"
    systemctl stop nvidia-persistenced 2>/dev/null
elif [ "$ACTION" = "post-stop" ]; then
    bus_ids=$(qm config "$VMID" --current 1 | awk '/^hostpci/{ split($2, a, ","); print a[1] (a[1] ~ /\.[0-9]$/ ? "" : ".0") }')
    for bus_id in $bus_ids; do
        echo "I: Checking $bus_id"
        # check whether the device is a NVIDIA graphics card or not
        if [ "$(< /sys/bus/pci/devices/$bus_id/vendor)" = "0x10de" -a "$(< /sys/bus/pci/devices/$bus_id/class)" = "0x030000" ]; then
            # unbind from the VFIO driver
            echo "D: Unbinding from old driver"
            echo "$bus_id" > /sys/bus/pci/drivers/vfio-pci/unbind

            # bind to nvidia driver
            echo "D: Binding to NVIDIA driver"
            echo "$bus_id" > /sys/bus/pci/drivers/nvidia/bind

            for i in {0..5}; do
                echo "D: Trying to enable persistence mode"
                # enable persistence mode
                nvidia-smi -i "$bus_id" -pm 1

                if [ "$?" -eq 0 ]; then
                    echo "D: Persistence mode enabled"
                    break
                fi
                sleep 1
            done
        else
            echo "I: $bus_id is not a NVIDIA graphics card, ignoring"
        fi
    done
fi

exit 0
