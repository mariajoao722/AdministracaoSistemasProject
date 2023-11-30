
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
    mon host = 10.204.0.34
    # specify Hostname of Monitor Daemon
    mon initial members = node01
    osd pool default crush rule = -1

    # mon.(Node name)
    [mon.node01]
    # specify Hostname of Monitor Daemon
    host = node01
    # specify IP address of Monitor Daemon
    mon addr = 10.0.0.51
    # allow to delete pools
    mon allow pool delete = true
    EOF