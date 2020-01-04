resource "aws_cloudwatch_log_group" "kinesis-analytics-flink" {
  name = "kinesis-analytics-flink"

  retention_in_days = 7
}

resource "aws_cloudwatch_log_stream" "kinesis-flink-s3" {
  name           = "kinesis-flink-s3"
  log_group_name = aws_cloudwatch_log_group.kinesis-analytics-flink.name
}
