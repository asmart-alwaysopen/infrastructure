variable "aws_region" {
  description = "AWS region where infrastructure is deployed."
  type        = string
  default     = "us-west-2"
}

variable "environment" {
  description = "Environment name used for naming and tagging."
  type        = string
  default     = "production"
}

variable "project_name" {
  description = "Project name prefix used for resource naming."
  type        = string
  default     = "always-open"
}

variable "cluster_name" {
  description = "EKS cluster name."
  type        = string
  default     = "always-open-eks"
}

variable "kubernetes_version" {
  description = "Kubernetes version for EKS control plane and managed node groups."
  type        = string
  default     = "1.35"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Availability zones used by the VPC."
  type        = list(string)
  default     = ["us-west-2a", "us-west-2b", "us-west-2c"]
}

variable "private_subnets" {
  description = "Private subnet CIDRs for worker nodes."
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "public_subnets" {
  description = "Public subnet CIDRs for load balancers and NAT gateways."
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}

variable "enable_single_nat_gateway" {
  description = "Whether to use a single shared NAT gateway."
  type        = bool
  default     = true
}

variable "managed_node_group_defaults" {
  description = "Default settings applied to all managed node groups."
  type = object({
    ami_type       = string
    instance_types = list(string)
    capacity_type  = string
    disk_size      = number
    min_size       = number
    max_size       = number
    desired_size   = number
  })
  default = {
    ami_type       = "AL2023_x86_64_STANDARD"
    instance_types = ["m6i.large"]
    capacity_type  = "ON_DEMAND"
    disk_size      = 50
    min_size       = 2
    max_size       = 6
    desired_size   = 3
  }
}

variable "managed_node_groups" {
  description = "Map of managed node groups for EKS."
  type = map(object({
    instance_types = optional(list(string))
    capacity_type  = optional(string)
    ami_type       = optional(string)
    disk_size      = optional(number)
    min_size       = optional(number)
    max_size       = optional(number)
    desired_size   = optional(number)
    labels         = optional(map(string))
    taints = optional(list(object({
      key    = string
      value  = string
      effect = string
    })))
  }))
  default = {
    general = {
      labels = {
        workload = "general"
      }
    }
  }
}

variable "extra_tags" {
  description = "Extra tags to merge with the default tags."
  type        = map(string)
  default     = {}
}
