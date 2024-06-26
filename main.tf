# https://cloud.google.com/compute/docs/disks/add-persistent-disk?hl=pt-br#terraform

# Using pd-standard because it's the default for Compute Engine
# create new disk for some VM's
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

/*
# For postgresql
resource "google_sql_database_instance" "postgresql-terraform" {
  name             = "postgresql-terraform"
  region           = "europe-southwest1"
  database_version = "POSTGRES_14"
  settings {
    tier = "db-f1-micro"

    ip_configuration {
      ipv4_enabled = true

      authorized_networks {
        name  = "my-network"
        value = "10.204.0.20/32"
      }
    }
  }
  # so we can do terrafrom destroy
  deletion_protection  = "false"
}

resource "google_sql_database" "database-tf" {
  name     = "database-tf"
  instance = google_sql_database_instance.postgresql-terraform.name
}


resource "google_sql_user" "myuser" {
  name     = "adm-sistemas"
  instance = google_sql_database_instance.postgresql-terraform.name
  password = "password"
}
*/

# create VM's

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

  metadata_startup_script = file("scripts/scriptBackup.sh")
}
