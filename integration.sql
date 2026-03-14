
-- https://sfc-gh-dwilczak.github.io/tutorials/tools/git/

-- https://www.youtube.com/watch?v=WEklZ63mMr4

use sysadmin;

create database raw;

create schema raw.git;

create warehouse if not exists developer
    warehouse_size = small
    initially_suspended = true;

use database raw;
use schema git;
use warehouse developer;


-------------------

use role accountadmin;

create or replace secret github_secret
    type = password
    username = 'icmayank-alt'
    password = ''; 

create or replace api integration git_api_integration
    api_provider = git_https_api
    api_allowed_prefixes = ('https://github.com/icmayank-alt') 
    allowed_authentication_secrets = (github_secret)
    enabled = true;

create or replace git repository for_snowsight
    api_integration = git_api_integration
    git_credentials = github_secret
    origin = 'https://github.com/icmayank-alt/for_snowsight';


-------------


-- Show repos added to snowflake.
show git repositories;

-- Show branches in the repo.
show git branches in git repository for_snowsight;

-- List files.
ls @for_snowsight/branches/main;

-- Show code in file.
select $1 from @for_snowsight/branches/main/current_date.sql;

-- Fetch git repository updates.
alter git repository for_snowsight fetch;


-----------------


-- Run the files in Snowflake.
execute immediate from @for_snowsight/branches/main/current_date.sql;


---------



-- Create snowpark procedure
create or replace procedure hello()
    returns string
    language python 
    runtime_version= '3.9'
    packages=('snowflake-snowpark-python')
    imports=('@for_snowsight/branches/main/hello.py')
    handler='hello.main';

call hello();

-- Streamlit app ...

