# localbox
Project Reserved IPs
```
monitor		192.168.2.5
centos7		192.168.2.6
ubuntu1804	192.168.2.7
proxysql	192.168.2.8
proxysql2	192.168.2.9
pxc		192.168.2.81/82/83
async		192.168.2.91/92
```

For projects with multiple VMs that will need Ansible, run the prepare script to:
- generate a "vagrantfile" for looping over multiple VMs
- generate ansible SSH keys for the project
- generate the Vagrant provisioner script that will create an ansible user, grant sudo, and configure SSH on each VM

```
cd localbox

mkdir <project>

sh prepare_ansible_for_project.sh <project>
```
