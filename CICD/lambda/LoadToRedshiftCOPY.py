import boto3
import time

# Redshift Data API client
client = boto3.client('redshift-data', region_name='us-west-2')

# -----------------------------
# Config
# -----------------------------
REDSHIFT_CLUSTER = "my-redshift-cluster"
DATABASE = "dev"
DB_USER = "awsuser"
SCHEMA = "public"
IAM_ROLE = "arn:aws:iam::474668386387:role/RedshiftCopyRole"
S3_BUCKET = "my-data-lake-lab-nandnioubt"
S3_PREFIX = "master/redshift/"

# Redshift tables -> S3 folders
TABLES = {
    "vendor_dim": "dim_vendor",
    "zone_dim": "dim_zone",
    "rate_code_dim": "dim_rate_code",
    "trip_fact": "trip_fact"   # Added fact table
}

def lambda_handler(event, context):
    for table_name, folder_name in TABLES.items():
        s3_path = f"s3://{S3_BUCKET}/{S3_PREFIX}/{folder_name}/"
        copy_sql = f"""
            COPY {SCHEMA}.{table_name}
            FROM '{s3_path}'
            IAM_ROLE '{IAM_ROLE}'
            FORMAT AS PARQUET;
        """
        response = client.execute_statement(
            ClusterIdentifier=REDSHIFT_CLUSTER,
            Database=DATABASE,
            DbUser=DB_USER,
            Sql=copy_sql
        )
        stmt_id = response['Id']
        print(f"COPY submitted for {table_name}, statement ID: {stmt_id}")

        # Poll until COPY finishes
        while True:
            desc = client.describe_statement(Id=stmt_id)
            status = desc['Status']
            if status in ['FINISHED', 'FAILED', 'ABORTED']:
                break
            time.sleep(2)

        if status != 'FINISHED':
            raise Exception(f"COPY failed for {table_name}: {desc.get('Error')}")

        print(f"COPY finished successfully for {table_name}")

    return {"status": "COPY commands completed", "tables": list(TABLES.keys())}
