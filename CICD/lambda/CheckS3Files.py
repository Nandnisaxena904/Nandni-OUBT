import boto3
import os

s3 = boto3.client('s3')

def lambda_handler(event, context):
    # S3 bucket and key (file path)
    bucket = 'my-data-lake-lab-nandnioubt'
    key = 'raw/nyc_taxi/yellow_tripdata_2023-01.parquet'
    
    try:
        # Check if the object exists
        s3.head_object(Bucket=bucket, Key=key)
        # File exists
        return {
            "status": "PASS",
            "file": f"s3://{bucket}/{key}"
        }
    except s3.exceptions.ClientError as e:
        # If a 404 error, file does not exist
        if e.response['Error']['Code'] == '404':
            raise Exception(f"File not found: s3://{bucket}/{key}")
        else:
            # Other errors
            raise e
