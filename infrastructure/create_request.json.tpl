{
  "ApplicationName": "${application-name}",
  "ApplicationDescription": "Kinesis flink app which stores data in s3",
  "RuntimeEnvironment": "FLINK-1_8",
  "ServiceExecutionRole": "${role-arn}",
  "ApplicationConfiguration": {
    "ApplicationCodeConfiguration": {
      "CodeContent": {
        "S3ContentLocation": {
          "BucketARN": "${bucket-arn}",
          "FileKey": "${kinesis-app-jar-key}"
        }
      },
      "CodeContentType": "ZIPFILE"
    },
    "EnvironmentProperties":  {
      "PropertyGroups": [
        {
          "PropertyGroupId": "FlinkS3AppProperties",
          "PropertyMap" : {
            "aws.region" : "${region}",
            "stream.name" : "${stream-name}",
            "output.path": "${output-path}",
            "checkpoint.interval.min": "5"
          }
        }
      ]
    }
  },
  "CloudWatchLoggingOptions": [{
    "LogStreamARN": "${log-stream-arn}"
  }]
}

