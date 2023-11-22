resource "google_compute_instance" "webserver" {
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
}

resource "google_compute_instance" "webserver2" {
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
}