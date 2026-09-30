# VPC Service Controls Module for RHAA Enterprise Network Isolation

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

# VPC Service Perimeter for RHAA Enterprise
resource "google_vpc_service_perimeter" "default" {
  name        = "${var.name}"
  network     = var.network
  
  # DLP-based perimeter (most secure)
  perimeter_dlp_config {
    allow_listed_findings = false
    deny_listed_findings  = true
    
    data_loss_prevention_settings {
      allowed_resources {
        resource_type = "VPC_NETWORK"
        resource_name = "${var.project_id}/${var.network}"
      }
      
      allowed_destinations {
        resource_type = "VPC_NETWORK"
        resource_name = "${var.peer_project_id}/${var.peer_network}"
      }
    }
  }
  
  # Dependency protection
  dependency_protection_config {
    enabled = var.dependency_protection.enabled
    
    allow_listed_findings = false
    deny_listed_findings  = true
  }
}

# Endpoint service for VPC Service Controls
resource "google_vpc_service_perimeter_endpoint_service" "default" {
  count   = var.enable_endpoint_service ? 1 : 0
  
  name        = "${var.name}-endpoint-${count.index}"
  network     = var.network
  
  endpoint_config {
    allow_listed_findings = false
    deny_listed_findings  = true
  }
}

# Private Service Access for GKE
resource "google_compute_network_peering" "default" {
  count   = var.enable_private_service_access ? 1 : 0
  
  name                          = "${var.name}-peering-${count.index}"
  network                       = var.network
  peer_network                  = var.peer_network
  peer_project                  = var.peer_project
}

output "perimeter_id" {
  value = google_vpc_service_perimeter.default.id
}
