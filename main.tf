#change to debian 11

resource "google_compute_instance" "osd1" {
  name         = var.instance_name
  machine_type = "e2-micro"
  zone         = "europe-southwest1-b"

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
  }

  # Add a service_account block
 /* service_account {
    email  = "terraform@projectadms.iam.gserviceaccount.com"
    scopes = ["cloud platform"]
  }*/

  # # Provisioner for Ceph OSD configuration
  # provisioner "remote-exec" {
  #   inline = [
  #     "sudo apt-get update",
  #     "sudo apt-get install -y ceph",
  #     "sudo mkdir /var/local/osd-data",
  #     # Replace /dev/sdb with the actual disk you want to use for OSD
  #     "sudo ceph-deploy osd create --data /dev/sdb ceph-node-1",
  #     # Additional OSD configuration commands
  #   ]
  # }

  metadata_startup_script = file("scripts/scriptOSD.sh") 
}

resource "google_compute_instance" "osd2" {
  name         = var.instance_name2
  machine_type = "e2-micro"
  zone         = "europe-southwest1-b"

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
  }

  # Add a service_account block
/* service_account {
    email  = "terraform@projectadms.iam.gserviceaccount.com"
    scopes = ["cloud platform"]
  }*/
   # Provisioner for Ceph OSD configuration
  #provisioner "remote-exec" {
    #inline = [
      #"sudo apt-get update",
      #"sudo apt-get install -y ceph",
      #"sudo mkdir /var/local/osd-data",
      # Replace /dev/sdb with the actual disk you want to use for OSD
      #"sudo ceph-deploy osd create --data /dev/sdb ceph-node-1",
      # Additional OSD configuration commands
    #]
  #}
  metadata_startup_script = file("scripts/scriptOSD.sh") 
}

resource "google_compute_instance" "mon" {
  name         = var.instance_name3
  machine_type = "e2-micro"
  zone         = "europe-southwest1-b"

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
  }

  # Add a service_account block
/* service_account {
    email  = "terraform@projectadms.iam.gserviceaccount.com"
    scopes = ["cloud platform"]
  }*/

  #provisioner "remote-exec" {
   # inline = [
    #  "sudo apt-get update",
     # "sudo apt-get install -y ceph",
      # Initialize the Ceph MON (replace `ceph-node-3` with your node name)
      #"sudo ceph-deploy mon create-initial",
      # Additional MON configuration commands
    #]
  #}
  metadata_startup_script = file("scripts/scriptMON.sh")
}

resource "google_compute_instance" "mjr" {
  name         = var.instance_name4
  machine_type = "e2-micro"
  zone         = "europe-southwest1-b"

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
  }

 /* service_account {
    email  = "terraform@projectadms.iam.gserviceaccount.com"
    scopes = ["cloud platform"]
  }*/

   # Provisioner for Ceph OSD configuration
  #provisioner "remote-exec" {
   # inline = [
    #  "sudo apt-get update",
     # "sudo apt-get install -y ceph",
      # Initialize the Ceph MGR (replace `ceph-node-4` with your node name)
      #"sudo ceph-deploy mgr create ceph-node-4",
      # Additional MGR configuration commands
    #]
  #}
  metadata_startup_script = file("scripts/scriptMJR.sh")
}

resource "google_compute_instance" "backup" {
  name         = var.instance_name5
  machine_type = "e2-micro"
  zone         = "europe-southwest1-b"

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
  }

  # Add a service_account block
 /* service_account {
    email  = "terraform@projectadms.iam.gserviceaccount.com"
    scopes = ["cloud platform"]
  }*/

  metadata_startup_script = file("scripts/scriptBackup.sh")
}

resource "google_compute_instance" "rdb" {  # cliente
  name         = var.instance_name6
  machine_type = "e2-micro"
  zone         = "europe-southwest1-b"

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
  }

  # Add a service_account block
  /* service_account {
    email  = "terraform@projectadms.iam.gserviceaccount.com"
    scopes = ["cloud platform"]
  }*/

  #sudo apt-get install -y openssh-client
  #funciona como servidor?
  metadata_startup_script = file("scripts/scriptRDB.sh")

}