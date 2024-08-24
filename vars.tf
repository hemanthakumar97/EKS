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
        subnet_ids              = ["subnet-1", "subnet-2", "subnet-3", "subnet-4"]
        security_group_ids      = ["<security_group_id>"]
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
    default = {
        node-group-1 = {
            ami_type        = "AL2023_x86_64_STANDARD"
            #ami_type        = "AL2_x86_64"
            instance_types  = ["t3.large"]
            labels          = { app = "node-group-1" }
            node_role_arn   = "arn:aws:iam::<ACOUNT_ID>:role/EKS-NodeInstanceRole"
            subnet_ids      = ["subnet-1", "subnet-2"]
            desired_size    = 1
            max_size        = 1
            min_size        = 1
            max_unavailable = 1
            tags            = {}
        },
        node-group-2 = {
            ami_type        = "AL2023_x86_64_STANDARD"
            instance_types  = ["t3.medium"]
            labels          = { app = "node-group-2" }
            node_role_arn   = "arn:aws:iam::<ACOUNT_ID>:role/EKS-NodeInstanceRole"
            subnet_ids      = ["subnet-1", "subnet-2"]
            desired_size    = 1
            max_size        = 1
            min_size        = 1
            max_unavailable = 1
            tags            = {}
        },
        node-group-3 = {
            ami_type        = "AL2023_x86_64_STANDARD"
            instance_types  = ["t3.medium"]
            labels          = { app = "node-group-3" }
            node_role_arn   = "arn:aws:iam::<ACOUNT_ID>:role/EKS-NodeInstanceRole"
            subnet_ids      = ["subnet-1", "subnet-2"]
            desired_size    = 1
            max_size        = 1
            min_size        = 1
            max_unavailable = 1
            tags            = {}
        },
        node-group-4 = {
            ami_type        = "AL2023_x86_64_STANDARD"
            instance_types  = ["t3.xlarge"]
            labels          = { app = "node-group-4" }
            node_role_arn   = "arn:aws:iam::<ACOUNT_ID>:role/EKS-NodeInstanceRole"
            subnet_ids      = ["subnet-1", "subnet-2"]
            desired_size    = 1
            max_size        = 1
            min_size        = 1
            max_unavailable = 1
            tags            = {}
        }
    }
}

variable "aws_eks_access_entry" {
    default = {
        Buildpc-dev = {
            principal_arn     = "arn:aws:iam::<ACOUNT_ID>:role/Jumpbox-Role"
            type              = "STANDARD"
            policy_arn        = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
        },
        SRE-Prod = {
            principal_arn     = "arn:aws:iam::<ACOUNT_ID>:role/aws-reserved/sso.amazonaws.com/us-east-1/AWSReservedSSO-sre-prod"
            type              = "STANDARD"
            policy_arn        = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
        },
        SRE-admin = {
            principal_arn     = "arn:aws:iam::<ACOUNT_ID>:role/aws-reserved/sso.amazonaws.com/us-east-1/AWSReservedSSO-sre-admin"
            type              = "STANDARD"
            policy_arn        = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
        }
    }
}

