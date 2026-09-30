# Terraform Variables for RHAA Enterprise GCP Infrastructure
# All variables are documented with descriptions and defaults

variable "gcp_project_id" {
  description = "GCP Project ID for deployment"
  type        = string
  default     = "ansible-gcp-ado-project"
}

variable "gcp_region" {
  description = "GCP Region for resource deployment"
  type        = string
  default     = "australia-southeast1"  # Sydney region
}

variable "gcp_zone" {
  description = "GCP Zone for zone-specific resources"
  type        = string
  default     = "australia-southeast1-a"
}

variable "environment" {
  description = "Environment name (dev, staging, production)"
  type        = string
  default     = "production"
}

variable "gcp_credentials_path" {
  description = "Path to GCP credentials JSON file"
  type        = string
  default     = "~/.config/gcloud/application_default_credentials.json"
}

variable "billing_account_id" {
  description = "GCP Billing Account ID"
  type        = string
  default     = ""
}

variable "organization_id" {
  description = "GCP Organization ID (if part of org)"
  type        = string
  default     = ""
}

variable "user_project_override" {
  description = "Use user project override (for billing purposes)"
  type        = bool
  default     = false
}

variable "cost_center" {
  description = "Cost center code for billing"
  type        = string
  default     = "RHAA-ENTERPRISE"
}

variable "vpc_subnet_cidr" {
  description = "CIDR block for VPC subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "ssh_ip_ranges" {
  description = "IP ranges allowed SSH access (comma-separated)"
  type        = string
  default     = "0.0.0.0/0"
}

variable "node_machine_type" {
  description = "Machine type for GKE nodes"
  type        = string
  default     = "e2-standard-4"
}

variable "min_nodes" {
  description = "Minimum number of nodes in cluster"
  type        = number
  default     = 3
}

variable "max_nodes" {
  description = "Maximum number of nodes in cluster"
  type        = number
  default     = 10
}

variable "node_disk_size" {
  description = "Disk size for GKE nodes in GB"
  type        = number
  default     = 100
}

variable "master_client_cert_path" {
  description = "Path to master client certificate"
  type        = string
  default     = ""
}

variable "master_client_key_path" {
  description = "Path to master client key"
  type        = string
  default     = ""
}

variable "cluster_ca_cert_path" {
  description = "Path to cluster CA certificate"
  type        = string
  default     = ""
}

variable "private_key_name" {
  description = "Name of private key in GCP KMS"
  type        = string
  default     = "rhaa-enterprise-private-key"
}

variable "certificate_authority_certificate" {
  description = "Certificate authority certificate for master auth"
  type        = string
  default     = ""
}

variable "notification_email" {
  description = "Email for monitoring alerts"
  type        = string
  default     = ""
}

variable "enable_compute_engine" {
  description = "Enable Compute Engine instance for Ansible Controller"
  type        = bool
  default     = false
}

variable "controller_machine_type" {
  description = "Machine type for controller VM"
  type        = string
  default     = "e2-standard-8"
}

variable "controller_service_account" {
  description = "Service account for controller VM"
  type        = string
  default     = ""
}

variable "enable_vpc_service_controls" {
  description = "Enable VPC Service Controls for network isolation"
  type        = bool
  default     = true
}

variable "enable_monitoring" {
  description = "Enable Cloud Monitoring and Logging"
  type        = bool
  default     = true
}

variable "enable_backup" {
  description = "Enable automated backups to Cloud Storage"
  type        = bool
  default     = true
}

variable "backup_retention_days" {
  description = "Number of days to retain backups"
  type        = number
  default     = 30
}

variable "enable_sso_integration" {
  description = "Enable Entra ID SSO integration"
  type        = bool
  default     = true
}

variable "sso_client_id" {
  description = "Entra ID application client ID"
  type        = string
  default     = ""
}

variable "sso_client_secret" {
  description = "Entra ID application client secret (use Secret Manager)"
  type        = string
  sensitive   = true
  default     = ""
}

variable "enable_rbac" {
  description = "Enable RBAC permissions"
  type        = bool
  default     = true
}
