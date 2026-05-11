# Managed EBS CSI driver: required for StorageClasses that use provisioner ebs.csi.aws.com
# (default gp2 on modern EKS routes PVCs through CSI).

variable "enable_ebs_csi_driver" {
  description = "Install the AWS EBS CSI driver EKS addon with IRSA (recommended for persistent volumes)."
  type        = bool
  default     = true
}

module "ebs_csi_irsa" {
  count = var.enable_ebs_csi_driver ? 1 : 0

  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.39"

  role_name = "${var.cluster_name}-ebs-csi-controller"

  attach_ebs_csi_policy = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }

  tags = local.common_tags
}

resource "aws_eks_addon" "ebs_csi" {
  count = var.enable_ebs_csi_driver ? 1 : 0

  cluster_name                = module.eks.cluster_name
  addon_name                  = "aws-ebs-csi-driver"
  service_account_role_arn    = module.ebs_csi_irsa[0].iam_role_arn
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  depends_on = [module.eks]
}
