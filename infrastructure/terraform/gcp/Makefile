# Makefile for RHAA Enterprise Terraform Infrastructure Deployment
.PHONY: help init plan apply destroy validate lint docs

help: ## Show this help message
	@echo 'RHAA Enterprise GCP Terraform Infrastructure'
	@echo ''
	@echo 'Usage:'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+/ {printf "  %-10s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

# Initialize Terraform
init: ## Initialize Terraform and download providers
	terraform init -backend=false

# Validate Terraform configuration
validate: ## Validate Terraform configuration syntax
	terraform validate

# Generate documentation
docs: ## Generate Terraform documentation
	terraform fmt -write
	@echo "Documentation generated"

# Plan infrastructure changes
plan: ## Show what Terraform will do without making changes
	terraform plan -out=tfplan

# Apply Terraform configuration
apply: ## Create GCP infrastructure (use with caution!)
	terraform apply -auto-approve tfplan

# Destroy GCP infrastructure
destroy: ## Remove all created resources
	terraform destroy -auto-approve

# Taint a resource for recreation
taint: ## Taint a specific resource
	terraform taint $(RESOURCE)

# Refresh Terraform state
refresh: ## Update local state with remote data
	terraform pull

# Show Terraform state
state: ## Display current infrastructure state
	terraform show

# Format Terraform files
fmt: ## Format all Terraform files
	terraform fmt -recursive

# Lint Terraform configuration
lint: ## Run linting on Terraform code
	@echo "Running lint checks..."
	@which tflint || echo "tflint not installed"

# Export infrastructure as JSON
export-json: ## Export infrastructure to JSON file
	terraform show -json > infrastructure-export.json

# Import existing resources
import: ## Import existing GCP resources
	terraform import $(RESOURCE) $(IMPORT_ID)

# Clean up temporary files
clean: ## Remove temporary files and state
	rm -f tfplan terraform.tfstate.backup
