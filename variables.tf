variable "region" {
  description = "The AWS region to deploy our resources"
  type        = string
}

variable "ami" {
  description = "The AWS ami to use"
  type        = string
}

variable "instance_type" {
  description = "The AWS instance type for the VM"
  type        = string
}

variable "key_name" {
  description = "The key-pair name for SSH access"
  type        = string
}

variable "ssh_key_pub" {
  default     = "id_rsa.pub"
  description = "Path to the SSH public key"
}

variable "ssh_key_priv" {
  default     = "id_rsa"
  description = "Path to the SSH private key"
}

