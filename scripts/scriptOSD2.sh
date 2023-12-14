#!/bin/bash
sudo apt-get update
sudo apt-get install -y ceph
sudo apt-get install rsync

ssh-keygen -C publicMethod1 -f home/mjmarquespais/.ssh/publicMethod1 -N "" -q

# https://docs.ceph.com/en/latest/install/manual-deployment/
# https://www.server-world.info/en/note?os=Debian_11&p=ceph14&f=2

#copiar ficheiros
#scp -i home/mjmarquespais/.ssh/publicMethod1 home/mjmarquespais/exemplo.txt publicMethod1@10.204.0.12:home/mjmarquespais/exemplo.txt

# ver discos da maquina
# lsblk 

sudo cat <<EOF > home/mjmarquespais/script.sh
#!/bin/bash
sudo chown ceph. /etc/ceph/ceph.* /var/lib/ceph/bootstrap-osd/ceph.keyring
sudo parted --script /dev/sdb 'mklabel gpt'
sudo parted --script /dev/sdb "mkpart primary 0% 100%"
sudo ceph-volume lvm create --data /dev/sdb1
EOF

sudo chmod +x home/mjmarquespais/script.sh

cat <<EOF > home/mjmarquespais/scriptBUPosd2.sh
#!/bin/bash

sudo rsync -av --exclude='.ceph' -e "ssh -i home/mjmarquespais/.ssh/publicMethod1" publicMethod1@10.204.0.14:home/mjmarquespais/backup/OSD2/cephconf/ /etc/ceph 

sudo rsync -av --exclude='.ceph' -e "ssh -i home/mjmarquespais/.ssh/publicMethod1" publicMethod1@10.204.0.14:home/mjmarquespais/backup/OSD2/cephvar/ /var/lib/ceph 
EOF

sudo chmod +x home/mjmarquespais/scriptBUPosd2.sh

# mudar permissões para o backup
sudo chmod -R +rx /etc/ceph/
sudo chmod -R +rx /var/lib/ceph/