resource "aws_s3_bucket" "bucket" {
  bucket_prefix = "kinesis-flink"
  acl           = "private"
}
