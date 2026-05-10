output "cluster_name" {
  description = "EKS cluster name."
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "Kubernetes API server endpoint."
  value       = module.eks.cluster_endpoint
}

output "cluster_version" {
  description = "Kubernetes version for the EKS cluster."
  value       = module.eks.cluster_version
}

output "cluster_certificate_authority_data" {
  description = "Base64 certificate authority data for the cluster."
  value       = module.eks.cluster_certificate_authority_data
  sensitive   = true
}

output "cluster_oidc_provider_arn" {
  description = "OIDC provider ARN for IAM roles for service accounts."
  value       = module.eks.oidc_provider_arn
}

output "vpc_id" {
  description = "VPC ID used by the EKS cluster."
  value       = module.vpc.vpc_id
}

output "private_subnet_ids" {
  description = "Private subnets where EKS managed node groups run."
  value       = module.vpc.private_subnets
}
