#!/bin/sh

######## color variables for the echo command
COLOR='\033[0;32m'
DEFCOLOR='\033[0m'
###################

# copy the controller external ip manually from gcp console 
CONTROLLER_IP=34.89.188.218
# directory of the sshkey used to ssh and scp into the gcp VMs
GC_SSH_KEY_DIR=sshkey

if [ $1 = "clean" ]; then
    echo "${COLOR}\t\t<<< cleaning up first >>>${DEFCOLOR}"
    openstack security group delete open-all
    rm -r openstack_sshkey*
    openstack keypair delete openstack_keypair
fi

echo "${COLOR}\tSTEP 1: create security group${DEFCOLOR}"
openstack security group create open-all
echo "${COLOR}\tSTEP 2: create security group rules${DEFCOLOR}"
openstack security group rule create open-all --ingress --protocol tcp --dst-port 1:65525
openstack security group rule create open-all --ingress --protocol icmp --dst-port 1:65525
openstack security group rule create open-all --ingress --protocol udp --dst-port 1:65525
openstack security group rule create open-all --egress --protocol tcp --dst-port 1:65525
openstack security group rule create open-all --egress --protocol icmp --dst-port 1:65525
openstack security group rule create open-all --egress --protocol udp --dst-port 1:65525


# TODO: turn ssh key into metadata.txt
echo "${COLOR}\tSTEP 3: create ssh key and export it to openstack${DEFCOLOR}"
echo 'y\n' | ssh-keygen -t rsa -f openstack_sshkey -C openstack_user -N ""
chmod 400 openstack_sshkey
openstack keypair create --public-key openstack_sshkey.pub openstack_keypair

echo "${COLOR}\tSTEP 4: copy ssh private key to the gc controller VM to home directory${DEFCOLOR}"
# scp -i <gc ssh key> <openstack ssh key file> username@external_ip_of_controller:/home
scp -i ${GC_SSH_KEY_DIR} openstack_sshkey $USER@${CONTROLLER_IP}:/home
ssh -i ${GC_SSH_KEY_DIR} $USER@${CONTROLLER_IP} "chmod 400 /home/openstack_sshkey"

echo "${COLOR}\tSTEP 5: create a new flavor before the new VM instance on openstack${DEFCOLOR}"
openstack flavor create --id 0 --vcpus 2 --ram 4096 --disk 40 m1.medium

echo "${COLOR}\tSTEP 6: launch a new VM instance on openstack${DEFCOLOR}"
# openstack server create --flavor <flavor size> --image <image name> --nic net-id=<just admin-net. already exists> --security-group <the sg we created> --key-name <the keypair we uploaded> <instance name>
openstack server create --flavor m1.medium --image ubuntu-16.04 --nic net-id=admin-net --security-group open-all --key-name openstack_keypair new_vm_instance