------------------------------------------------------------------------------------------------------------------------
-- VARIABLES

set integration_name   = 'S3_INT';                                           -- The name of the storage integration. Must be uppercase
set stage_name         = 'S3_STAGE';                                         -- The name of the stage. Must be uppercase
set snowflake_role_arn = 'arn:aws:iam::YOUR-ACCOUNT-ID:role/snowflake-role'; -- The role created in the S3 CloudFormation Stack 
set integration_s3_url = 's3://YOUR-BUCKET-NAME/data/';                      -- The location you would like your integration to access
set stage_s3_url       = 's3://YOUR-BUCKET-NAME/data/';                      -- Can match or be a subset of the integration URL 

------------------------------------------------------------------------------------------------------------------------
-- SCRIPT SETUP

use role databaseadmin;
create schema if not exists demo_db.test;
use demo_db.test;

------------------------------------------------------------------------------------------------------------------------
-- CREATE INTEGRATION

use role accountadmin;

create storage integration if not exists identifier($integration_name)
  type = external_stage
  storage_provider = s3
  enabled = true
  storage_aws_role_arn = $snowflake_role_arn
  storage_allowed_locations = ($integration_s3_url)
;

grant usage on integration identifier($integration_name) to role databaseadmin;

------------------------------------------------------------------------------------------------------------------------
-- CREATE STAGE

use role databaseadmin;

create stage if not exists identifier($integration_name)
  storage_integration = identifier($integration_name)
  url = $stage_s3_url;

------------------------------------------------------------------------------------------------------------------------
-- SHOW INTEGRATION DETAILS

desc integration identifier($integration_name);

select "property"
     , "property_value"
  from table(result_scan(last_query_id()))
 where "property" = 'STORAGE_AWS_IAM_USER_ARN'
    or "property" = 'STORAGE_AWS_EXTERNAL_ID'
;
