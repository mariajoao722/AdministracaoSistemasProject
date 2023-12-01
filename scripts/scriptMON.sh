
#!/bin/bash
sudo apt-get update
sudo apt-get install -y ceph
sudo apt-get install -y openssh-client
uui=$(uuidgen)
# Create or update ceph.conf
cat <<EOF > /etc/ceph/ceph.conf
[global]
# specify cluster network for monitoring
cluster network = 10.204.0.0/24
# specify public network
public network = 10.204.0.0/24
# specify UUID generated above
fsid = $uui
# specify IP address of Monitor Daemon
mon host = 10.204.0.12
# specify Hostname of Monitor Daemon
mon initial members = node01
osd pool default crush rule = -1

# mon.(Node name)
[mon.node01]
# specify Hostname of Monitor Daemon
host = node01
# specify IP address of Monitor Daemon
mon addr = 10.0.0.12
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

# create a directory for Monitor Daemon
# directory name ⇒ (Cluster Name)-(Node Name)
sudo mkdir /var/lib/ceph/mon/ceph-node01

# assosiate key and monmap to Monitor Daemon
# --cluster (Cluster Name)
sudo ceph-mon --cluster ceph --mkfs -i $NODENAME --monmap /etc/ceph/monmap --keyring /etc/ceph/ceph.mon.keyring
sudo chown ceph. /etc/ceph/ceph.*
sudo chown -R ceph. /var/lib/ceph/mon/ceph-node01 /var/lib/ceph/bootstrap-osd
sudo systemctl enable --now ceph-mon@$NODENAME

outfile=/home/mjmarquespais/debug.txt
# enable Messenger v2 Protocol
echo "before" | tee -a $outfile
sudo ceph mon enable-msgr2 | tee -a $outfile
echo "after" | tee -a $outfile
sudo ceph config set mon auth_allow_insecure_global_id_reclaim false

# create a directory for Manager Daemon
# directory name ⇒ (Cluster Name)-(Node Name)
sudo mkdir /var/lib/ceph/mgr/ceph-node01

# create auth key
sudo ceph auth get-or-create mgr.$NODENAME mon 'allow profile mgr' osd 'allow *' mds 'allow *'


sudo ceph auth get-or-create mgr.node01 | tee /etc/ceph/ceph.mgr.admin.keyring
sudo cp /etc/ceph/ceph.mgr.admin.keyring /var/lib/ceph/mgr/ceph-node01/keyring
sudo chown ceph. /etc/ceph/ceph.mgr.admin.keyring
sudo chown -R ceph. /var/lib/ceph/mgr/ceph-node01
sudo systemctl enable --now ceph-mgr@$NODENAME

chown ceph. /etc/ceph/ceph.* /var/lib/ceph/bootstrap-osd/*; \
parted --script /dev/sdb 'mklabel gpt'; \
parted --script /dev/sdb "mkpart primary 0% 100%"; \
ceph-volume lvm create --data /dev/sdb1
