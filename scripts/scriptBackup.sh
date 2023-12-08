#!/bin/bash
sudo apt-get -y install ceph-common
sudo apt-get install -y ceph-osd
sudo apt-get install xfsprogs -y
sudo apt-get install rsync

#Next, install both the PostgreSQL package and the contrib packages

sudo apt install postgresql postgresql-contrib -y

#To verify that the PostgreSQL server is running, run the following command:

sudo systemctl start postgresql.service

# https://www.devart.com/dbforge/postgresql/how-to-install-postgresql-on-linux/
# https://www.server-world.info/en/note?os=Debian_11&p=ceph14&f=3
# https://www.digitalocean.com/community/tutorials/how-to-use-rsync-to-sync-local-and-remote-directories-pt
# https://www.rosehosting.com/blog/install-pgadmin-4-on-debian-10/
# https://computingforgeeks.com/how-to-install-pgadmin4-on-debian/ 

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


# To switch to the postgres account on your server, execute the following command:

# sudo -i -u postgres

# To access the PostgreSQL prompt, type:

# psql

# This will log you into the PostgreSQL prompt where you can interact with the database management system.



# create a user and database with the following command:

# CREATE USER pguser WITH PASSWORD 'password';
# CREATE DATABASE pgdb;

# grant all the privileges to PostgreSQL database with the following command:

# GRANT ALL PRIVILEGES ON DATABASE pgdb to pguser;


# To exit the PostgreSQL prompt, type:

#\q


cat <<EOF > /home/mjmarquespais/scriptpgAdmin.sh
#!/bin/bash
# pgAdmin repository
sudo curl https://www.pgadmin.org/static/packages_pgadmin_org.pub | sudo apt-key add

#Then create the repository configuration file
sudo sh -c 'echo "deb https://ftp.postgresql.org/pub/pgadmin/pgadmin4/apt/$(lsb_release -cs) pgadmin4 main" > /etc/apt/sources.list.d/pgadmin4.list'
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'

# Import the Repository Signing Key
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo gpg --dearmor -o /usr/share/keyrings/postgresql-archive-keyring.gpg


sudo apt update
sudo apt install pgadmin4 -y
EOF

sudo chmod +x /home/mjmarquespais/scriptpgAdmin.sh

# Configure Web Server for pgAdmin4

# sudo /usr/pgadmin4/bin/setup-web.sh
# email: mjmarquespais@gmail.com
# password: 1234567890

# mover  pasta do postgreSQL para /dev/rbd0
# sudo mv /var/lib/postgresql/ /dev/rbd0/

# sincronizar os ficheiros dentro da maquina backup
# rsync -a dir3/ dir2

