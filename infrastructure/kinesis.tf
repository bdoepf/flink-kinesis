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

