#!/bin/bash

# Check if the AWS CLI is installed
if ! [ -x "$(command -v aws)" ]; then
  echo 'Error: AWS CLI is not installed.' >&2
  exit 1
fi

# Fetch the EC2 instances and metadata
instances=$(aws ec2 describe-instances --query 'Reservations[*].Instances[*].{ID:InstanceId,State:State.Name,Type:InstanceType,PublicIP:PublicIpAddress,LaunchTime:LaunchTime}' --output json)

# Check if the AWS CLI command was successful
if [ $? -ne 0 ]; then
  echo "Error: Failed to retrieve EC2 instance data." >&2
  exit 1
fi

# Parse and display the results
if [ -n "$instances" ]; then
  echo "EC2 Instances Status:"
  echo "$instances" | jq '.[] | .[] | "Instance ID: \(.ID), State: \(.State), Type: \(.Type), Public IP: \(.PublicIP), Launch Time: \(.LaunchTime)"'
else
  echo "No EC2 instances found."
fi

