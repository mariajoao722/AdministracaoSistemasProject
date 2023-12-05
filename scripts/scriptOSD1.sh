#!/bin/bash
sudo apt-get update
sudo apt-get install -y ceph
sudo apt-get install -y openssh-client
sudo apt-get install -y openssh-server

outfile=/home/mjmarquespais/debug.txt

# ver discos da maquina
# lsblk 

# fazer manualmente
# sudo nano /etc/ceph/ceph.conf
#scp /etc/ceph/ceph.conf node02:/etc/ceph/ceph.conf

# sudo nano /etc/ceph/ceph.client.admin.keyring
#scp /etc/ceph/ceph.client.admin.keyring node02:/etc/ceph

# sudo nano /var/lib/ceph/bootstrap-osd/ceph.keyring
#scp /var/lib/ceph/bootstrap-osd/ceph.keyring node02:/var/lib/ceph/bootstrap-osd

cat <<EOF > /home/mjmarquespais/script.sh
#!/bin/bash
sudo chown ceph. /etc/ceph/ceph.* /var/lib/ceph/bootstrap-osd/ceph.keyring
sudo parted --script /dev/sdb 'mklabel gpt'
sudo parted --script /dev/sdb "mkpart primary 0% 100%"
# sudo ceph-volume lvm create --data /dev/sdb1
EOF