import boto3

def stop_instances(event, context):
    asg = autoscaling()
    ec2 = boto3.client('ec2')

    running_instances = ec2.describe_instances(
        Filters=[
            {
                'Name': 'instance-state-name',
                'Values': [
                    'running'
                ]
            },
            {
                'Name': 'tag:AutoStartStop',
                'Values': [
                    'True'
                ]
            }
        ]
    )['Reservations']

    instances_to_stop = []

    for instances in running_instances:
        for instance in instances['Instances']:
            instance_id = instance['InstanceId']
            instances_to_stop.append(instance_id)
    
    if len(instances_to_stop) > 0:
        response = ec2.stop_instances(InstanceIds=instances_to_stop)
        return response, asg
    else:
        return "No running instances"

def autoscaling():
    auto_scaling = boto3.client('autoscaling')
    asgroups = [i for i in auto_scaling.describe_auto_scaling_groups()['AutoScalingGroups'] if [h for h in i['Tags'] if h['Key'] == 'AutoStartStop' and h['Value'] == 'True']]
    if len(asgroups) > 0:
        for asg in asgroups:
            # To ensure that all AutoScalingGroups have the right tags, we will
            # apply necessary tags when shutting them down
            group_name = asg['AutoScalingGroupName']
            MinSize = str(asg['MinSize'])
            MaxSize = str(asg['MaxSize'])
            DesSize = str(asg['DesiredCapacity'])
            auto_scaling.create_or_update_tags(
                Tags=[
                    {
                        'Key': 'MinCap',
                        'Value': MinSize,
                        'PropagateAtLaunch': True,
                        'ResourceId': group_name,
                        'ResourceType': 'auto-scaling-group'
                    },
                    {
                        'Key': 'MaxCap',
                        'Value': MaxSize,
                        'PropagateAtLaunch': True,
                        'ResourceId': group_name,
                        'ResourceType': 'auto-scaling-group'
                    },
                    {
                        'Key': 'DesCap',
                        'Value': DesSize,
                        'PropagateAtLaunch': True,
                        'ResourceId': group_name,
                        'ResourceType': 'auto-scaling-group'
                    }
                ]
            )
            auto_scaling.update_auto_scaling_group(
                AutoScalingGroupName=group_name,
                MinSize=0,
                MaxSize=0,
                DesiredCapacity=0
            )
        return "AutoScaling Groups halted"
    
    else:
        return "No Applicable AutoScaling Groups"