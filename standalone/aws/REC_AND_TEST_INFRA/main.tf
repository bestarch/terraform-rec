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

data "rediscloud_payment_method" "card" {
  last_four_numbers = var.CC_last_four_numbers
}

data "rediscloud_cloud_account" "rlabs_cloud_account" {
  exclude_internal_account = true
  provider_type = "AWS"
}

resource "rediscloud_subscription" "rec_subscription" {
  name = "${var.prefix}-sub-${random_string.suffix.result}"

  # If you want to pay with a marketplace account, replace this line with payment_method = 'marketplace'.
  payment_method_id = data.rediscloud_payment_method.card.id 
  memory_storage = var.is_rof ? "ram-and-flash" : "ram"
  redis_version  = "7.4"

  cloud_provider {
    provider = "AWS"
    #cloud_account_id = data.rediscloud_cloud_account.rlabs_cloud_account.id
    region {
      region = var.region_primary
      multiple_availability_zones  = true
      networking_deployment_cidr = var.deployment_cidr_primary
    }
  }

  creation_plan {
    dataset_size_in_gb = var.dataset_size
    quantity = 1
    replication = var.replication
    throughput_measurement_by = "operations-per-second"
    throughput_measurement_value = var.throughput
    support_oss_cluster_api = var.support_oss_cluster_api
  }

  maintenance_windows {
    mode = "automatic"
  }

  depends_on = [
    random_string.suffix
  ]
}

resource "rediscloud_subscription_database" "rec-database" {
  subscription_id = rediscloud_subscription.rec_subscription.id
  name = "${var.prefix}-db-${random_string.suffix.result}"
  dataset_size_in_gb = var.dataset_size
  data_persistence = var.data_persistence
  throughput_measurement_by = "operations-per-second"
  throughput_measurement_value = var.throughput
  replication = var.replication
  data_eviction = var.eviction_policy
  support_oss_cluster_api = var.support_oss_cluster_api
  password = var.password
  enable_tls = var.enable_tls
  average_item_size_in_bytes = var.is_rof ? var.payload_size : null

  dynamic "modules" {
    for_each = var.is_rof ? [] : [{ name = "RedisJSON" },{ name = "RediSearch" }]
    content {
      name = modules.value.name
    }
  }

  tags = {
    "owner" = var.prefix
  }
}
