terraform {
  required_providers {
    rediscloud = {
      source = "RedisLabs/rediscloud"
      version = "2.0.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}

provider "rediscloud" {
  # Configuration options
}

resource "random_string" "suffix" {
  length  = 5
  special = false
  upper   = true
  lower   = true
  numeric = true              
}

data "rediscloud_payment_method" "card" {
  last_four_numbers = var.CC_last_four_numbers
}

resource "rediscloud_subscription" "subscription_pro_standard" {
     name = "${var.prefix}-sub-${random_string.suffix.result}"

     # If you want to pay with a marketplace account, replace this line with payment_method = 'marketplace'.
     payment_method_id = data.rediscloud_payment_method.card.id 
     memory_storage = "ram"
     redis_version  = "7.4"

     cloud_provider {
             provider = "GCP"
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
        modules = ["RedisJSON", "RediSearch"]
     }

     maintenance_windows {
        mode = "automatic"
     }

     depends_on = [
        random_string.suffix
    ]
}

// The primary database to provision
resource "rediscloud_subscription_database" "rec-database" {
    subscription_id = rediscloud_subscription.subscription_pro_standard.id
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

    modules = [
        {
          name = "RedisJSON"
        },
        {
          name = "RediSearch"
        }
    ]

    tags = {
      "owner" = var.prefix
    }
}

# resource "rediscloud_active_active_subscription" "subscription-aa" {
#   name = "${var.prefix}-aa-sub-${random_string.suffix.result}"
#   payment_method_id = data.rediscloud_payment_method.card.id 
#   cloud_provider = "GCP"

#   creation_plan {
#     memory_limit_in_gb = var.dataset_size
#     quantity = 1
#     modules = ["RedisJSON", "RediSearch"]
#     region {
#       region = var.region_primary
#       networking_deployment_cidr = var.deployment_cidr_primary
#       write_operations_per_second = var.write_ops_primary
#       read_operations_per_second = var.read_ops_primary
#     }
#     region {
#       region = var.region_secondary
#       networking_deployment_cidr = var.deployment_cidr_secondary
#       write_operations_per_second = var.write_ops_secondary
#       read_operations_per_second = var.read_ops_secondary
#     }
#   }

#   maintenance_windows {
#     mode = "automatic"
#   }

#    depends_on = [
#     random_string.suffix
#    ]   

# }
