variable "region" {
  type = string
  default = "eu-north-1"
}


variable "vcp_cidr" {
  default = "10.0.0.0/16"
}
variable "env" {
  default = "dev"
}

variable "public_subnet_ciders" {
  default = [
    "10.0.1.0/24",
    "10.0.2.0/24"]
}
variable "private_subnet_ciders" {
  default = [
    "10.0.11.0/24",
    "10.0.22.0/24"]
}

#variable "aws_access_key" {
 # type    = string
  #default = "xxx"
#}#
#variable "aws_secret_key" {
  #type    = string
  #default = "xxx"
#}

variable "security_port" {
  type = list 
  default = ["80", "433", "8080", "22"]
}

variable "instance_type" {
  type = string
  default = "t3.micro"
}

variable "ami" {
 type = string
 default = "ami-0ed17ff3d78e74700"  
}
