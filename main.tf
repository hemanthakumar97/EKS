terraform {
  backend "s3" {
    bucket = "terraform-state"
    key    = "eks/terraform.tfstate"
    region = "us-east-1"

    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}

module "eks-cluster" {
  source                = "modules/eks"
  cluster_config        = var.cluster_config
  vpc_config            = var.vpc_config
  network_config        = var.network_config
  node_groups           = var.node_groups
  aws_eks_access_entry  = var.aws_eks_access_entry
}
