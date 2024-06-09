# Google Cloud Run with load balancer

This uses Google's [HTTPS load balancer with Serverless NEG backend example](https://github.com/terraform-google-modules/terraform-google-lb-http/tree/master/examples/cloudrun).

## Setup

To use this you will need:
- Terraform
- A GCP account

1. Login to gcloud
   ```bash
   gcloud auth application-default login 
   ```
2. Run plan changes
   ```bash
   terraform plan
   ```
3. Apply changes
   ```bash
   terraform apply
   ```
4. Destroy infrastructure
   ```bash
   terraform destroy
   ```
