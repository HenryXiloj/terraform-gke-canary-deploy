# Terraform GKE Canary Deployment

A comprehensive Infrastructure as Code (IaC) solution for setting up canary deployments on Google Kubernetes Engine (GKE) using Terraform and Google Cloud Deploy.

📘 Blog Post: [Canary Deployment on GKE with Terraform and Cloud Deploy](https://jarmx.blogspot.com/2024/05/canary-deployment-on-gke-with-terraform.html)

## Overview

This project demonstrates how to deploy applications to a GKE cluster using canary deployment strategies to gradually roll out updates, reducing risk and enabling safer production deployments.

## Architecture

The solution includes:

- **GKE Cluster**: Multi-regional Kubernetes cluster with node pools
- **VPC Network**: Custom network configuration with subnets and firewall rules
- **Service Account**: IAM configuration for secure access
- **Cloud Deploy**: Pipeline for automated canary deployments
- **Skaffold**: Application deployment configuration

## Prerequisites

Before you begin, ensure you have:

- [Terraform](https://www.terraform.io/downloads.html) >= 1.0
- [Google Cloud SDK](https://cloud.google.com/sdk/docs/install) installed and configured
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) for Kubernetes cluster management
- [Skaffold](https://skaffold.dev/docs/install/) for application deployment
- A Google Cloud Project with billing enabled
- Required APIs enabled:
  - Kubernetes Engine API
  - Cloud Deploy API
  - Compute Engine API
  - Service Networking API

## Quick Start

### 1. Configuration Setup

Clone the repository and configure your environment:

```bash
git clone https://github.com/HenryXiloj/terraform-gke-canary-deploy.git
cd terraform-gke-canary-deploy
```

Update `terraform.tfvars` with your project details:

```hcl
project_id = "your-project-id"
region     = "us-central1"
zone       = "us-central1-a"
sec_region = "us-west1"
sec_zone   = "us-west1-a"
```

### 2. Infrastructure Deployment

Initialize and deploy the infrastructure:

```bash
# Initialize Terraform
terraform init

# Validate configuration
terraform validate

# Plan the deployment
terraform plan

# Apply the configuration
terraform apply -auto-approve
```

### 3. Application Deployment

Configure your application for deployment:

```bash
# Register the Cloud Deploy pipeline
gcloud deploy apply --file=clouddeploy.yaml --region=us-central1 --project=YOUR_PROJECT_ID

# Create the first release (skips canary phase)
gcloud deploy releases create test-release-001 \
  --project=YOUR_PROJECT_ID \
  --region=us-central1 \
  --delivery-pipeline=my-canary-demo-app-1 \
  --images=my-app-image=gcr.io/google-containers/nginx@sha256:f49a843c290594dcf4d193535d1f4ba8af7d56cea2cf79d1e9554f077f1e7aaa
```

## Project Structure

```
terraform-gke-canary-deploy/
├── provider.tf          # Terraform provider configuration
├── variables.tf         # Input variables
├── terraform.tfvars     # Variable values
├── serviceaccount.tf    # Service account configuration
├── network.tf           # VPC and networking setup
├── iam.tf              # IAM roles and permissions
├── main.tf             # GKE cluster configuration
├── skaffold.yaml       # Skaffold configuration
├── kubernetes.yaml     # Kubernetes manifests
├── clouddeploy.yaml    # Cloud Deploy pipeline
└── README.md           # This file
```

## Infrastructure Components

### Network Configuration

- **VPC Network**: Custom network with MTU 1460
- **Subnets**: 
  - Primary: `10.10.1.0/24` (us-central1)
  - Secondary: `10.10.2.0/24` (europe-west2)
- **Firewall Rules**: SSH, internal communication, and IAP access
- **NAT Gateway**: For private subnet internet access

### GKE Cluster

- **Cluster**: Regional cluster with shielded nodes
- **Node Pool**: Preemptible e2-medium instances
- **Service Account**: Custom service account with minimal required permissions

### Security

- **IAM Roles**:
  - `roles/iam.serviceAccountTokenCreator`
  - `roles/clouddeploy.jobRunner`
  - `roles/container.developer`

## Canary Deployment Strategy

The canary deployment pipeline is configured to:

1. **First Release**: Skips canary phase and deploys to 100%
2. **Subsequent Releases**: Executes canary deployment at 50% traffic
3. **Manual Promotion**: Requires manual approval to advance phases

### Pipeline Configuration

The `clouddeploy.yaml` defines:

- **Canary Strategy**: 50% traffic split
- **Target**: Production GKE cluster
- **Service Networking**: Routes traffic based on service configuration

## Monitoring and Management

Monitor your deployments through:

- **Google Cloud Console**: Cloud Deploy > Delivery pipelines
- **kubectl**: Direct cluster management
- **Cloud Logging**: Deployment logs and metrics

## Usage Examples

### Creating a New Release

```bash
gcloud deploy releases create test-release-002 \
  --project=YOUR_PROJECT_ID \
  --region=us-central1 \
  --delivery-pipeline=my-canary-demo-app-1 \
  --images=my-app-image=gcr.io/google-containers/nginx@sha256:f49a843c290594dcf4d193535d1f4ba8af7d56cea2cf79d1e9554f077f1e7aaa
```

### Advancing Rollout Phases

1. Navigate to Cloud Deploy in the Google Cloud Console
2. Select your pipeline
3. Click "Advance Rollout" when ready
4. Confirm the advancement

## Customization

### Variables

Key variables you can customize:

| Variable | Description | Default |
|----------|-------------|---------|
| `project_id` | Google Cloud Project ID | `""` |
| `region` | Primary region | `""` |
| `zone` | Primary zone | `""` |
| `sec_region` | Secondary region | `""` |
| `sec_zone` | Secondary zone | `""` |

### Canary Configuration

Modify the canary deployment in `clouddeploy.yaml`:

```yaml
canaryDeployment:
  percentages: [25, 50, 75]  # Custom traffic percentages
  verify: true               # Enable verification
```

## Troubleshooting

Common issues and solutions:

### Authentication Issues
```bash
gcloud auth application-default login
```

### Terraform State Issues
```bash
terraform refresh
terraform plan
```

### Cluster Access
```bash
gcloud container clusters get-credentials canary-quickstart-cluster --region us-central1
```

## Clean Up

To destroy the infrastructure:

```bash
terraform destroy -auto-approve
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## References

- [Cloud Deploy Canary Deployments](https://cloud.google.com/deploy/docs/deploy-app-canary#gke_4)
- [Config Connector Installation](https://cloud.google.com/config-connector/docs/how-to/install-upgrade-uninstall)
- [Terraform Google Provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs)

---

**Note**: Remember to update the `YOUR_PROJECT_ID` placeholder with your actual Google Cloud Project ID in all commands and configuration files.
