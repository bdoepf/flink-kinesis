#!/usr/bin/env bash
export application_name="kinesis-flink-s3"
export region=$(terraform output region)
export application_version="$(aws --region "${region}" kinesisanalyticsv2 describe-application --application-name "${application_name}" | jq -r '.ApplicationDetail.ApplicationVersionId')"
export bucket_name="$(terraform output bucket_name)"
export bucket_arn="arn:aws:s3:::${bucket_name}"
export kinesis_app_jar_key="applications/flink-kinesis.jar"

# Build assembly jar
cd ../
sbt clean assembly
cd infrastructure

# Upload assembly jar
aws s3 cp ../target/scala-2.11/flink-kinesis-assembly*.jar "s3://${bucket_name}/${kinesis_app_jar_key}"

# Update kinesis analytics application
envsubst < update_request.json.tpl > update_request.json
aws --region "${region}" kinesisanalyticsv2 update-application --cli-input-json "file://update_request.json"

# Clean up
rm update_request.json

echo "Updating..."
