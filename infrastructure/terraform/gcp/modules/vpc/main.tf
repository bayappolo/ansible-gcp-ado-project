# VPC Module for RHAA Enterprise GCP Infrastructure

terraform {
  required_version = ">= 1.5.0"
  
  required_providers {
    google {
      source = "hashicorp/google"
      
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# VPC Network
resource "google_compute_network" "main" {
  name          = "${var.network_name}"
  auto_create_subnetworks = false
  
  routing_mode = var.routing_mode
  
  # Custom IP range (optional)
  ip_cidr_range = var.ip_cidr_range
}

# Subnets
resource "google_compute_subnetwork" "default" {
  name                          = "${var.network_name}-${var.subnet.name}"
  ip_cidr_range                 = var.subnet.ip_cidr_range
  region                        = var.region
  network                       = google_compute_network.main.self_link
  
  purpose                       = var.subnet.purpose
  private_ip_google_access      = true
  
  log_config {
    enable = true
    sample_rate = 1.0
  }
}

# Firewall Rules
resource "google_compute_firewall" "allow_internal" {
  name    = "${var.network_name}-allow-internal"
  network = google_compute_network.main.self_link
  
  allow {
    protocol = "icmp"
    ports    = ["-1"]
  }
  
  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }
  
  source_ranges = ["10.0.0.0/8", "192.168.0.0/16", "172.16.0.0/12"]
}

resource "google_compute_firewall" "allow_ssh" {
  count   = var.firewall_rules.length > 0 ? 1 : 0
  
  name    = "${var.network_name}-allow-ssh"
  network = google_compute_network.main.self_link
  
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  
  source_ranges = [var.ssh_ip_ranges]
}

# Network Policy (using CNI)
resource "google_compute_network_peering" "default" {
  count   = var.enable_peering ? 1 : 0
  
  name                          = "${var.network_name}-peering"
  network                       = google_compute_network.main.self_link
  peer_network                  = var.peer_network
  peer_project                  = var.peer_project
}

output "network_self_link" {
  value = google_compute_network.main.id
}

output "subnet_self_link" {
  value = google_compute_subnetwork.default.id
}
