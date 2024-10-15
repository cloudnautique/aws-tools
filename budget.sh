#!/bin/bash

# Check if the AWS CLI is installed
if ! [ -x "$(command -v aws)" ]; then
  echo 'Error: AWS CLI is not installed.' >&2
  exit 1
fi

# Set the time period (e.g., last 30 days)
START_DATE=$(date -v-30d +%Y-%m-%d)  # For systems like macOS
END_DATE=$(date +%Y-%m-%d)

# Fetch cost breakdown by service for the last 30 days
cost_data=$(aws ce get-cost-and-usage \
  --time-period Start=$START_DATE,End=$END_DATE \
  --granularity MONTHLY \
  --metrics "BlendedCost" \
  --group-by Type=DIMENSION,Key=SERVICE \
  --output json)

# Check if the AWS CLI command was successful
if [ $? -ne 0 ]; then
  echo "Error: Failed to retrieve cost data." >&2
  exit 1
fi

# Parse and display the results, filtering out $0.00 items
if [ -n "$cost_data" ]; then
  echo "AWS Cost Breakdown by Resource (Last 30 Days):"
  echo "$cost_data" | jq '.ResultsByTime[0].Groups[] | select(.Metrics.BlendedCost.Amount | tonumber > 0) | "\(.Keys[0]): \(.Metrics.BlendedCost.Amount) USD"'
else
  echo "No cost data found."
fi

