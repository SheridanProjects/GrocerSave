#!/bin/bash

# This script sets up a SIEM (Security Information and Event Management) pipeline
# in LocalStack by creating an OpenSearch domain, a Kinesis Firehose stream,
# and connecting it to the existing EventBridge rule for CloudTrail events.

set -e

# --- Configuration ---
REGION="us-east-1"
ACCOUNT_ID="000000000000" # Default LocalStack account ID
ENDPOINT_URL="http://localhost:4566"

# SIEM Components
OPENSEARCH_DOMAIN_NAME="grocersave-siem"
FIREHOSE_ROLE_NAME="FirehoseDeliveryRole"
FIREHOSE_STREAM_NAME="grocersave-audit-stream"
OPENSEARCH_INDEX_NAME="cloudtrail-audit-logs"

# Existing Resources (from setup_cloudtrail.sh)
S3_BUCKET_NAME="grocersave-audit-logs"
EVENT_RULE_NAME="RouteCloudTrailToCWLogs"

# --- Helper function for AWS CLI calls ---
aws_cmd() {
    aws --endpoint-url="$ENDPOINT_URL" --region="$REGION" "$@"
}

# --- Main script ---
echo "Step 1: Creating OpenSearch Domain..."
aws_cmd opensearch create-domain \
    --domain-name "$OPENSEARCH_DOMAIN_NAME" \
    --engine-version "OpenSearch_2.3"

echo "Step 2: Creating IAM Role for Kinesis Firehose..."
FIREHOSE_ROLE_ARN=$(aws_cmd iam create-role \
    --role-name "$FIREHOSE_ROLE_NAME" \
    --assume-role-policy-document '{"Version":"2012-10-17","Statement":[{"Effect":"Allow","Principal":{"Service":"firehose.amazonaws.com"},"Action":"sts:AssumeRole"}]}' \
    --query 'Role.Arn' --output text)
echo "Role '$FIREHOSE_ROLE_NAME' created with ARN: $FIREHOSE_ROLE_ARN"

echo "Waiting for OpenSearch domain to initialize (approx. 60 seconds)..."
sleep 60

echo "Step 3: Creating Kinesis Firehose Delivery Stream..."
OPENSEARCH_DOMAIN_ARN="arn:aws:es:${REGION}:${ACCOUNT_ID}:domain/${OPENSEARCH_DOMAIN_NAME}"
S3_BUCKET_ARN="arn:aws:s3:::${S3_BUCKET_NAME}"

aws_cmd firehose create-delivery-stream \
    --delivery-stream-name "$FIREHOSE_STREAM_NAME" \
    --elasticsearch-destination-configuration "{
        \"RoleARN\": \"${FIREHOSE_ROLE_ARN}\",
        \"DomainARN\": \"${OPENSEARCH_DOMAIN_ARN}\",
        \"IndexName\": \"${OPENSEARCH_INDEX_NAME}\",
        \"BufferingHints\": {\"IntervalInSeconds\": 60, \"SizeInMBs\": 1},
        \"S3Configuration\": {
            \"RoleARN\": \"${FIREHOSE_ROLE_ARN}\",
            \"BucketARN\": \"${S3_BUCKET_ARN}\"
        }
    }"

echo "Step 4: Adding Firehose stream as a target for the EventBridge rule..."
FIREHOSE_STREAM_ARN="arn:aws:firehose:${REGION}:${ACCOUNT_ID}:deliverystream/${FIREHOSE_STREAM_NAME}"
aws_cmd events put-targets \
    --rule "$EVENT_RULE_NAME" \
    --targets "Id"="2","Arn"="${FIREHOSE_STREAM_ARN}"

echo "--------------------------------------------------"
echo "SIEM pipeline setup is complete!"
echo "Generate some AWS API activity to test the flow."
echo "Then, check for your index with the following command (it may take a minute for logs to appear):"
echo "curl -X GET \"http://${OPENSEARCH_DOMAIN_NAME}.${REGION}.opensearch.localhost.localstack.cloud:4566/_cat/indices?v\""
echo "--------------------------------------------------"
