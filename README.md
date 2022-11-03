
Pull FCOS image
```shell
coreos-installer download -s stable -p qemu -f qcow2.xz --decompress -C .
```


Generate ignition file
```shell
podman run --interactive --rm \
quay.io/coreos/butane:release \
--pretty --strict < fcos.bu > fcos.ign
```
