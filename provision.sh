#!/bin/bash

# IGN_CONFIG=''
# IMAGE=''
# VM_NAME=''
# VCPUS=''
# RAM_MB=''
# DISK_GB=''
# STREAM=''

sudo -E chcon --verbose --type svirt_home_t ${IGN_CONFIG}
sudo -E virt-install --connect="qemu:///system" --name="${VM_NAME}" \
    --vcpus="${VCPUS}" --memory="${RAM_MB}" \
    --os-variant="fedora-coreos-$STREAM" --import --graphics=none \
    --disk="size=${DISK_GB},backing_store=${IMAGE}" \
    --qemu-commandline="-fw_cfg name=opt/com.coreos/config,file=${IGN_CONFIG}"
