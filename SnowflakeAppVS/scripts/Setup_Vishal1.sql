-- Setup script for the Hello Snowflake! application.
CREATE APPLICATION ROLE app_public;
CREATE SCHEMA IF NOT EXISTS core;
GRANT USAGE ON SCHEMA core TO APPLICATION ROLE app_public;
CREATE OR REPLACE PROCEDURE CORE.HELLO()
  RETURNS STRING
  LANGUAGE SQL
  EXECUTE AS OWNER
  AS
  BEGIN
    RETURN 'Hello Snowflake!';
  END;
  GRANT USAGE ON PROCEDURE core.hello() TO APPLICATION ROLE app_public;
  CREATE OR ALTER VERSIONED SCHEMA code_schema;
GRANT USAGE ON SCHEMA code_schema TO APPLICATION ROLE app_public;
CREATE VIEW IF NOT EXISTS code_schema.accounts_view
  AS SELECT ID, NAME, VALUE
  FROM shared_data.accounts;
GRANT SELECT ON VIEW code_schema.accounts_view TO APPLICATION ROLE app_public;

CREATE OR REPLACE FUNCTION code_schema.addone(i int)
RETURNS INT
LANGUAGE PYTHON
RUNTIME_VERSION = '3.8'
HANDLER = 'addone_py'
AS
$$
def addone_py(i):
  return i+1
$$;

GRANT USAGE ON FUNCTION code_schema.addone(int) TO APPLICATION ROLE app_public;

CREATE or REPLACE FUNCTION code_schema.multiply(num1 float, num2 float)
  RETURNS float
  LANGUAGE PYTHON
  RUNTIME_VERSION=3.8
  IMPORTS = ('/python/hello_python.py')
  HANDLER='hello_python.multiply';

GRANT USAGE ON FUNCTION code_schema.multiply(FLOAT, FLOAT) TO APPLICATION ROLE app_public;
CREATE STREAMLIT code_schema.hello_snowflake_streamlit
  FROM '/streamlit'
  MAIN_FILE = '/hello_snowflake.py'
;
GRANT USAGE ON STREAMLIT code_schema.hello_snowflake_streamlit TO APPLICATION ROLE app_public;