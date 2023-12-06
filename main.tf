# Using pd-standard because it's the default for Compute Engine

resource "google_compute_disk" "default" {
  name = "dbs"
  type = "pd-standard"
  zone = "europe-southwest1-c"
  size = "10"
}

resource "google_compute_disk" "default1" {
  name = "dbss"
  type = "pd-standard"
  zone = "europe-southwest1-c"
  size = "10"
}

resource "google_compute_disk" "default2" {
  name = "dbsss"
  type = "pd-standard"
  zone = "europe-southwest1-c"
  size = "10"
}

resource "google_compute_instance" "osd1" {
  name         = var.instance_name
  machine_type = "e2-micro"
  zone         = "europe-southwest1-c"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  attached_disk {
    source      = google_compute_disk.default.id
    device_name = google_compute_disk.default.name
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
    network_ip = "10.204.0.11"
  }

  attached_disk {
    source      = google_compute_disk.default1.id
    device_name = google_compute_disk.default1.name
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
    network_ip = "10.204.0.12"
  }

  attached_disk {
    source      = google_compute_disk.default2.id
    device_name = google_compute_disk.default2.name
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
    network_ip = "10.204.0.15"
  }

  # Add a service_account block
  /* service_account {
    email  = "terraform@projectadms.iam.gserviceaccount.com"
    scopes = ["cloud platform"]
  }*/

  metadata_startup_script = file("scripts/scriptRDB.sh")

}