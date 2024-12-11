#!/bin/bash


sudo kubeadm init \
    --ignore-preflight-errors=all \
    --kubernetes-version='v1.28.15' \
    --image-repository='registry.k8s.io' \
    --service-cidr='10.96.0.0/12' \
    --pod-network-cidr='10.244.0.0/16' \
    --v=5


sudo kubeadm token create --print-join-comman |sed 's/^/sudo /' |tee -a join_k8s.sh
sudo chmod +x join_k8s.sh

mkdir -p $HOME/.kube
rm -rf $HOME/.kube/config
sudo cp /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config


# 去除污点
kubectl taint nodes $(hostname) node-role.kubernetes.io/control-plane:NoSchedule-