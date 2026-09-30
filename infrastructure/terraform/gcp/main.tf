# Main Terraform Configuration for RHAA Enterprise on GCP
# Red Hat Ansible Automation Platform Enterprise Edition Deployment
# Environment: Production (with placeholders for credentials)

terraform {
  required_version = ">= 1.5.0"
  
  required_providers {
    google {
      source  = "hashicorp/google"
      version = "~> 5.0"
      
      configuration_blocks {
        auth {
          application_default_credential_credentials_file = var.gcp_credentials_path
        }
      }
    }
    
    google-beta {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

# Provider Configuration
provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
  zone    = var.gcp_zone
  
  # GCP Access Token (placeholder - use Secret Manager in production)
  access_token = var.gcp_access_token
  
  user_project_override = var.user_project_override
}

# Default labels for all resources
locals {
  project_labels = {
    project     = "ansible-gcp-ado-project"
    environment = var.environment
    team        = "rhaa-platform"
    managed_by  = "terraform"
    created_at  = timestamp()
  }
  
  common_tags = merge(local.project_labels, {
    cost_center = var.cost_center
  })
}

# GCP Project Settings
module "project_settings" {
  source = "./modules/project"
  
  project_id         = var.gcp_project_id
  billing_account    = var.billing_account_id
  organization       = var.organization_id
  enable_api_service = true
  
  labels = local.project_labels
}

# VPC Network Configuration
module "vpc_network" {
  source = "./modules/vpc"
  
  project_id   = var.gcp_project_id
  network_name = "ansible-gcp-ado-network"
  region       = var.gcp_region
  
  subnets = [
    {
      name        = "default-subnet"
      region      = var.gcp_region
      ip_cidr_range = var.vpc_subnet_cidr
      purpose      = "compute-regional-default"
    }
  ]
  
  routing_mode = "REGIONAL"
  firewall_rules = [
    {
      name       = "allow-internal-traffic"
      allow      = ["INTERNAL"]
      source_ranges = ["10.0.0.0/8"]
    },
    {
      name       = "allow-rsshell"
      allow      = ["SSH", "RDP"]
      source_ranges = [var.ssh_ip_ranges]
    }
  ]
}

# VPC Service Controls for network isolation
module "vpc_service_controls" {
  source = "./modules/vpc-service-controls"
  
  project_id      = var.gcp_project_id
  network         = module.vpc_network.network_self_link
  region          = var.gcp_region
  
  perimeter = [
    {
      name       = "ansible-gcp-ado-perimeter"
      resource_type = "VPC_NETWORK"
      resource_name = "${module.vpc_network.project_id}/${module.vpc_network.network_name}"
    }
  ]
  
  dependency_protection = {
    enabled = true
  }
}

# GKE Cluster for RHAA Container Deployment
module "gke_cluster" {
  source = "./modules/gke"
  
  project_id       = var.gcp_project_id
  cluster_name     = "rhaa-enterprise-cluster"
  region           = var.gcp_region
  zone             = var.gcp_zone
  
  node_pools = [
    {
      name               = "rhaa-nodes"
      machine_type       = var.node_machine_type
      min_node_count     = var.min_nodes
      max_node_count     = var.max_nodes
      
      autoscaling {
        min_node_count  = var.min_nodes
        max_node_count  = var.max_nodes
      }
      
      managed_auto_provisioning {
        enabled = true
      }
      
      node_config {
        disk_size_gb = var.node_disk_size
        disk_type    = "pd-standard"
        labels       = local.common_tags
        taints       = [
          {
            key    = "workload-type"
            value  = "rhaa-enterprise"
            effect = "NO_SCHEDULE"
          }
        ]
      }
      
      metadata = [
        "enable-gke-nanny-agent=false",
        "gke-default-cgroups-enabled=true"
      ]
    }
  ]
  
  addons_config {
    http_load_balancing     { enabled = true }
    horizontal_pod_autoscaling { enabled = true }
    network_policy_config {
      enabled = true
      provider = "CALICO"
    }
    gcp_filestore_csi_driver_config {
      enabled = true
    }
  }
  
  master_auth {
    client_certificate   = base64encode(file(var.master_client_cert_path))
    client_key           = base64encode(file(var.master_client_key_path))
    cluster_ca_certificate = base64encode(file(var.cluster_ca_cert_path))
    private_key_name     = var.private_key_name
    certificate_authority_certificate = var.certificate_authority_certificate
  }
  
  release_channel = "REGULAR"
  initial_node_count = 1
  
  network            = module.vpc_network.network_self_link
  subnetwork         = module.vpc_network.subnet_self_link
}

# Container Registry for RHAA Images
module "container_registry" {
  source = "./modules/container-registry"
  
  project_id    = var.gcp_project_id
  registry_name = "rhaa-images"
  
  location      = var.gcp_region
  storage_pool  = [
    {
      name     = "default-storage-pool"
      locations = [var.gcp_region]
    }
  ]
}

# Secret Manager for Credential Management
module "secret_manager" {
  source = "./modules/secret-manager"
  
  project_id   = var.gcp_project_id
  secret_names = [
    "rhaa-enterprise-password",
    "rhaa-enterprise-db-password",
    "rhaa-enterprise-ssh-keys",
    "rhaa-enterprise-api-keys",
    "rhaa-enterprise-sso-certs"
  ]
  
  locations = [var.gcp_region]
}

# Cloud Storage for Backups and Artifacts
module "cloud_storage" {
  source = "./modules/cloud-storage"
  
  project_id          = var.gcp_project_id
  bucket_name_prefix  = "rhaa-enterprise-"
  location            = var.gcp_region
  
  versions = true
  uniform_bucket_level_access = true
  
  cors = [
    {
      origin     = ["*"]
      method     = ["GET", "HEAD", "PUT", "POST", "DELETE", "OPTIONS"]
      response_headers = []
      max_age_seconds = 3600
    }
  ]
  
  lifecycle_rules = [
    {
      action = { type = "Delete" }
      condition = { age = 365 }
    }
  ]
}

# Monitoring and Logging
module "monitoring_logging" {
  source = "./modules/monitoring"
  
  project_id   = var.gcp_project_id
  
  dashboards = [
    {
      title       = "RHAA Enterprise Dashboard"
      description = "Main monitoring dashboard for RHAA platform"
      chart_type  = "time_series"
      
      charts = [
        {
          title       = "CPU Usage"
          timeseries_filter = 'resource.type="k8s_container" AND metric.type="container_cpu_usage_seconds_total"'
        },
        {
          title       = "Memory Usage"
          timeseries_filter = 'resource.type="k8s_container" AND metric.type="container_memory_usage_bytes"'
        }
      ]
    }
  ]
  
  alerts = [
    {
      name           = "rhaa-high-cpu-alert"
      condition      = 'metric("container_cpu_usage_seconds_total").value > 90'
      duration       = "5m"
      comparison     = "GAUGE"
      change         = "ABOVE"
      
      notifications = [
        {
          type           = "email"
          destination    = var.notification_email
          send_interval  = "3h"
        }
      ]
    }
  ]
}

# Compute Engine for Ansible Controller (Optional)
module "compute_engine" {
  count = var.enable_compute_engine ? 1 : 0
  
  source = "./modules/compute-engine"
  
  project_id       = var.gcp_project_id
  machine_type     = var.controller_machine_type
  zone             = var.gcp_zone
  
  boot_disk {
    initialize_params {
      image_family = "rhel-9-server-guest-cloud-kernel"
      image_project = "rhel-cloud"
    }
  }
  
  network_interface {
    network = module.vpc_network.network_self_link
    access_config {
      nat_ip = "${module.vpc_network.project_id}-controller-ip"
    }
  }
  
  metadata = {
    startup-script = file("${path.module}/startup.sh")
  }
  
  service_account = var.controller_service_account
  
  tags       = local.common_tags["tags"]
}

# Output Variables
output "project_info" {
  value = {
    project_id      = var.gcp_project_id
    region          = var.gcp_region
    zone            = var.gcp_zone
    cluster_name    = module.gke_cluster.cluster_id
    registry_url    = "${module.container_registry.registry_url}/gcr.io/${var.gcp_project_id}"
  }
}

output "endpoints" {
  value = {
    master_endpoint = module.gke_cluster.master_endpoint
    node_pools      = module.gke_cluster.node_pools
  }
}
