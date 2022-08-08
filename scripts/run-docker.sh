#!/usr/bin/env bash

# thanks stackoverflow
# https://unix.stackexchange.com/a/634849
# this function doesnt work in zsh for some reason
getdevice() {
    idV=${1%:*}
    idP=${1#*:}
    for path in `find /sys/devices/ -name idVendor | sed 's/idVendor$//'`; do
        if grep -q $idV $path/idVendor && grep -q $idP $path/idProduct; then
	    find $path -name 'device' | rev | cut -d / -f 2 | rev
        fi
    done
}

device=/dev/$(getdevice 10c4:ea60)
ip=$(ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1  -d'/')

exec podman --runtime $(which crun) run --network host --device $device -e ROS_IP=$ip -it --rm lidar $@
