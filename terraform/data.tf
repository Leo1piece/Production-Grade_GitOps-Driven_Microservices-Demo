# 文件用于 Terraform 中定义“数据源”。它不会创建资源本身，而是查找已有信息供后续资源配置使用。
data "http" "my_ip" {
  url = "https://checkip.amazonaws.com"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
# Canonical 官方账户 ID
  owners = ["099720109477"] # Canonical
}

