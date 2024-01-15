# AWS EC2 Scheduler in Terraform and Python

### Project rationale:
This project is meant to address cost issues with DEVELOPMENT EC2 instances. A typical use case would be a software or application POC that uses one or more instances that does not necessarily need to be accessed by developers outside of business hours. This saves on EC2 costs by more than halving an instances uptime.

A production use case would be an internal application that is distributed among several instances and is used heavily during regular business hours, but rarely accessed on nights and weekends.

**This Terraform project deploys:**
- Python 3.10 Lambda function that uses the Python boto3 library to start and stop instances
- IAM roles and policies to attach to the Lambda function
- Two CloudWatch Events that trigger the Lambda function

**This Project assumes that:**
- You have an existing AWS account with existing EC2 instances
- You have an IAM role with appropriate permissions to create the resources in this project
- You have Terraform and the aws-cli installed on your system

#### Clone the repo to get started
```
git clone https://github.com/sarah-23/aws-ec2-scheduler.git
cd aws-ec2-scheduler/
```

#### Or use directly as a Terraform module in an existing configuration
```hcl
module "scheduler" {
  source        = "git::https://github.com/sarah-23/aws-ec2-scheduler.git?ref=v2.0.0
  function_name = "ec2_scheduler"
  # An instance tag that the scheduler should look for
  tag_key       = "Scheduled"
  tag_value     = "True"
  # Change these variables according to an AWS supported `cron` statement.
     https://docs.aws.amazon.com/AmazonCloudWatch/latest/events/ScheduledEvents.html
  start_cron    = "cron(0 11 ? * MON-FRI *)"
  stop_cron     = "cron(0 23 ? * MON-FRI *)"
}
```
----------------------------------------------------------------

## Instance tags
- The Lambda functions will only apply to instances with a specific tag

- Attach a [tag](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/Using_Tags.html) to each instance or ASG
- Example:
  ```
  AutoStartStop: True
  ```
- Define this tag when using as a standalone Terraform project or as a module within an existing Terraform conifguration
- Example:
  ```hcl
  # Booleans must be quoted literals
  tag_key   = "AutoStartStop"
  tag_value = "True"
  ```

----------------------------------------------------------------

## Terraform usage
Choose an AWS region you'd like to use. `us-east-1` is shown as an example.

Initialize your Terraform project:
```
terraform init
```

Export a plan:
```
terraform plan -out plan
```

Apply the plan:
```
terraform apply plan
```

Cleanup resources:
```
terraform destroy
```

----------------------------------------------------------------

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_archive"></a> [archive](#provider\_archive) | 2.4.1 |
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.32.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_event_rule.StartInstances](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_rule.StopInstances](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_target.StartInstances](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_cloudwatch_event_target.StopInstances](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_cloudwatch_log_group.scheduler_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_iam_role.scheduler_lambda_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.scheduler_lambda_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_lambda_function.scheduler_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_lambda_permission.StartInstances](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_lambda_permission.StopInstances](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [archive_file.lambda_code](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file) | data source |
| [aws_iam_policy_document.assume](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.scheduler_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_function_name"></a> [function\_name](#input\_function\_name) | Name of the Lambda function. Also used as a prefix for other resources | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | Your preferred region | `string` | `""` | no |
| <a name="input_start_cron"></a> [start\_cron](#input\_start\_cron) | An AWS CloudWatch cron expression for use in starting instances | `string` | `""` | no |
| <a name="input_stop_cron"></a> [stop\_cron](#input\_stop\_cron) | An AWS CloudWatch cron expression for use in stopping instances | `string` | `""` | no |
| <a name="input_tag_key"></a> [tag\_key](#input\_tag\_key) | A custom tag applied to your instances that the scheduler should look for | `string` | n/a | yes |
| <a name="input_tag_value"></a> [tag\_value](#input\_tag\_value) | A custom tag applied to your instances that the scheduler should look for | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
