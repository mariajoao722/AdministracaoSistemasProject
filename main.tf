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
    # Assign a static internal IP address
    network_ip = "10.204.0.10"

  }

  # Add a service_account block
  /* service_account {
    email  = "terraform@projectadms.iam.gserviceaccount.com"
    scopes = ["cloud platform"]
  }*/
  metadata_startup_script = file("scripts/scriptOSD1.sh")
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
    # Assign a static internal IP address
    network_ip = "10.204.0.11"
  }

  # Add a service_account block
  /* service_account {
    email  = "terraform@projectadms.iam.gserviceaccount.com"
    scopes = ["cloud platform"]
  }*/

  metadata_startup_script = file("scripts/scriptOSD2.sh")
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
    # Assign a static internal IP address
    network_ip = "10.204.0.12"
  }

  # Add a service_account block
  /* service_account {
    email  = "terraform@projectadms.iam.gserviceaccount.com"
    scopes = ["cloud platform"]
  }*/

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
    # Assign a static internal IP address
    network_ip = "10.204.0.13"
  }

  /* service_account {
    email  = "terraform@projectadms.iam.gserviceaccount.com"
    scopes = ["cloud platform"]
  }*/
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
    # Assign a static internal IP address
    network_ip = "10.204.0.14"
  }

  # Add a service_account block
  /* service_account {
    email  = "terraform@projectadms.iam.gserviceaccount.com"
    scopes = ["cloud platform"]
  }*/

  metadata_startup_script = file("scripts/scriptBackup.sh")
}

resource "google_compute_instance" "rdb" { # cliente
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
    # Assign a static internal IP address
    network_ip = "10.204.0.15"
  }

  # Add a service_account block
  /* service_account {
    email  = "terraform@projectadms.iam.gserviceaccount.com"
    scopes = ["cloud platform"]
  }*/

  metadata_startup_script = file("scripts/scriptRDB.sh")

}