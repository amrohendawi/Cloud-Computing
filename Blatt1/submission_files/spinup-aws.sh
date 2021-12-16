#!/bin/sh
# name for the generated public key pair
KEY='cc-keypair'
# image name for "Ubuntu Server 18.04"
IMG=ami-00ddb0e5626798373
#instance type <requires non-educate account>
VMTYPE=t2.large
# security group name
SG_NAME=cloud-computing-group
######## color variables for the echo command
COLOR='\033[0;32m'
DEFCOLOR='\033[0m'
###################

# making sure we have default vpc
echo "${COLOR}STEP 1: creating default VPC. outputs error when one already exists${DEFCOLOR}"
aws ec2 create-default-vpc
# alternative method to create keypair
# aws ec2 create-key-pair --key-name ${KEY} --query 'KeyMaterial' --output text > cc-keypair.pem
# create keypair. overwrite if a key exists
echo "${COLOR}STEP 2: creating keypair${DEFCOLOR}"
echo 'y\n' | ssh-keygen -t rsa -C ${KEY} -f ~/.ssh/id_rsa -N ""
# protects the private key
chmod 600 ~/.ssh/id_rsa
# import the saved key from above
aws ec2 import-key-pair --key-name ${KEY} --public-key-material fileb://~/.ssh/id_rsa.pub

# extract Default vpcId to create a new security group
echo "${COLOR}STEP 3: extracting Default vpc ID${DEFCOLOR}"
VPCID=$(aws ec2 describe-vpcs --output json | grep -oP 'VpcId\":\s*\"\K[a-z\-0-9.]*')

# create new Security Group with the default vpc-id
echo "${COLOR}STEP 4: creating new Security Group with the default vpc-id ${VPCID}${DEFCOLOR}"
SG_ID=$(aws ec2 create-security-group --group-name ${SG_NAME} --description "first security group" --vpc-id ${VPCID} --output json | grep -oP 'GroupId\":\s*\"\K[a-z\-0-9]*')
echo "sg group name ${SG_ID}"
# add tcp rule to security group
echo "${COLOR}STEP 5: adding tcp and ICMP rule to security group${DEFCOLOR}"
aws ec2 authorize-security-group-ingress --group-id ${SG_ID} --protocol tcp --port 22 --cidr 0.0.0.0/0
# add ICMP rule to security group
aws ec2 authorize-security-group-ingress --group-id ${SG_ID} --protocol icmp --port all --cidr 0.0.0.0/0

# get a valid subnet ID
echo "${COLOR}STEP 6: getting a valid subnet ID and availability zone${DEFCOLOR}"
SUBNET_ID=$(aws ec2 describe-subnets --output json | grep -oP 'SubnetId\":\s*\"\K[a-z\-0-9]*' | head -1)
AVZONE=$(aws ec2 describe-subnets --output json | grep -oP 'AvailabilityZone\":\s*\"\K[a-z\-0-9]*' | head -1)

# launch a new instance
echo "${COLOR}STEP 7: launching a new instance..${DEFCOLOR}"
INST_ID=$(aws ec2 run-instances --image-id ${IMG} --count 1 --instance-type ${VMTYPE} --key-name ${KEY} --security-group-ids ${SG_ID} --subnet-id ${SUBNET_ID} --output json | grep -oP 'InstanceId\":\s*\"\K[a-z\-0-9]*')
# resizing the new instance <requires non-educate account>
# echo "${COLOR}STEP 8: getting instance-id of the created instance${DEFCOLOR}"
# INST_ID= cat ${RES} | grep -oP 'InstanceId\":\s*\"\K[a-z\-0-9]*'

echo "${COLOR}STEP 8: getting vol-ID of the created instance using instance-id <${INST_ID}>${DEFCOLOR}"
VOLID=$(aws ec2 describe-instances --output json | grep -A 9999999 "${INST_ID}.*" | grep -oP 'VolumeId\":\s*\"\K[a-z\-0-9]*' | head -1)

echo "${COLOR}STEP 9: resizing volume using vol-ID <${VOLID}>${DEFCOLOR}"
NEWVOLID=$(aws ec2 create-volume --volume-type gp2 --size 100 --availability-zone ${AVZONE} --output json | grep -oP 'VolumeId\":\s*\"\K[a-z\-0-9]*')
echo "id of newly created vol <${NEWVOLID}>"

# this line doesnt work with educate account
# aws ec2 modify-volume --size 100 --volume-id ${VOLID}

# wait until the instance is running before attaching new volume of size 100GB
while ! aws ec2 describe-instance-status --instance-id ${INST_ID} | grep -q "running";
do
echo "waiting until instance <${INST_ID}> is running..";
done

aws ec2 attach-volume --volume-id ${NEWVOLID} --instance-id ${INST_ID} --device /dev/sdf
echo "resize-job complete";

# TODO: copy run-bash.sh manually to the instance
# chmod 400 cc-keypair.pem
# scp run_bench.sh ubuntu@<your machine public DNS>:/home/ubuntu
# TODO: ssh into the created machine
# ssh -i "cc-keypair.pem" ubuntu@<your machine public DNS>
# TODO: install dependencies manually after ssh-ing in the launched instance
# sudo apt update && sudo apt install -y sysbench cron
# TODO: run this one-liner to add job to crontab
# chmod +x run_bench.sh && crontab -l > file; echo "*/30 * * * * ~/run_bench.sh" >> file; crontab file; rm file