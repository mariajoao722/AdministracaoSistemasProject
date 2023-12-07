#!/bin/bash
sudo apt-get update
sudo apt-get install -y ceph

ssh-keygen -C publicMethod1 -f /home/mjmarquespais/.ssh/publicMethod1 -N "" -q

# https://docs.ceph.com/en/latest/install/manual-deployment/
# https://www.server-world.info/en/note?os=Debian_11&p=ceph14&f=2

#copiar ficheiros
#scp -i ~/.ssh/publicMethod1 ~/exemplo.txt publicMethod1@10.204.0.12:~/exemplo.txt

# ver discos da maquina
# lsblk 

sudo cat <<EOF > /home/mjmarquespais/script.sh
#!/bin/bash
sudo chown ceph. /etc/ceph/ceph.* /var/lib/ceph/bootstrap-osd/ceph.keyring
sudo parted --script /dev/sdb 'mklabel gpt'
sudo parted --script /dev/sdb "mkpart primary 0% 100%"
sudo ceph-volume lvm create --data /dev/sdb1
EOF

sudo chmod +x /home/mjmarquespais/script.sh