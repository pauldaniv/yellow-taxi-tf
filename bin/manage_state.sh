#!/usr/bin/env bash

ACTION=$1
AVAILABLE_ACTIONS="Available actions: [apply, destroy, re-create]"

cd "$(cd "$(dirname "$0")/.."; pwd)"

if [[ -z "$ACTION" ]]; then
  echo "Action not specified. $AVAILABLE_ACTIONS"
  exit 1
fi
echo 1
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

if [[ "$ACTION" = "apply" ]]; then
  echo "Creating infrastructure"
  apply
elif [[ "$ACTION" = "destroy" ]]; then
  echo "Destroying infrastructure"
  destroy
elif [[ "$ACTION" = "re-create" ]]; then
  echo "Re-creating infrastructure"
  recreate
else
  echo "Unknown action provided: $ACTION. Available actions: $AVAILABLE_ACTIONS"
fi
