DROP SCHEMA IF EXISTS test CASCADE;
CREATE SCHEMA test AUTHORIZATION bob;
GRANT ALL ON SCHEMA test to bob;

CREATE TYPE test.result_type AS (
    name              VARCHAR(255)
  , status            BOOLEAN
  , description       JSON
);

CREATE OR REPLACE FUNCTION test.add_user(
  _name    VARCHAR(255)
)
RETURNS test.result_type
AS $$
DECLARE
  res test.result_type;
  tmp api.user_type;
  e6 text; e7 text; e8 text; e9 text;
BEGIN
  SELECT CONCAT('add user', ' ', $1) INTO res.name;
  SELECT * FROM api.add_user($1) INTO tmp;
  res.description := json_build_object();
  res.status := TRUE;
  RETURN res;
EXCEPTION
  when others then get stacked diagnostics e6=returned_sqlstate, e7=message_text, e8=pg_exception_detail, e9=pg_exception_context;
  res.description := json_build_object('code',e6,'message',e7,'detail',e8,'context',e9);
  res.status := FALSE;
  RETURN res;
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION test.add_duplicate_user(
  _name    VARCHAR(255)
)
RETURNS test.result_type
AS $$
-- We can add a user with duplicate name, it will be considered an update.
-- So if we should not expect an exception when inserting a duplicate user.
DECLARE
  res test.result_type;
  tmp api.user_type;
  e6 text; e7 text; e8 text; e9 text;
BEGIN
  SELECT CONCAT('add duplicate user', ' ', $1) INTO res.name;
  SELECT * FROM api.add_user($1) INTO tmp;
  res.description := json_build_object();
  res.status := TRUE;
  RETURN res;
EXCEPTION
  when others then get stacked diagnostics e6=returned_sqlstate, e7=message_text, e8=pg_exception_detail, e9=pg_exception_context;
  res.description := json_build_object('code',e6,'message',e7,'detail',e8,'context',e9);
  res.status := FALSE;
  RETURN res;
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION test.find_user(
  _name VARCHAR(255)
)
RETURNS test.result_type
AS $$
DECLARE
  res test.result_type;
  tmp api.user_type;
  e6 text; e7 text; e8 text; e9 text;
BEGIN
  SELECT CONCAT('add and find user', ' ', $1) INTO res.name;
  SELECT * FROM api.find_user_by_name($1) INTO tmp;
  res.description := json_build_object();
  res.status := TRUE;
  RETURN res;
EXCEPTION
  when others then get stacked diagnostics e6=returned_sqlstate, e7=message_text, e8=pg_exception_detail, e9=pg_exception_context;
  res.description := json_build_object('code',e6,'message',e7,'detail',e8,'context',e9);
  res.status := FALSE;
  RETURN res;
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION test.delete_user(
  _name VARCHAR(255)
)
RETURNS test.result_type
AS $$
DECLARE
  res test.result_type;
  tmp api.user_type;
  e6 text; e7 text; e8 text; e9 text;
BEGIN
  SELECT CONCAT('delete user', ' ', $1) INTO res.name;
  SELECT * FROM api.delete_user_by_name($1) INTO tmp;
  res.description := json_build_object();
  res.status := TRUE;
  RETURN res;
EXCEPTION
  when others then get stacked diagnostics e6=returned_sqlstate, e7=message_text, e8=pg_exception_detail, e9=pg_exception_context;
  res.description := json_build_object('code',e6,'message',e7,'detail',e8,'context',e9);
  res.status := FALSE;
  RETURN res;
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION test.main()
RETURNS SETOF test.result_type
AS $$
BEGIN
  CREATE TABLE test.results (
      name              VARCHAR(255)
    , status            BOOLEAN
    , description       JSON
  );
  INSERT INTO test.results SELECT * FROM test.add_user('bob');                                 -- we add a user bob
  INSERT INTO test.results SELECT * FROM test.add_duplicate_user('bob');                       -- we add bob again
  INSERT INTO test.results SELECT * FROM test.find_user('bob');                                -- we check bob is in there
  RETURN QUERY SELECT * from test.results;
END;
$$
LANGUAGE plpgsql;

