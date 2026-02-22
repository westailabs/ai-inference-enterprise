# AI Inference Enterprise (GCP Terraform)

This repository defines the enterprise-grade infrastructure for deploying scalable AI inference services on Google Cloud Platform using Terraform.

## Enterprise Patterns
This project demonstrates the following best practices:
1. **Remote State & Locking**: GCS backend for state management and concurrency control.
2. **Modular Architecture**: Reusable infrastructure components (`network`, `compute`, `loadbalancer`, `security`).
3. **Environment Separation**: Distinct workspaces (`dev`, `prod`) using parameterized environments.
4. **Least Privilege IAM**: Granular service accounts for provisioning and runtime execution.
5. **Data Sources**: Dynamic retrieval of existing GCP resource data.

## Directory Structure
- `environments/`: Contains the entry point configurations for different deployment stages (e.g., `dev`, `prod`).
- `modules/`: Contains the reusable, parameterized Terraform modules.
