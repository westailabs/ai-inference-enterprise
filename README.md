# AI Inference Enterprise (GCP Terraform)

This repository defines the enterprise-grade infrastructure for deploying scalable AI inference services on Google Cloud Platform using Terraform.

## Architectural Philosophy: Infrastructure as OOP
This project moves beyond procedural infrastructure scripts and treats Terraform modules like Object-Oriented Programming (OOP) classes:
- **Modules (`modules/`)** act as **Classes**. They encapsulate logic, define private internals, and expose public interfaces.
- **Variables (`variables.tf`)** act as **Constructor Arguments**. They allow environments to instantiate the infrastructure with different parameters.
- **Outputs (`outputs.tf`)** act as **Public Properties**. They allow separate infrastructure components to interface with each other securely.
- **Environments (`environments/dev/main.tf`)** act as the **Main Function**, instantiating the objects and wiring them together via dependency injection.

## Enterprise Patterns Implemented
1. **Remote State & Locking (`bootstrap/`)**: GCS backend for state management and concurrency control to support multi-engineer teams.
2. **Modular Architecture**: Reusable infrastructure components (`network`, `compute`, `loadbalancer`, `security`, `monitoring`).
3. **Least Privilege IAM**: Granular service accounts. The Cloud Run container is explicitly restricted to only read the specific secret it needs from Secret Manager.
4. **Immutable Infrastructure**: Cloud Run serverless deployment model ensuring clean, immutable container revisions.
5. **Edge Security**: Global HTTP(S) Load Balancer using a Serverless NEG to route traffic to the container without exposing it directly to the internet.
6. **Observability as Code**: Cloud Monitoring alerts (High Latency, High 5XX Error Rate) are deployed alongside the infrastructure to prevent monitoring blind spots.

## Directory Structure
```
├── bootstrap/               # GCS State Bucket creation
├── environments/
│   ├── dev/                 # Dev environment instantiation
│   └── prod/                # Prod environment instantiation (future)
└── modules/
    ├── compute/             # Cloud Run & Service Accounts
    ├── loadbalancer/        # Global HTTP(S) LB & Serverless NEG
    ├── monitoring/          # Cloud Monitoring Alerts
    ├── network/             # VPC & Subnets
    └── security/            # Secret Manager & IAM Bindings
```

## Deployment Instructions
1. Run `terraform apply` in the `bootstrap/` directory to create the state bucket.
2. Navigate to `environments/dev/`.
3. Run `terraform init` to pull local modules and configure the GCS backend.
4. Run `terraform apply`. You will be prompted for:
   - `api_key_payload`: A test secret to inject into Secret Manager.
   - `pagerduty_service_key`: The PagerDuty integration/service key to receive Cloud Monitoring alerts.
