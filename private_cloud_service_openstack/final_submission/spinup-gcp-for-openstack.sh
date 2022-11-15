#!/bin/sh


# TODO: to create private ssh key do the following lines:
# ssh-keygen -t rsa -f <ssh key name> -C <username of ur current terminal>
# chmod 600 <ssh key name>
# echo -n <username of ur current terminal>:$(cat <ssh key name>.pub) > metadata.txt
# gcloud compute project-info add-metadata --metadata-from-file ssh-keys=metadata.txt

# TODO: to ssh into a VM do:
# ssh -i <ssh key name> <username of ur current terminal>@<external ip address of the VM>
# if you get publickey error then make sure the ssh key is in the folder and chmod 600 again

# initial variables
USER_NAME='cc_2020'

######## color variables for the echo command
COLOR='\033[0;32m'
DEFCOLOR='\033[0m'
###################

# ip source ranges
IPRANGE1='172.28.0.0/24'
IPRANGE1_2='10.1.0.0/16'
IPRANGE2='172.24.0.0/24'

# clean previously created instances and subnets etc in case of calling the script more than once
if [ $1 = "clean" ]; then
    echo "${COLOR}\t\t<<< cleaning up first >>>${DEFCOLOR}"
    echo -e 'y\n' | gcloud compute instances delete controller --zone europe-west3-c
    echo -e 'y\n' | gcloud compute instances delete compute1   --zone europe-west3-c
    echo -e 'y\n' | gcloud compute instances delete compute2   --zone europe-west3-c
    echo -e 'y\n' | gcloud compute networks subnets delete cc-subnet1 --region europe-west3
    echo -e 'y\n' | gcloud compute networks subnets delete cc-subnet2 --region europe-west3
    echo -e 'y\n' | gcloud compute firewall-rules delete cc2020-blatt2-fw-rule1
    echo -e 'y\n' | gcloud compute firewall-rules delete cc2020-blatt2-fw-rule2
    echo -e 'y\n' | gcloud compute firewall-rules delete cc2020-blatt2-fw-rule12
    echo -e 'y\n' | gcloud compute firewall-rules delete cc2020-blatt2-fw-rule22
    echo "sleep 5 seconds...."
    sleep 5
fi

echo "${COLOR}\tSTEP 1: create two VPC networks. ignore the error if any already exists ${DEFCOLOR}"
gcloud compute networks create cc-network1 --subnet-mode=custom
gcloud compute networks create cc-network2 --subnet-mode=custom

echo "${COLOR}\tSTEP 2: create respective subnet for each VPC network ${DEFCOLOR}"
gcloud compute networks subnets create cc-subnet1 --range ${IPRANGE1} --secondary-range range1=${IPRANGE1_2} --network=cc-network1 --region=europe-west3
gcloud compute networks subnets create cc-subnet2 --range ${IPRANGE2} --network=cc-network2 --region=europe-west3

echo "${COLOR}\tSTEP 3: create custom disk with ubuntu image ${DEFCOLOR}"
gcloud compute disks create cc2020-blatt2 --size=100GB --zone=europe-west3-c --image=ubuntu-1804-bionic-v20201116 --image-project=ubuntu-os-cloud

echo "${COLOR}\tSTEP 4: Create custom image from the created disk including nested virtualization license ${DEFCOLOR}"
gcloud compute images create cc2020-nested-vm-image --source-disk cc2020-blatt2 --source-disk-zone europe-west3-c --licenses "https://www.googleapis.com/compute/v1/projects/vm-options/global/licenses/enable-vmx"

echo "${COLOR}\tSTEP 5: Create the three instances ${DEFCOLOR}"
echo "${COLOR}a: Create the controller instance ${DEFCOLOR}"
gcloud compute instances create controller --zone=europe-west3-c --image=cc2020-nested-vm-image --boot-disk-size=100GB --machine-type=n2-standard-2 --tags=cc --network-interface "subnet=cc-subnet1,aliases=range1:/24" --network-interface "subnet=cc-subnet2"
echo "${COLOR}b: Create the compute1 instance ${DEFCOLOR}"
gcloud compute instances create compute1   --zone=europe-west3-c --image=cc2020-nested-vm-image --boot-disk-size=100GB --machine-type=n2-standard-2 --tags=cc --network-interface "subnet=cc-subnet1" --network-interface "subnet=cc-subnet2"
echo "${COLOR}b: Create the compute2 instance ${DEFCOLOR}"
gcloud compute instances create compute2   --zone=europe-west3-c --image=cc2020-nested-vm-image --boot-disk-size=100GB --machine-type=n2-standard-2 --tags=cc --network-interface "subnet=cc-subnet1" --network-interface "subnet=cc-subnet2"

echo "${COLOR}\tSTEP 6: Create the firewall rules ${DEFCOLOR}"
gcloud compute firewall-rules create cc2020-blatt2-fw-rule1 --network cc-network1 --action=ALLOW --rules=tcp,udp,icmp --source-ranges=${IPRANGE1},${IPRANGE1_2},${IPRANGE2} --target-tags cc
gcloud compute firewall-rules create cc2020-blatt2-fw-rule2 --network cc-network2 --action=ALLOW --rules=tcp,udp,icmp --source-ranges=${IPRANGE1},${IPRANGE1_2},${IPRANGE2} --target-tags cc

# # TODO: dont forget to remove the line below before submission
# gcloud compute firewall-rules create cc2020-blatt2-fw-rule-ssh --network cc-network1 --allow tcp,udp,icmp
