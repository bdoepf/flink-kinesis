resource "aws_kinesis_stream" "stream" {
  name             = var.kinesis-stream-name
  shard_count      = var.kinesis-num-shards
  retention_period = 24

  shard_level_metrics = [
    "IncomingBytes",
    "OutgoingBytes",
  ]

  enforce_consumer_deletion = true
}

locals {
  create-request-filename = "create_request.json"
  start-request-filename  = "start_request.json"
  application-name        = "kinesis-flink-s3"
}

data "template_file" "kinsis-analytics-flink" {
  template = file("${path.module}/create_request.json.tpl")
  vars     = {
    application-name    = local.application-name
    role-arn            = aws_iam_role.kinesis-analytics-flink-s3.arn
    bucket-arn          = aws_s3_bucket.bucket.arn
    kinesis-app-jar-key = aws_s3_bucket_object.kinesis-flink-jar.id
    region              = var.region
    stream-name         = aws_kinesis_stream.stream.name
    output-path         = "s3a://${aws_s3_bucket.bucket.bucket}/data/"
    log-stream-arn      = aws_cloudwatch_log_stream.kinesis-flink-s3.arn
  }
}

resource "local_file" "kinsis-analytics-flink" {
  content  = data.template_file.kinsis-analytics-flink.rendered
  filename = "${path.module}/${local.create-request-filename}"
}

resource "null_resource" "kinesis-analytics-flink" {
  depends_on = [
    local_file.kinsis-analytics-flink,
  ]

  triggers = {
    application-jar = aws_s3_bucket_object.kinesis-flink-jar.etag
    //    create-request-json = filemd5(local_file.kinsis-analytics-flink.filename)
  }

  provisioner "local-exec" {
    when    = destroy
    command = "aws --region eu-west-1 kinesisanalyticsv2 describe-application --application-name kinesis-flink-s3 | jq '.ApplicationDetail | {ApplicationName: .ApplicationName, CreateTimestamp: .CreateTimestamp}' > delete_request.json && aws --region ${var.region} kinesisanalyticsv2 delete-application --cli-input-json file://delete_request.json"
  }

  provisioner "local-exec" {
    command = "aws --region ${var.region} kinesisanalyticsv2 create-application --cli-input-json file://${local.create-request-filename} && aws --region ${var.region} kinesisanalyticsv2 start-application --cli-input-json file://${local.start-request-filename}"
  }

}
