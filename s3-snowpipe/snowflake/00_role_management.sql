--------------------------------------------------------------------------------
-- SETUP

use role securityadmin;
set warehouse_name = 'COMPUTE_WH';
set database_name  = 'DEMO_DB';

--------------------------------------------------------------------------------
-- READ

set read_role_name = concat('READ_', $database_name);

-- create role

create role if not exists identifier($read_role_name)
    comment = 'Can query, interact with data, perform read operations';

-- grant privileges

grant usage  on warehouse                   identifier($warehouse_name) to role identifier($read_role_name);

grant usage  on database                    identifier($database_name)  to role identifier($read_role_name);

grant usage  on all schemas    in database  identifier($database_name)  to role identifier($read_role_name);
grant usage  on future schemas in database  identifier($database_name)  to role identifier($read_role_name);

grant select on all tables     in database  identifier($database_name)  to role identifier($read_role_name);
grant select on future tables  in database  identifier($database_name)  to role identifier($read_role_name);

grant select on all views      in database  identifier($database_name)  to role identifier($read_role_name);
grant select on future views   in database  identifier($database_name)  to role identifier($read_role_name);


--------------------------------------------------------------------------------
-- WRITE

set write_role_name = concat('WRITE_', $database_name);

-- create role

create role if not exists identifier($write_role_name)
    comment = 'Can operate on the data for updates, insert etc.';

-- grant usage

grant role identifier($read_role_name) to role identifier($write_role_name);

-- grant privileges

grant all on database                      identifier($database_name)  to role identifier($write_role_name);

grant all on all schemas      in database  identifier($database_name)  to role identifier($write_role_name);
grant all on future schemas   in database  identifier($database_name)  to role identifier($write_role_name);

grant all on all tables       in database  identifier($database_name)  to role identifier($write_role_name);
grant all on future tables    in database  identifier($database_name)  to role identifier($write_role_name);

grant all on all views        in database  identifier($database_name)  to role identifier($write_role_name);
grant all on future views     in database  identifier($database_name)  to role identifier($write_role_name);


--------------------------------------------------------------------------------
-- DATABASEADMIN

set dba_role_name = concat('DBA_', $database_name);

-- create role

create role if not exists identifier($dba_role_name)
    comment = 'Database administrator can manage databases and consituents';

-- grant usage

grant role identifier($write_role_name) to role identifier($dba_role_name);
grant role identifier($dba_role_name)   to role sysadmin;

-- grant privileges

use role accountadmin;
grant create integration on account to role identifier($dba_role_name);
grant create database    on account to role identifier($dba_role_name);
grant create warehouse   on account to role identifier($dba_role_name);
grant execute task       on account to role identifier($dba_role_name);