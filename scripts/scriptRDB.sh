#!/bin/bash
sudo apt-get update
sudo apt-get install -y ceph
sudo apt-get -y install ceph-commo
sudo apt-get install xfsprogs -y
sudo apt-get install rsync


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
