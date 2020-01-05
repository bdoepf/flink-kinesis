{
   "ApplicationName": "${application_name}",
   "CurrentApplicationVersionId": ${application_version},
   "ApplicationConfigurationUpdate": {
      "ApplicationCodeConfigurationUpdate": {
        "CodeContentTypeUpdate": "ZIPFILE",
        "CodeContentUpdate": {
          "S3ContentLocationUpdate": {
            "BucketARNUpdate": "${bucket_arn}",
            "FileKeyUpdate": "${kinesis_app_jar_key}"
          }
        }
      }
   }
}
