IGN_CONFIG=/opt/fcos-ops/fcos-nogpg.ign
IMAGE=/opt/fcos/images/fedora-coreos-36.20221014.3.1-qemu.x86_64.qcow2
VM_NAME=node$1
VCPUS=2
RAM_MB=4096
DISK_GB=10
STREAM=stable

chcon --verbose --type svirt_home_t ${IGN_CONFIG}
virt-install --connect="qemu:///system" --name="${VM_NAME}" \
    --vcpus="${VCPUS}" --memory="${RAM_MB}" \
    --os-variant="fedora-coreos-$STREAM" --import --graphics=none \
    --disk="size=${DISK_GB},backing_store=${IMAGE}" \
    --qemu-commandline="-fw_cfg name=opt/com.coreos/config,file=${IGN_CONFIG}"
