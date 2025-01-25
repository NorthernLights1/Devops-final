# Terraform code to provision 5 EC2 instances and set up integration with Ansible
# Each instance is assigned a specific role (e.g., Jenkins Master, Kubernetes Agent, etc.)
# Instances will be t2.micro, using a specified AMI ID, and prepared for Ansible automation

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

# Security group allowing SSH and HTTP/HTTPS access
resource "aws_security_group" "common_sg" {
  name        = "common-sg"
  description = "Allow SSH, HTTP, and HTTPS access"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
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

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Function to create an instance
resource "aws_instance" "jenkins_master" {
  ami           = var.instance_ami
  instance_type = var.instance_type
  
  security_groups = [aws_security_group.common_sg.name]

  tags = {
    Name = "jenkins-master"
  }

 

  provisioner "local-exec" {
    command = "echo '${self.public_ip} jenkins-master' >> ./ansible_inventory"
  }
}

resource "aws_instance" "jenkins_worker" {
  ami           = var.instance_ami
  instance_type = var.instance_type
  
  security_groups = [aws_security_group.common_sg.name]

  tags = {
    Name = "jenkins-worker"
  }

 

  provisioner "local-exec" {
    command = "echo '${self.public_ip} jenkins-worker' >> ./ansible_inventory"
  }
}

resource "aws_instance" "kubernetes_master" {
  ami           = var.instance_ami
  instance_type = "t3a.medium"
  
  security_groups = [aws_security_group.common_sg.name]

  tags = {
    Name = "kubernetes-master"
  }

 

  provisioner "local-exec" {
    command = "echo '${self.public_ip} kubernetes-master' >> ./ansible_inventory"
  }
}

resource "aws_instance" "kubernetes_agent" {
  ami           = var.instance_ami
  instance_type = "t3a.medium"
  
  security_groups = [aws_security_group.common_sg.name]

  tags = {
    Name = "kubernetes-agent"
  }

 

  provisioner "local-exec" {
    command = "echo '${self.public_ip} kubernetes-agent' >> ./ansible_inventory"
  }
}

resource "aws_instance" "pg_instance" {
  ami           = var.instance_ami
  instance_type = var.instance_type
  
  security_groups = [aws_security_group.common_sg.name]

  tags = {
    Name = "PG-instance"
  }

 

  provisioner "local-exec" {
    command = "echo '${self.public_ip} pg-instance' >> ./ansible_inventory"
  }
}

# Output the generated Ansible inventory
output "ansible_inventory" {
  value = "cat ./ansible_inventory"
}
