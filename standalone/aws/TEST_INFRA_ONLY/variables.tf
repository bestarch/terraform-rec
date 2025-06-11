## Set Env variables for REDISCLOUD_SECRET_KEY & REDISCLOUD_ACCESS_KEY

variable "prefix" {
  description = "Prefix of the resources to be created"
  type        = string
  default     = "abhi"
}

variable "region_primary" {
  description = "Primary region where Redis is deployed"
  type        = string
  default = "ap-south-1"
}

variable "deployment_cidr_primary" {
  description = "Network CIDR block for primary region"
  type        = string
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

variable "create_test_vm" {
  description = "Setting to create a test VM with peering cnnection to Redis"
  type        = bool
  default     = false
}

variable "application_vpc_cidr" {
  description = "CIDR block for the application VPC"
  type        = string
  default     = "11.1.0.0/16"
}

variable "application_subnet_cidr" {
  description = "CIDR block for the application subnet"
  type        = string
  default     = "11.1.0.0/20"
}

variable "aws_access_key" {
  description = "AWS access key"
  type        = string
  sensitive = true
}

variable "aws_secret_key" {
  description = "AWS secret key"
  type        = string
  sensitive = true
}

variable "availability_zone" {
  description = "AWS AZ for the VM and subnet"
  type        = string
  default     = "ap-south-1a"
} 

variable "rec_subs_name" {
  description = "Redis Cloud subscription name"
  type        = string
} 

variable "rec_dbname" {
  description = "Redis Cloud database name"
  type        = string
}
