# localbox
Pre-requisites
- Vagrant 2.2+ https://www.vagrantup.com/downloads.html
- VirtualBox 6.0+ https://www.virtualbox.org/wiki/Downloads

Project IPs
- Vbox subnet `192.168.2.%`
```
monitor		192.168.2.5
centos7		192.168.2.6
ubuntu1804	192.168.2.7
proxysql	192.168.2.8
proxysql2	192.168.2.9
pxc		192.168.2.81/82/83
async		192.168.2.91/92
```

For projects with a single VM, run the prepare script to:
- Create project directory
- Generate CentOS7 `vagrantfile`
```
sh prepare_project_single_vm.sh <project> <4th octet IP>
```

For projects with multiple VMs, run the prepare script to:
- Create project directory
- Generate CentOS7 `vagrantfile` to loop over multiple VMs
- Generate `ansible` SSH keys for the project
- Generate bash provisioner script to create an `ansible` user, grant `ansible` sudo, and configure SSH for `ansible` on each VM
```
sh prepare_project_multi_vm.sh <project> <4th octet IP> <total number of VMs>
```
