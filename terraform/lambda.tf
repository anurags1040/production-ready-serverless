module "get_index_lambda" {
  source = "terraform-aws-modules/lambda/aws"
  version = "~> 7.0"

  function_name = "${var.service_name}-${var.stage_name}-get-index"
  handler       = "index.handler"
  runtime       = "nodejs20.x"
  memory_size   = 1024
  timeout       = 6

  source_path = [{
    path = "${path.module}/../functions/get-index",
    commands = [
      "rm -rf node_modules",
      "npm ci --omit=dev",
      ":zip"
    ]
  }]

  environment_variables = {
    restaurants_api = "https://${aws_api_gateway_rest_api.main.id}.execute-api.${var.aws_region}.amazonaws.com/${var.stage_name}/restaurants"
  }

  attach_policy_statements = true
  policy_statements = {
    dynamodb_read = {
      effect = "Allow"
      actions = [      
        "execute-api:Invoke"
      ]
      resources = [
        "${aws_api_gateway_rest_api.main.execution_arn}/${var.stage_name}/GET/restaurants"
      ]
    }    
  }

  publish = true
  
  allowed_triggers = {
    APIGatewayGet = {
      service    = "apigateway"
      source_arn = "${aws_api_gateway_rest_api.main.execution_arn}/${var.stage_name}/GET/"
    }
  }
  
  cloudwatch_logs_retention_in_days = 7
}

module "get_restaurants_lambda" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "~> 7.0"

  function_name = "${var.service_name}-${var.stage_name}-get-restaurants"
  handler       = "index.handler"
  runtime       = "nodejs20.x"
  memory_size   = 1024
  timeout       = 6

  source_path = [{
    path = "${path.module}/../functions/get-restaurants"
  }]

  environment_variables = {
    default_results = "8"
    restaurants_table = module.dynamodb_restaurants_table.dynamodb_table_id
  }

  attach_policy_statements = true
  policy_statements = {
    dynamodb_read = {
      effect = "Allow"
      actions = [      
        "dynamodb:Scan"
      ]
      resources = [module.dynamodb_restaurants_table.dynamodb_table_arn]
    }    
  }

  publish = true
  
  allowed_triggers = {
    APIGatewayGet = {
      service    = "apigateway"
      source_arn = "${aws_api_gateway_rest_api.main.execution_arn}/${var.stage_name}/GET/restaurants"
    }
  }

  cloudwatch_logs_retention_in_days = 7
}

module "search_restaurants_lambda" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "~> 7.0"

  function_name = "${var.service_name}-${var.stage_name}-search-restaurants"
  handler       = "index.handler"
  runtime       = "nodejs20.x"
  memory_size   = 1024
  timeout       = 6

  source_path = [{
    path = "${path.module}/../functions/search-restaurants"
  }]

  environment_variables = {
    default_results = "8"
    restaurants_table = module.dynamodb_restaurants_table.dynamodb_table_id
  }

  attach_policy_statements = true
  policy_statements = {
    dynamodb_read = {
      effect = "Allow"
      actions = [      
        "dynamodb:Scan"
      ]
      resources = [module.dynamodb_restaurants_table.dynamodb_table_arn]
    }    
  }

  publish = true
  
  allowed_triggers = {
    APIGatewayGet = {
      service    = "apigateway"
      source_arn = "${aws_api_gateway_rest_api.main.execution_arn}/${var.stage_name}/POST/restaurants/search"
    }
  }

  cloudwatch_logs_retention_in_days = 7
}


