terraform {
  required_providers {
    rediscloud = {
      source = "RedisLabs/rediscloud"
      version = "2.1.4"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "5.99.1"
    }
  }
}

provider "rediscloud" {
  # Configuration options
}

resource "random_string" "suffix" {
  length  = 4
  special = false
  upper   = true
  lower   = false
  numeric = true              
}

data "rediscloud_subscription" "rec_subscription" {
  name = var.rec_subs_name
}
