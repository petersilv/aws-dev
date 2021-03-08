# -----------------------------------------------------------------------------
# Import Packages

import boto3
import io
import pandas as pd 


# -----------------------------------------------------------------------------
# Check if file exists in S3

def list_objects(Bucket,Prefix,MaxKeys=1000):

    s3_client = boto3.client('s3')

    list_objects_response = s3_client.list_objects_v2(
        Bucket = Bucket,
        Prefix = Prefix,
        MaxKeys = MaxKeys
    )

    return list_objects_response


# -----------------------------------------------------------------------------
# Read CSV from S3

def read_csv(Bucket,Key):

    s3_client = boto3.client('s3')

    get_object_response = s3_client.get_object(
        Bucket = Bucket, 
        Key = Key
    )

    csv_bytes = get_object_response['Body'].read()
    csv_str = csv_bytes.decode("utf-8") 

    # Convert to dataframe
    df = pd.read_csv(
        io.StringIO(csv_str)
    )

    return df


# -----------------------------------------------------------------------------
# Write Dataframe to S3 as CSV

def write_df_as_csv(Bucket,Key,DataFrame):

    csv_bytes = DataFrame.to_csv(index = False).encode('UTF-8')

    s3_client = boto3.client('s3')

    put_object_response = s3_client.put_object(
        Bucket = Bucket, 
        Key = Key,
        Body = csv_bytes
    )

    return put_object_response