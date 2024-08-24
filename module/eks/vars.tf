variable "cluster_config" {
    default = {
        cluster_name        = "test-eks"
        version             = "1.30"
        role_arn            = "arn:aws:iam::<ACOUNT_ID>:role/eksClusterRole"
        authentication_mode = "API_AND_CONFIG_MAP"
        environment         = "Dev and MGH prod"    # It will added to tags
    }
}

variable "vpc_config" {
    default = {
        subnet_ids              = ["subnet-1", "subnet-2"]
        security_group_ids      = ["sg-id"]
        endpoint_private_access = true      # Cluster will be access within the VPC
        endpoint_public_access  = false     # Make it true to access the cluster through internet
    }
}

variable "network_config" {
    default = {
        service_ipv4_cidr   = "10.0.0.0/16"   # The CIDR block to assign Kubernetes pod and service IP addresses from
        ip_family           = "ipv4"            # Valid values are 'ipv4' and 'ipv6'
    }
}

variable "node_groups" {
  description = "Map of node group configurations"
  type = map(object({
    ami_type        = string
    instance_types  = list(string)
    labels          = map(string)       # Kubernetes label
    node_role_arn   = string
    subnet_ids      = list(string)
    desired_size    = number
    max_size        = number
    min_size        = number
    max_unavailable = number
    tags            = map(string)
  }))
}

variable "aws_eks_access_entry" {
  description = "Map of roles to provide the cluster access"
  type = map(object({
        principal_arn     = string
        type              = string
        policy_arn        = string
  }))
}
