# EKS Terraform Documentation

This documentation provides information on the Terraform configuration used to provision EKS cluster on AWS. The variables are defined in the `vars.tf` file, and this README explains their purpose and usage.

## Prerequisites

- Terraform
- AWS CLI
- eksctl
- helm


## Variables

### cluster_config

Configuration for the EKS cluster, including essential settings such as:

- **`cluster_name`**: Specifies the name of the EKS cluster.
- **`version`**: Defines the Kubernetes version for the EKS cluster.
- **`role_arn`**: The ARN of the IAM role associated with the EKS cluster, which provides the necessary permissions.
- **`authentication_mode`**: Specifies the authentication mode for the EKS cluster. Options include `API_AND_CONFIG_MAP`, which controls how users and applications authenticate to the cluster.
- **`environment`**: Tags that categorize the cluster based on its environment, such as development or production.

### vpc_config

Configuration for the VPC that will house the EKS cluster:

- **`subnet_ids`**: A list of subnet IDs where the EKS cluster will be deployed. These subnets are used for distributing cluster resources. 
    
    **NOTE:** Atleast 2 public subnets should be added to launch an internet facing ALB, and these subnets should be tagged properly, refer [this](https://repost.aws/knowledge-center/eks-vpc-subnet-discovery) for more information on subnet tagging
- **`security_group_ids`**: A list of security group IDs associated with the cluster, which define the network access rules.
- **`endpoint_private_access`**: Determines whether the cluster can be accessed privately within the VPC. Setting this to `true` restricts access to within the VPC.
- **`endpoint_public_access`**: Indicates if the cluster is accessible from the internet. Setting this to `true` allows external access.

### network_config

Configuration for the network settings of the EKS cluster:

- **`service_ipv4_cidr`**: Defines the CIDR block used for assigning IP addresses to Kubernetes pods and services within the cluster.
- **`ip_family`**: Specifies the IP family used by the cluster. Valid options are `ipv4` or `ipv6`, depending on your network requirements.

### node_groups

Map of configurations for node groups within the cluster:

- **`ami_type`**: Specifies the AMI type for the instances in the node group.
- **`instance_types`**: List of EC2 instance types to use for the nodes in the group.
- **`labels`**: Kubernetes labels applied to the nodes in the group, used for scheduling and management.
- **`node_role_arn`**: ARN of the IAM role associated with the node group, which provides the required permissions for the nodes.
- **`subnet_ids`**: List of subnet IDs where the node group instances will be deployed.
- **`desired_size`**: Desired number of instances in the node group.
- **`max_size`**: Maximum number of instances allowed in the node group.
- **`min_size`**: Minimum number of instances required in the node group.
- **`max_unavailable`**: Maximum number of instances that can be unavailable during scaling or maintenance.
- **`tags`**: Tags applied to the instances in the node group for organizational purposes.

### aws_eks_access_entry

Map of roles and permissions to provide access to the EKS cluster:

- **`principal_arn`**: ARN of the role or user that needs access to the cluster.
- **`type`**: The type of access being provided (e.g., `STANDARD`).
- **`policy_arn`**: ARN of the policy that grants the necessary permissions for access.

## Connecting to the EKS Cluster

To connect to the EKS cluster, follow these steps:

- **Update kubeconfig**: Use the AWS CLI to update your kubeconfig file with the EKS cluster information.
    ```bash
    aws eks update-kubeconfig --region <region> --name <cluster_name>
    ```
    Replace `<region>` with the AWS region where the EKS cluster is located, and `<cluster_name>` with the name of the cluster.

- **Verify Connection**: Ensure you can connect to the cluster by running:
    ```bash
    kubectl get nodes
    ```
    This command should list the nodes in the EKS cluster if the connection is successful.


## Installing the ALB Ingress Controller using Helm ([Official doc](https://docs.aws.amazon.com/eks/latest/userguide/lbc-helm.html)):

- **Create IAM policy and IAM Service account**: Follow these steps to create IAM Policy and IAM Service account for ALB Ingress Controller:

    ```bash
    export cluster_name=<cluster_name>
    export policy_name=AWSLoadBalancerControllerIAMPolicy<env_suffix>
    export role_name=AmazonEKSLoadBalancerControllerRole<env_suffix>
    export region=<region>
    export vpc_id=<vpc_id>
    export csi_role_name=AmazonEKS_EBS_CSI_DriverRole<env_suffix>
    ```
    Replace `<region>` with the AWS region where the EKS cluster is located, and `<cluster_name>` with the name of the cluster, `<env_suffix>`, and `<vpc_id>`.

    Below commands will create policy and IAM service account to use with ALB controller

    ```bash
    curl -O https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.7.2/docs/install/iam_policy.json

    aws iam create-policy \
        --policy-name $policy_name \
        --policy-document file://iam_policy.json

    eksctl utils associate-iam-oidc-provider --region=us-east-1 --cluster=$cluster_name --approve

    eksctl create iamserviceaccount \
    --cluster=$cluster_name \
    --namespace=kube-system \
    --name=aws-load-balancer-controller \
    --role-name $role_name \
    --attach-policy-arn=arn:aws:iam::<ACOUNT_ID>:policy/$policy_name \
    --approve

    ```

- **Add the Helm Repository**: Add the AWS ALB Ingress Controller Helm repository to your Helm setup.
    ```bash
    helm repo add eks https://aws.github.io/eks-charts
    ```

- **Update Helm Repositories**: Update your Helm repositories to fetch the latest charts.
    ```bash
    helm repo update
    ```

- **Install the ALB Ingress Controller**: Use Helm to install the ALB Ingress Controller in the EKS cluster. Adjust the values as needed for your setup.
    ```bash
    helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
    -n kube-system \
    --set clusterName=$cluster_name \
    --set serviceAccount.create=false \
    --set serviceAccount.name=aws-load-balancer-controller \
    --set region=$region \
    --set vpcId=$vpc_id
    ```

    Verify that the controller is installed
    ```bash
    kubectl get deployment -n kube-system aws-load-balancer-controller
    ```

    An example output is as follows.
    ```bash
    NAME                           READY   UP-TO-DATE   AVAILABLE   AGE
    aws-load-balancer-controller   2/2     2            2           84s
    ```

- Command to list the components in a cluster which are installed using helm
    ```bash
    helm list --all-namespaces
    ```

## Author

- [@Hemanth](https://github.com/hemanthakumar97)