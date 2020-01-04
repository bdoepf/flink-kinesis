variable "region" {
  description = "AWS region to deploy the aws resources to"
  default = "eu-west-1"
}
variable "kinesis-stream-name" {
  description = "Name of the kinesis stream to deploy"
  default = "test-stream"
}

variable "kinesis-num-shards" {
  description = "Number of shards of the kinesis stream"
  default = 1
}

variable "kinesis-flink-jar-path" {
  description = "Path to the flink fat jar to upload"
  default = "../target/scala-2.11/flink-kinesis-assembly-0.1.jar"
}
