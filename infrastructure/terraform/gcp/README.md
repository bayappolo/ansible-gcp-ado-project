# RHAA Enterprise GCP Infrastructure - Terraform Configuration

## 🏗️ Overview

This Terraform configuration deploys Red Hat Ansible Automation Platform (RHAA) Enterprise Edition infrastructure on Google Cloud Platform (GCP).

### Architecture Components

- **GKE Cluster**: Containerized RHAA deployment using Universal Base Images (UBI)
- **VPC Network**: Isolated network with VPC Service Controls
- **Secret Manager**: Secure credential management
- **Cloud Storage**: Backups, artifacts, and logging
- **Monitoring**: Cloud Monitoring and Logging integration
- **Container Registry**: Image storage for RHAA components

## 📋 Prerequisites

- Terraform 1.5+
- Google Cloud SDK (gcloud)
- GCP credentials with project access
- Billing account enabled

## 🚀 Quick Start

```bash
# Navigate to infrastructure directory
cd /Users/appolobay/.openclaw/workspace/ansible-gcp-ado-project/infrastructure/terraform/gcp

# Initialize Terraform
make init

# Validate configuration
make validate

# Plan changes (review before applying)
make plan

# Apply infrastructure (USE WITH CAUTION!)
make apply

# Destroy infrastructure when done
make destroy
```

## 📁 Directory Structure

```
gcp/
├── main.tf                    # Main Terraform configuration
├── variables.tf               # Variable definitions
├── providers.tf               # Provider configurations
├── Makefile                   # Automation scripts
├── README.md                  # This file
└── modules/
    ├── project/               # GCP project settings
    ├── vpc/                  # VPC network configuration
    ├── gke/                  # GKE cluster deployment
    ├── secret-manager/       # Secret management
    ├── container-registry/   # Container image storage
    ├── cloud-storage/        # Cloud Storage buckets
    ├── monitoring/           # Monitoring and alerts
    └── compute-engine/       # Compute Engine VMs
```

## 🔐 Security Notes

**IMPORTANT**: This configuration uses placeholder credentials. For production:

1. Use GCP Secret Manager for all secrets
2. Enable VPC Service Controls
3. Configure IAM roles properly
4. Enable encryption at rest and in transit
5. Set up network policies

## 📊 Monitoring

The configuration includes:
- CPU and memory monitoring
- Alerting policies
- Uptime checks
- Log aggregation

## 🧪 Testing

```bash
# Run Terraform validation
terraform validate

# Format code
terraform fmt

# Generate plan
terraform plan -out=tfplan

# Review plan
terraform show tfplan
```

## 📚 Next Steps

1. Set up GCP project and billing
2. Configure IAM roles
3. Create secrets in Secret Manager
4. Deploy infrastructure with `make apply`
5. Deploy RHAA containers using Ansible playbooks

## ⚠️ Disclaimer

**DO NOT DEPLOY TO PRODUCTION WITHOUT REVIEW**

This configuration is a starting point. Review and customize:
- Network topology
- IAM policies
- Security settings
- Backup strategies
- Monitoring alerts
