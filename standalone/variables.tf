## Set Env variables for REDISCLOUD_SECRET_KEY & REDISCLOUD_ACCESS_KEY

variable "prefix" {
  description = "Prefix of the resources to be created"
  type        = string
  default     = "abhi"
}

variable "CC_last_four_numbers" {
  description = "Last 4 digit of the CC"
  type        = string
}

variable "region_primary" {
  description = "Primary region where Redis is deployed"
  type        = string
  default = "asia-south1"
}

variable "deployment_cidr_primary" {
  description = "Network CIDR block for primary region"
  type        = string
}

variable "dataset_size" {
  description = "Dataset size of DB"
  type        = number
}

variable "throughput" {
  description = "Supported throughput of DB"
  type        = number
}

variable "eviction_policy" {
  description = "Eviction policy for the DB"
  type        = string
}

variable "replication" {
  description = "Replication policy for the database"
  type        = bool
}

variable "data_persistence" {
  description = "Data persistence policy for the database"
  type        = string
}

variable "support_oss_cluster_api" {
  description = "OSS cluster policy for the database"
  type        = bool
}

variable "enable_tls" {
  description = "TLS setting for the database"
  type        = bool
}

variable "password" {
  description = "Default password to connect to the database"
  type        = string
  sensitive = true
}
