#!/bin/bash

PROJECT=$1
OS=$2
IP=$3
VM_COUNT=$4
USER=ansible

if test -z ${PROJECT}
then
    echo "Not enough arguments provided."
    exit 1
elif test -z ${OS}
then
    echo "Not enough arguments provided."
    exit 1
elif test -z ${IP}
then
    echo "Not enough arguments provided."
    exit 1
elif test -z ${VM_COUNT}
then
    echo "Not enough arguments provided."
    exit 1
fi

case $OS in
  centos6)
      BOX="centos/6"
      VERSION="2004.01" ;;
  centos7)
      BOX="centos/7"
      VERSION="2004.01" ;;
  ubuntu1804)
      BOX="ubuntu/bionic64"
      VERSION="20190514.0.0" ;;
  ubuntu2004)
      BOX="ubuntu/focal64"
      VERSION="20190514.0.0" ;;
  *)
      echo "$OS is not supported. Please choose from: centos6, centos7, ubuntu1804, ubuntu2004"
      exit 1 ;;
esac

mkdir -p ${PROJECT}

#########################
### Generate vagrantfile
#########################

case $VM_COUNT in
  1)
cat << EOF >> ${PROJECT}/vagrantfile
Vagrant.configure("2") do |config|

  config.vm.provider "virtualbox" do |vb|

    # Hardware
    vb.memory = 512
    vb.cpus = 1
    vb.linked_clone = true
    #vb.customize ["modifyvm", :id, "--audio", "none"]

  end

  # VM
  config.vm.define "vm", primary: true do |node|

    # OS
    node.vm.box = "${BOX}"
    #node.vm.box_version = "${VERSION}"
    #node.vm.box_check_update = false

    # Network
    node.vm.hostname = "${PROJECT}"
    node.vm.network "private_network", ip: "192.168.2.${IP}"
    #node.hostmanager.enabled = true
    #node.hostmanager.manage_guest = true
    #node.hostmanager.ignore_private_ip = false

    # Provision
    node.vm.provision "shell", path: "ansible.sh", run: "always"

  end

end
EOF
;;
  [2-6])
cat << EOF >> ${PROJECT}/vagrantfile
Vagrant.configure("2") do |config|

  config.vm.provider "virtualbox" do |vb|

    # Hardware
    vb.memory = 512
    vb.cpus = 1
    vb.linked_clone = true
    #vb.customize ["modifyvm", :id, "--audio", "none"]

  end

  # VMs
  (1..${VM_COUNT}).each do |i|
    config.vm.define "vm#{i}", primary: true do |node|

      # OS
      node.vm.box = "${BOX}"
      #node.vm.box_version = "${VERSION}"
      #node.vm.box_check_update = false

      # Network
      node.vm.hostname = "${PROJECT}-#{i}"
      node.vm.network "private_network", ip: "192.168.2.${IP}#{i}"
      #node.hostmanager.enabled = true
      #node.hostmanager.manage_guest = true
      #node.hostmanager.ignore_private_ip = false

      # Provision
      node.vm.provision "shell", path: "ansible.sh", run: "always"

    end

  end

end
EOF
;;
  *)
echo "Invalid VM count. It must be an int >=1."
exit 1 ;;
esac

#########################
### Generate ansible.sh
#########################

cat << EOF >> ${PROJECT}/${USER}.sh
#!/bin/bash

USER=${USER}
SSH_DIR=/home/\${USER}/.ssh
PUB_KEY=/vagrant/\${USER}_rsa.pub
PRIV_KEY=/vagrant/\${USER}_rsa

if test ! \$(id -u \${USER})
  then
    useradd -m \${USER}
    mkdir -p \${SSH_DIR}
    cp \${PUB_KEY} \${SSH_DIR}/authorized_keys
    cp \${PRIV_KEY} \${SSH_DIR}/id_rsa
    chown \${USER}.\${USER} -R \${SSH_DIR}
    chmod 700 \${SSH_DIR}
    chmod 600 \${SSH_DIR}/*
    echo "\${USER} ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/\${USER}
    #yum update -y
    #yum install -y epel-release
    #yum install -y ansible git
    apt update && apt upgrade -y
    apt install python3-pip -y
    pip3 install ansible-core ansible
    git clone https://github.com/code-red-panda/crp-ansible.git /var/crp-ansible
    echo "for i in \$(seq 1 \${VM_COUNT}) ; do echo \"192.168.2.\${IP}\${i} \${PROJECT}-\${i}\" >> /etc/hosts ; done"
    for i in \$(seq 1 \${VM_COUNT}) ; do echo "192.168.2.\${IP}\${i} \${PROJECT}-\${i}" >> /etc/hosts ; done
fi
EOF

#########################
### Generate SSH keys
#########################

if ! test -f ${USER}_rsa
then
    ssh-keygen -t rsa -C "${USER}" -f "./${USER}_rsa" -P "" 1> /dev/null
fi

cp ${USER}_rsa ${USER}_rsa.pub ./${PROJECT}
