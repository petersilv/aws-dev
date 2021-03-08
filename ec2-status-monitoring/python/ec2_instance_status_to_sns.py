# -----------------------------------------------------------------------------
# Import Packages

import boto3
import logging
import pandas as pd 
from datetime import datetime as dt

import ec2
import s3
import utils_logging

utils_logging.config()

# -----------------------------------------------------------------------------
# Get Instance Details

instance_list = ec2.get_instance_list()
instance_list_parsed = ec2.parse_instance_list(instance_list)
instance_status_list = ec2.get_instance_status_list()


# -----------------------------------------------------------------------------
# Write Instance Details to CSV Log in S3

# Set S3 Variables
bucket_name = 'psilv2'
folder_name = 'ec2_logs/'
file_name_root = 'instance_status_log'

dt_today = dt.today().strftime('%Y_%m_%d')

object_key = f'{folder_name}{file_name_root}_{dt_today}.csv'

# Get Instance Statuses
df_new = pd.DataFrame(instance_list_parsed)

# Check if CSV exists in S3
check_file_response = s3.list_objects(
    Bucket = bucket_name,
    Prefix = object_key,
    MaxKeys = 1
)

file_exists_flag = 'Contents' in check_file_response

if file_exists_flag:
    
    df_existing = s3.read_csv(
        Bucket = bucket_name,
        Key = object_key,
    )

    # Union for final dataframe
    df = pd.concat([df_existing,df_new]).reset_index(drop = True)

else:
    # Create final dataframe
    df = df_new.copy()

# Convert to CSV and write to S3
s3.write_df_as_csv(
    Bucket = bucket_name,
    Key = object_key,
    DataFrame = df
)


# -----------------------------------------------------------------------------
# Create dataframe to check for issues

# If there is multiple logs from today then use those to check for issues,
# else we need to build a combined dataframe check this log against 
# logs from a previous day

if file_exists_flag:
    df_for_sns = df.copy()

else:
    # List existing objects in folder
    list_objects_response = s3.list_objects(
        Bucket = bucket_name,
        Prefix = folder_name
    )

    # Create sorted list of CSVs
    csv_list = sorted([
        item['Key'] 
        for item in list_objects_response['Contents'] 
        if '.csv' in item['Key']
    ], reverse=True)

    # Concat current day and previous day if previous day file exists
    if len(csv_list) > 1:
        object_key_previous_day = csv_list[1] 

        df_previous_day = s3.read_csv(
            Bucket = bucket_name,
            Key = object_key_previous_day,
        )

        # Union for final dataframe
        df_for_sns = pd.concat([df_previous_day,df_new]).reset_index(drop = True)

    # Use just today's log if no previous file
    else:
        df_for_sns = df.copy()


# -----------------------------------------------------------------------------
# 

if len(df_for_sns) < 2:
    logging.info('Issue Checking - Insufficient Log Data')

else: 

    df_for_sns = df_for_sns \
        .sort_values('UpdateDateTime', ascending=False) \
        [:2] \
        .reset_index(drop = True)

    if df_for_sns['StateName'][0] != df_for_sns['StateName'][1]:

        logging.info('Issue Checking - Alert - Instance State Changed')

        logging.info('Issue Checking - Alert - Instance State Changed - {}')
