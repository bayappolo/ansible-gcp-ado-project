# Compute Engine Module for RHAA Enterprise Controller VM

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
  zone    = var.zone
}

# Compute Engine VM for Ansible Controller
resource "google_compute_instance" "controller" {
  count   = var.count
  
  name         = "${var.name_prefix}${count.index}"
  machine_type = var.machine_type
  
  boot_disk {
    initialize_params {
      image_family            = "rhel-9-server-guest-cloud-kernel"
      image_project           = "rhel-cloud"
      disk_size_gb            = var.boot_disk_size
      disk_type               = var.boot_disk_type
      
      labels = merge(local.common_tags, {
        purpose = "rhaa-controller"
      })
    }
  }
  
  network_interface {
    network           = var.network
    subnetwork        = var.subnetwork
    access_config {
      nat_ip = var.nat_ip[count.index]
    }
    
    # Metadata for startup script
    metadata = {
      startup-script = file(var.startup_script_path)
    }
  }
  
  service_account {
    scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
      "https://www.googleapis.com/auth/devstorage.read_only"
    ]
  }
  
  # Tags for firewall rules
  tags = var.tags
  
  # Metadata
  metadata = {
    startup-script = file(var.startup_script_path)
  }
}

# Static IP for controller VM
resource "google_compute_address" "controller_ip" {
  count   = var.count
  
  name         = "${var.name_prefix}-ip-${count.index}"
  address_type = "EXTERNAL"
  
  labels = merge(local.common_tags, {
    purpose = "rhaa-controller-ip"
  })
}

# Firewall rule for controller access
resource "google_compute_firewall" "allow_controller" {
  count   = var.count
  
  name    = "${var.name_prefix}-allow-controller-${count.index}"
  network = var.network
  
  allow {
    protocol = "tcp"
    ports    = ["22", "8080", "8443"]
  }
  
  source_ranges = var.source_ranges
  
  target_tags   = var.tags
  
  description = "Allow access to RHAA Controller VM"
}

output "instance_id" {
  value = google_compute_instance.controller[0].id
}

output "instance_name" {
  value = google_compute_instance.controller[0].name
}
