aws cloudformation deploy \
    --stack-name snowflake-s3 \
    --template-file ./templates/cfn_s3.yaml \
    --capabilities CAPABILITY_NAMED_IAM \
    --parameter-overrides \
        S3BucketName='***' \
        SnowflakeIntegrationCreated=False \
        SnowflakeSnowPipeCreated=False \
        SnowflakeUserARN='' \
        SnowflakeExternalID='' \
        SnowflakeSnowpipeQueueARN=''