import boto3
import os
import time

REGION = os.environ.get("AWS_REGION", "us-west-2")
ACCOUNT_ID = os.environ.get("ACCOUNT_ID", "474668386387")
DATASET_ID = os.environ.get("DATASET_ID", "040827cf-6dc9-41cd-8e4b-d0cf76bd11ce")

qs_client = boto3.client("quicksight", region_name=REGION)

def lambda_handler(event, context):
    """
    Start QuickSight dataset ingestion if no active ingestion exists
    """
    # 1️⃣ Check existing ingestions
    try:
        response = qs_client.list_ingestions(
            DataSetId=DATASET_ID,
            AwsAccountId=ACCOUNT_ID,
            MaxResults=10
        )

        for ingestion in response.get("Ingestions", []):
            status = ingestion["IngestionStatus"]
            if status in ["QUEUED", "RUNNING"]:
                ingestion_id = ingestion["IngestionId"]
                print(f"Existing ingestion in progress: {ingestion_id}")
                return {
                    "dataset_id": DATASET_ID,
                    "ingestion_id": ingestion_id,
                    "status": status,
                    "message": "Existing ingestion in progress"
                }

        # 2️⃣ No active ingestion → start new one
        ingestion_id = str(int(time.time()))
        response = qs_client.create_ingestion(
            DataSetId=DATASET_ID,
            IngestionId=ingestion_id,
            AwsAccountId=ACCOUNT_ID
        )
        print(f"Started new ingestion: {ingestion_id}")
        return {
            "dataset_id": DATASET_ID,
            "ingestion_id": ingestion_id,
            "status": "STARTED",
            "message": "New ingestion started"
        }

    except Exception as e:
        print(f"Error in StartIngestion Lambda: {e}")
        raise e
