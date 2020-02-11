# AWS EC2 Scheduler in Terraform and Python

### Project rationale:
This project is meant to address cost issues with DEVELOPMENT EC2 instances. A typical use case would be a software or application POC that uses one or more instances that does not necessarily need to be accessed by developers outside of business hours. This saves on EC2 costs by more than halving an instances uptime.

A production use case would be an internal application that is distributed among several instances and is used heavily during regular business hours, but rarely accessed on nights and weekends.

**This Terraform project deploys:**
- Two Python 3.7 Lambda functions that uses the Python boto3 library to start and stop instances
- IAM roles and policies to attach to the Lambda functions
- Two CloudWatch Events that trigger the Lambda functions

**This Project assumes that:**
- You have an existing AWS with existing EC2 instances or AutoScaling groups (ASGs)
- You have an IAM role with appropriate permissions to create the resources in this project
- You have Terraform and the aws-cli installed on your system

#### Clone the repo to get started
```
git clone https://github.com/zach-23/aws-ec2-scheduler.git
cd aws-ec2-scheduler/
```
----------------------------------------------------------------

## Environment setup
Before running this example, you will need to configure your AWS credentials. Follow the Terraform documentation to set up your AWS credentials: https://www.terraform.io/docs/providers/aws/

----------------------------------------------------------------

## Instance tags
- The Lambda functions will only apply to instances os ASGs with a specific tag

- Attach a [tag](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/Using_Tags.html) to each instance or ASG
  ```
  AutoStartStop: True
  ```

- For ASGs, the Lambda function pulls the properties `MinSize`, `MaxSize`, and `DesiredCapacity` from the ASG, saves them as tags, and sets all values to `0`. When the ASG is started again, those tags are applied and the ASG restores to its previous state.

----------------------------------------------------------------

## Terraform usage
Choose an AWS region you'd like to use. `us-east-1` is shown as an example.

Initialize your Terraform project:
```
terraform init
```

Export a plan:
```
terraform plan -out plan -var region="us-east-1"
```

Apply the plan:
```
terraform apply plan
```

Cleanup resources:
```
terraform destroy -var region="us-east-1"
```

----------------------------------------------------------------

## Change the timing of your CloudWatch Events
In the [cloudwatch.tf](./cloudwatch.tf) file, take a look at the two resources blocks titled `aws_cloudwatch_event_rule`

```
rresource "aws_cloudwatch_event_rule" "StartInstances" {
    name                = "lambda-start-instances"
    description         = "Turns on AWS instances at 6am Eastern Time"
    schedule_expression = "cron(0 11 ? * MON-FRI *)"
}
```

Change the `schedule_expression` argument according to an AWS supported `cron` statement.
https://docs.aws.amazon.com/AmazonCloudWatch/latest/events/ScheduledEvents.html