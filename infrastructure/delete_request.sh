#!/usr/bin/env bash
export application_name="kinesis-flink-s3"
export region=$(terraform output region)

# Delete
aws --region eu-west-1 kinesisanalyticsv2 describe-application --application-name "${application_name}"| jq '.ApplicationDetail | {ApplicationName: .ApplicationName, CreateTimestamp: .CreateTimestamp}' > delete_request.json
aws --region "${region}" kinesisanalyticsv2 delete-application --cli-input-json file://delete_request.json
rm delete_request.json
echo "Deleting..."
