output "project_id" {
  description = "GCP Project ID"
  value       = var.project_id
}

output "region" {
  description = "GCP Region"
  value       = var.region
}

# VPC Outputs
output "vpc_name" {
  description = "VPC Network Name"
  value       = google_compute_network.vpc.name
}

output "vpc_id" {
  description = "VPC Network ID"
  value       = google_compute_network.vpc.id
}

output "subnet_name" {
  description = "Subnet Name"
  value       = google_compute_subnetwork.gke_subnet.name
}

output "subnet_cidr" {
  description = "Subnet CIDR Range"
  value       = google_compute_subnetwork.gke_subnet.ip_cidr_range
}

# GKE Outputs
output "cluster_name" {
  description = "GKE Cluster Name"
  value       = google_container_cluster.autopilot.name
}

output "cluster_id" {
  description = "GKE Cluster ID"
  value       = google_container_cluster.autopilot.id
}

output "cluster_endpoint" {
  description = "GKE Cluster Endpoint"
  value       = google_container_cluster.autopilot.endpoint
  sensitive   = true
}

output "cluster_ca_certificate" {
  description = "GKE Cluster CA Certificate"
  value       = google_container_cluster.autopilot.master_auth[0].cluster_ca_certificate
  sensitive   = true
}

output "cluster_location" {
  description = "GKE Cluster Location"
  value       = google_container_cluster.autopilot.location
}

# Connectivity Outputs
output "nat_ip_addresses" {
  description = "NAT IP addresses for egress traffic"
  value       = google_compute_router_nat.nat.nat_ip_allocate_option
}

output "get_credentials_command" {
  description = "Command to get cluster credentials"
  value       = "gcloud container clusters get-credentials ${google_container_cluster.autopilot.name} --region ${var.region} --project ${var.project_id}"
}
