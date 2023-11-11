import json
import boto3
import os

def lambda_handler(event, context):
    aws_region = os.environ['AWS_REGION']
    # Initialize DynamoDB client
    dynamodb = boto3.client('dynamodb')
    
    # Define the DynamoDB table name
    table_name = 'usertable'
    
    try:
        # Query all user records from the DynamoDB table
        response = dynamodb.scan(TableName=table_name)
        
        # Extract the user records from the response
        user_records = response.get('Items', [])
        
        # Convert user records to JSON format
        # user_records_json = json.dumps(user_records, default=str)
        user_records_json = []
        for item in user_records:
            user = {}
            for key, value in item.items():
                user[key] = value.get('S') if 'S' in value else value.get('N') if 'N' in value else value
            user_records_json.append(user)
        
        # Return the JSON response
        return {
            'statusCode': 200,
            'body': user_records_json,
            'aws_region': aws_region,
        }
    except Exception as e:
        return {
            'statusCode': 500,
            'body': json.dumps({'error': str(e)}),
            'aws_region': aws_region,
        }


if __name__=="__main__":
    pass