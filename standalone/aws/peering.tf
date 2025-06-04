
resource "rediscloud_subscription_peering" "peering" {
   subscription_id = rediscloud_subscription.rec_subscription.id
   region = var.region_primary
   vpc_id = data.aws_vpc.application_vpc.id
   vpc_cidr = data.aws_vpc.application_vpc.cidr_block
   aws_account_id = var.aws_account_id
   depends_on = [ rediscloud_subscription.rec_subscription ]
}

resource "aws_vpc_peering_connection_accepter" "peering-acceptor" {
  vpc_peering_connection_id = rediscloud_subscription_peering.peering.aws_peering_id
  auto_accept               = true
}

resource "aws_route" "to_peer_vpc" {
  route_table_id            = data.aws_route_table.rtb.id # or resource if you're managing it
  destination_cidr_block    = var.deployment_cidr_primary                # CIDR block of peer (acceptor) VPC
  vpc_peering_connection_id = rediscloud_subscription_peering.peering.aws_peering_id
  depends_on = [aws_vpc_peering_connection_accepter.peering-acceptor]
}

data "aws_route_table" "rtb" {
  filter {
    name   = "vpc-id"
    values = [var.application_vpc]  # VPC ID of requestor
  }

  filter {
    name   = "tag:Name"
    values = [var.route_table_name]     # Tag on the route table
  }
}