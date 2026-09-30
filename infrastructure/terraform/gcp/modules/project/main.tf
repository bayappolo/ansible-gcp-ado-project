# GCP Project Module for RHAA Enterprise Deployment

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
}

# Project Settings (placeholder - GCP projects created via console)
resource "null_resource" "project_metadata" {
  triggers = {
    project_id = var.project_id
    environment = var.environment
  }
  
  provisioner "local-exec" {
    command = <<EOT
echo "Project: ${var.project_id}" | tee -a /tmp/rhaa-project-logs.txt
echo "Environment: ${var.environment}" >> /tmp/rhaa-project-logs.txt
EOT
  }
}

# Enable required APIs
resource "google_project_service" "anthos_gke" {
  count   = var.enable_api_service ? 1 : 0
  
  project = var.project_id
  service = "anthos-gke.googleapis.com"
}

resource "google_project_service" "container" {
  project = var.project_id
  service = "container.googleapis.com"
}

resource "google_project_service" "compute" {
  project = var.project_id
  service = "compute.googleapis.com"
}

resource "google_project_service" "secretmanager" {
  project = var.project_id
  service = "secretmanager.googleapis.com"
}

resource "google_project_service" "monitoring" {
  project = var.project_id
  service = "monitoring.googleapis.com"
}

resource "google_project_service" "logging" {
  project = var.project_id
  service = "logging.googleapis.com"
}

resource "google_project_service" "containerregistry" {
  project = var.project_id
  service = "containerregistry.googleapis.com"
}

resource "google_project_service" "servicecontrol" {
  project = var.project_id
  service = "servicecontrol.googleapis.com"
}

resource "google_project_service" "vpcaccess" {
  project = var.project_id
  service = "vpcaccess.googleapis.com"
}

output "project_id" {
  value = var.project_id
}
