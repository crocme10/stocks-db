DROP SCHEMA IF EXISTS api CASCADE;
CREATE SCHEMA api AUTHORIZATION croesus;
GRANT ALL ON SCHEMA api to croesus;

-------------
--  USERS  --
-------------

CREATE TYPE api.user_type AS (
    id           UUID
	, name         VARCHAR(255)
);

CREATE OR REPLACE FUNCTION api.list_users()
RETURNS SETOF api.user_type
AS $$
BEGIN
  RETURN QUERY
  SELECT id, name
  FROM main.users;
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION api.add_user(
    _name   VARCHAR(255)
) RETURNS api.user_type
AS $$
DECLARE
  res api.user_type;
BEGIN
  INSERT INTO main.users (name) VALUES (
    $1    -- name
  )
  ON CONFLICT ("name") DO UPDATE SET name = EXCLUDED.name
  RETURNING id, name INTO res;
  RETURN res;
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION api.find_user_by_name(
    _name   VARCHAR(255)
)
RETURNS api.user_type
AS $$
DECLARE
  res api.user_type;
BEGIN
  SELECT id, name
  FROM main.users
  WHERE name = _name
  INTO res;
  RETURN res;
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION api.delete_user_by_name(
    _name   VARCHAR(255)
)
RETURNS api.user_type
AS $$
DECLARE
  res api.user_type;
BEGIN
  DELETE FROM main.users
  WHERE name = $1
  RETURNING id, name INTO res;
  RETURN res;
END;
$$
LANGUAGE plpgsql;
