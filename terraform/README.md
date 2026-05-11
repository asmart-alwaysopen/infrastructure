# Infrastructure Terraform (EKS)

This directory is the new baseline for provisioning AWS infrastructure for Always Open.

It currently provisions:
- VPC with public/private subnets and NAT gateway
- EKS cluster on Kubernetes `1.35`
- EKS managed node groups
- Core EKS addons (`coredns`, `kube-proxy`, `vpc-cni`, `eks-pod-identity-agent`)
- **Amazon EBS CSI driver** (`aws-ebs-csi-driver`) with IRSA, so `gp2` / CSI-backed PVCs can bind

Set `enable_ebs_csi_driver = false` in `terraform.tfvars` if you install the driver outside Terraform.

## Usage

1. Copy the example variables file:

   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. Initialize Terraform:

   ```bash
   terraform init
   ```

3. Review plan:

   ```bash
   terraform plan
   ```

4. Apply:

   ```bash
   terraform apply
   ```

## Notes

- Set your AWS credentials/profile before running Terraform.
- This stack intentionally starts focused on EKS. Additional services (datastores, DNS, certs, secrets, etc.) can be layered in incrementally.
- Managed node groups set **`attach_cluster_primary_security_group = true`** so worker ENIs include the EKS cluster primary security group. That matches AWS guidance and avoids admission webhook timeouts (e.g. Istio `/inject`) when nothing else has customized security groups.

## Jenkins CI/CD

Use `infrastructure/Jenkinsfile` to run Terraform in Jenkins.

Pipeline parameters:
- `ENVIRONMENT`: sets `TF_VAR_environment` (`dev`, `staging`, `production`)
- `AWS_REGION`: sets `TF_VAR_aws_region`
- `AWS_CREDENTIALS_ID`: Jenkins credentials ID used for AWS access keys
- `ACTION`: `plan`, `apply`, or `destroy` (`destroy` is blocked for production)
- `REQUIRE_MANUAL_APPROVAL`: when enabled, Jenkins pauses before `apply`/`destroy`

The pipeline runs:
1. `terraform init -reconfigure`
   - configures S3 backend in `always-open-terraform-state` with key `infrastructure/<environment>/<region>/terraform.tfstate`
2. `terraform fmt -check -recursive`
3. `terraform validate`
4. `terraform plan` (for `plan`/`apply`) or `terraform plan -destroy` (for `destroy`)
5. optional gated `terraform apply` or gated `terraform destroy`
