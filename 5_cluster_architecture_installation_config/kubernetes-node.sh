swapoff -a
sed -i '/\bswap\b/d' /etc/fstab

apt update
apt install -y apt-transport-https ca-certificates gpg iputils-ping

curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /' | tee /etc/apt/sources.list.d/kubernetes.list

apt update
apt install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl

ipv4_address=$(ip a | grep 'inet ' | grep -w 'eth0' | awk '{print $2}')
gateway_address=$(ip route | grep default | awk '{print $3}')

cat <<EOF | sudo tee /etc/netplan/00-installer-config.yaml
network:
  version: 2
  ethernets:
    eth0:
      dhcp4: true
      addresses: [$ipv4_address]
      gateway4: $gateway_address
      nameservers:
        addresses: [8.8.8.8]
EOF

sudo netplan apply

sleep $((120 - $(date +%S) ))

systemctl enable kubelet

mkdir -p /data/volumes/pv1
chmod 777 /data/volumes/pv1
