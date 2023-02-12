resource "aws_api_gateway_rest_api" "resume-count" {
  name        = "resume-count"
  description = "This is my API that invokes a lambda function that counts and updates a database"


  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_resource" "resume-count" {
  parent_id   = aws_api_gateway_rest_api.resume-count.root_resource_id
  path_part   = "visitorCounter"
  rest_api_id = aws_api_gateway_rest_api.resume-count.id

}

resource "aws_api_gateway_method" "resume-count" {
  authorization = "NONE"
  http_method   = "GET"
  resource_id   = aws_api_gateway_resource.resume-count.id
  rest_api_id   = aws_api_gateway_rest_api.resume-count.id
}

resource "aws_api_gateway_method_response" "resume-count" {
  rest_api_id = aws_api_gateway_rest_api.resume-count.id
  status_code = "200"
  resource_id = aws_api_gateway_resource.resume-count.id
  http_method = aws_api_gateway_method.resume-count.http_method

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true,
    "method.response.header.Access-Control-Allow-Methods" = true,
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
  depends_on = [aws_api_gateway_method.resume-count]
}

resource "aws_api_gateway_integration" "resume-count" {
  http_method             = aws_api_gateway_method.resume-count.http_method
  resource_id             = aws_api_gateway_resource.resume-count.id
  rest_api_id             = aws_api_gateway_rest_api.resume-count.id
  type                    = "AWS"
  uri                     = aws_lambda_function.lambda_count.invoke_arn
  integration_http_method = "GET"
  depends_on = [aws_lambda_function.lambda_count, aws_api_gateway_method.resume-count
  ]
}

resource "aws_api_gateway_integration_response" "resume-count" {
  http_method = aws_api_gateway_method.resume-count.http_method
  resource_id = aws_api_gateway_resource.resume-count.id
  rest_api_id = aws_api_gateway_rest_api.resume-count.id
  status_code = aws_api_gateway_method_response.resume-count.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'*'",
    "method.response.header.Access-Control-Allow-Methods" = "'*'",
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }

  depends_on = [aws_api_gateway_integration.resume-count]
}


resource "aws_api_gateway_deployment" "count_deployment" {
  rest_api_id = aws_api_gateway_rest_api.resume-count.id
  stage_name  = "test-stage"
  depends_on  = [aws_api_gateway_integration.resume-count]
}

