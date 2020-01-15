#cloud-config
repo_update: true
repo_upgrade: all

packages:
- amazon-efs-utils

runcmd:
- mkdir -p /mnt/efs
- grep -v "/mnt/efs" /etc/fstab > /etc/fstab.new
- mv /etc/fstab.new /etc/fstab
- echo "fs-38536ff0:/ /mnt/efs efs tls,_netdev" >> /etc/fstab
- mount -a -t efs defaults
