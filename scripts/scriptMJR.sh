#!/bin/bash
sudo apt-get install -y ceph
sudo apt-get install rsync

ssh-keygen -C publicMethod4 -f /home/mjmarquespais/.ssh/publicMethod4 -N "" -q


outfile=/home/mjmarquespais/debug.txt

sudo mkdir /var/lib/ceph/mgr/ceph-mon

echo "after1" | tee -a $outfile
# create auth key
sudo ceph auth get-or-create mgr.mon mon 'allow profile mgr' osd 'allow *' mds 'allow *'

sudo ceph auth get-or-create mgr.mon | sudo tee /etc/ceph/ceph.mgr.admin.keyring

cat <<EOF > /home/mjmarquespais/script.sh
#!/bin/bash
sudo chown ceph. /etc/ceph/ceph.*
sudo cp /etc/ceph/ceph.mgr.admin.keyring /var/lib/ceph/mgr/ceph-mon/keyring
sudo chown ceph. /etc/ceph/ceph.mgr.admin.keyring
sudo chown -R ceph. /var/lib/ceph/mgr/ceph-mon
sudo systemctl enable --now ceph-mgr@mon
EOF

sudo chmod +x /home/mjmarquespais/script.sh

cat <<EOF > /home/mjmarquespais/scriptBUPmgr.sh
#!/bin/bash

sudo rsync -av --exclude='.ceph' -e "ssh -i /home/mjmarquespais/.ssh/publicMethod4" publicMethod4@10.204.0.14:/home/mjmarquespais/backup/MGR/cephconf/ /etc/ceph

sudo rsync -av --exclude='.ceph' -e "ssh -i /home/mjmarquespais/.ssh/publicMethod4" publicMethod4@10.204.0.14:/home/mjmarquespais/backup/MGR/cephvar/ /var/lib/ceph
EOF

sudo chmod +x /home/mjmarquespais/scriptBUPmgr.sh

echo "after2" | tee -a $outfile

# mudar permissões para o backup
sudo chmod -R +rx /etc/ceph/
sudo chmod -R +rx /var/lib/ceph/
