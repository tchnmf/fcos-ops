
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

Install packages
```
$ sudo rpm-ostree install kubelet kubeadm kubectl cri-o     # control plane
$ sudo rpm-ostree install kubelet kubeadm cri-o             # compute

```


Create cluster from `clusterconfig.yml`
```
kubeadm init ––config clusterconfig.yml
```


Configure kubectl on the control plane
```
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

Pod networking with kube-router
```
kubectl apply -f \
https://raw.githubusercontent.com/cloudnativelabs/kube-router/master/daemonset/kubeadm-kuberouter.yaml
```

Join token and instructions
```
kubeadm token create –-print-join-command
```

Test deployment
```
kubectl create deployment test --image nginx --replicas 3
```

Create service
```shell
$ kubectl create -f testsvc.yml
$ kubectl describe svc testsvc
Name:                     testsvc
Namespace:                default
Labels:                   <none>
Annotations:              <none>
Selector:                 app=test
Type:                     NodePort
IP Family Policy:         SingleStack
IP Families:              IPv4
IP:                       10.109.35.123
IPs:                      10.109.35.123
Port:                     <unset>  80/TCP
TargetPort:               80/TCP
NodePort:                 <unset>  30001/TCP
Endpoints:                10.244.1.2:80,10.244.2.2:80,10.244.2.3:80
Session Affinity:         None
External Traffic Policy:  Cluster
Events:                   <none>
```

Check
```
telnet node3 30001
Trying 192.168.122.40...
Connected to node3.
Escape character is '^]'.
GET / HTTP/1.0

HTTP/1.1 200 OK
Server: nginx/1.23.2
Date: Thu, 03 Nov 2022 19:41:42 GMT
Content-Type: text/html
Content-Length: 615
Last-Modified: Wed, 19 Oct 2022 07:56:21 GMT
Connection: close
ETag: "634fada5-267"
Accept-Ranges: bytes
```
