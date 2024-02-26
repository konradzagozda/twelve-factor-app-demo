# 1.config.tf

Terraform module for initializing secrets and parameters in aws.
Once they are initialized, should not be managed by terraform anymore.
Update them manually in AWS.
Subsequent applies will not modify the secrets and parameters, but they will create new ones if added.
Each secret / env should be defined here.
