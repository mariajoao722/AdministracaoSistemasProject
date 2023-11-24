resource "google_compute_instance" "osd1" {
  name         = var.instance_name
  machine_type = "e2-micro"
  zone         = "europe-southwest1-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network = "default"
  }

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

  metadata_startup_script = <<-SCRIPT
    #!/bin/bash
    sudo apt-get update
    sudo-apt-get install -y ceph
  SCRIPT
}

resource "google_compute_instance" "osd2" {
  name         = var.instance_name2
  machine_type = "e2-micro"
  zone         = "europe-southwest1-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network = "default"
  }
   # Provisioner for Ceph OSD configuration
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y ceph",
      "sudo mkdir /var/local/osd-data",
      # Replace /dev/sdb with the actual disk you want to use for OSD
      "sudo ceph-deploy osd create --data /dev/sdb ceph-node-1",
      # Additional OSD configuration commands
    ]
  }
}

resource "google_compute_instance" "mon" {
  name         = var.instance_name3
  machine_type = "e2-micro"
  zone         = "europe-southwest1-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network = "default"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y ceph",
      # Initialize the Ceph MON (replace `ceph-node-3` with your node name)
      "sudo ceph-deploy mon create-initial",
      # Additional MON configuration commands
    ]
  }
}

resource "google_compute_instance" "mjr" {
  name         = var.instance_name4
  machine_type = "e2-micro"
  zone         = "europe-southwest1-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network = "default"
  }
   # Provisioner for Ceph OSD configuration
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y ceph",
      # Initialize the Ceph MGR (replace `ceph-node-4` with your node name)
      "sudo ceph-deploy mgr create ceph-node-4",
      # Additional MGR configuration commands
    ]
  }
}

resource "google_compute_instance" "backup" {
  name         = var.instance_name5
  machine_type = "e2-micro"
  zone         = "europe-southwest1-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network = "default"
  }
}

resource "google_compute_instance" "rdb" {
  name         = var.instance_name6
  machine_type = "e2-micro"
  zone         = "europe-southwest1-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network = "default"
  }
}