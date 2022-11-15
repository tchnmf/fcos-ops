#!/bin/bash

vm="$1"
echo $vm

function remove_vm() {
    echo $vm
    virsh destroy $vm
    vm_disk=$(virsh domblklist $vm | grep vda |  awk '{ print $2 }')
    rm -f $vm_disk
    virsh undefine $vm
}


remove_vm
