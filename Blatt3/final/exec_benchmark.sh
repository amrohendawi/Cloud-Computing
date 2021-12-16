#!/bin/sh
######## color variables for the echo command
COLOR='\033[0;32m'
DEFCOLOR='\033[0m'
###################
LOOP_END=10  # adjust loop end for quick tests. set it to 10 before final benchmark collection

QEMU_SSH_IP=$(sudo virsh domifaddr instance-no-kvm | awk '/ipv4/{print $4}' | rev | cut -c 4- | rev)
if [ -z "$QEMU_SSH_IP" ]
then
    echo "${COLOR}\$QEMU_SSH_IP is empty! make sure instance-1 is on by running sudo virsh start instance-1${DEFCOLOR}"
    exit 1
fi

KVM_SSH_IP=$(sudo virsh domifaddr instance-1 | awk '/ipv4/{print $4}' | rev | cut -c 4- | rev)
if [ -z "$KVM_SSH_IP" ]
then
    echo "${COLOR}\$KVM_SSH_IP is empty! make sure instance-1 is on by running sudo virsh start instance-1${DEFCOLOR}"
    exit 1
fi

iperf3 -s -D        # start iperf3 server as a daemon

echo "${COLOR}PreSTEP 1: install dependencies${DEFCOLOR}"
sudo apt-get update && sudo apt-get -y install sysbench clang iperf3 bc make

echo "${COLOR}PreSTEP 2: create four csv files with header inside${DEFCOLOR}"
for VM_type in native docker kvm qemu
do
echo "time,cpu,mem,diskSeq,diskRand,fork,uplink" > ${VM_type}-results.csv 
done

############################################################################
echo "${COLOR}STEP 1: collect 10 time series from native machine${DEFCOLOR}"
for _ in $(seq 1 $LOOP_END);
do
    echo "loop $_"
    sh benchmark.sh >> native-results.csv
done
############################################################################
echo "${COLOR}STEP 2: collect 10 time series from docker container${DEFCOLOR}"
sudo docker build . -t docker_bench
for _ in $(seq 1 $LOOP_END);
do
    echo "loop $_"
    sudo docker run --rm -it docker_bench >> docker-results.csv
done
############################################################################
echo "${COLOR}STEP 3: collect 10 time series from KVM VM${DEFCOLOR}"
ssh -i id_rsa ubuntu@$KVM_SSH_IP "sudo apt-get update && sudo apt-get -y install sysbench clang iperf3 bc make"              # make sure the dependencies are installed
scp -i id_rsa forkbench.c benchmark.sh  ubuntu@$KVM_SSH_IP:~/
for _ in $(seq 1 $LOOP_END);
do
    echo "loop $_"
     ssh -i id_rsa ubuntu@$KVM_SSH_IP "sh benchmark.sh" >> kvm-results.csv
done
############################################################################
echo "${COLOR}STEP 4: collect 10 time series from qemu VM${DEFCOLOR}"
ssh -i id_rsa ubuntu@$QEMU_SSH_IP "sudo apt-get update && sudo apt-get -y install sysbench clang iperf3 bc make"              # make sure the dependencies are installed
scp -i id_rsa forkbench.c benchmark.sh  ubuntu@$QEMU_SSH_IP:~/
for _ in $(seq 1 $LOOP_END);
do
    echo "loop $_"
    ssh -i id_rsa ubuntu@$QEMU_SSH_IP "sh benchmark.sh" >> qemu-results.csv
done