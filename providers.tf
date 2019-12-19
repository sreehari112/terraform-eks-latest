#
# Provider Configuration
#

provider "aws" {
  region  = var.region
  profile = var.profile
}

data "aws_availability_zones" "available" {}

provider "http" {}
