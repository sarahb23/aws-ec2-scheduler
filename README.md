# AWS EC2 Scheduler in Terraform and Python

### Project rationale:
This project is meant to address cost issues with DEVELOPMENT EC2 instances. A typical use case would be a software or application POC that uses one or more instances that does not necessarily need to be accessed by developers outside of business hours. This saves on EC2 costs by more than halving an instances uptime.

A production use case would be an internal application that is distributed among several instances and is used heavily during regular business hours, but rarely accessed on nights and weekends.

**This Terraform project deploys:**
- Two Python 3.7 Lambda functions that uses the Python boto3 library to start and stop instances
- IAM roles and policies to attach to the Lambda functions
- Two CloudWatch Events that trigger the Lambda functions

**This Project assumes that:**
- You have an existing AWS account with existing EC2 instances or AutoScaling groups (ASGs)
- You have an IAM role with appropriate permissions to create the resources in this project
- You have Terraform and the aws-cli installed on your system

#### Clone the repo to get started
```
git clone https://github.com/zach-23/aws-ec2-scheduler.git
cd aws-ec2-scheduler/
```

#### Or use directly as a Terraform module in an existing configuration
```hcl
module "scheduler" {
  source       = "git::https://github.com/zach-23/aws-ec2-scheduler.git?ref=v1.0.1"
  region       = var.region
  # An instance tag that the scheduler should look for
  instance_tag = {"Key" = "Value"}
  # Change these variables according to an AWS supported `cron` statement.
    # https://docs.aws.amazon.com/AmazonCloudWatch/latest/events/ScheduledEvents.html
  start_cron   = "cron(0 11 ? * MON-FRI *)"
  stop_cron    = "cron(0 23 ? * MON-FRI *)"

  providers = {
    aws.src = aws
  }
}
```
----------------------------------------------------------------

## Instance tags
- The Lambda functions will only apply to instances and/or ASGs with a specific tag

- Attach a [tag](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/Using_Tags.html) to each instance or ASG
- Example:
  ```
  AutoStartStop: True
  ```
- Define this tag when using as a standalone Terraform project or as a module within an existing Terraform conifguration
- Example:
  ```hcl
  instance_tag = {"AutoStartStop" =  "True"}
  ```

- For ASGs, the Lambda function pulls the properties `MinSize`, `MaxSize`, and `DesiredCapacity` from the ASG, saves them as tags, and sets all values to `0`. When the ASG is started again, those tags are applied and the ASG restores to its previous state.

----------------------------------------------------------------
