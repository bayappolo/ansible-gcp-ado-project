# Cloud Storage Module for RHAA Enterprise Backups and Artifacts

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

# Cloud Storage Buckets for RHAA Enterprise
resource "google_storage_bucket" "backups" {
  name          = "${var.bucket_name_prefix}${random_string.bucket_suffix.id}"
  location      = var.location
  
  # Versioning
  versioning {
    enabled = var.versions
  }
  
  # Uniform bucket-level access
  uniform_bucket_level_access = true
  
  # Public access prevention
  public_access_prevention = "enforced"
  
  # CORS configuration
  cors {
    origin     = var.cors[0].origin
    method     = var.cors[0].method
    response_headers = var.cors[0].response_headers
    max_age_seconds = var.cors[0].max_age_seconds
  }
  
  # Lifecycle rules
  lifecycle_rule {
    action {
      type = var.lifecycle_rules[0].action.type
    }
    
    condition {
      age   = var.lifecycle_rules[0].condition.age
    }
  }
  
  # Labels
  labels = merge(local.common_tags, {
    bucket_type = "backups"
  })
}

# Artifact Storage for CI/CD outputs
resource "google_storage_bucket" "artifacts" {
  count   = var.enable_artifact_storage ? 1 : 0
  
  name          = "${var.bucket_name_prefix}artifacts-${random_string.artifact_suffix.id}"
  location      = var.location
  
  versioning {
    enabled = true
  }
  
  uniform_bucket_level_access = true
  
  public_access_prevention = "enforced"
  
  labels = merge(local.common_tags, {
    bucket_type = "artifacts"
  })
}

# Logging bucket
resource "google_storage_bucket" "logging" {
  count   = var.enable_logging ? 1 : 0
  
  name          = "${var.bucket_name_prefix}logs-${random_string.log_suffix.id}"
  location      = var.location
  
  versioning {
    enabled = true
  }
  
  uniform_bucket_level_access = true
  
  public_access_prevention = "enforced"
  
  labels = merge(local.common_tags, {
    bucket_type = "logging"
  })
}

# Private CA for signing certificates (for internal use)
resource "google_storage_bucket" "ca" {
  count   = var.enable_private_ca ? 1 : 0
  
  name          = "${var.bucket_name_prefix}private-ca-${random_string.ca_suffix.id}"
  location      = var.location
  
  versioning {
    enabled = true
  }
  
  uniform_bucket_level_access = true
  
  public_access_prevention = "enforced"
  
  labels = merge(local.common_tags, {
    bucket_type = "private-ca"
  })
}

output "backup_bucket_name" {
  value = google_storage_bucket.backups.name
}

output "artifact_bucket_name" {
  value = length(google_storage_bucket.artifacts) > 0 ? google_storage_bucket.artifacts[0].name : null
}
