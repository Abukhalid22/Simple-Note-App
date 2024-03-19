# **Terraform AWS Infrastructure Setup Guide**

This guide will walk through the process of deploying a basic infrastructure on AWS, including a Virtual Private Cloud (VPC), subnet, internet gateway, route table, security group, and an EC2 instance. Each step will be explained thoroughly, along with the purpose of each configuration.

### **Step 1: Main.tf**

```
resource "aws_vpc" "my_vpc" {
  cidr_block            = var.vpc_cidr_block
  enable_dns_support    = true
  enable_dns_hostnames  = true
}

resource "aws_subnet" "my_subnet" {
  vpc_id                = aws_vpc.my_vpc.id
  cidr_block            = var.subnet_cidr_block
  availability_zone     = var.availability_zone
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "my_igw" {
  vpc_id                = aws_vpc.my_vpc.id
}

resource "aws_route_table" "my_route_table" {
  vpc_id                = aws_vpc.my_vpc.id

  route {
    cidr_block          = "0.0.0.0/0"
    gateway_id          = aws_internet_gateway.my_igw.id
  }
}

resource "aws_route_table_association" "my_route_table_association" {
  subnet_id             = aws_subnet.my_subnet.id
  route_table_id        = aws_route_table.my_route_table.id
}

resource "aws_security_group" "my_security_group" {
  name_prefix           = "my-security-group-"
  description           = "Allow SSH and web traffic"
  vpc_id                = aws_vpc.my_vpc.id

  ingress {
    description         = "Allow SSH access from anywhere"
    from_port           = 22
    to_port             = 22
    protocol            = "tcp"
    cidr_blocks         = ["0.0.0.0/0"]  # Allow SSH access from anywhere
  }

  ingress {
    description         = "Allow HTTP access from anywhere"
    from_port           = 80
    to_port             = 80
    protocol            = "tcp"
    cidr_blocks         = ["0.0.0.0/0"]  # Allow HTTP access from anywhere
  }

  # Allow Django traffic on port 8000 from anywhere
  ingress {
    description         = "Allow Django access from anywhere"
    from_port           = 8000
    to_port             = 8000
    protocol            = "tcp"
    cidr_blocks         = ["0.0.0.0/0"] # Allow Django access from anywhere
  }

  # Allow React traffic on port 30002 from anywhere
  ingress {
    description         = "Allow react access from anywhere"
    from_port           = 30002
    to_port             = 30002
    protocol            = "tcp"
    cidr_blocks         = ["0.0.0.0/0"] # Allow react access from anywhere
  }

 ingress {
    description         = "Allow Argo CD access and port forwarding from anywhere"
    from_port           = 8080
    to_port             = 8080
    protocol            = "tcp"
    cidr_blocks         = ["0.0.0.0/0"]
  }

  egress {
    from_port           = 0
    to_port             = 0
    protocol            = "-1"
    cidr_blocks         = ["0.0.0.0/0"]  # Allow all outbound traffic
  }
}

resource "aws_instance" "my_ec2_instance" {
  ami                           = var.instance_ami
  instance_type                 = var.instance_type
  subnet_id                     = aws_subnet.my_subnet.id
  key_name                      = var.key_name
  vpc_security_group_ids        = [aws_security_group.my_security_group.id]
  user_data = base64encode(file(var.user_data_file))
}

output "public_ip" {
  description = "Public IP Address of the EC2 Instance"
  value       = aws_instance.my_ec2_instance.public_ip
}

```

Explanation:

- **aws_vpc**: This resource creates a Virtual Private Cloud (VPC) in AWS. A VPC is a logically isolated section of the AWS Cloud where you can launch AWS resources in a virtual network.
- **aws_subnet**: This resource creates a subnet within the VPC. Subnets are segments of a VPC's IP address range that you can assign to resources.
- **aws_internet_gateway**: This resource creates an internet gateway, allowing the VPC to connect to the internet.
- **aws_route_table**: This resource defines a route table for the VPC, specifying the route for internet-bound traffic through the internet gateway.
- **aws_route_table_association**: This resource associates the subnet with the route table.
- **aws_security_group**: This resource creates a security group, which acts as a virtual firewall for the EC2 instance, controlling inbound and outbound traffic.
- **aws_instance**: This resource launches an EC2 instance, specifying its AMI, instance type, subnet, security group, and user data.

### **Step 2: Variables.tf**

```
variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cidr_block" {
  description = "CIDR block for the subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "availability_zone" {
  description = "Availability zone for the subnet"
  type        = string
  default     = "us-east-1a"
}

variable "instance_ami" {
  description = "AMI ID for the EC2 instance"
  type        = string
  default     = "ami-"  # Replace with your desired AMI ID
}

variable "instance_type" {
  description = "Instance type for the EC2 instance"
  type        = string
  default     = "T2.---"
}

variable "key_name" {
  description = "Name of the EC2 key pair"
  type        = string
  default     = "----"
}

variable "user_data_file" {
  description = "Path to the user data file for the EC2 instance"
  type        = string
  default     = "userdata.sh"
}

```

Explanation:

- **Variables.tf** contains declarations for various variables used in the Terraform configuration. These variables allow for customization of the infrastructure parameters such as VPC CIDR block, subnet CIDR block, availability zone, EC2 instance AMI ID, instance type, key name, and user data file path.

### **Step 3: Provider.tf**

```
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.40.0"
    }
  }
}

provider "aws" {
  # Configuration options
  region = "us-east-1"
}

```

Explanation:

- **Provider.tf** specifies the Terraform provider and its configuration. In this case, it configures the AWS provider with the specified region.

### **Step 4: Userdata.sh**

```bash
#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Log all output to file
exec >> /var/log/userdata.log 2>&1

echo "Starting initialization script..."

# Update package lists and install any available updates
sudo apt update -y
sudo apt upgrade -y

# Install essential utilities
sudo apt install -y curl wget git python3 python3-pip nodejs npm

# Install Docker
sudo apt install -y docker.io
sudo systemctl enable --now docker

# Add current user to the docker group
sudo usermod -aG docker ubuntu

sleep 15

# Install Gunicorn
sudo apt install -y gunicorn

# Install AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
sudo apt install unzip -y
unzip awscliv2.zip
sudo ./aws/install

# Install kubectl
sudo apt update
sudo apt install curl -y
sudo curl -LO "https://dl.k8s.io/release/v1.28.4/bin/linux/amd64/kubectl"
sudo chmod +x kubectl
sudo mv kubectl /usr/local/bin/
kubectl version --client

# Install Minikube
curl -LO "https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64"
sudo chmod +x minikube-linux-amd64
sudo mv minikube-linux-amd64 /usr/local/bin/minikube

# Start Minikube cluster with Docker driver
# Run Minikube as the non-root user
sudo -u ubuntu minikube start --driver=docker

# Wait for Minikube to start
echo "Waiting for Minikube to start..."
sleep 30

# Enable Minikube addons
sudo -u ubuntu minikube addons enable ingress

# Install Argo CD with Kubectl
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/v2.4.7/manifests/install.yaml
sudo apt install jq -y

# Installing Helm
sudo snap install helm --classic

# Adding Helm repositories
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

# Install Prometheus
helm install prometheus prometheus-community/kube-prometheus-stack --namespace monitoring --create-namespace

# Install Grafana
helm install grafana grafana/grafana --namespace monitoring --create-namespace

# Install ingress-nginx
helm install ingress-nginx ingress-nginx/ingress-nginx

# Clone your project repository (Optional)
----

# Print instructions for accessing your application
echo "Your application has been deployed successfully."
echo "Initialization script completed successfully."

```

Explanation:

- **Userdata.sh** is a bash script that will be executed on the EC2 instance during initialization. It performs the following tasks:
    - Updates package lists and installs available updates.
    - Installs essential utilities such as curl, wget, git, Python, Node.js, and npm.
    - Installs Docker and adds the current user to the Docker group.
    - Installs Gunicorn, AWS CLI, kubectl, Minikube, and other necessary tools for Kubernetes and Docker management.
    - Starts Minikube with the Docker driver and enables required addons.
    - Installs Argo CD using kubectl, Helm, Prometheus, Grafana, and Ingress-Nginx.
    - Clones a project repository and provides instructions for accessing the deployed application.
