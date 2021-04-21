--------------------------------------------------------------------------------
-- READACCESS

use role SECURITYADMIN;

--  set variables

set role_name = 'READACCESS';
set database_name   = 'DEMO_DB';

-- create role

create role if not exists identifier($role_name)
    comment = 'Can query, interact with data, perform read operations';

-- grant privileges

grant usage on warehouse COMPUTE_WH to role identifier($role_name);

grant usage on database identifier($database_name) to role identifier($role_name);

grant usage on all schemas    in database identifier($database_name) to role identifier($role_name);
grant usage on future schemas in database identifier($database_name) to role identifier($role_name);

grant select on all tables    in database identifier($database_name) to role identifier($role_name);
grant select on future tables in database identifier($database_name) to role identifier($role_name);

grant select on all views    in database identifier($database_name) to role identifier($role_name);
grant select on future views in database identifier($database_name) to role identifier($role_name);

grant role PUBLIC to role identifier($role_name);

--------------------------------------------------------------------------------
-- WRITEACCESS

use role SECURITYADMIN;

--  set variables

set role_name = 'WRITEACCESS';
set database_name   = 'DEMO_DB';

-- create role

create role if not exists identifier($role_name)
    comment = 'Can operate on the data for updates, insert etc.';

-- grant privileges

grant usage on warehouse COMPUTE_WH to role identifier($role_name);

grant usage on database identifier($database_name) to role identifier($role_name);

grant all on all schemas    in database identifier($database_name) to role identifier($role_name);
grant all on future schemas in database identifier($database_name) to role identifier($role_name);

grant all on all tables    in database identifier($database_name) to role identifier($role_name);
grant all on future tables in database identifier($database_name) to role identifier($role_name);

grant all on all views    in database identifier($database_name) to role identifier($role_name);
grant all on future views in database identifier($database_name) to role identifier($role_name);

grant role READACCESS to role identifier($role_name);

--------------------------------------------------------------------------------
-- DATABASEADMIN

use role SECURITYADMIN;

--  set variables

set role_name = 'DATABASEADMIN';
set database_name   = 'DEMO_DB';

-- create role

create role if not exists identifier($role_name)
    comment = 'Database administrator can manage databases and consituents';

-- grant privileges

grant create database  on ACCOUNT                                            to role identifier($role_name);
grant create warehouse on ACCOUNT                                            to role identifier($role_name);
grant create stage     on ALL SCHEMAS IN DATABASE identifier($database_name) to role identifier($role_name);

grant role WRITEACCESS            to role identifier($role_name);
grant role identifier($role_name) to role SYSADMIN;

-- additional privileges that must be granted by account admin

use role ACCOUNTADMIN;
grant execute task on account to role databaseadmin;