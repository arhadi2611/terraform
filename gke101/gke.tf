# GKE Autopilot Cluster
resource "google_container_cluster" "autopilot" {
  name     = var.cluster_name
  location = var.region

  # Enable Autopilot mode
  enable_autopilot = true

  # Network configuration
  network    = google_compute_network.vpc.id
  subnetwork = google_compute_subnetwork.gke_subnet.id

  # IP allocation policy for pods and services
  ip_allocation_policy {
    cluster_secondary_range_name  = "pods"
    services_secondary_range_name = "services"
  }

  # Private cluster configuration
  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = var.enable_private_endpoint
    master_ipv4_cidr_block  = var.master_cidr
  }

  # Master authorized networks
  master_authorized_networks_config {
    dynamic "cidr_blocks" {
      for_each = var.master_authorized_networks
      content {
        cidr_block   = cidr_blocks.value.cidr_block
        display_name = cidr_blocks.value.display_name
      }
    }
  }

  # Release channel for automatic updates
  release_channel {
    channel = "REGULAR"
  }

  # Maintenance window
  maintenance_policy {
    daily_maintenance_window {
      start_time = "03:00"
    }
  }

  # Workload Identity
  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  # Binary Authorization (disabled by default, can be enabled)
  binary_authorization {
    evaluation_mode = "DISABLED"
  }

  # Logging and monitoring
  logging_config {
    enable_components = ["SYSTEM_COMPONENTS", "WORKLOADS"]
  }

  monitoring_config {
    enable_components = ["SYSTEM_COMPONENTS"]
    managed_prometheus {
      enabled = true
    }
  }

  # Deletion protection
  deletion_protection = false
}
