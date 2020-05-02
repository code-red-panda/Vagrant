#!/bin/bash

PROJECT=$1
IP=$2
VM_COUNT=$3
USER=ansible

if test -z $PROJECT
then
    echo "Not enough arguments provided."
    exit 1
elif test -z $IP
then
    echo "Not enough arguments provided."
    exit 1
elif test -z $VM_COUNT
then
    echo "Not enough arguments provided."
    exit 1
fi

mkdir -p $PROJECT

#########################
### Generate vagrantfile
#########################

echo 'Vagrant.configure("2") do |config|

  config.vm.provider "virtualbox" do |vb|

    # Hardware
    vb.memory = 512
    vb.cpus = 1
    vb.linked_clone = true

  end

  # VMs
  (1..'$VM_COUNT').each do |i|
    config.vm.define "vm#{i}", primary: true do |node|

      # OS
      node.vm.box = "centos/7"
      node.vm.box_version = "1905.01"
      node.vm.box_check_update = false

      # Network
      node.vm.hostname = "'$PROJECT'#{i}"
      node.vm.network "private_network", ip: "192.168.2.'$IP'#{i}"
      node.hostmanager.enabled = true
      node.hostmanager.manage_guest = true
      node.hostmanager.ignore_private_ip = false

      # Provision
      node.vm.provision "shell", path: "ansible.sh", run: "always"

    end

  end

end' > $PROJECT/vagrantfile

#########################
### Generate ansible.sh
#########################

echo '#!/bin/bash

USER=ansible
SSH_DIR=/home/$USER/.ssh
PUB_KEY=/vagrant/${USER}_rsa.pub
PRIV_KEY=/vagrant/${USER}_rsa

if test ! $(id -u $USER)
  then
    useradd $USER
    mkdir -p $SSH_DIR
    cp $PUB_KEY $SSH_DIR/authorized_keys
    cp $PRIV_KEY $SSH_DIR/id_rsa
    chown $USER.$USER -R $SSH_DIR
    chmod 700 $SSH_DIR
    chmod 600 $SSH_DIR/*
    echo "$USER ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/$USER
fi' > $PROJECT/$USER.sh

#########################
### Generate SSH keys
#########################

ssh-keygen -t rsa -C "$USER" -f "./$PROJECT/${USER}_rsa" -P ""
