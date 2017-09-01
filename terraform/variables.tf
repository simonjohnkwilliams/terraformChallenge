variable "access_key" {}
variable "secret_key" {}
variable "aws_key_path" {}
variable "aws_key_name" {}

variable "region" {
	default = "eu-west-2"
}
variable "vpc_cidr" {
    description = "CIDR for the whole VPC"
    default = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
    description = "CIDR for the Public Subnet"
    default = "10.0.0.0/24"
}

variable "private_subnet_cidr" {
    description = "CIDR for the Private Subnet"
    default = "10.0.1.0/24"
}