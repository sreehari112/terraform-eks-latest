#
# Variables Configuration
#

variable "cluster-name" {
  default = "terraform-eks-automation-cluster"
  type    = string
}

variable "region" {
 description = "Enter region"
 default = "us-east-1"
}

variable "profile"{
description = "Enter the profile"
default = "shiva"
}

variable "instance_type"{
  description = "Choose instance type"
   default = "t2.micro"
}

variable "instance_ami"{
  description = "Choose ami for instance"
  default = "ami-*******"
}

variable "instance_key"{
  description = "provide the key pair"
  default = "h******"
}

variable "server_name"{
  default = "terraform-eks-client"
}
