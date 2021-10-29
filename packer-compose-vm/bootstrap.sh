#!/bin/bash
set -e

export HOME=/root

IP=$(ip addr show ens4 | grep "inet\b" | awk '{print $2}' | cut -d/ -f1)
echo $IP > /etc/oldip

ln -sf /run/systemd/resolve/resolv.conf /etc/resolv.conf

export DEBIAN_FRONTEND=noninteractive

echo "waiting 180 seconds for cloud-init to update /etc/apt/sources.list"
timeout 180 /bin/bash -c \
  'until stat /var/lib/cloud/instance/boot-finished 2>/dev/null; do echo waiting ...; sleep 1; done'

apt-get update
apt-get -y install \
    git curl wget \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common \
    conntrack \
    jq vim nano emacs joe \
    inotify-tools \
    socat make golang-go \
    docker.io \
    bash-completion

apt-get -y remove sshguard

cp -a /tmp/bootstrap/*.service /lib/systemd/system/

curl -o /usr/local/bin/docker-compose -L https://github.com/docker/compose/releases/download/1.27.4/docker-compose-Linux-x86_64
chmod +x /usr/local/bin/docker-compose

systemctl daemon-reload
systemctl enable docker
systemctl start docker

mkdir -p /opt/docker-compose
cp -a /tmp/bootstrap/compose/* /opt/docker-compose

# Scan the /opt/docker-compose directory and replace the service name
# with the directory name and prepull all images
for i in $(find /opt/docker-compose -mindepth 1 -maxdepth 1 -type d); do
  pushd "$i"
  docker-compose pull
  popd

  svc=$(basename "$i")
  systemctl enable docker-compose@$svc
done
