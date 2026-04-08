#!/bin/bash

# This script automates the setup of AWS CloudTrail in a LocalStack environment
# using an EventBridge pipeline to route logs to CloudWatch.

set -e

# --- Configuration ---
REGION="us-east-1"
ACCOUNT_ID="000000000000" # Default LocalStack account ID
ENDPOINT_URL="http://localhost:4566"
S3_BUCKET_NAME="grocersave-audit-logs"
LOG_GROUP_NAME="/aws/cloudtrail/grocersave-audit"
TRAIL_NAME="grocersave-infrastructure-trail"
EVENT_RULE_NAME="RouteCloudTrailToCWLogs"
LOG_GROUP_ARN="arn:aws:logs:${REGION}:${ACCOUNT_ID}:log-group:${LOG_GROUP_NAME}"

# --- Helper function for AWS CLI calls ---
aws_cmd() {
    aws --endpoint-url="$ENDPOINT_URL" --region="$REGION" "$@"
}

# --- Main script ---
echo "Step 1: Creating S3 Bucket for CloudTrail's primary log storage..."
aws_cmd s3api create-bucket --bucket "$S3_BUCKET_NAME"

echo "Step 2: Creating the target CloudWatch Log Group..."
aws_cmd logs create-log-group --log-group-name "$LOG_GROUP_NAME"

echo "Step 3: Creating the CloudTrail Trail (without direct CW integration)..."
aws_cmd cloudtrail create-trail \
    --name "$TRAIL_NAME" \
    --s3-bucket-name "$S3_BUCKET_NAME"

echo "Step 4: Starting CloudTrail Logging..."
aws_cmd cloudtrail start-logging --name "$TRAIL_NAME"

echo "Step 5: Creating EventBridge Rule to capture CloudTrail events..."
aws_cmd events put-rule \
    --name "$EVENT_RULE_NAME" \
    --event-pattern '{"detail-type": ["AWS API Call via CloudTrail"]}'

echo "Step 6: Setting the CloudWatch Log Group as the target for the EventBridge rule..."
aws_cmd events put-targets \
    --rule "$EVENT_RULE_NAME" \
    --targets "Id"="1","Arn"="${LOG_GROUP_ARN}"

echo "Step 7: Verifying the new pipeline by creating a dummy SNS topic..."
aws_cmd sns create-topic --name dummy-audit-test-eventbridge
echo "SNS topic 'dummy-audit-test-eventbridge' created."

echo "--------------------------------------------------"
echo "CloudTrail and EventBridge pipeline setup complete!"
echo "Check the '${LOG_GROUP_NAME}' log group in your LocalStack CloudWatch UI to see audit events routed via EventBridge."
echo "--------------------------------------------------"
