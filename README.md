#Yellow-Taxi promotion project

Run to init lock table for terraform:
```shell
aws dynamodb create-table --cli-input-json file://state_table.json --region us-east-2
```
