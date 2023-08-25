#!/usr/bin/env bash

ACTION=$1
AVAILABLE_ACTIONS="Available actions: [apply, enabled, disabled]"

cd "$(cd "$(dirname "$0")/.."; pwd)"

if [[ -z "$ACTION" ]]; then
  echo "Action not specified. $AVAILABLE_ACTIONS"
  exit 1
fi

function apply() {
  terraform init --migrate-state
  terraform apply --auto-approve
}

function destroy() {
    terraform init
    terraform destroy --auto-approve
}

function recreate() {
  destroy
  echo "Backoff (20s)..."
  sleep 20s
  apply
}

if [[ "$ACTION" = "enabled" && "$GITHUB_COMMIT_MESSAGE" == *"action: apply"* ]]; then
  echo "Creating infrastructure"
  apply
elif [[ "$ACTION" = "disabled" || "$GITHUB_COMMIT_MESSAGE" == *"action: destroy"* ]]; then
  echo "Destroying infrastructure"
  destroy
elif [[ "$ACTION" = "enabled" && "$GITHUB_COMMIT_MESSAGE" == *"action: re-create"* ]]; then
  echo "Re-creating infrastructure"
  recreate
elif [[ "$ACTION" = "enabled" || "$ACTION" = "disabled" ]]; then
  echo "Unknown commit message action provided: $GITHUB_COMMIT_MESSAGE. Available actions: [action: apply, action: destroy, action: re-create]"
else
  echo "Unknown action provided: $ACTION. Available actions: $AVAILABLE_ACTIONS"
fi
