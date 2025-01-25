provider "aws" {
  region = "us-east-2"
}

variable "instance_ami" {
  description = "AMI ID to use for all instances"
  default     = "ami-08970251d20e940b0"
}

variable "instance_type" {
  description = "Instance type to use for all instances"
  default     = "t2.micro"
}

# Security group allowing necessary access
resource "aws_security_group" "common_sg" {
  name        = "common-sg"
  description = "Allow necessary access for SSH, HTTP, HTTPS, Jenkins, Kubernetes, and monitoring"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 50000
    to_port     = 50000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 10250
    to_port     = 10250
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 2379
    to_port     = 2380
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 30000
    to_port     = 32767
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 instances
resource "aws_instance" "jenkins_master" {
  ami           = var.instance_ami
  instance_type = var.instance_type
  security_groups = [aws_security_group.common_sg.name]

  tags = {
    Name = "jenkins-master"
  }
}

resource "aws_instance" "jenkins_worker" {
  ami           = var.instance_ami
  instance_type = var.instance_type
  security_groups = [aws_security_group.common_sg.name]

  tags = {
    Name = "jenkins-worker"
  }
}

resource "aws_instance" "kubernetes_master" {
  ami           = var.instance_ami
  instance_type = "t3a.medium"
  security_groups = [aws_security_group.common_sg.name]

  tags = {
    Name = "kubernetes-master"
  }
}

resource "aws_instance" "kubernetes_agent" {
  ami           = var.instance_ami
  instance_type = "t3a.medium"
  security_groups = [aws_security_group.common_sg.name]

  tags = {
    Name = "kubernetes-agent"
  }
}

resource "aws_instance" "pg_instance" {
  ami           = var.instance_ami
  instance_type = var.instance_type
  security_groups = [aws_security_group.common_sg.name]

  tags = {
    Name = "PG-instance"
  }
}

# Output the generated Ansible inventory in YAML format
output "ansible_inventory" {
  value = yamlencode({
    all = {
      hosts = {
        jenkins_master = {
          ansible_host = aws_instance.jenkins_master.public_ip
          ansible_user = "ec2-user"
        }
        jenkins_worker = {
          ansible_host = aws_instance.jenkins_worker.public_ip
          ansible_user = "ec2-user"
        }
        kubernetes_master = {
          ansible_host = aws_instance.kubernetes_master.public_ip
          ansible_user = "ec2-user"
        }
        kubernetes_agent = {
          ansible_host = aws_instance.kubernetes_agent.public_ip
          ansible_user = "ec2-user"
        }
        pg_instance = {
          ansible_host = aws_instance.pg_instance.public_ip
          ansible_user = "ec2-user"
        }
      }
    }
  })
}
