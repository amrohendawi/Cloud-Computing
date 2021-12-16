#!/bin/sh

# initial variables
USER_NAME='cc_2020'
METADATA_FILE='metadata_file.txt'
TAG='cloud-computing'
INSTANCE_NAME='cc-instance'
ZONE='europe-west3-c'

######## color variables for the echo command
COLOR='\033[0;32m'
DEFCOLOR='\033[0m'
###################

# Creating ssh keys pair using specified USER_NAME
echo "${COLOR}STEP 1: create ssh-key${DEFCOLOR}"
echo -e 'y\n' | ssh-keygen -f id_rsa -C $USER_NAME

# pub key is formatted as gcloud requires and saved in a metadata file
echo "${COLOR}\nSTEP 2: transform ssh.pub to gcloud key${DEFCOLOR}"
echo -n $USER_NAME":$(cat id_rsa.pub)" > $METADATA_FILE

# add metadata_file with public ssh key to project metadata
echo "${COLOR}STEP 3: uploading the public key into the project metadata${DEFCOLOR}"
gcloud compute project-info add-metadata --metadata-from-file ssh-keys=$METADATA_FILE

# create the firewall rule for ssh and icmp
echo "${COLOR}STEP 4: create the firewall rule for ssh${DEFCOLOR}"
gcloud compute firewall-rules create allow-ssh-icmp-rule --network default --action allow --direction ingress --rules tcp:22,icmp --source-ranges=0.0.0.0/0 --target-tags $TAG

# create instance
echo "${COLOR}STEP 5: creating instance${DEFCOLOR}"
gcloud compute instances create $INSTANCE_NAME --zone=$ZONE --machine-type e2-standard-2 --image-project ubuntu-os-cloud --image-family ubuntu-1804-lts --tags $TAG

# resize disk space of the created instance
echo "${COLOR}STEP 6: resizing disk space of the created instance${DEFCOLOR}"
echo 'y' | gcloud compute disks resize $INSTANCE_NAME --size=100G --zone=$ZONE

# TODO: copy run-bash.sh manually to the instance
# chmod 400 id_rsa
# scp run_bench.sh cc_2020@<your machine public DNS>:~/
# TODO: ssh into the created machine
# ssh -i id_rsa cc_2020@<your machine public DNS>
# or gcloud beta compute ssh --zone <ZONE> <INSTANCE_NAME>
# TODO: install dependencies manually after ssh-ing in the launched instance
# sudo apt update && sudo apt install -y sysbench cron
# TODO: run this one-liner to add job to crontab
# chmod +x run_bench.sh && crontab -l > file; echo "*/30 * * * * ~/run_bench.sh" >> file; crontab file; rm file