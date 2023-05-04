#Yellow-Taxi promotion project

Run to init lock table for terraform:
```shell
aws dynamodb create-table --cli-input-json file://state_table.json --region us-east-2
```
And to delete the state use:
```shell
aws dynamodb delete-table --table-name yellow-taxi-tf-state --region us-east-2
```
