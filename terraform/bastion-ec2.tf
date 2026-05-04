# Generate a key and registers it in AWS.
# create ec2的时候需要 key pair， 这里我们使用 terraform 的 tls provider 来生成一个 RSA 密钥对，
# 并将公钥注册到 AWS 中，同时将私钥保存到本地文件系统中，权限设置为 0400（仅所有者可读）。

#这个是public key
resource "tls_private_key" "bastion_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "bastion_keypair" {
  key_name   = "bastion-key"
  public_key = tls_private_key.bastion_key.public_key_openssh
}


# Save the private key locally

resource "local_file" "bastion_private_key" {
  content         = tls_private_key.bastion_key.private_key_pem
  filename        = "bastion-key.pem" # 当你创建 EC2 实例时，需要使用这个私钥文件来 SSH 连接到 Bastion Host。 运行terraform的时候会在本地生成
  file_permission = "0400"
}

# Security Group for Bastion

resource "aws_security_group" "bastion_sg" {
  name   = "bastion-sg"
  vpc_id = module.vpc.vpc_id

  ingress {
    description = "SSH from my IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.my_ip.response_body)}/32"]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "bastion-sg"
  }
}


# Bastion Host

module "bastion_host" {
  source  = "terraform-aws-modules/ec2-instance/aws"

  name = "bastion-host"
  ami = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  key_name      = aws_key_pair.bastion_keypair.key_name
  monitoring    = true

  subnet_id              = element(module.vpc.public_subnets, 0)
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]

  associate_public_ip_address = true # 这个是jmpbox ,我们需要access from public / outside

  tags = {
    Terraform   = "true"
    Environment = "dev"
    Role        = "bastion"
  }
}

