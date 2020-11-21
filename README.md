# vagrant
Pre-requisites
- Vagrant 2.2+ https://www.vagrantup.com/downloads.html
- VirtualBox 6.0+ https://www.virtualbox.org/wiki/Downloads
- Vagrant plugins
```
vagrant plugin install hostmanager vagrant-hostmanager
```

Project IPs
- Vbox subnet `192.168.2.%`
```
monitor		192.168.2.5
centos7		192.168.2.6
ubuntu1804	192.168.2.7
proxysql	192.168.2.8
proxysql2	192.168.2.9
pxc		192.168.2.81/82/83
async57		192.168.2.91/92
```

Available OS'
- `centos6`
- `centos7`
- `ubuntu1804`
- `ubuntu2004`

For projects with multiple VMs, run the prepare script to:
- Create project directory
- Generate CentOS7 `vagrantfile`
# Removed this so all VMs can SSH to each other- Generate `ansible` SSH keys for the project
- Copy `ansible` SSH keys
- Generate bash provisioner script to:
  - create an `ansible` user
  - grant `ansible` user sudo
  - configure SSH for `ansible` user on each VM
```
sh prepare_project.sh <project name> <os> <4th octet IP> <total number of VMs>
```
