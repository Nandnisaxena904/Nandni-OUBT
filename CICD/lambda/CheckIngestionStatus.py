import boto3
import os

REGION = os.environ.get("AWS_REGION", "us-west-2")
ACCOUNT_ID = os.environ.get("ACCOUNT_ID", "474668386387")
DATASET_ID = os.environ.get("DATASET_ID", "040827cf-6dc9-41cd-8e4b-d0cf76bd11ce")

qs_client = boto3.client("quicksight", region_name=REGION)

def lambda_handler(event, context):
    """
    Check the ingestion status of a QuickSight dataset
    """
    ingestion_id = event.get("ingestion_id")
    if not ingestion_id:
        raise ValueError("Missing ingestion_id in event input")

    response = qs_client.describe_ingestion(
        DataSetId=DATASET_ID,
        IngestionId=ingestion_id,
        AwsAccountId=ACCOUNT_ID
    )

    status = response["Ingestion"]["IngestionStatus"]
    print(f"Ingestion {ingestion_id} status: {status}")

    return {
        "dataset_id": DATASET_ID,
        "ingestion_id": ingestion_id,
        "status": status
    }
