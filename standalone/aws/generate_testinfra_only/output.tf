# This Terraform script sets up a test infrastructure on AWS for Redis Cloud, including a VPC, subnet, security group, and an EC2 instance with Redis CLI and memtier-benchmark installed.

output "test_VM_public_IP_address" {
  value = aws_instance.test_vm[0].public_ip
}
output "test_VM_private_IP_address" {
  value = aws_instance.test_vm[0].private_ip
}
