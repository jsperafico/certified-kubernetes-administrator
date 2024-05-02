# Cluster Architecture, Installation and Configuration

Let's start by serving the `shell script` files in any webserver. Open any powershell terminal and type the following.
Please keep in mind that python is a personal preference of mine, you don't need to use specifically this one.

```powershell
# Make sure your are in the same folder as this file.
Write-Host "curl http://$(hostname):8000/"
python -m http.server --directory .\
```

If not already, download an ISO for your preferable Linux Operating System. You can also use any regular powershell terminal. The default is ubuntu server 22.04 LTS.

```powershell
PS > mkdir C:\vms
PS > .\iso-downloader.ps1 -Path "C:\vms" -FileName "ubuntu-server"
```

The following steps require Powershel Terminal in administrator mode.

```powershell
PS > cd $WorkDirectory # same as this file
PS > .\vm-creation.ps1 -Path "C:\vms" -Name "k8smain" -IsoName "ubuntu-server.iso" -Size "s"
PS > .\vm-creation.ps1 -Path "C:\vms" -Name "k8snode" -IsoName "ubuntu-server.iso" -Size "xs"
```

Once you first start the VM, the instalation will be required, then follow:

```txt
1) Try and Install Ubuntu Server
2) Select language: English
2.1) Confirm 
3) Choose Instalation: Ubuntu Server (Minimized)
4) Network configuration: Default
5) Proxy: none
6) Package Mirror: default
7) Disk: default
8) Partition: default
9) Machine and User
9.1) Name: kubernetes
9.2) Your Server Name: k8smain #or k8snode
9.3) Username: k8s
9.4) Password: k8s
9.5) Confirm password: k8s
9.6) Confirm
10) No ubuntu Pro
11) Enable OpenSSH
12) No Default Snap
```

Login in the machine to double check the installation and then perform:

```sh
ip -c a
```

Copy your Ip Address, you will use to ssh later on.

## Back to Kubernetes!

Choose your container deamon runner, in our case we will use `containerd`. To this, make sure to run on each machine the script bellow.
Be smart and ssh from your machine to each k8s related vm. It simplifies the copy and paste. Yeap... it took me a while to realize that.

```powershell
ssh k8s@ip-address-of-vm
```

```sh
sudo su

# The `YOUR_MACHINE_NAME` can be seen by running the first powershell statement in this readme file.
curl http://YOUR_MACHINE_NAME:8000/containerd.sh > containerd.sh
curl http://YOUR_MACHINE_NAME:8000/kubernetes-main.sh > kubernetes.sh
# or
# curl http://YOUR_MACHINE_NAME:8000/kubernetes-node.sh > kubernetes.sh

chmod +x containerd.sh kubernetes.sh
./containerd.sh
./kubernetes.sh
```

A quick disclaimer here... `Kubeadm` is being used in [kubernetes-main.sh](./kubernetes-main.sh) and
[kubernetes-node.sh](./kubernetes-node.sh)  and it allows the user to quickly provision a secure Kubernetes cluster.

At this point, copy the `kubeadm join` statement in your `k8smain` VM and paste it at your `k8snode` VM.
It should appear something like this: 

```sh
kubeadm join [MAIN-IP]:6443 --token [AUTO-GENERATED] --discovery-token-ca-cert-hash sha256:[AUTO_GENERATED]
```

Now, you cluster should have 2 nodes sucessfully. At `k8smain` you can acquire the content to config your local machine:

```sh
cat /etc/kubernetes/admin.conf
```

Just copy the content to your `C:\Users\YOUR_USER\.kube\config` file. If file and folder doesn't exists, make sure to create.
You always have the possibility to create a service account for it as seen in [README](../3_security/README.md) on section 3.

## Kafka in this config

Aiming to validate this configuration, let's spin up a Kafka cluster:

```powershell
cd .\5_cluster_architecture_installation_config\kafka\
kubectl create ns kafka
kubectl apply -f .\0-storage.kafka.yaml
helm install kafka bitnami/kafka --version 28.1.1 --namespace kafka -f kafka.values.yaml

$secret = kubectl get secret kafka-user-passwords --namespace kafka -o json | ConvertFrom-Json
$clientPasswordsBase64 = $secret.data.'client-passwords'
$clientPasswords = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($clientPasswordsBase64))
$clientPassword = $clientPasswords.Split(',')[0].Trim()
$clientPassword
"security.protocol=SASL_PLAINTEXT" | Out-File -FilePath client.properties
"sasl.mechanism=SCRAM-SHA-256" | Add-Content -Path client.properties
"sasl.jaas.config=org.apache.kafka.common.security.scram.ScramLoginModule required username=`"user1`" password=`"$clientPassword`"; " | Add-Content -Path client.properties

kubectl run kafka-client --restart='Never' --image docker.io/bitnami/kafka:3.7.0-debian-12-r3 --namespace kafka --command -- sleep infinity       
kubectl cp --namespace kafka /path/to/client.properties kafka-client:/tmp/client.properties
kubectl exec --tty -i kafka-client --namespace kafka -- bash
```
Once inside `kafka-client` let's try to product any message:

```sh
kafka-console-producer.sh \
    --producer.config /tmp/client.properties \
    --broker-list kafka-controller-0.kafka-controller-headless.kafka.svc.cluster.local:9092 \
    --topic test
```

To delete what it was created, please do the following:

```powershell
kubectl delete pod kafka-client -n kafka
helm uninstall kafka --namespace kafka
kubectl delete -f .\0-storage.kafka.yaml
kubectl delete ns kafka
```


## Upgrading your Kubernetes Cluster

The process it's quite well described on [kubeadm-upgrade](https://kubernetes.io/docs/tasks/administer-cluster/kubeadm/kubeadm-upgrade/).
Nonetheless, let's have a quick cheat sheet:

```sh
sudo su
apt-cache madison kubeadm
apt-mark unhold kubeadm kubelet kubectl && \
apt update && apt install -y kubeadm='1.30.x-*' kubelet='1.30.x-*' kubectl='1.30.x-*' && \
apt-mark hold kubeadm kubelet kubectl
kubeadm version
kubeadm upgrade plan
kubeadm upgrade apply v1.30.x
systemctl daemon-reload
systemctl restart kubelet
```

## Designing from Scratch

## Deleting your VMs

# And now?

|[Previous](../4_storage/README.md)|[Next](../6_troubleshooting/README.md)|