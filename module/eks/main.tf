resource "aws_eks_cluster" "eks" {
  name      = var.cluster_config.cluster_name
  version   = var.cluster_config.version
  role_arn  = var.cluster_config.role_arn

  access_config{
    authentication_mode = var.cluster_config.authentication_mode
  }
  vpc_config{
    subnet_ids  = var.vpc_config.subnet_ids
    security_group_ids = var.vpc_config.security_group_ids
    endpoint_private_access = var.vpc_config.endpoint_private_access
    endpoint_public_access = var.vpc_config.endpoint_public_access
  }

  kubernetes_network_config {
    service_ipv4_cidr = var.network_config.service_ipv4_cidr
    ip_family = var.network_config.ip_family
  }
}

resource "null_resource" "delay" {
  provisioner "local-exec" {
    when      = destroy
    command   = "sleep 10"
  }

  depends_on = [
    aws_eks_node_group.this
  ]
}

resource "aws_eks_node_group" "this" {
  for_each       = var.node_groups
  cluster_name   = var.cluster_config.cluster_name
  node_group_name = each.key
  ami_type       = each.value.ami_type
  instance_types = each.value.instance_types
  labels         = each.value.labels
  node_role_arn  = each.value.node_role_arn
  subnet_ids     = each.value.subnet_ids

  scaling_config {
    desired_size = each.value.desired_size
    max_size     = each.value.max_size
    min_size     = each.value.min_size
  }

  update_config {
    max_unavailable = each.value.max_unavailable
  }

  tags = merge({
    Name        = each.key
    Environment = var.cluster_config.environment
    Terraform   = "true"
  }, each.value.tags)

  depends_on = [
    aws_eks_cluster.eks
  ]
}


resource "aws_eks_addon" "eks-pod-identity-agent" {
  depends_on                  = [aws_eks_node_group.this]
  cluster_name                = aws_eks_cluster.eks.name
  addon_name                  = "eks-pod-identity-agent"
  resolve_conflicts_on_update = "PRESERVE"
}

resource "aws_eks_addon" "vpc-cni" {
  depends_on                  = [aws_eks_node_group.this]
  cluster_name                = aws_eks_cluster.eks.name
  addon_name                  = "vpc-cni"
  resolve_conflicts_on_update = "PRESERVE"
}

resource "aws_eks_addon" "coredns" {
  depends_on                  = [aws_eks_node_group.this]
  cluster_name                = aws_eks_cluster.eks.name
  addon_name                  = "coredns"
  resolve_conflicts_on_update = "PRESERVE"
}

resource "aws_eks_addon" "kube-proxy" {
  depends_on                  = [aws_eks_node_group.this]
  cluster_name                = aws_eks_cluster.eks.name
  addon_name                  = "kube-proxy"
  resolve_conflicts_on_update = "PRESERVE"
}

resource "aws_eks_addon" "aws-ebs-csi-driver" {
  depends_on                  = [aws_eks_node_group.this]
  cluster_name                = aws_eks_cluster.eks.name
  addon_name                  = "aws-ebs-csi-driver"
  resolve_conflicts_on_update = "PRESERVE"
  service_account_role_arn    = "arn:aws:iam::<ACOUNT_ID>:role/AmazonEKS_EBS_CSI_DriverRolePADev"
}

resource "aws_eks_access_entry" "example" {
  for_each          = var.aws_eks_access_entry
  cluster_name      = aws_eks_cluster.eks.name
  principal_arn     = each.value.principal_arn
  user_name         = each.key
  type              = "STANDARD"
}

resource "aws_eks_access_policy_association" "example" {
  for_each        = var.aws_eks_access_entry
  cluster_name    = aws_eks_cluster.eks.name
  policy_arn      = each.value.policy_arn
  principal_arn   = each.value.principal_arn

  access_scope {
    type       = "cluster"
  }
}