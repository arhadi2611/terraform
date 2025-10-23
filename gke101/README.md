# GKE Autopilot Cluster with Terraform

A modular Terraform configuration to deploy a Google Kubernetes Engine (GKE) Autopilot cluster with a custom VPC network on Google Cloud Platform.

## 📋 Table of Contents

- [Overview](#-overview)
- [Architecture](#-architecture)
- [Prerequisites](#-prerequisites)
- [Project Structure](#-project-structure)
- [Quick Start](#-quick-start)
- [Configuration](#-configuration)
- [Deployment](#-deployment)
- [Accessing the Cluster](#-accessing-the-cluster)
- [Cleanup](#-cleanup)
- [Troubleshooting](#-troubleshooting)
- [Cost Considerations](#-cost-considerations)

## 🎯 Overview

This project provides a production-ready, modular Terraform configuration for deploying:

- **GKE Autopilot Cluster**: Fully managed Kubernetes cluster
- **Custom VPC Network**: Isolated network environment
- **Private Cluster**: Enhanced security with private nodes
- **Cloud NAT**: Enables internet access for private nodes
- **Firewall Rules**: Secure network policies
- **Monitoring & Logging**: Integrated observability

## 🏗 Architecture

```
┌─────────────────────────────────────────────────────┐
│                  GCP Project                        │
│  ┌───────────────────────────────────────────────┐  │
│  │           Custom VPC Network                  │  │
│  │  ┌─────────────────────────────────────────┐  │  │
│  │  │         GKE Subnet                      │  │  │
│  │  │  - Primary: 10.0.0.0/20                 │  │  │
│  │  │  - Pods: 10.4.0.0/14                    │  │  │
│  │  │  - Services: 10.8.0.0/20                │  │  │
│  │  │  ┌───────────────────────────────────┐  │  │  │
│  │  │  │   GKE Autopilot Cluster           │  │  │  │
│  │  │  │   (Private Nodes)                 │  │  │  │
│  │  │  └───────────────────────────────────┘  │  │  │
│  │  └─────────────────────────────────────────┘  │  │
│  │                                               │  │
│  │  Cloud Router + NAT ──→ Internet              │  │
│  └───────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────┘
```

## ✅ Prerequisites

### Required Software

1. **Terraform** (>= 1.0)
   - Download: https://www.terraform.io/downloads
   - Verify: `terraform --version`

2. **Google Cloud SDK** (gcloud CLI)
   - Download: https://cloud.google.com/sdk/docs/install
   - Verify: `gcloud --version`

3. **kubectl** (Kubernetes CLI)
   - Install via gcloud: `gcloud components install kubectl`
   - Verify: `kubectl version --client`

### GCP Requirements

1. **GCP Project** with billing enabled
2. **Required APIs** enabled:
   - Kubernetes Engine API
   - Compute Engine API
   - Cloud Resource Manager API

3. **IAM Permissions**: Your account needs `Editor` or `Owner` role

### Enable APIs

```bash
gcloud services enable container.googleapis.com
gcloud services enable compute.googleapis.com
gcloud services enable cloudresourcemanager.googleapis.com
```

## 📁 Project Structure

```
.
├── provider.tf          # Terraform and provider configuration
├── variables.tf         # Input variable definitions
├── vpc.tf              # VPC and subnet resources
├── routing.tf          # Cloud Router and NAT configuration
├── firewall.tf         # Firewall rules
├── gke.tf              # GKE Autopilot cluster
├── outputs.tf          # Output values
├── terraform.tfvars    # Your variable values (create this)
├── .gitignore          # Git ignore file
└── README.md           # This file
```

## 🚀 Quick Start

### 1. Clone the Repository

```bash
git clone <your-repo-url>
cd gke101
```

### 2. Authenticate with GCP

```bash
# Login to GCP
gcloud auth login

# Set your project
gcloud config set project YOUR_PROJECT_ID

# Create application default credentials for Terraform
gcloud auth application-default login
```

### 3. Create `terraform.tfvars`

Create a file named `terraform.tfvars` with your configuration:

```hcl
project_id   = "your-gcp-project-id"
region       = "us-central1"
cluster_name = "my-autopilot-cluster"
network_name = "my-gke-vpc"
```

### 4. Initialize Terraform

```bash
terraform init
```

### 5. Review the Plan

```bash
terraform plan
```

### 6. Deploy Infrastructure

```bash
terraform apply
```

Type `yes` when prompted. Deployment takes approximately 10-15 minutes.

## ⚙️ Configuration

### Required Variables

| Variable     | Description    | Example          |
|--------------|----------------|------------------|
| `project_id` | GCP Project ID | `my-project-123` |
| `region`     | GCP Region     | `us-central1`    |

### Optional Variables

| Variable                  | Description              | Default             |
|---------------------------|--------------------------|---------------------|
| `cluster_name`            | Name of GKE cluster      | `autopilot-cluster` |
| `network_name`            | Name of VPC network      | `gke-vpc`           |
| `subnet_cidr`             | Primary subnet CIDR      | `10.0.0.0/20`       |
| `pods_cidr`               | Pods secondary range     | `10.4.0.0/14`       |
| `services_cidr`           | Services secondary range | `10.8.0.0/20`       |
| `master_cidr`             | Master nodes CIDR        | `172.16.0.0/28`     |
| `enable_private_endpoint` | Private GKE endpoint     | `false`             |

### Example: Custom Configuration

```hcl
# terraform.tfvars
project_id   = "my-project-123"
region       = "asia-southeast1"
cluster_name = "production-cluster"
network_name = "prod-vpc"
subnet_cidr  = "10.10.0.0/20"
pods_cidr    = "10.20.0.0/14"
services_cidr = "10.30.0.0/20"
enable_private_endpoint = true
```

## 🎯 Deployment

### Full Deployment

```bash
# Initialize
terraform init

# Validate configuration
terraform validate

# Plan changes
terraform plan

# Apply changes
terraform apply

# View outputs
terraform output
```

### Partial Deployment

Target specific modules:

```bash
# Deploy only VPC
terraform apply -target=google_compute_network.vpc

# Deploy only GKE cluster
terraform apply -target=google_container_cluster.autopilot
```

## 🔌 Accessing the Cluster

### Get Cluster Credentials

```bash
gcloud container clusters get-credentials CLUSTER_NAME --region REGION --project PROJECT_ID
```

Or use the output command:

```bash
terraform output -raw get_credentials_command
```

### Verify Connection

```bash
kubectl cluster-info
kubectl get nodes
kubectl get namespaces
```

### Deploy a Test Application

```bash
# Create deployment
kubectl create deployment hello-app --image=gcr.io/google-samples/hello-app:1.0

# Expose as LoadBalancer
kubectl expose deployment hello-app --port=8080 --type=LoadBalancer

# Get service details
kubectl get service hello-app

# Wait for EXTERNAL-IP and test
curl http://EXTERNAL-IP:8080
```

## 🧹 Cleanup

### Remove Test Applications

```bash
kubectl delete service hello-app
kubectl delete deployment hello-app
```

### Disable Deletion Protection

If you get deletion protection errors:

**Option 1: Via Console**
1. Go to GKE Console
2. Edit your cluster
3. Uncheck "Enable deletion protection"
4. Save

**Option 2: Via gcloud**
```bash
gcloud container clusters update CLUSTER_NAME \
  --no-enable-deletion-protection \
  --region REGION
```

### Destroy All Resources

```bash
terraform destroy
```

Type `yes` when prompted. This will delete:
- GKE Autopilot cluster
- VPC network and subnet
- Cloud Router and NAT
- Firewall rules
- All associated resources

⚠️ **Warning**: This action is irreversible!

## 🔧 Troubleshooting

### Authentication Issues

**Error**: `google: could not find default credentials`

**Solution**:
```bash
gcloud auth application-default login
```

### API Not Enabled

**Error**: `API [container.googleapis.com] not enabled`

**Solution**:
```bash
gcloud services enable container.googleapis.com
gcloud services enable compute.googleapis.com
```

### Insufficient Permissions

**Error**: `Permission denied` or `403 Forbidden`

**Solution**:
- Verify your account has `Editor` or `Owner` role
- Check project billing is enabled

### Cluster Creation Timeout

**Issue**: Cluster takes too long to create

**Solution**:
- This is normal for Autopilot clusters (10-15 minutes)
- Check GCP Console for progress
- Review logs: `gcloud container clusters describe CLUSTER_NAME --region REGION`

### Deletion Protection Error

**Error**: `Cannot destroy cluster because deletion_protection is set to true`

**Solution**:
```bash
# Via gcloud
gcloud container clusters update CLUSTER_NAME \
  --no-enable-deletion-protection \
  --region REGION

# Then destroy
terraform destroy
```

### State Lock Issues

**Error**: `Error acquiring the state lock`

**Solution**:
```bash
# Force unlock (use with caution)
terraform force-unlock LOCK_ID
```

## 💰 Cost Considerations

### Estimated Monthly Costs

- **GKE Autopilot**: ~$73/month (management fee)
- **Compute Resources**: Variable based on workload
- **Network Egress**: ~$0.12/GB
- **NAT Gateway**: ~$0.045/hour (~$32/month)

### Cost Optimization Tips

1. **Delete when not in use**: Run `terraform destroy` for development/testing
2. **Use smaller regions**: `us-central1` is typically cheaper
3. **Monitor usage**: Set up billing alerts in GCP Console
4. **Right-size workloads**: Autopilot automatically optimizes, but monitor requests/limits
5. **Use committed use discounts**: For production workloads

### Set Up Billing Alerts

```bash
# Via Console
GCP Console → Billing → Budgets & alerts → Create Budget
```

Set alert at 50%, 90%, and 100% of your budget.

## 📚 Additional Resources

- [Terraform GCP Provider Documentation](https://registry.terraform.io/providers/hashicorp/google/latest/docs)
- [GKE Autopilot Documentation](https://cloud.google.com/kubernetes-engine/docs/concepts/autopilot-overview)
- [Terraform Best Practices](https://www.terraform.io/docs/cloud/guides/recommended-practices/index.html)
- [kubectl Cheat Sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)
- [GCP VPC Documentation](https://cloud.google.com/vpc/docs)

## 🤝 Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙋 Support

For issues and questions:

1. Check the [Troubleshooting](#troubleshooting) section
2. Review [GCP Documentation](https://cloud.google.com/docs)
3. Open an issue in this repository
4. Contact: [your-email@example.com]

## ⚠️ Important Notes

- **Security**: This configuration uses private nodes but public endpoint. For production, consider fully private clusters.
- **Costs**: GKE and associated resources incur charges. Always destroy resources when not in use.
- **State Management**: Consider using remote state (GCS bucket) for team collaboration.
- **Secrets**: Never commit `terraform.tfvars` or `.terraform/` to version control.

## 🔄 Version History

- **v1.0.0** (2024-10-23): Initial release with modular structure
  - GKE Autopilot cluster
  - Custom VPC with private nodes
  - Cloud NAT and firewall rules
  - Comprehensive documentation

---
