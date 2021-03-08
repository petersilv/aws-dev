# -----------------------------------------------------------------------------
# Import Packages

import boto3
from datetime import datetime as dt


# -----------------------------------------------------------------------------
# Describe Instances

def get_instance_list():

    # Set Up Client
    ec2_client = boto3.client('ec2')

    response_instances = ec2_client.describe_instances(
        MaxResults=1000
    )

    # Update Time
    instances_update_dt = dt.now().strftime('%Y-%m-%d %H:%M:%S')

    # Build List of Instances
    instance_list = []
    for reservation in response_instances["Reservations"]:
        instance_list += reservation['Instances']

    # Add Update Time to Dicts
    for instance in instance_list:
        instance['UpdateDateTime'] = instances_update_dt

    return instance_list


# -----------------------------------------------------------------------------
# Describe Instance Statuses

def get_instance_status_list():

    # Set Up Client
    ec2_client = boto3.client('ec2')

    response_instance_status = ec2_client.describe_instance_status(
        MaxResults=1000,
        IncludeAllInstances=True
    )

    # Update Time
    instance_status_update_dt = dt.now().strftime('%Y-%m-%d %H:%M:%S')

    # Build List of Instance Statuses
    instance_status_list = response_instance_status["InstanceStatuses"]

    # Add Update Time to Dicts
    for instance_status in instance_status_list:
        instance_status['UpdateDateTime'] = instance_status_update_dt

    return instance_status_list


# -----------------------------------------------------------------------------
# Parse Instance Details

def parse_instance_list(instance_list):

    key_list = [
        'UpdateDateTime',
        'VpcId',
        'SubnetId',
        'InstanceId',
        'Tags',
        'State',
        'StateReason',
        'StateTransitionReason',
    ]

    instance_details_list = []

    # Loop through instances
    for instance in instance_list:

        instance_details_dict = {}

        # Loop through keys
        for key in key_list:
            if key in instance.keys():

                # Parse nested dictionaries
                if isinstance(instance[key],dict):
                    for subkey in instance[key].keys():
                        instance_details_dict[key+subkey] = instance[key][subkey]

                # Parse Name tag
                elif key == 'Tags':
                    for item in instance[key]:
                        tag_key = item['Key']
                        tag_value = item['Value']

                        if tag_key == 'Name':  
                            instance_details_dict[tag_key+'Tag'] = tag_value

                # Add simple values
                else:
                    instance_details_dict[key] = instance[key]

        # Append single instance details to list   
        instance_details_list.append(instance_details_dict)

    return instance_details_list