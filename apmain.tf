# Dickson Kimani: Staking Facilities Task

provider "aws" {
  region = var.region
}

# Create the VPC
resource "aws_vpc" "main" {
  cidr_block = "10.200.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "DicksonUbuntuVPC"
  }
}

# Create subnet for the external interface
resource "aws_subnet" "external" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.200.1.0/24"
  map_public_ip_on_launch = true
  availability_zone = "eu-central-1a"
  tags = {
    Name = "ExternalSubnet"
  }
}

# Create subnet for the internal interface
resource "aws_subnet" "internal" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.200.16.0/28" # A /28 subnet to allow adding more hosts in future
  map_public_ip_on_launch = false
  availability_zone = "eu-central-1a"
  tags = {
    Name = "InternalSubnet"
  }
}

# Create the Internet Gateway for public access
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "InternetGateway"
  }
}

# Route table for the external subnet
resource "aws_route_table" "external_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "external_assoc" {
  subnet_id = aws_subnet.external.id
  route_table_id = aws_route_table.external_rt.id
}

# Security group for the external interface
resource "aws_security_group" "external_sg" {
  name        = "ExternalSG"
  description = "Allow external traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # To allow for SSH access
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # To allow HTTP traffic from anywhere
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # To allow HTTPS traffic from anywhere
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security group for the internal interface
resource "aws_security_group" "internal_sg" {
  name        = "InternalSG"
  description = "Allow internal traffic on port 9000"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = ["10.200.16.100/32"] # Allow traffic only from the single IP address of the device
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create the External Network Interface
resource "aws_network_interface" "external_interface" {
  subnet_id       = aws_subnet.external.id
  security_groups = [aws_security_group.external_sg.id]
  tags = {
    Name = "ExternalInterface"
  }
}

# Create the Internal Network Interface
resource "aws_network_interface" "internal_interface" {
  subnet_id       = aws_subnet.internal.id
  security_groups = [aws_security_group.internal_sg.id]
  tags = {
    Name = "InternalInterface"
  }
}


# Create the VM as a EC2 Ubuntu instance and install Python and Ansible on it
resource "aws_instance" "ubuntu_vm" {
  ami                  = var.ami
  instance_type        = var.instance_type
  key_name             = var.key_name
  network_interface {
    network_interface_id = aws_network_interface.external_interface.id
    device_index         = 0
  }

  network_interface {
    network_interface_id = aws_network_interface.internal_interface.id
    device_index         = 1
  }

  tags = {
    Name = "Dickson-TestUbuntuVM"
  }

  depends_on = [aws_network_interface.external_interface, aws_network_interface.internal_interface]
}


# Elastic IP for external interface
resource "aws_eip" "external_ip" {
  network_interface = aws_network_interface.external_interface.id
  depends_on = [aws_instance.ubuntu_vm]

  tags = {
    Name = "PublicEIP" #The public IP is auto-assigned as an AWS elastic IP 
  }
  provisioner "local-exec" {
    command = "sleep 60" # Add a delay to wait for the elastic IP to be allocated to the instance
  }
}


#Install Python and Ansible on the VM
resource "null_resource" "install_python_ansible" {
  depends_on = [aws_eip.external_ip]

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update -y",
      "sudo apt-get install -y ansible"
    ]

    connection {
      type        = "ssh"
      host        = aws_eip.external_ip.public_ip
      user        = "ubuntu"
      private_key = "${file(var.ssh_key_priv)}"
      timeout     = "2m"
    }
  }
}

#Copy the Ansible playbook from host to the remote VM and run it on remote
resource "null_resource" "copy_ansible_playbook" {
  depends_on = [aws_eip.external_ip, null_resource.install_python_ansible]

  provisioner "file" {
    source      = "./apache1.yml"  #Replace with correct playbook path if necessary
    destination = "/tmp/apache1.yml"

    connection {
      type        = "ssh"
      host        = aws_eip.external_ip.public_ip
      user        = "ubuntu"
      private_key = "${file(var.ssh_key_priv)}"
      timeout     = "2m"
    }
  }

  provisioner "remote-exec" {
    inline = [
      "#!/bin/bash",
      "sudo ansible-playbook /tmp/apache1.yml"
    ]

    connection {
      type        = "ssh"
      host        = aws_eip.external_ip.public_ip
      user        = "ubuntu"
      private_key = "${file(var.ssh_key_priv)}"
      timeout     = "2m"
    }
  }
}

