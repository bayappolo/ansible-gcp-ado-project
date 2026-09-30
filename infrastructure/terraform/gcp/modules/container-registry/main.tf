# Container Registry Module for RHAA Enterprise Image Storage

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
  region  = var.location
}

# Container Registry for storing RHAA images
resource "google_container_registry" "default" {
  name     = "${var.registry_name}"
  location = var.location
  
  # Storage pool configuration
  storage_pool {
    name      = var.storage_pool[0].name
    locations = var.storage_pool[0].locations
    
    # Replication (optional)
    replication_config {
      automatic = false
      
      replicas {
        location     = var.storage_pool[0].replication_locations[0]
        replica_count = 3
      }
    }
  }
  
  labels = merge(local.common_tags, {
    purpose = "rhaa-enterprise-images"
  })
}

# Artifact Registry (alternative to Container Registry)
resource "google_artifact_registry_repository" "default" {
  count   = var.enable_artifact_registry ? 1 : 0
  
  name     = "${var.registry_name}-artifact"
  location = var.location
  format    = "DOCKER"
  
  description = "RHAA Enterprise Artifact Registry for container images"
  
  labels = merge(local.common_tags, {
    purpose = "rhaa-enterprise-artifacts"
  })
}

output "registry_url" {
  value = "${google_container_registry.default.id}/gcr.io/${var.project_id}"
}
