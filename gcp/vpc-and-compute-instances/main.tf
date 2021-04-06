provider "google" {
  project     = var.gcp_project
  region      = var.region
  zone        = var.zone
}

resource "google_compute_subnetwork" "subnet" {
  name          = "${var.prefix}-subnet"
  ip_cidr_range = var.cidr_block
  network       = google_compute_network.net.id
}

resource "google_compute_network" "net" {
  name                    = "${var.prefix}-net"
  auto_create_subnetworks = false
}

resource "google_compute_firewall" "firewall" {
  name    = "${var.prefix}-firewall"
  network = google_compute_network.net.id

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}

resource "google_compute_network" "default" {
  name = "test-network"
}

resource "google_compute_instance" "vm" {
  count        = var.instance_count
  name         = "${var.prefix}-vm-${count.index}"
  machine_type = var.instance_type

  boot_disk {
    initialize_params {
      image = var.instance_image
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.subnet.id

    access_config {
      // Ephemeral IP
    }
  }

  metadata = {
    ssh-keys = "${var.sshuser}:${file("~/.ssh/id_rsa.pub")}"
  }
}
