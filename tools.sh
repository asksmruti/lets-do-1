#!/bin/bash

set -x
user=$1 # app server login user - default ubuntu
host_ip=$2 # App server IP

chmod 600 /tmp/general-test.pem 

# Generate Private/Public key on Jenkins server which will be used for autossh into app server
ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa
cat ~/.ssh/id_rsa.pub | ssh -q -i /tmp/general-test.pem -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ${user}@${host_ip} 'cat >> .ssh/authorized_keys'

# Add deb repos for required software installation 
wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | sudo apt-key add -
sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
echo | sudo add-apt-repository "deb http://archive.ubuntu.com/ubuntu $(lsb_release -sc) main universe restricted multiverse"
sleep 10

# JDK installation to build project on Jenkins server
sudo apt-get clean -y && sudo apt-get -y update
sudo apt-get -y install openjdk-8-jdk

# Standalone jenkins  installation
sudo apt-get -y clean && sudo apt-get -y update
sudo apt-get -y install jenkins
sudo service jenkins start

# Git setup on jenkins to checkout petclinic repo
sudo apt-get clean -y
sudo apt-get -y update && sudo apt-get -y upgrade
sudo apt-get -y install git-core
git config --global user.name "testuser"
git config --global user.email "testuser@example.com"

# Install ansible
echo | sudo apt-add-repository ppa:ansible/ansible
sudo apt-get update -y
sudo apt-get install ansible -y

# Install maven from repo
cd /opt && sudo wget http://www-eu.apache.org/dist/maven/maven-3/3.3.9/binaries/apache-maven-3.3.9-bin.tar.gz
sudo tar -xvzf /opt/apache-maven-3.3.9-bin.tar.gz
sudo ln -s apache-maven-3.3.9 maven && cd -
 
# Create local artifact directory 
sudo mkdir -p /mnt/artefact
sudo chown -R jenkins:jenkins /mnt/

# Create Jenkins user home directory
sudo mkdir /home/jenkins
sudo mv /tmp/general-test.pem /home/jenkins/
sudo chown -R jenkins:jenkins /home/jenkins/

## Generate ansible inventory file
cd /tmp/ansible/
cat <<INVENTORY >hosts.ini
[app-servers]
$host_ip ansible_user=$user

[app-servers:vars]
ansible_python_interpreter=/usr/bin/python3
ansible_ssh_common_args='-o StrictHostKeyChecking=no'
ansible_ssh_private_key_file='/home/jenkins/general-test.pem'
INVENTORY
