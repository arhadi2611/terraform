# Allow internal communication within VPC
resource "google_compute_firewall" "allow_internal" {
  name    = "${var.network_name}-allow-internal"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "icmp"
  }

  source_ranges = [
    var.subnet_cidr,
    var.pods_cidr,
    var.services_cidr
  ]

  description = "Allow internal communication within VPC"
}

# Allow SSH from IAP (Identity-Aware Proxy)
resource "google_compute_firewall" "allow_iap_ssh" {
  name    = "${var.network_name}-allow-iap-ssh"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  # IAP IP range
  source_ranges = ["35.235.240.0/20"]
  
  description = "Allow SSH via Identity-Aware Proxy"
}

# Allow health checks from GCP load balancers
resource "google_compute_firewall" "allow_health_checks" {
  name    = "${var.network_name}-allow-health-checks"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
  }

  # Health check IP ranges
  source_ranges = [
    "35.191.0.0/16",
    "130.211.0.0/22"
  ]

  description = "Allow health checks from GCP load balancers"
}
