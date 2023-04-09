#!/usr/bin/env bash

ACTION=$1
SCRATCH=$2
AVAILABLE_ACTIONS="Available actions: [apply, destroy]"

cd "$(cd "$(dirname "$0")/.."; pwd)"

if [[ -z "$ACTION" ]]; then
  echo "Action not specified. $AVAILABLE_ACTIONS"
  exit 1
fi

if [[ "$ACTION" = "apply" ]]; then
  echo "Creating infrastructure"
  if [[ "$SCRATCH" ]]; then
    echo "Creating setup from scratch!"
    echo "Creating additional unmanaged resources for terraform..."
    echo "Creating dynamoDB table for locking..."
    aws dynamodb create-table --cli-input-json file://state_table.json --region us-east-2
  fi
  terraform init
  terraform apply --auto-approve
elif [[ "$ACTION" = "destroy" ]]; then
  echo "Destroying infrastructure"
  terraform init
  terraform destroy --auto-approve
  if [[ "$SCRATCH" ]]; then
    echo "Deleting all related resources to this setup!"
    echo "Destroying additional unmanaged resources"
    aws dynamodb delete-table --table-name yellow-taxi-tf-state --region us-east-2
  fi
else
  echo "Unknown action provided: $ACTION. $AVAILABLE_ACTIONS"
fi
