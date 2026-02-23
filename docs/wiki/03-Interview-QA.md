# Interview Q&A

This repository includes real-world architectural decisions and trade-offs. Use this Q&A to prepare for discussions on enterprise GCP usage.

---

### Q: Why did you deploy the Load Balancer on HTTP (Port 80) instead of HTTPS (Port 443)?
**A:** This is a lab environment, and GCP Managed SSL Certificates require a domain name pointed via DNS to the reserved static IP address. Because this lab provisions ephemeral resources, DNS validation would hang the Terraform apply. In a true enterprise environment, we use `google_compute_managed_ssl_certificate` and `google_compute_target_https_proxy`, both of which are documented and commented out in the `modules/loadbalancer/main.tf` code.

### Q: Does HTTP mean internal traffic between the Load Balancer and Cloud Run is unencrypted?
**A:** No. The connection between the Global Load Balancer and the Serverless NEG traverses the Google backbone network, which encrypts data in transit automatically. However, enforcing HTTPS at the edge provides end-to-end encryption to meet Zero Trust requirements.

### Q: In `environments/dev/variables.tf`, you define `project_id` and `region`, but where does the script actually get those values?
**A:** Terraform parameters are defined in `variables.tf`, but the actual values are injected via the `terraform.tfvars` file located in the same directory. This separates the logic from the configuration, allowing us to deploy `dev` and `prod` using the same module code but completely different variable files.

### Q: When PagerDuty triggers an alert, where is the "eyes on glass" for the responding engineer?
**A:** For a purely GCP-native team, we would build custom **Google Cloud Monitoring Dashboards** linked directly in the PagerDuty alert. For hybrid or multi-cloud enterprises, we would likely pipe GCP metrics into a third-party tool like **Dynatrace**, giving the NOC a single pane of glass to trace requests from the cloud edge all the way to legacy on-prem databases.

### Q: How would you use Terraform to support a Data Science team that needs to run inference on massive, sporadic batches of data?
**A:** I wouldn't build them a static GKE cluster or raw VMs. I would use Terraform to provision a **Pub/Sub topic** wired to a **Cloud Run** service configured to scale from 0 to 50 instances based on concurrency. The data scientists drop their batch jobs into the topic, Cloud Run auto-scales out to process the backlog, and then spins back down to zero when idle, optimizing costs and removing infrastructure burden from the dev team.