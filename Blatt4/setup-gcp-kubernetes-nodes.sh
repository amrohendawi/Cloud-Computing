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

# clean previously created instances and subnets etc in case of calling the script more than once
if [ $1 = "clean" ]; then
    echo "${COLOR}\t\t<<< cleaning up first >>>${DEFCOLOR}"
    echo -e 'y\n' | gcloud compute instances delete k-node1 --zone europe-west3-c
    echo -e 'y\n' | gcloud compute instances delete k-node2 --zone europe-west3-c
    echo -e 'y\n' | gcloud compute instances delete k-node3 --zone europe-west3-c
    echo -e 'y\n' | gcloud compute networks subnets delete cc-subnet --region europe-west3
    echo -e 'y\n' | gcloud compute firewall-rules delete cc2020-kubernetes-fw-rule
    echo "sleep 5 seconds...."
    sleep 5
fi

echo "${COLOR}\tSTEP 5: Create the three instances ${DEFCOLOR}"
echo "${COLOR}a: Create the node1 instance ${DEFCOLOR}"
gcloud compute instances create node1 --zone=europe-west3-c --image-project ubuntu-os-cloud --image-family ubuntu-1804-lts --boot-disk-size=100GB --machine-type=n2-standard-2 --tags=cc
echo "${COLOR}b: Create the node2 instance ${DEFCOLOR}"
gcloud compute instances create node2   --zone=europe-west3-c --image-project ubuntu-os-cloud --image-family ubuntu-1804-lts --boot-disk-size=100GB --machine-type=n2-standard-2 --tags=cc
echo "${COLOR}b: Create the node3 instance ${DEFCOLOR}"
gcloud compute instances create node3   --zone=europe-west3-c --image-project ubuntu-os-cloud --image-family ubuntu-1804-lts --boot-disk-size=100GB --machine-type=n2-standard-2 --tags=cc
echo "${COLOR}\tSTEP 6: Create the firewall rules ${DEFCOLOR}"
gcloud compute firewall-rules create cc2020-kubernetes-fw-rule --network default --action=ALLOW --rules=tcp,udp,icmp --source-ranges=0.0.0.0/0 --target-tags cc

# # TODO: dont forget to remove the line below before submission
# gcloud compute firewall-rules create cc2020-kubernetes-fw-rule-ssh --network cc-network1 --allow tcp,udp,icmp
