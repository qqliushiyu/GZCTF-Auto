#!/bin/sh

hostname NAME

source_add="https://docker.huhstsec.top"

login=0

login_docker(){
    while true; do
        username="USER_OP"
        password="PASSWORD_OP"
        address="ADDRESS_OP"
        out=$(echo $password | sudo docker login --username=$username $address 2>&1)
        if echo "$login_command_output" | grep -q "Login Succeeded"; then
            echo "登录成功!"
            break
        else
            echo "登录失败，用户名或密码错误！"
        fi
    done
}

if [ -f /etc/os-release ]; then
. /etc/os-release
VERSION_ID=$(echo "$VERSION_ID" | tr -d '"')
IFS='.' read -r major minor <<< "$VERSION_ID"
if [ "$major" -lt 24 ] || { [ "$major" -eq 24 ] && [ "$minor" -lt 4 ]; }; then
    sudo sed -i 's@//.*archive.ubuntu.com@//mirrors.ustc.edu.cn@g' /etc/apt/sources.list
    echo "换源成功！"
else
    sudo sed -i 's@//.*archive.ubuntu.com@//mirrors.ustc.edu.cn@g' /etc/apt/sources.list.d/ubuntu.sources
    echo "换源成功！"
fi
else
    echo "/etc/os-release 文件不存在，无法确定系统版本信息。"
    echo "换源失败，请手动换源！"
fi

sudo apt-get update
sudo apt-get upgrade -y --no-install-recommends
sudo apt-get -y --no-install-recommends install apt-transport-https ca-certificates curl software-properties-common dig
curl -fsSL http://mirrors.aliyun.com/docker-ce/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] http://mirrors.aliyun.com/docker-ce/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get -y update
sudo apt-get -y --no-install-recommends install docker-ce

wget -O daemon.json https://cdn.moran233.xyz/https://raw.githubusercontent.com/MoRan23/GZCTF-Auto/main/config-auto/docker/daemon.json
sed -i "s|\[\"[^\"]*\"\]|\[\"$source_add\"\]|g" daemon.json
mv daemon.json /etc/docker/
sudo systemctl daemon-reload && sudo systemctl restart docker

if [ "$login" -eq 1 ]; then
  echo "变量 hostNum 的值为 0"
else
  echo "跳过登录..."
fi

curl -sfL https://rancher-mirror.rancher.cn/k3s/k3s-install.sh | INSTALL_K3S_EXEC="--kube-controller-manager-arg=node-cidr-mask-size=16" INSTALL_K3S_EXEC="--docker" INSTALL_K3S_MIRROR=cn K3S_URL=https://SERVER:6443 K3S_TOKEN=mynodetoken sh -
wget -O kubelet.config https://cdn.moran233.xyz/https://raw.githubusercontent.com/MoRan23/GZCTF-Auto/main/config-auto/k3s/kubelet.config
mv kubelet.config /etc/rancher/k3s/
wget -O config-auto/k3s/registries.yaml https://cdn.moran233.xyz/https://raw.githubusercontent.com/MoRan23/GZCTF-Auto/main/config-auto/k3s/registries.yaml
sed -i "s|https://docker.huhstsec.top|$source_add|g" registries.yaml
mv registries.yaml /etc/rancher/k3s/
sudo systemctl daemon-reload && sudo systemctl restart k3s

echo "部署成功！"