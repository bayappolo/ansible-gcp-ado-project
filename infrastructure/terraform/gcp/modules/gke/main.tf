# GKE Cluster Module for RHAA Enterprise Container Deployment

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

# GKE Cluster for RHAA Enterprise
resource "google_container_cluster" "primary" {
  name     = "${var.cluster_name}"
  location = "${var.region}-${var.zone}"
  
  initial_node_count = var.initial_node_count
  
  # Network and Subnetwork
  network    = var.network
  subnetwork = var.subnetwork
  
  # IP Range for GKE pods
  ip_allocation_policy {
    cluster_secondary_range_name  = "pods"
    services_secondary_range_name = "services"
  }
  
  # Release channel
  release_channel {
    channel = var.release_channel
  }
  
  # Master Auth (placeholder - use Secret Manager in production)
  master_auth {
    cluster_ca_certificate = base64encode(file(var.cluster_ca_cert_path))
    
    client_certificate = var.master_auth_client_certificate != null ? file(var.master_auth_client_certificate) : null
    client_key         = var.master_auth_client_key != null ? file(var.master_auth_client_key) : null
    
    # Custom credentials (placeholder)
    password           = var.master_auth_password
  }
  
  # Workload Identity
  workload_identity_config {
    enabled = true
  }
  
  # Private cluster (optional)
  private_cluster_config {
    enable_private_nodes    = var.enable_private_cluster
    enable_private_endpoint = var.enable_private_cluster
    master_ipv4_cidr_block  = "172.16.0.0/28"
  }
}

# Node Pools
dynamic "node_pool" {
  for_each = var.node_pools
  
  content {
    name               = node_pool.value.name
    location           = "${var.region}-${var.zone}"
    machine_type       = node_pool.value.machine_type
    min_node_count     = node_pool.value.min_node_count
    max_node_count     = node_pool.value.max_node_count
    
    # Autoscaling configuration
    autoscaling {
      min_node_count  = node_pool.value.autoscaling.min_node_count
      max_node_count  = node_pool.value.autoscaling.max_node_count
    }
    
    # Managed auto-provisioning
    managed_auto_provisioning {
      enabled = node_pool.value.managed_auto_provisioning.enabled
    }
    
    # Node config
    node_config {
      labels       = merge(node_pool.value.labels, local.common_tags)
      metadata     = node_pool.value.metadata
      taints       = node_pool.value.taints
      
      # Boot disk
      boot_disk {
        initialize_params {
          image_family            = "rhel-9-server-guest-cloud-kernel"
          image_project           = "rhel-cloud"
          disk_size_gb            = node_pool.value.node_config.disk_size_gb
          disk_type               = node_pool.value.node_config.disk_type
        }
      }
      
      # Additional disks (persistent storage)
      dynamic "disk" {
        for_each = node_pool.value.additional_disks
        content {
          disk_size_gb  = disk.value.disk_size_gb
          disk_type     = disk.value.disk_type
          auto_delete   = true
          boot          = false
        }
      }
      
      # Metadata
      metadata = merge(node_pool.value.metadata, {
        "enable-gke-nanny-agent" = "false"
        "gke-default-cgroups-enabled" = "true"
      })
      
      # Shielded instance config
      shielded_instance_config {
        enable_secure_boot          = true
        enable_integrity_monitoring = true
      }
    }
    
    # Binary authorization (security)
    binary_authorization {
      evaluation_mode = node_pool.value.binary_authorization.evaluation_mode
    }
  }
}

# Ingress Gateway for external access
resource "google_container_cluster" "ingress" {
  count   = var.enable_ingress_gateway ? 1 : 0
  
  name     = "${var.cluster_name}-ingress"
  location = "${var.region}"
  
  initial_node_count = 1
  
  network    = var.network
  subnetwork = var.subnetwork
  
  ip_allocation_policy {
    cluster_secondary_range_name  = "pods-ingress"
    services_secondary_range_name = "services-ingress"
  }
}

output "cluster_id" {
  value = google_container_cluster.primary.id
}

output "master_endpoint" {
  value = google_container_cluster.primary.master_endpoint
}

output "node_pools" {
  value = google_container_cluster.primary.node_pools
}
