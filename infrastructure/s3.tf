resource "aws_s3_bucket" "bucket" {
  bucket_prefix = "kinesis-flink"
  acl           = "private"
}

resource "aws_s3_bucket_object" "kinesis-flink-jar" {
  bucket = aws_s3_bucket.bucket.bucket
  key    = "applications/flink-kinesis.jar"
  source = var.kinesis-flink-jar-path

  etag = filemd5(var.kinesis-flink-jar-path)
}
