# Architectural Phase Breakdown

This project builds out infrastructure incrementally, following enterprise best practices at every stage.

## Phase 1: Bootstrap & Network
**Enterprise Concept:** Separation of Concerns & State Management
- **GCS Remote State:** Before provisioning infrastructure, we establish a secure Google Cloud Storage backend. This moves state files off local machines and enables remote state locking, a requirement for multi-engineer collaboration.
- **Custom VPC & Subnets:** We disable auto-created subnets to ensure strict IP address management (IPAM) and prevent IP overlap when peering networks across regions or organizations.

## Phase 2: Compute
**Enterprise Concept:** Immutable Infrastructure & Least Privilege
- **Cloud Run (Serverless):** We deploy containers on Cloud Run instead of managing raw VMs or GKE clusters, optimizing for stateless AI inference APIs that need to scale rapidly from zero based on traffic.
- **Dedicated Service Accounts:** We strip away the overly permissive Default Compute Engine Service Account. Our Cloud Run instance receives a custom, dedicated identity (`${env}-inference-sa`), limiting the blast radius of a potential compromise.
- **Direct VPC Egress:** The container's outbound traffic is routed explicitly into our custom VPC subnet instead of traversing the public internet, ensuring secure connections to internal databases or APIs.

## Phase 3: Load Balancing
**Enterprise Concept:** Edge Security & Performance
- **Global HTTP(S) LB:** Provides a single, static anycast IP address globally, unlocking Cloud CDN caching, Cloud Armor WAF protection, and multi-region failover.
- **Serverless NEG:** The Serverless Network Endpoint Group bridges the VPC-native load balancer to the serverless Cloud Run instance securely, avoiding public internet exposure for the backend service.

## Phase 4: Security
**Enterprise Concept:** Centralized Secrets & Dynamic IAM Binding
- **Secret Manager:** API keys and credentials are moved out of environment variables and source control, and stored securely in Google Secret Manager.
- **IAM Binding at the Resource Level:** Instead of granting the Cloud Run service account project-wide access to all secrets, we bind the `roles/secretmanager.secretAccessor` role to the specific secret resource itself.

## Phase 5: Monitoring
**Enterprise Concept:** Observability as Code
- **Cloud Monitoring Alerts:** We define MQL (Monitoring Query Language) alerts for High 5XX Error Rates (> 5%) and High Latency (> 2000ms p99) in code alongside the infrastructure.
- **PagerDuty Integration:** Alerts are routed programmatically to the on-call rotation via PagerDuty, rather than relying on manual dashboard creation or email alerts.
