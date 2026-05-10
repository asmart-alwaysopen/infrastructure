locals {
  name_prefix = "${var.project_name}-${var.environment}"

  common_tags = merge(
    {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "terraform"
    },
    var.extra_tags
  )

  # Ensure each managed node group has concrete scaling values so the EKS module
  # never receives null for required scaling_config attributes.
  resolved_managed_node_groups = {
    for name, ng in var.managed_node_groups : name => merge(
      {
        ami_type       = var.managed_node_group_defaults.ami_type
        instance_types = var.managed_node_group_defaults.instance_types
        capacity_type  = var.managed_node_group_defaults.capacity_type
        disk_size      = var.managed_node_group_defaults.disk_size
        min_size       = var.managed_node_group_defaults.min_size
        max_size       = var.managed_node_group_defaults.max_size
        desired_size   = var.managed_node_group_defaults.desired_size
        taints         = []
      },
      ng,
      {
        taints = try(ng.taints, [])
      }
    )
  }
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "${local.name_prefix}-vpc"
  cidr = var.vpc_cidr

  azs             = var.availability_zones
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  enable_nat_gateway = true
  single_nat_gateway = var.enable_single_nat_gateway

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }

  tags = local.common_tags
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = var.cluster_name
  cluster_version = var.kubernetes_version

  cluster_endpoint_public_access           = true
  enable_cluster_creator_admin_permissions = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
    eks-pod-identity-agent = {
      most_recent = true
    }
  }

  eks_managed_node_group_defaults = {
    ami_type       = var.managed_node_group_defaults.ami_type
    instance_types = var.managed_node_group_defaults.instance_types
    capacity_type  = var.managed_node_group_defaults.capacity_type
    disk_size      = var.managed_node_group_defaults.disk_size
    min_size       = var.managed_node_group_defaults.min_size
    max_size       = var.managed_node_group_defaults.max_size
    desired_size   = var.managed_node_group_defaults.desired_size
  }

  eks_managed_node_groups = local.resolved_managed_node_groups

  tags = local.common_tags
}
