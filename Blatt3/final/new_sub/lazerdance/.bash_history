clear
watch cat native-results.csv 
lss
ls
sudo apt update
sudo apt upgrade
sudo apt install qemu-kvm libvirt-bin qemu-utils genisoimage virtinst
wget https://cloud-images.ubuntu.com/bionic/current/bionic-server-cloudimg-amd64.img
qemu-img info bionic-server-cloudimg-amd64.img
sudo mkdir /var/lib/libvirt/images/base
sudo mv bionic-server-cloudimg-amd64.img /var/lib/libvirt/images/base/ubuntu-18.04.qcow2
sudo mkdir /var/lib/libvirt/images/instance-1
sudo qemu-img create -f qcow2 -o backing_file=/var/lib/libvirt/images/base/ubuntu-18.04.qcow2 /var/lib/libvirt/images/instance-1/instance-1.qcow2 5G
sudo qemu-img info /var/lib/libvirt/images/instance-1/instance-1.qcow2
cat >meta-data <<EOF
local-hostname: instance-1
EOF

ssh-keygen -t rsa -f id_rsa
export PUB_KEY=$(cat id_rsa.pub)
cat >user-data <<EOF
#cloud-config
users:
  - name: ubuntu
    ssh-authorized-keys:
      - $PUB_KEY
    sudo: ['ALL=(ALL) NOPASSWD:ALL']
    groups: sudo
    shell: /bin/bash
runcmd:
  - echo "AllowUsers ubuntu" >> /etc/ssh/sshd_config
  - restart ssh
EOF

sudo genisoimage  -output /var/lib/libvirt/images/instance-1/instance-1-cidata.iso -volid cidata -joliet -rock user-data meta-data
sudo virt-install --connect qemu:///system --virt-type kvm --name instance-1 --ram 4096 --vcpus=2 --os-type linux --os-variant ubuntu18.04 --disk path=/var/lib/libvirt/images/instance-1/instance-1.qcow2,format=qcow2 --disk /var/lib/libvirt/images/instance-1/instance-1-cidata.iso,device=cdrom --import --network network=default --noautoconsole
sudo virsh list
sudo virsh domifaddr instance-1
chmod 600 id_rsa
sudo virsh domifaddr instance-1
ssh -i id_rsa ubuntu@192.168.122.30
sudo apt-get remove docker docker-engine docker.io containerd runc
sudo apt update && sudo apt-get install     apt-transport-https     ca-certificates     curl     gnupg-agent     software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository    "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
sudo apt update && sudo apt-get install docker-ce docker-ce-cli containerd.io
docker
ls
sh exec_benchmark.sh 
sh exec_benchmark.sh
iperf3 -s -f Mbits
iperf3 --client localhost --parallel 5 --version4 --format m --time 5
ls
iperf3 --client localhost --parallel 5 --version4 --format MBits --time 5
ssh -i id_rsa ubuntu@192.168.122.30
sh exec_benchmark.sh
ls
cat qemu-results.csv 
cat kvm-results.csv 
cat docker-results.csv 
sh exec_benchmark.sh
cat docker-results.csv 
docker run -it docker_bench
sudo docker run -it docker_bench
sudo docker run -it docker_bench .
sudo docker run docker_bench
docker exec -it docker_bench
docker exec -it docker_bench /bin/bash
sudo docker exec -it docker_bench /bin/bash
sudo docker exec -it docker_bench
docker ps -a
sudo docker ps -a
docker container prune -a
docker container prune
sudo docker container prune
sudo docker ps -a
sudo docker build . -t docker_bench
sudo docker run --rm -it docker_bench
docker ps -a
sudo docker ps -a
sudo docker exec --rm -it docker_bench .
sudo docker exec -it docker_bench .
sudo docker run --rm -it docker_bench .
sudo docker run --rm -it docker_bench bash
sudo docker run --rm -it docker_bench sh
nano Dockerfile 
sudo docker build . -t docker_bench
sudo docker run --rm -it docker_bench
cat Dockerfile 
nano Dockerfile 
sudo docker build . -t docker_bench
sudo docker run --rm -it docker_bench
ls
nano Dockerfile 
sudo docker build . -t docker_bench
sudo docker run --rm -it docker_bench
ls
ifconfig
iperf3 -s
ls
sudo docker run --rm -it docker_bench
ls
sh exec_benchmark.sh 
cat docker-results.csv 
echo $localhost
echo $LOCALHOST
localhost
ls
echo "$localhost"
cat kvm-results.csv 
ls
docker ps -a
sudo docker ps -a
ls
rm kvm-results.csv qemu-results.csv docker-results.csv native-results.csv a.out 
ls
sh exec_benchmark.sh 
cat docker-results.csv 
cat qemu-results.csv 
cat kvm-results.csv 

ls
ssh -i id_rsa ubuntu@$KVM_SSH_IP
KVM_SSH_IP=$(sudo virsh net-dhcp-leases default | awk '/ipv4/{print $5}' | rev | cut -c 4- | rev)
ssh -i id_rsa ubuntu@$KVM_SSH_IP
KVM_SSH_IP=$(sudo virsh net-dhcp-leases default | awk '/ipv4/{print $5}' | rev | cut -c 4- | rev)
ps -ef | grep qemu
ls
clear
ps -ef | grep qemu
qemu-image
sudo qemu-image
qemu-img
qemu-img --help
sudo virsh shutdown instance-name
sudo virsh shutdown instance-1
ls
sudo virsh list
sudo virt-install --connect qemu:///system --virt-type qemu --name instance-1 --ram 4096 --vcpus=2 --os-type linux --os-variant ubuntu18.04 --disk path=/var/lib/libvirt/images/instance-1/instance-1.qcow2,format=qcow2 --disk /var/lib/libvirt/images/instance-1/instance-1-cidata.iso,device=cdrom --import --network network=default --noautoconsole
sudo virsh list
sudo virt-install --connect qemu:///system --virt-type qemu --name instance-no-kvm --ram 4096 --vcpus=2 --os-type linux --os-variant ubuntu18.04 --disk path=/var/lib/libvirt/images/instance-1/instance-1.qcow2,format=qcow2 --disk /var/lib/libvirt/images/instance-1/instance-1-cidata.iso,device=cdrom --import --network network=default --noautoconsole
sudo virsh list
ls sudo mkdir /var/lib/libvirt/images/instance-1
sudo qemu-img create -f qcow2 -o backing_file=/var/lib/libvirt/images/base/ubuntu-18.04.qcow2 /var/lib/libvirt/images/instance-1/instance-no-kvm.qcow2 5G
ls /var/lib/libvirt/images/instance-1/
sudo genisoimage  -output /var/lib/libvirt/images/instance-1/instance-1-cidata.iso -volid cidata -joliet -rock user-data meta-data
clear
sudo virt-install --connect qemu:///system --virt-type qemu --name instance-no-kvm --ram 4096 --vcpus=2 --os-type linux --os-variant ubuntu18.04 --disk path=/var/lib/libvirt/images/instance-1/instance-no-kvm.qcow2,format=qcow2 --disk /var/lib/libvirt/images/instance-1/instance-1-cidata.iso,device=cdrom --import --network network=default --noautoconsole
sudo mkdir /var/lib/libvirt/images/instance-no-kvm
sudo qemu-img create -f qcow2 -o backing_file=/var/lib/libvirt/images/base/ubuntu-18.04.qcow2 /var/lib/libvirt/images/instance-1/instance-no-kvm.qcow2 5G
sudo qemu-img create -f qcow2 -o backing_file=/var/lib/libvirt/images/base/ubuntu-18.04.qcow2 /var/lib/libvirt/images/instance-no-kvm/instance-no-kvm.qcow2 5G
sudo qemu-img info /var/lib/libvirt/images/instance-no-kvm/instance-no-kvm.qcow2
sudo genisoimage  -output /var/lib/libvirt/images/instance-no-kvm/instance-no-kvm-cidata.iso -volid cidata -joliet -rock user-data meta-data
sudo virt-install --connect qemu:///system --virt-type qemu --name instance-no-kvm --ram 4096 --vcpus=2 --os-type linux --os-variant ubuntu18.04 --disk path=/var/lib/libvirt/images/instance-no-kvm/instance-no-kvm.qcow2,format=qcow2 --disk /var/lib/libvirt/images/instance-no-kvm/instance-no-kvm-cidata.iso,device=cdrom --import --network network=default --noautoconsole
sudo virsh list
sudo virsh start instance-1
sudo virsh list
clear
sudo virsh domifaddr instance-1
sudo virsh domifaddr instance-no-kvm
clear
watch sudo virsh domifaddr instance-no-kvm
ps -ef | grep qemu
ps -ef | grep qemu > t.txt
nano t.txt 
ps -ef | grep qemu > t.txt
ls
cat t.txt 
nano t.txt 
clear
ls
sh exec_benchmark.sh 
sudo virsh domifaddr instance-1
sudo virsh domifaddr instance-1 | awk '/ipv4/{print $5}'
sudo virsh domifaddr instance-1 | awk '/ipv4/{print $4}'
sh exec_benchmark.sh 
cat kvm-results.csv 
cat qemu-results.csv 
cat docker-results.csv 
cat native-results.csv 
nano exec_benchmark.sh 
sh exec_benchmark.sh 
sh exec_benchmark.sh
screen
exit
screen
screen -r
exit
clear
cat docker-results.csv 
nano benchmark.sh 
screen 
screen -r
exit
screen -r
exit
sh exec_benchmark.sh 
screen -r
ls
cat qemu-results.csv 
cat kvm-results.csv 
ls
mkdir bkp
cp . bkp/
cp -r . bkp/
ls
ls bkp/
cd bkp/
ls
clear
cd ..
exit
screen -r
exit
cat docker-results.csv 
cat native-results.csv 
cat benchmark.sh 
htop
exit
ls
clear
ls
make forkbench
nano exec_benchmark.sh 
nano Dockerfile 
ls
rm native-results.csv qemu-results.csv kvm-results.csv docker-results.csv a.out 
nano exec_benchmark.sh 
nano forkbench.c 
nano benchmark.sh 
sh benchmark.sh 
nano benchmark.sh 
nano exec_benchmark.sh 
sh benchmark.sh
nano benchmark.sh 
nano Dockerfile 
sh benchmark.sh
make forkbench
sh exec_benchmark.sh 
nano exec_benchmark.sh 
history | grep virsh
sudo virsh start instance-1
sudo virsh start instance-no-kvm
sudo virsh list
sudo virsh domifaddr instance-1
sudo virsh domifaddr instance-no-kvm
sudo virsh list
sudo virsh domifaddr instance-no-kvm
sh exec_benchmark.sh 
cat native-results.csv 
make
make forkbench
nano benchmark.sh 
make -Wno-everything forkbench
make -Wno-error=format-truncation forkbench
make CFLAGS="-Wno-everything" forkbench
make CFLAGS="-Wno-error=format-truncation"
make CFLAGS="-Wno-error=format-truncation" forkbench
make CFLAGS="-Wno-error=format-truncation" forkbench.c
l
make forkbench
ls
rm forkbench
make forkbench
rm forkbench
make CFLAGS="-Wno-everything" forkbench
ls
rm forkbench
make -Wno-everything forkbench
rm forkbench
nano benchmark.sh 
sh benchmark.sh 
ls
nano benchmark.sh 
sh benchmark.sh 
nano benchmark.sh 
sh benchmark.sh 
nano benchmark.sh 
iperf3 -c $HOST_IP --parallel 5 --version4 -f m --time $TIME | tail -n 3 | awk '/\[SUM\]/{print $6}'
iperf3 -c 35.246.180.255 --parallel 5 --version4 -f m --time 3 | tail -n 3 | awk '/\[SUM\]/{print $6}'
iperf3 -c 35.246.180.255 --parallel 5 --version4 -f m --time 3
iperf3-
iperf3
iperf3 -s
iperf3 -c 35.246.180.255 --parallel 5 --version4 -f m --time 3
ls
nano benchmark.sh 
nano docker-results.csv 
nano Dockerfile 
nano exec_benchmark.sh 
sh exec_benchmark.sh 
nano exec_benchmark.sh 
sh exec_benchmark.sh 
cat docker-results.csv 
cat kvm-results.csv 
cat qemu-results.csv 
cat native-results.csv 
nano benchmark.sh 
nano exec_benchmark.sh 
iperf3 -s -D
iperf3 -c $HOST_IP --parallel 5 --version4 -f m --time $TIME | tail -n 3 | awk '/\[SUM\]/{print $6}'
iperf3 -c 34.107.117.50 --parallel 5 --version4 -f m --time 3 | tail -n 3 | awk '/\[SUM\]/{print $6}'
iperf3 -c 34.107.117.50 --parallel 5 --version4 -f m --time 3
iperf3 -c 34.107.117.50 --parallel 5 --version4 -f m
iperf3 -c localhost --parallel 5 --version4 -f m
iperf3 -c 34.107.117.50 --parallel 5 --version4 -f m --time 3 | tail -n 3 | awk '/\[SUM\]/{print $6}'
iperf3 -c 35.246.180.255 --parallel 5 --version4 -f m --time 3 | tail -n 3 | awk '/\[SUM\]/{print $6}'
exit
dig +short myip.opendns.com @resolver1.opendns.com
ssh -i id_rsa ubuntu@$QEMU_SSH_IP "dig +short myip.opendns.com @resolver1.opendns.com"
QEMU_SSH_IP=$(sudo virsh domifaddr instance-no-kvm | awk '/ipv4/{print $4}' | rev | cut -c 4- | rev)
history | grep virsh
sudo virsh start instance-1
sudo virsh start instance-no-kvm
sudo virsh domifaddr instance-no-kvm
sudo virsh domifaddr instance-1
QEMU_SSH_IP=$(sudo virsh domifaddr instance-no-kvm | awk '/ipv4/{print $4}' | rev | cut -c 4- | rev)
echo $QEMU_SSH_IP
ssh -i id_rsa ubuntu@$QEMU_SSH_IP "dig +short myip.opendns.com @resolver1.opendns.com"
ls
ssh -i id_rsa ubuntu@$QEMU_SSH_IP "dig +short myip.opendns.com @resolver1.opendns.com"
nano benchmark.sh
nano exec_benchmark.sh 
sh exec_benchmark.sh 
iperf3 -c $HOST_IP --parallel 5 --version4 -f m --time 2 | tail -n 3 | awk '/\[SUM\]/{print $6}'
HOST_IP=$(dig +short myip.opendns.com @resolver1.opendns.com)
iperf3 -c $HOST_IP --parallel 5 --version4 -f m --time 2 | tail -n 3 | awk '/\[SUM\]/{print $6}'
echo $HOST_IP
iperf3 -c $HOST_IP --parallel 5 --version4 -f m --time 2
iperf3 -s -D
iperf3 -c $HOST_IP --parallel 5 --version4 -f m --time 2
iperf3 -c $HOST_IP --parallel 5 --version4 -f m --time 2 | tail -n 3 | awk '/\[SUM\]/{print $6}'
clear
sh exec_benchmark.sh 
nano exec_benchmark.sh 
sh exec_benchmark.sh 
cat docker-results.csv 
cat kvm-results.csv 
cat qemu-results.csv 
cat native-results.csv 
nano benchmark.sh
history | grep docker
sudo docker run --rm -it docker_bench
nano Dockerfile 
sudo docker build . -t docker_bench
sudo docker run --rm -it docker_bench
ls
nano benchmark.sh
nano exec_benchmark.sh 
rm native-results.csv qemu-results.csv kvm-results.csv docker-results.csv forkbench t.txt 
ls
rm -r bkp/
ls
nano benchmark.sh.save 
rm benchmark.sh.save 
ls
exit
