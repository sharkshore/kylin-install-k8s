#!/bin/bash


# 该脚本运行前，必须提前做好互信



# -----------------安装containerd

containerd_dir=containerd/1.7.0
containerd_config=$containerd_dir/config

# install containerd
sudo tar Cxzvf /usr/local $containerd_dir/containerd-1.7.0-linux-amd64.tar.gz
cat $containerd_config/containerd.service | sudo tee /usr/lib/systemd/system/containerd.service 

sudo systemctl daemon-reload
sudo systemctl enable containerd


# install runc
sudo install -m 755 $containerd_dir/runc.amd64 /usr/local/sbin/runc



# install cni ，包含crictl
sudo mkdir -p /opt/cni/bin
sudo tar Cxzvf /opt/cni/bin $containerd_dir/cni-plugins-linux-amd64-v1.2.0.tgz

#配置 systemd cgroup 驱动
sudo mkdir -p /etc/containerd && sudo rm -rf /etc/containerd/config.toml
sudo cp $containerd_config/config.toml /etc/containerd/config.toml
sudo systemctl start containerd.service

# 配置 crictl
cat $containerd_config/crictl.yaml | sudo tee /etc/crictl.yaml

# -----------------加载k8s镜像

k8s_image_dir=image/k8s/1.28.15
# 加载k8s镜像
for tar_file in $k8s_image_dir/*.tar; do
   sudo ctr -n k8s.io images import $tar_file
done

# -----------------安装k8s


k8s_dir=k8s/1.28.15/rpm
sudo yum localinstall --disablerepo=* -y $k8s_dir/dependencies/*.rpm
sudo yum localinstall --disablerepo=* -y $k8s_dir/*.rpm

# 重加载k8s配置，并设置开机启动
sudo systemctl daemon-reload
sudo systemctl enable --now kubelet

