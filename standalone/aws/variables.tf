## Set Env variables for REDISCLOUD_SECRET_KEY & REDISCLOUD_ACCESS_KEY

variable "prefix" {
  description = "Prefix of the resources to be created"
  type        = string
  default     = "abhi"
}

variable "CC_last_four_numbers" {
  description = "Last 4 digit of the CC"
  type        = string
  sensitive = true
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
  default = true
}

variable "data_persistence" {
  description = "Data persistence policy for the database"
  type        = string
}

variable "support_oss_cluster_api" {
  description = "OSS cluster policy for the database"
  type        = bool
  default = false
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

variable "is_rof" {
  description = "Store on RAM or Flash"
  type        = bool
  default     = false
}

variable "payload_size" {
  description = "Payload size of each item in bytes"
  type        = number
  default = 1000
}

variable "application_vpc" {
  description = "VPC where application is deployed or from where it will connect to Redis"
  type        = string
  sensitive = true
}

variable "application_subnet" {
  description = "Subnet where application is deployed or from where it will connect to Redis"
  type        = string
  sensitive = true
}

variable test_vm_type {
  description = "Type of the test VM to be created"
  type        = string
  default     = "c6a.8xlarge"
}

variable "key_pair_name" {
  description = "SSH Key pair name for the test VM"
  type        = string
  sensitive = true
}

variable "aws_account_id" {
  description = "AWS account ID for peering connection"
  type        = string
  sensitive = true
}

variable "route_table_name" {
  description = "Name of the route table to be used for peering"
  type        = string
}