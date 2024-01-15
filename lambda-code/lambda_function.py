import boto3
import os

def lambda_handler(event, context):
    action = event['action']
    start_stop_instances(action)

def start_stop_instances(action):
    ec2 = boto3.client('ec2')
    tag_key = os.environ['TAG_KEY']
    tag_value = os.environ['TAG_VALUE']

    instances = ec2.describe_instances(
        Filters=[
            {
                'Name': f'tag:{tag_key}',
                'Values': [
                    tag_value
                ]
            }
        ]
    )['Reservations']

    instance_ids = [h['InstanceId'] for h in [i['Instances'] for i in instances][0]]

    if action == 'start':
        retrun ec2.start_instances(InstanceIds=instance_ids)
    elif action == 'stop':
        return ec2.stop_instances(InstanceIds=instances_ids)
