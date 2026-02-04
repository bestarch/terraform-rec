terraform {
  required_providers {
    rediscloud = {
      source = "RedisLabs/rediscloud"
      version = "2.10.4"
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

resource "rediscloud_active_active_subscription" "subscription-aa" {
  name = "${var.prefix}-aa-sub-${random_string.suffix.result}"
  payment_method_id = data.rediscloud_payment_method.card.id 
  cloud_provider = "AWS"

  creation_plan {
    dataset_size_in_gb = var.dataset_size
    quantity = 1
    # modules = ["RedisJSON", "RediSearch"]
    region {
      region = var.region_primary
      networking_deployment_cidr = var.deployment_cidr_primary
      write_operations_per_second = var.write_ops_primary
      read_operations_per_second = var.read_ops_primary
    }
    region {
      region = var.region_secondary
      networking_deployment_cidr = var.deployment_cidr_secondary
      write_operations_per_second = var.write_ops_secondary
      read_operations_per_second = var.read_ops_secondary
    }
  }

  maintenance_windows {
    mode = "automatic"
  }

   depends_on = [
    random_string.suffix
   ]   

}

resource "rediscloud_active_active_subscription_database" "database-resource" {
    subscription_id = rediscloud_active_active_subscription.subscription-aa.id
    name = "${var.prefix}-aa-sub-${random_string.suffix.result}"
    dataset_size_in_gb = var.dataset_size
    global_data_persistence = var.data_persistence
    global_password = var.password 
    #global_source_ips = ["192.168.0.0/16"]
    # global_alert {
    #   name = "dataset-size"
    #   value = 1
    # }

    # global_modules = ["RedisJSON", "RediSearch"]

    override_region {
      name = "${var.prefix}-${var.region_primary}"
      #override_global_source_ips = ["192.10.0.0/16"]
    }

    override_region {
      name = "${var.prefix}-${var.region_secondary}"
      #override_global_data_persistence = "none"
      #override_global_password = "region-specific-password"
      # override_global_alert {
      #   name = "dataset-size"
      #   value = 60
      # }
   }

    tags = {
      "owner" = var.prefix
    }
}


resource "rediscloud_active_active_subscription_regions" "regions-resource" {
    subscription_id = rediscloud_active_active_subscription.subscription-aa.id
    delete_regions = false
    region {
      region = var.region_primary
      networking_deployment_cidr = var.deployment_cidr_primary
      database {
          database_id = rediscloud_active_active_subscription_database.database-resource.db_id
          database_name = rediscloud_active_active_subscription_database.database-resource.name
          local_write_operations_per_second = var.write_ops_primary
          local_read_operations_per_second = var.read_ops_primary
      }
    }
    region {
      region = var.region_secondary
      networking_deployment_cidr = var.deployment_cidr_secondary
      #local_resp_version = "resp2"
      database {
          database_id = rediscloud_active_active_subscription_database.database-resource.db_id
          database_name = rediscloud_active_active_subscription_database.database-resource.name
          local_write_operations_per_second = var.write_ops_secondary
          local_read_operations_per_second = var.read_ops_secondary
      }
      }
 }
