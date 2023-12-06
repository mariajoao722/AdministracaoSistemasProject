#!/bin/bash
sudo apt-get update
sudo apt-get install -y ceph

echo "feito" | tee -a /home/mjmarquespais/debug.txt

ssh-keygen -C publicMethod -f /home/mjmarquespais/.ssh/publicMethod -N "" -q

uui=$(uuidgen)
HOSTNAME=$(hostname)

# Create or update ceph.conf
cat <<EOF > /etc/ceph/ceph.conf
[global]
# specify cluster network for monitoring
cluster network = 10.204.0.0/24

# specify public network
public network = 10.204.0.0/24

# specify UUID generated above
fsid = $uui

# specify IP address of Monitor DaemonS
mon host = 10.204.0.12

# specify Hostname of Monitor Daemon
mon initial members = $HOSTNAME
osd pool default crush rule = -1

auth_cluster required = cephx
auth_service required = cephx
auth_client required = cephx

# mon.(Node name)
[mon.mon]

# specify Hostname of Monitor Daemon
host = mon

# specify IP address of Monitor Daemon
mon addr = 10.204.0.12

# allow to delete pools
mon allow pool delete = true
EOF

# Generate secret key for Cluster monitoring
sudo ceph-authtool --create-keyring /etc/ceph/ceph.mon.keyring --gen-key -n mon. --cap mon 'allow *'S

# generate secret key for Cluster admin
sudo ceph-authtool --create-keyring /etc/ceph/ceph.client.admin.keyring --gen-key -n client.admin --cap mon 'allow *' --cap osd 'allow *' --cap mds 'allow *' --cap mgr 'allow *'

# generate key for bootstrap
sudo ceph-authtool --create-keyring /var/lib/ceph/bootstrap-osd/ceph.keyring --gen-key -n client.bootstrap-osd --cap mon 'profile bootstrap-osd' --cap mgr 'allow r'

# import generated key
sudo ceph-authtool /etc/ceph/ceph.mon.keyring --import-keyring /etc/ceph/ceph.client.admin.keyring
sudo ceph-authtool /etc/ceph/ceph.mon.keyring --import-keyring /var/lib/ceph/bootstrap-osd/ceph.keyring

# generate monitor map
FSID=$(grep "^fsid" /etc/ceph/ceph.conf | awk {'print $NF'})
NODENAME=$(grep "^mon initial" /etc/ceph/ceph.conf | awk {'print $NF'})
NODEIP=$(grep "^mon host" /etc/ceph/ceph.conf | awk {'print $NF'})
monmaptool --create --add $NODENAME $NODEIP --fsid $FSID /etc/ceph/monmap

outfile=/home/mjmarquespais/debug.txt

echo $HOSTNAME | tee -a $outfile  # mon
echo $uui | tee -a $outfile
echo $FSID | tee -a $outfile
echo $NODENAME | tee -a $outfile  # mon
echo $NODEIP | tee -a $outfile

# create a directory for Monitor Daemon
# directory name ⇒ (Cluster Name)-(Node Name)
sudo mkdir /var/lib/ceph/mon/ceph-mon

# assosiate key and monmap to Monitor Daemon
# --cluster (Cluster Name)
sudo ceph-mon --cluster ceph --mkfs -i $NODENAME --monmap /etc/ceph/monmap --keyring /etc/ceph/ceph.mon.keyring
sudo chown ceph. /etc/ceph/ceph.*
sudo chown -R ceph. /var/lib/ceph/mon/ceph-mon /var/lib/ceph/bootstrap-osd
sudo systemctl enable --now ceph-mon@$NODENAME


# enable Messenger v2 Protocol
echo "before" | tee -a $outfile
sudo ceph mon enable-msgr2 | tee -a $outfile
echo "after" | tee -a $outfile
sudo ceph config set mon auth_allow_insecure_global_id_reclaim false

sudo firewall-cmd --zone=public --add-service=ceph-mon
sudo firewall-cmd --zone=public --add-service=ceph-mon --permanent


# create a directory for Manager Daemon
# directory name ⇒ (Cluster Name)-(Node Name)
sudo mkdir /var/lib/ceph/mgr/ceph-mon

sudo ceph auth get-or-create mgr.$NODENAME mon 'allow profile mgr' osd 'allow *' mds 'allow *'

sudo ceph auth get-or-create mgr.mon | sudo tee /etc/ceph/ceph.mgr.admin.keyring

sudo cp /etc/ceph/ceph.mgr.admin.keyring /var/lib/ceph/mgr/ceph-mon/keyring
sudo chown ceph. /etc/ceph/ceph.mgr.admin.keyring
sudo chown -R ceph. /var/lib/ceph/mgr/ceph-mon
sudo systemctl enable --now ceph-mgr@$NODENAME


cat <<EOF > /home/mjmarquespais/scriptosd1.sh
#!/bin/bash
sudo scp -i ~/.ssh/publicMethod /etc/ceph/ceph.conf publicMethod@10.204.0.10:/tmp/
sudo ssh -i ~/.ssh/publicMethod publicMethod@10.204.0.10 "sudo mv /tmp/ceph.conf /etc/ceph/ceph.conf"

sudo scp -i ~/.ssh/publicMethod /etc/ceph/ceph.client.admin.keyring publicMethod@10.204.0.10:/tmp/
sudo ssh -i ~/.ssh/publicMethod publicMethod@10.204.0.10 "sudo mv /tmp/ceph.client.admin.keyring  /etc/ceph/ceph.client.admin.keyring"

sudo scp -i ~/.ssh/publicMethod /var/lib/ceph/bootstrap-osd/ceph.keyring publicMethod@10.204.0.10:/tmp/
sudo ssh -i ~/.ssh/publicMethod publicMethod@10.204.0.10 "sudo mv /tmp/ceph.keyring /var/lib/ceph/bootstrap-osd/ceph.keyring"
EOF

cat <<EOF > /home/mjmarquespais/scriptosd2.sh
#!/bin/bash
sudo scp -i ~/.ssh/publicMethod /etc/ceph/ceph.conf publicMethod@10.204.0.11:/tmp/
sudo ssh -i ~/.ssh/publicMethod publicMethod@10.204.0.11 "sudo mv /tmp/ceph.conf /etc/ceph/ceph.conf"

sudo scp -i ~/.ssh/publicMethod /etc/ceph/ceph.client.admin.keyring publicMethod@10.204.0.11:/tmp/
sudo ssh -i ~/.ssh/publicMethod publicMethod@10.204.0.11 "sudo mv /tmp/ceph.client.admin.keyring  /etc/ceph/ceph.client.admin.keyring"

sudo scp -i ~/.ssh/publicMethod /var/lib/ceph/bootstrap-osd/ceph.keyring publicMethod@10.204.0.11:/tmp/
sudo ssh -i ~/.ssh/publicMethod publicMethod@10.204.0.11 "sudo mv /tmp/ceph.keyring /var/lib/ceph/bootstrap-osd/ceph.keyring"
EOF



cat <<EOF > /home/mjmarquespais/script.sh
#!/bin/bash
sudo chown ceph. /etc/ceph/ceph.* /var/lib/ceph/bootstrap-osd/ceph.keyring
sudo parted --script /dev/sdb 'mklabel gpt'
sudo parted --script /dev/sdb "mkpart primary 0% 100%"
sudo ceph-volume lvm create --data /dev/sdb1
EOF


cat <<EOF > /home/mjmarquespais/scriptrdb.sh
#!/bin/bash
sudo scp -i ~/.ssh/publicMethod /etc/ceph/ceph.conf publicMethod@10.204.0.15:/tmp/
sudo ssh -i ~/.ssh/publicMethod publicMethod@10.204.0.15 "sudo mv /tmp/ceph.conf /etc/ceph/ceph.conf"

sudo scp -i ~/.ssh/publicMethod /etc/ceph/ceph.client.admin.keyring publicMethod@10.204.0.15:/tmp/
sudo ssh -i ~/.ssh/publicMethod publicMethod@10.204.0.15 "sudo mv /tmp/ceph.client.admin.keyring  /etc/ceph/ceph.client.admin.keyring"

# sudo chown ceph. /etc/ceph/ceph.*
EOF

cat <<EOF > /home/mjmarquespais/scriptmgr.sh
#!/bin/bash
sudo scp -i ~/.ssh/publicMethod /etc/ceph/ceph.conf publicMethod@10.204.0.13:/tmp/
sudo ssh -i ~/.ssh/publicMethod publicMethod@10.204.0.13 "sudo mv /tmp/ceph.conf /etc/ceph/ceph.conf"

sudo scp -i ~/.ssh/publicMethod /etc/ceph/ceph.client.admin.keyring publicMethod@10.204.0.13:/tmp/
sudo ssh -i ~/.ssh/publicMethod publicMethod@10.204.0.13 "sudo mv /tmp/ceph.client.admin.keyring  /etc/ceph/ceph.client.admin.keyring"

# sudo chown ceph. /etc/ceph/ceph.*
EOF

sudo chmod +x /home/mjmarquespais/scriptosd1.sh
sudo chmod +x /home/mjmarquespais/scriptosd2.sh
sudo chmod +x /home/mjmarquespais/script.sh
sudo chmod +x /home/mjmarquespais/scriptrdb.sh
sudo chmod +x /home/mjmarquespais/scriptmgr.sh