output "count_table" {
  value = aws_dynamodb_table.visitorCount
}

output "lambda_arn" {
  value = aws_lambda_function.lambda_count.invoke_arn
}
