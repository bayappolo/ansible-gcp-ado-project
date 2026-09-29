# Ansible Automation Platform Enterprise on GCP

## Project Overview

Enterprise-grade deployment of **Red Hat Ansible Automation Platform (RHAA)** on Google Cloud Platform using Azure DevOps Pipelines for CI/CD.

### Architecture

```
┌─────────────────┐     ┌──────────────────┐     ┌─────────────────┐
│   GitHub Repo   │────>│  Azure ADO CI/CD │────>│    GCP         │
│  (Code & Tests) │     │   Pipeline       │     │   Compute      │
└─────────────────┘     └──────────────────┘     │ Engine + RHEL9 │
                                                 └─────────────────┘
```

## Enterprise Edition Features

- ✅ **Red Hat Certified Support** - Full Red Hat support contract
- ✅ **Enterprise Licensing** - Subscription-based access
- ✅ **Advanced Security** - SOC 2 Type II compliance
- ✅ **Entra ID SSO** - Azure AD integration for single sign-on
- ✅ **RBAC Management** - Role-based access control with custom roles
- ✅ **Audit Logging** - Comprehensive activity tracking

## Technology Stack

| Component | Version/Type | Notes |
|-----------|--------------|-------|
| **RHEL** | 9.4 (Latest) | Latest minor version |
| **RHAA** | Enterprise Edition | Not community edition |
| **Container Runtime** | Podman/Docker | Containerized deployment |
| **GCP Platform** | Compute Engine | RHEL 9 VMs |
| **SSO** | Entra ID (Azure AD) | SAML 2.0 + OAuth2/OIDC |

## Project Structure

```
ansible-gcp-ado-project/
├── .github/workflows/     # GitHub Actions for optional CI
├── .vscode/               # VS Code configuration
├── research/              # Research findings and documentation
│   ├── log.md            # Research session log
│   └── [topic].md        # Specific research topics
├── code/                  # Ansible playbooks and automation
├── tests/                 # Test suites and validation scripts
├── docs/                  # Project documentation
├── scripts/               # Utility scripts
├── .azure-pipelines.yml   # Azure DevOps pipeline definition
└── README.md             # This file
```

## Development Workflow

### Phase 1: Research
- Team researches RHAA Enterprise deployment options
- Documents RHEL 9 compatibility
- Investigates Entra ID integration patterns
- Reviews GCP infrastructure requirements

### Phase 2: Development
- Code written in `code/` directory
- Regular commits to GitHub
- Pull requests for code review

### Phase 3: Testing
- Unit tests and integration tests
- Security scanning
- Performance validation

### Phase 4: Deployment
- CI/CD pipeline deploys to GCP
- Automated configuration management
- Health checks and monitoring setup

### Phase 5: Review
- Manual validation of SSO integration
- Permission matrix verification
- Security policy compliance check

## Getting Started

1. **Open in VS Code**: The repository is already open in Visual Studio Code
2. **Review Research**: Check `research/` folder for team findings
3. **Read Documentation**: See `docs/` for detailed guides
4. **Clone & Sync**: Keep your local copy synchronized with GitHub

## Security Considerations

- **Entra ID SSO**: Enterprise SSO with Azure AD integration
- **RBAC**: Role-based permissions with audit logging
- **Network**: VPC isolation with firewall rules
- **Secrets**: GCP Secret Manager for credential management
- **Compliance**: SOC 2 Type II ready configuration

## License

Red Hat Ansible Automation Platform Enterprise - See LICENSE file for subscription details.

---

*Project maintained by Appolo Bay | Enterprise Edition Only*
