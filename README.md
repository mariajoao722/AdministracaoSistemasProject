# Project System Administration 23/24 - Ceph Cluster Using Virtual Machines and Terraform with Backup Strategy
This is the project for the System Administration class to design, deploy, and manage a Ceph cluster using virtual machines (VMs) and, where feasible, Terraform. 

## Introduction

This project involves the design, deployment, and management of a Ceph cluster on Google Cloud Platform (GCP). Our Ceph cluster consists of Object Storage Devices (OSDs), Monitor Nodes (MONs), Manager Nodes (MGRs), an RBD client, and a backup solution implemented using rsync.

## Project Overview

### Architecture
The architecture of this project includes:

- **Distributed Storage Cluster**:
  - 2 OSD VMs
  - 1 MON VM
  - 1 MGR VM

- **Client Integration**:
  - PostgreSQL deployed over RBD (Rados Block Device) for data storage

- **Backup Solution**:
  - 1 VM dedicated to serving as the backup server using rsync

### Project Tasks

1. [x] **Infrastructure Setup**:
   - Provision VM instances using Terraform.

2. [x] **Ceph Software Installation**:
   - Install and configure Ceph software on the provisioned VMs.

3. [x] **Ceph Cluster Setup**:
   - Define roles for each VM.
   - Configure networking and storage within GCP.

4. [x] **RBD Client Deployment**:
   - Deploy and configure an RBD client on a designated GCP VM.

5. [x] **Backup Solution Implementation**:
   - Set up a backup server using rsync.
   - Configure backups from the Ceph cluster for data protection.

6. [x] **Testing and Validation**:
   - Test cluster functionality, data storage, replication, and retrieval.
   - Perform backup and recovery tests to validate effectiveness.

7. [x] **Monitoring and Evaluation**:
   - Monitor the health and performance of the Ceph cluster, backup system, and RBD client.

8. [x] **Documentation and Presentation**:
   - Document configurations, backup strategies, RBD client setup, and troubleshooting steps.
   - Prepare a project presentation demonstrating the working cluster.

## Configurations

To use the Terraform configurations:
1. Ensure you have Terraform installed on your local machine.

   #### For linux (using apt)
  
    ```
    sudo apt-get update
    sudo apt-get install -y terraform
    ```
  
    #### For macOS (using Homebrew):
    
    ```
    brew install terraform
    ```


3. Clone or download this repository.
4. Navigate to the directory containing the `main.tf` file.
5. Run `terraform init` to initialize the configuration.
6. Run `terraform validate` to check the syntax and validity of the configuration.
7. Run `terraform plan` to preview the changes that Terraform will make to your infrastructure.
8. Run `terraform apply` to create the VM instances as defined in the configuration file.
   - For better efficiency and to avoid manual confirmation, you can add the `--auto-approve` flag.

**Note:** If you make changes to your Terraform files, just rerun the final three steps. The initial `terraform init` is only necessary during the initial setup or when transitioning to a different Terraform configuration."

To have a connection between all VMs using SSH, after the installation is complete we have to copy the public key to Metadata in GCP. After doing this we can continue with the configurations of the cluster.

For all the VMs after the installation of packages is complete we have the scripts that are created.
For MON VM:
- run ``` ./scriptosd1.sh```, ``` ./scriptosd2.sh```, ``` ./script.sh```, ``` ./scriptrdb.sh```, ``` ./scriptmgr.sh```.

For OSD1 VM:
- after running the script  ``` ./scriptosd1.sh``` in MON VM we have to run  ``` ./script.sh```.

For OSD2 VM:
- after running the script  ``` ./scriptosd2.sh``` in MON VM we have to run  ``` ./script.sh```.

For MGR VM:
- after running the script  ``` ./scriptmgr.sh``` in MON VM we have to run  ``` ./script.sh```.

For RDB/Backup VM:
- after running the script  ``` ./scriptrdb.sh``` in MON VM we have to run  ``` ./script.sh```.

## Backup Strategies

The VM created to serve as the backup server solution was created using Terraform with the following code:

```terraform
resource "google_compute_instance" "backup" {
  name         = var.instance_name5
  machine_type = "e2-micro"
  zone         = "europe-southwest1-c"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network = "default"
    # Add access_config with a static external IP address
    access_config {
    }
    # Assign a static internal IP address
    network_ip = "10.204.0.14"
  }

  metadata_startup_script = file("scripts/scriptBackup.sh")
}
```
The script used for the backup strategies was the `scriptBackup.sh` with the following code:

```bash
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

ssh-keygen -C publicMethod3 -f ~/.ssh/publicMethod3 -N "" -q

cat <<EOF > ~/script.sh
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

sudo chmod +x ~/script.sh


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



cat <<EOF > ~/scriptpgAdmin.sh
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

sudo chmod +x ~/scriptpgAdmin.sh

# Configure Web Server for pgAdmin4

# sudo /usr/pgadmin4/bin/setup-web.sh
# email: mjmarquespais@gmail.com
# password: 1234567890

# mover  pasta do postgreSQL para pasta que dei mount
# sudo mv /var/lib/postgresql/ /mnt


# BACKUP

sudo mkdir -p backup/MON/cephconf
sudo mkdir -p backup/MON/cephvar
sudo mkdir -p backup/MGR/cephconf
sudo mkdir -p backup/MGR/cephvar
sudo mkdir -p backup/OSD1/cephconf
sudo mkdir -p backup/OSD1/cephvar
sudo mkdir -p backup/OSD2/cephconf
sudo mkdir -p backup/OSD2/cephvar

cat <<EOF > ~/scriptBUPmon.sh
#!/bin/bash
# sudo rsync -av --delete --exclude='.ceph' -e "ssh -i ~/.ssh/publicMethod3" publicMethod3@10.204.0.12:/etc/ceph ~/backup/MON/cephconf
sudo rsync -av --exclude='.ceph' -e "ssh -i ~/.ssh/publicMethod3" publicMethod3@10.204.0.12:/etc/ceph/ ~/backup/MON/cephconf

sudo rsync -av --exclude='.ceph' -e "ssh -i ~/.ssh/publicMethod3" publicMethod3@10.204.0.12:/var/lib/ceph/ ~/backup/MON/cephvar
EOF

cat <<EOF > ~/scriptBUPmgr.sh
#!/bin/bash

sudo rsync -av --exclude='.ceph' -e "ssh -i ~/.ssh/publicMethod3" publicMethod3@10.204.0.13:/etc/ceph/ ~/backup/MGR/cephconf

sudo rsync -av --exclude='.ceph' -e "ssh -i ~/.ssh/publicMethod3" publicMethod3@10.204.0.13:/var/lib/ceph/ ~/backup/MGR/cephvar
EOF

cat <<EOF > ~/scriptBUPosd1.sh
#!/bin/bash

sudo rsync -av --exclude='.ceph' -e "ssh -i ~/.ssh/publicMethod3" publicMethod3@10.204.0.10:/etc/ceph/ ~/backup/OSD1/cephconf

sudo rsync -av --exclude='.ceph' -e "ssh -i ~/.ssh/publicMethod3" publicMethod3@10.204.0.10:/var/lib/ceph/ ~/backup/OSD1/cephvar
EOF

cat <<EOF > ~/scriptBUPosd2.sh
#!/bin/bash

sudo rsync -av --exclude='.ceph' -e "ssh -i ~/.ssh/publicMethod3" publicMethod3@10.204.0.11:/etc/ceph/ ~/backup/OSD2/cephconf

sudo rsync -av --exclude='.ceph' -e "ssh -i ~/.ssh/publicMethod3" publicMethod3@10.204.0.11:/var/lib/ceph/ ~/backup/OSD2/cephvar
EOF

sudo chmod +x ~/scriptBUPmon.sh
sudo chmod +x ~/scriptBUPmgr.sh
sudo chmod +x ~/scriptBUPosd1.sh
sudo chmod +x ~/scriptBUPosd2.sh

sudo chmod -R +rx ~/backup

```

To do the backup of the cluster we have to run the following commands:
- for MON vm
```
./scriptBUPmon.sh
```
- for OSD1 vm
```
./scriptBUPosd1.sh
```
- for OSD2 vm
```
./scriptBUPosd2.sh
```
- for MGR vm
```
./scriptBUPmgr.sh
```

If we wanna recover the data from another VM, all we have to do is go the vm we want to fetch the backup and run the command ```./scriptBUP<NAME-OF-CLUSTER>.sh```

## RBD Client Setup

The script used for the RBD Client Setup was the `scriptBackup.sh`, the same one used for backup because these two components are together in one VM with the following code:

```bash
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

ssh-keygen -C publicMethod3 -f ~/.ssh/publicMethod3 -N "" -q

cat <<EOF > ~/script.sh
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

sudo chmod +x ~/script.sh


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



cat <<EOF > ~/scriptpgAdmin.sh
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

sudo chmod +x ~/scriptpgAdmin.sh

# Configure Web Server for pgAdmin4

# sudo /usr/pgadmin4/bin/setup-web.sh
# email: mjmarquespais@gmail.com
# password: 1234567890

# mover  pasta do postgreSQL para pasta que dei mount
# sudo mv /var/lib/postgresql/ /mnt


# BACKUP

sudo mkdir -p backup/MON/cephconf
sudo mkdir -p backup/MON/cephvar
sudo mkdir -p backup/MGR/cephconf
sudo mkdir -p backup/MGR/cephvar
sudo mkdir -p backup/OSD1/cephconf
sudo mkdir -p backup/OSD1/cephvar
sudo mkdir -p backup/OSD2/cephconf
sudo mkdir -p backup/OSD2/cephvar

cat <<EOF > ~/scriptBUPmon.sh
#!/bin/bash
# sudo rsync -av --delete --exclude='.ceph' -e "ssh -i ~/.ssh/publicMethod3" publicMethod3@10.204.0.12:/etc/ceph ~/backup/MON/cephconf
sudo rsync -av --exclude='.ceph' -e "ssh -i ~/.ssh/publicMethod3" publicMethod3@10.204.0.12:/etc/ceph/ ~/backup/MON/cephconf

sudo rsync -av --exclude='.ceph' -e "ssh -i ~/.ssh/publicMethod3" publicMethod3@10.204.0.12:/var/lib/ceph/ ~/backup/MON/cephvar
EOF

cat <<EOF > ~/scriptBUPmgr.sh
#!/bin/bash

sudo rsync -av --exclude='.ceph' -e "ssh -i ~/.ssh/publicMethod3" publicMethod3@10.204.0.13:/etc/ceph/ ~/backup/MGR/cephconf

sudo rsync -av --exclude='.ceph' -e "ssh -i ~/.ssh/publicMethod3" publicMethod3@10.204.0.13:/var/lib/ceph/ ~/backup/MGR/cephvar
EOF

cat <<EOF > ~/scriptBUPosd1.sh
#!/bin/bash

sudo rsync -av --exclude='.ceph' -e "ssh -i ~/.ssh/publicMethod3" publicMethod3@10.204.0.10:/etc/ceph/ ~/backup/OSD1/cephconf

sudo rsync -av --exclude='.ceph' -e "ssh -i ~/.ssh/publicMethod3" publicMethod3@10.204.0.10:/var/lib/ceph/ ~/backup/OSD1/cephvar
EOF

cat <<EOF > ~/scriptBUPosd2.sh
#!/bin/bash

sudo rsync -av --exclude='.ceph' -e "ssh -i ~/.ssh/publicMethod3" publicMethod3@10.204.0.11:/etc/ceph/ ~/backup/OSD2/cephconf

sudo rsync -av --exclude='.ceph' -e "ssh -i ~/.ssh/publicMethod3" publicMethod3@10.204.0.11:/var/lib/ceph/ ~/backup/OSD2/cephvar
EOF

sudo chmod +x ~/scriptBUPmon.sh
sudo chmod +x ~/scriptBUPmgr.sh
sudo chmod +x ~/scriptBUPosd1.sh
sudo chmod +x ~/scriptBUPosd2.sh

sudo chmod -R +rx ~/backup

```

After running the script for RDB in the MON VM we have to run the `script.sh` to configure the RDB client.

To create a database using PostgreSQL we have to run the following commands:
- ``` sudo -i -u postgres ```, now we are inside the Postgres account in my server;
- to enter the prompt use ```psql ``` ;
- create a user and database ``` CREATE USER pguser WITH PASSWORD 'password';
CREATE DATABASE pgdb; ``` ;
- grant all the privileges to the PostgreSQL database ``` GRANT ALL PRIVILEGES ON DATABASE pgdb to pguser; ``` 
- exit the PostgreSQL ```\q```.

To install pgAdmin4 we have to run the script `scriptpgAdmin.sh `.
To have connection to the database outside de vm we have the configure the web server:
- ```sudo /usr/pgadmin4/bin/setup-web.sh```;
- Then we have to enter our email and password information.

## Troubleshooting Steps

### 1. Network Configuration Problems

- **Issue**: Failure in the communication between OSDs, MONs, or MGRs.
- **Troubleshooting Steps**:
  - Check network configurations and ensure proper connectivity.
  - Check DNS configurations for accurate name resolution.
  - Review routing tables and network interfaces.

### 2. OSD Failures

- **Issue**: OSDs failing to join the cluster.
- **Troubleshooting Steps**:
  - Validate OSD configurations and ensure they are properly initialized.
  - Review Ceph logs for specific OSD initialization errors.
  - Verify OSD authentication and permissions.

### 3. MON or MGR Failures

- **Issue**: MON or MGR nodes experiencing issues or going offline.
- **Troubleshooting Steps**:
  - Review MON/MGR logs for any errors or warnings.
  - Restart MON/MGR services if necessary.

### 4. RBD Client Connectivity Problems

- **Issue**: RBD client unable to access or store data on the Ceph cluster.
- **Troubleshooting Steps**:
  - Validate RBD configuration, authentication keys and permissions.
  - Check network connectivity between the client and Ceph cluster.

### 5. Backup and Recovery Problems

- **Issue**: Backup failures to recover data.
- **Troubleshooting Steps**:
  - Check backup server configurations and connectivity to the Ceph cluster.
  - Ensure proper permissions and access to backup directories.

## Students Info
Project made by:
- Maria João Marques Pais (up202308322)
- Mónica Azevedo Araújo (up202005209)
- Rafael Azevedo Alves (up202004476)

