# output "card_output" {
#     description = "Outputs card detail for subscription"
#     value = "${data.rediscloud_payment_method.card}"
# }

output "db_id_for_pro_standard_db" {
    value = rediscloud_subscription_database.rec-database.id
}

output "public_endpoint_for_pro_standard_db" {
    value = rediscloud_subscription_database.rec-database.public_endpoint
}

output "private_endpoint_for_pro_standard_db" {
    value = rediscloud_subscription_database.rec-database.private_endpoint
}