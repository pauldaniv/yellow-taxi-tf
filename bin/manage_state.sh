#!/usr/bin/env bash

ACTION=$1
AVAILABLE_ACTIONS="Available actions: [apply, destroy]"

cd "$(cd "$(dirname "$0")/.."; pwd)"

if [[ -z "$ACTION" ]]; then
  echo "Action not specified. $AVAILABLE_ACTIONS"
  exit 1
fi

if [[ "$ACTION" = "apply" ]]; then
  echo "Creating infrastructure"
  terraform init --migrate-state
  terraform apply --auto-approve
  terraform output
elif [[ "$ACTION" = "destroy" ]]; then
  echo "Destroying infrastructure"
  terraform init
  terraform destroy --auto-approve
else
  echo "Unknown action provided: $ACTION. Available actions: $AVAILABLE_ACTIONS"
fi
