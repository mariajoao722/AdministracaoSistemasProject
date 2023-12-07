#!/bin/bash
sudo apt-get update
sudo apt-get install -y ceph
sudo apt-get -y install ceph-commo
sudo apt-get install xfsprogs -y
sudo apt-get install rsync

#https://www.devart.com/dbforge/postgresql/how-to-install-postgresql-on-linux/
# https://www.server-world.info/en/note?os=Debian_11&p=ceph14&f=3

ssh-keygen -C publicMethod3 -f /home/mjmarquespais/.ssh/publicMethod3 -N "" -q



cat <<EOF > /home/mjmarquespais/script.sh
#!/bin/bash
sudo chown ceph. /etc/ceph/ceph.*

# create default RBD pool [rbd]
sudo ceph osd pool create rbd 64

# enable Placement Groups auto scale mode
sudo ceph mgr module enable pg_autoscaler
sudo ceph osd pool set rbd pg_autoscale_mode on

# initialize the pool
sudo rbd pool init rbd
sudo ceph osd pool autoscale-status


# create a block device with 10G
sudo rbd create --size 10G --pool rbd rbd01

# confirm
sudo rbd ls -l


# map the block device
sudo rbd map rbd01

# confirm
sudo rbd showmapped

# format with XFS
sudo mkfs.xfs /dev/rbd0

# mount
sudo mount /dev/rbd0 /mnt
EOF

sudo chmod +x /home/mjmarquespais/script.sh



#Next, install both the PostgreSQL package and the contrib packages

sudo apt install postgresql postgresql-contrib -y

#To verify that the PostgreSQL server is running, run the following command:

sudo systemctl start postgresql.service

# To switch to the postgres account on your server, execute the following command:

# sudo -i -u postgres

# To access the PostgreSQL prompt, type:

# psql

# This will log you into the PostgreSQL prompt where you can interact with the database management system.

# To view the PostgreSQL server version running, use the command:

# psql -V

# To exit the PostgreSQL prompt, type:

#\q