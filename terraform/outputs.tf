# Outputs for API Gateway URLs

# Base invoke URL for the REST API stage, e.g.
# https://abc123.execute-api.us-east-2.amazonaws.com/dev/
output "api_invoke_url" {
  description = "Base invoke URL for the REST API stage"
  value       = "${aws_api_gateway_stage.main.invoke_url}"
}

output "restaurants_table" {
  description = "The name of the restaurants table"
  value       = "${module.dynamodb_restaurants_table.dynamodb_table_id}"
}