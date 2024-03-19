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

