import boto3

def start_instances(event, context):
    asg = autoscaling()
    ec2 = boto3.client('ec2')

    stopped_instances = ec2.describe_instances(
        Filters=[
            {
                'Name': 'instance-state-name',
                'Values': [
                    'stopped'
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

    instances_to_start = []

    for instances in stopped_instances:
        for instance in instances['Instances']:
            instance_id = instance['InstanceId']
            instances_to_start.append(instance_id)
    
    if len(instances_to_start) > 0:
        response = ec2.start_instances(InstanceIds=instances_to_start)
        return response, asg
    else:
        return "No stopped instances"

def autoscaling():
    auto_scaling = boto3.client('autoscaling')
    asgroups = [i for i in auto_scaling.describe_auto_scaling_groups()['AutoScalingGroups'] if [h for h in i['Tags'] if h['Key'] == 'AutoStartStop' and h['Value'] == 'True']]
    if len(asgroups) > 0: 
        for asg in asgroups:
            Tags = asg['Tags']
            MaxCap = [i for i in Tags if i['Key'] == 'MaxCap'][0]['Value']
            MinCap = [i for i in Tags if i['Key'] == 'MinCap'][0]['Value']
            DesCap = [i for i in Tags if i['Key'] == 'DesCap'][0]['Value']

            group_name = asg['AutoScalingGroupName']

            auto_scaling.update_auto_scaling_group(
                AutoScalingGroupName=group_name,
                MinSize=MinCap,
                MaxSize=MaxCap,
                DesiredCapacity=DesCap
            )
        return "AutoScaling Groups restarted"
    
    else:
        return "No applicable AutoScaling Groups"