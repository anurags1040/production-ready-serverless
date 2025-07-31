module "dynamodb_restaurants_table" {
  source  = "terraform-aws-modules/dynamodb-table/aws"
  version = "~> 4.0"

  name        = "${var.service_name}-restaurants-${var.stage_name}"
  hash_key    = "name"
  attributes  = [
    {
      name = "name"
      type = "S"
    }
  ]
}

resource "aws_cognito_user_pool" "main" {
  name = "${var.service_name}-${var.stage_name}-UserPool"

  alias_attributes         = ["email"]
  auto_verified_attributes = ["email"]

  username_configuration {
    case_sensitive = true
  }

  password_policy {
    minimum_length    = 8
    require_lowercase = true
    require_numbers   = true
    require_symbols   = true
    require_uppercase = true
  }

  # Required standard attributes
  schema {
    name                = "given_name"
    attribute_data_type = "String"
    required            = true
    mutable             = true
  }

  schema {
    name                = "family_name"
    attribute_data_type = "String"
    required            = true
    mutable             = true
  }

  schema {
    name                = "email"
    attribute_data_type = "String"
    required            = true
    mutable             = true    
  }
}

# Web client
resource "aws_cognito_user_pool_client" "web_client" {
  name         = "web_client"
  user_pool_id = aws_cognito_user_pool.main.id

  prevent_user_existence_errors = "ENABLED"

  explicit_auth_flows = [
    "ALLOW_USER_SRP_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH"
  ]
}

# Server client
resource "aws_cognito_user_pool_client" "server_client" {
  name         = "server_client"
  user_pool_id = aws_cognito_user_pool.main.id

  prevent_user_existence_errors = "ENABLED"

  explicit_auth_flows = [
    "ALLOW_ADMIN_USER_PASSWORD_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH"
  ]
}




