#!/bin/bash
sudo apt-get update
sudo apt-get install -y ceph
sudo apt-get install -y openssh-client
sudo apt-get install -y openssh-server

outfile=/home/mjmarquespais/debug.txt

# Create or update ceph.conf
cat <<EOF > /etc/ceph/ceph.conf
[global]
# Enable the manager module
mgr module enabled = true

# Specify the MGR module
mgr module = true
EOF

sudo mkdir /var/lib/ceph/mgr/ceph-mjr

echo "after1" | tee -a $outfile
# create auth key
sudo ceph auth get-or-create mgr.mjr mon 'allow profile mgr' osd 'allow *' mds 'allow *'
sudo chmod +r /etc/ceph/ceph.mgr.mjr.keyring


echo "after2" | tee -a $outfile

#sudo ceph auth get-or-create mgr.mjr | tee /etc/ceph/ceph.mgr.admin.keyring
#sudo cp /etc/ceph/ceph.mgr.admin.keyring /var/lib/ceph/mgr/ceph-mjr/keyring
#sudo chown ceph. /etc/ceph/ceph.mgr.admin.keyring
#sudo chown -R ceph. /var/lib/ceph/mgr/ceph-mjr
#sudo systemctl enable --now ceph-mgr@mgr