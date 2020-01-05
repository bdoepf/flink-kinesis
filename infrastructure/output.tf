output "region" {
  value = var.region
}

output stream_name {
  value = var.kinesis-stream-name
}

output "role_arn" {
  value = aws_iam_role.kinesis-analytics-flink-s3.arn
}

output "bucket_name" {
  value = aws_s3_bucket.bucket.bucket
}

output "log_stream_arn" {
  value = aws_cloudwatch_log_stream.kinesis-flink-s3.arn
}
