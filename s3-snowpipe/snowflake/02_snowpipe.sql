------------------------------------------------------------------------------------------------------------------------
-- VARIABLES

set table_name = 'JSON_S3_EXAMPLE'; -- The name of the table that the Snowpipe will write to
set pipe_name  = 'S3_PIPE';         -- The name of the Snowpipe. Must be uppercase

-- THERE IS A __STAGE__ ITEM ON LINE 41, THIS CANNOT BE POPULATED BY A VARIABLE SO YOU MUST MANUALLY EDIT IT TO
-- REFERENCE THE STAGE CREATED IN THE PREVIOUS SCRIPT. THE LINE SHOULD BE SOMETHING LIKE: from @MY_STAGE_NAME

------------------------------------------------------------------------------------------------------------------------
-- SCRIPT SETUP

use role databaseadmin;
use demo_db.test;

------------------------------------------------------------------------------------------------------------------------
-- CREATE TABLE

create or replace table identifier($table_name) (
    records    variant
  , full_path  varchar
  , directory  varchar
  , file_name  varchar
  , updated_at timestamp_tz
);

------------------------------------------------------------------------------------------------------------------------
-- CREATE PIPE

create or replace pipe identifier($pipe_name)
  auto_ingest=true 
as

  copy into identifier($table_name)
  from (
    select $1::variant
         , metadata$filename
         , regexp_replace(metadata$filename, '(.*/).*?.json','\\1')
         , regexp_replace(metadata$filename, '.*/(.*?).json','\\1')
         , current_timestamp::timestamp_tz
      from @__STAGE__                                                                                  -- EDIT THIS LINE
  )
  file_format = (type=json)
  on_error= skip_file;

show pipes;

select "name"
     , "notification_channel"
  from table(result_scan(last_query_id()))
 where "name" = $pipe_name
;
