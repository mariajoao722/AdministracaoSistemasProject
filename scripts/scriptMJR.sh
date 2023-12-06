#!/bin/bash
sudo apt-get update
sudo apt-get install -y ceph

ssh-keygen -C publicMethod4 -f /home/mjmarquespais/.ssh/publicMethod4 -N "" -q

# sudo chown ceph. /etc/ceph/ceph.*

outfile=/home/mjmarquespais/debug.txt

sudo mkdir /var/lib/ceph/mgr/ceph-mon

echo "after1" | tee -a $outfile
# create auth key
sudo ceph auth get-or-create mgr.mon mon 'allow profile mgr' osd 'allow *' mds 'allow *'

sudo ceph auth get-or-create mgr.mon | sudo tee /etc/ceph/ceph.mgr.admin.keyring

cat <<EOF > /home/mjmarquespais/script.sh
#!/bin/bash
sudo cp /etc/ceph/ceph.mgr.admin.keyring /var/lib/ceph/mgr/ceph-mon/keyring
sudo chown ceph. /etc/ceph/ceph.mgr.admin.keyring
sudo chown -R ceph. /var/lib/ceph/mgr/ceph-mon
sudo systemctl enable --now ceph-mgr@mon
EOF

echo "after2" | tee -a $outfile