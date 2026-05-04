# 这里我们定义了一个新的安全组 `additional-eks-sg`，并将其添加到 EKS 集群的安全组列表中。
# 这个安全组允许来自 Bastion Host 的 HTTPS 流量访问 EKS 集群的 API 服务器。
resource "aws_security_group" "add_sg_eks" {
  name   = "additional-eks-sg"
  vpc_id = module.vpc.vpc_id
  ingress {
    description = "HTTPS from bastion host"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "additional-eks-sg"
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name               = "terraform-cluster"
  kubernetes_version = "1.34"

  addons = {
    coredns = {}
    eks-pod-identity-agent = {
      before_compute = true
    }
    kube-proxy = {}
    vpc-cni = {
      before_compute = true
    }
  }

  # Optional
  endpoint_public_access = false

  # Optional: Adds the current caller identity as an administrator via cluster access entry
  enable_cluster_creator_admin_permissions = true


  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets
  # 这里我们将 Bastion Host 的安全组添加到 EKS 集群的安全组列表中，以允许 Bastion Host 通过 HTTPS 访问 EKS 集群的 API 服务器。
  additional_security_group_ids = [aws_security_group.add_sg_eks.id]

  eks_managed_node_groups = {
    example = {
      # Starting on 1.30, AL2023 is the default AMI type for EKS managed node groups
      ami_type       = "AL2023_x86_64_STANDARD"   
      # 这里我们指定了 AMI 类型为 AL2023_x86_64_STANDARD，这是一种基于 Amazon Linux 2023 的 AMI，适用于 EKS 管理节点组，提供了更好的性能和安全性。
      instance_types = ["c7i-flex.large"] 
      # 这里我们使用 c7i-flex.large 实例类型，这是一种基于 AWS Graviton3 处理器的实例类型，提供了更高的性能和更低的成本，适合运行 Kubernetes 工作负载。


      min_size     = 2
      max_size     = 10
      desired_size = 2
    }
  }

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}

