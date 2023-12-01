#!/bin/bash
sudo apt-get update
sudo apt-get install -y ceph
sudo apt-get install -y openssh-client

scp /etc/ceph/ceph.conf node02:/etc/ceph/ceph.conf
scp /etc/ceph/ceph.client.admin.keyring node02:/etc/ceph
scp /var/lib/ceph/bootstrap-osd/ceph.keyring node02:/var/lib/ceph/bootstrap-osd

chown ceph. /etc/ceph/ceph.* /var/lib/ceph/bootstrap-osd/*; \
parted --script /dev/sdb 'mklabel gpt'; \
parted --script /dev/sdb "mkpart primary 0% 100%"; \
ceph-volume lvm create --data /dev/sdb1
