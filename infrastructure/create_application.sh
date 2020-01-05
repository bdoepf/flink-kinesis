#!/usr/bin/env bash
export application_name="kinesis-flink-s3"
export role_arn="$(terraform output role_arn)"
export bucket_name="$(terraform output bucket_name)"
export bucket_arn="arn:aws:s3:::${bucket_name}"
export kinesis_app_jar_key="applications/flink-kinesis.jar"
export region=$(terraform output region)
export stream_name="$(terraform output stream_name)"
export output_path="s3a://${bucket_name}/data/parquet/"
export log_stream_arn="$(terraform output log_stream_arn)"

# Build assembly jar
cd ../
sbt clean assembly
cd infrastructure

# Upload assembly jar
aws s3 cp ../target/scala-2.11/flink-kinesis-assembly*.jar "s3://${bucket_name}/${kinesis_app_jar_key}"

# Create application
envsubst < create_request.json.tpl > create_request.json
aws --region "${region}" kinesisanalyticsv2 create-application --cli-input-json "file://create_request.json"

# Start application
envsubst < start_request.json.tpl > start_request.json
aws --region "${region}" kinesisanalyticsv2 start-application --cli-input-json "file://start_request.json"

# Clean up
rm create_request.json start_request.json

echo "Application starting..."
