# module: Terraform 语法，用于调用预定义模块（这里是 AWS VPC 模块），source 指定模块来源
module "vpc" {
  # source: 指定模块的源（可以是本地路径、Git 仓库或注册表）
  source = "terraform-aws-modules/vpc/aws"

  # name: 字符串变量赋值，定义 VPC 名称
  name = "test-vpc-01"
  # cidr: 字符串变量赋值，定义 VPC 的 CIDR 块
  cidr = "10.0.0.0/16"

  # azs: 列表（list）语法，定义可用区列表
  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
  # private_subnets 和 public_subnets: 列表语法，定义子网 CIDR 列表
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  # enable_nat_gateway 等: 布尔变量赋值，启用/禁用功能
  enable_nat_gateway = true
  enable_vpn_gateway = false
  single_nat_gateway = true  # 如果启用单 NAT 网关，则所有私有子网将共享一个 NAT 网关 default = false
  map_public_ip_on_launch = true

  # tags: 映射（map）语法，为资源添加键值对标签
  tags = {
    Terraform = "true"
    Environment = "dev"
  }
  # public_subnet_tags 和 private_subnet_tags: 映射语法，为特定子网添加标签
  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
  }
  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
  }
}