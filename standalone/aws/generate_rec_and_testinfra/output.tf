# This Terraform script sets up AWS Redis Cloud DB with a test infrastructure on AWS, including a VPC, subnet, security group, and an EC2 instance with Redis CLI and memtier-benchmark installed.

output "test_VM_public_IP_address" {
  value = aws_instance.test_vm[0].public_ip
}
output "test_VM_private_IP_address" {
  value = aws_instance.test_vm[0].private_ip
}

output "redislabs_cloud_account_name" {
  description = "Name of the Redis Labs cloud account used for the subscription"
  value = data.rediscloud_cloud_account.rlabs_cloud_account.name
}
