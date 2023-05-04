#Yellow-Taxi promotion project

Run to create lock table for terraform lock:
```shell
aws dynamodb create-table --cli-input-json file://state_table.json --region us-east-2
```
And to delete table and clear the lock use:
```shell
aws dynamodb delete-table --table-name yellow-taxi-tf-state --region us-east-2
```
