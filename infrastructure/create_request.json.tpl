{
  "ApplicationName": "${application_name}",
  "ApplicationDescription": "Kinesis flink app which stores data in s3",
  "RuntimeEnvironment": "FLINK-1_8",
  "ServiceExecutionRole": "${role_arn}",
  "ApplicationConfiguration": {
    "ApplicationCodeConfiguration": {
      "CodeContent": {
        "S3ContentLocation": {
          "BucketARN": "${bucket_arn}",
          "FileKey": "${kinesis_app_jar_key}"
        }
      },
      "CodeContentType": "ZIPFILE"
    },
    "ApplicationSnapshotConfiguration": {
      "SnapshotsEnabled": true
    },
    "EnvironmentProperties": {
      "PropertyGroups": [
        {
          "PropertyGroupId": "FlinkS3AppProperties",
          "PropertyMap": {
            "aws.region": "${region}",
            "stream.name": "${stream_name}",
            "output.path": "${output_path}"
          }
        }
      ]
    },
    "FlinkApplicationConfiguration": {
      "ParallelismConfiguration": {
        "AutoScalingEnabled": true,
        "ConfigurationType": "CUSTOM",
        "Parallelism": 2,
        "ParallelismPerKPU": 2
      },
      "CheckpointConfiguration": {
        "CheckpointingEnabled": true,
        "CheckpointInterval": 300000,
        "ConfigurationType": "CUSTOM",
        "MinPauseBetweenCheckpoints": 5000
      },
      "MonitoringConfiguration": {
        "ConfigurationType": "CUSTOM",
        "LogLevel": "INFO",
        "MetricsLevel": "TASK"
      }
    }
  },
  "CloudWatchLoggingOptions": [
    {
      "LogStreamARN": "${log_stream_arn}"
    }
  ]
}

