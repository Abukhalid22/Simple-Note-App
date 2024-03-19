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

