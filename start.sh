#!/bin/bash


controller_ip="172.20.63.100"
follower_ip_list="172.20.63.101,172.20.63.102"

dir=$(basename $(dirname $(realpath $0)))




# 函数定义

# SSH命令分发
# 参数：完整命令行
ssh_cmd(){
    for host in ${follower_ip_list//,/ };do
        echo "-----${host}:"
        ssh "$host" "$@"
    done
}

# SSH脚本分发
# 第1个参数：要执行的脚本名
ssh_script(){
    local script=$1
    for host in ${follower_ip_list//,/ };do
        echo "-----${host}:"
        scp "$script" "$host":~
        ssh "$host" bash ~/"$script"
        ssh "$host" rm -rf ~/"$script"
    done
}


# 文件传输分发
# 第1个参数：本地文件
# 第2个参数：远程目录
scp_file(){
    local lfile=$1
    for host in ${follower_ip_list//,/ };do
        echo "-----${host}:"
        scp "$lfile" "$host":~
    done
}

_file(){
    local lfile=$1
    for host in ${follower_ip_list//,/ };do
        echo "-----${host}:"
        scp "$lfile" "$host":~
    done
}



# -----------------0，检查

parent_dir=$(dirname $(realpath $0))
# -----------------1，分发所有安装包
for host in ${follower_ip_list//,/ };do
    rsync -av $parent_dir/ $host:$parent_dir
done


# -----------------2，所有节点安装docker和k8s，并加载镜像
ssh_cmd "cd ~/$dir && bash install_package.sh"

# -----------------3，主节点初始化k8s集群
bash init_k8s.sh
# -----------------4，从节点加入k8s集群
ssh_script join_k8s.sh




