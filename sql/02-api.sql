DROP SCHEMA IF EXISTS api CASCADE;
CREATE SCHEMA api AUTHORIZATION bob;
GRANT ALL ON SCHEMA api to bob;

-------------
--  USERS  --
-------------

CREATE TYPE api.user_type AS (
    id           UUID
	, name         VARCHAR(255)
  , balance      INTEGER
  , currency     CHAR(3)
);

CREATE OR REPLACE FUNCTION api.list_users()
RETURNS SETOF api.user_type
AS $$
BEGIN
  RETURN QUERY
  SELECT id, name, balance, currency
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
  INSERT INTO main.users (name, balance, currency) VALUES (
      $1    -- name
    , 0     -- balance
    , 'EUR' -- currency
  )
  ON CONFLICT ("name") DO UPDATE SET name = EXCLUDED.name
  RETURNING id, name, balance, currency INTO res;
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
  SELECT id, name, balance, currency
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
  RETURNING id, name, balance, currency INTO res;
  RETURN res;
END;
$$
LANGUAGE plpgsql;

------------------
--  CURRENCIES  --
------------------

CREATE TYPE api.currency_type AS (
    code     CHAR(3)
	, name     VARCHAR(255)
  , decimals INTEGER
);

CREATE OR REPLACE FUNCTION api.list_currencies()
RETURNS SETOF api.currency_type
AS $$
BEGIN
  RETURN QUERY
  SELECT code, name, decimals
  FROM main.currencies;
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION api.add_currency(
    _code   CHAR(3)
  , _name   VARCHAR(255)
  , _decimals INTEGER
) RETURNS api.currency_type
AS $$
DECLARE
  res api.currency_type;
BEGIN
  INSERT INTO main.currencies (code, name, decimals) VALUES (
      $1  -- code
    , $2  -- name
    , $3  -- decimals
  )
  ON CONFLICT ("code") DO UPDATE SET code = EXCLUDED.code
  RETURNING code, name, decimals INTO res;
  RETURN res;
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION api.find_currency_by_code(
    _code   CHAR(3)
)
RETURNS api.currency_type
AS $$
DECLARE
  res api.currency_type;
BEGIN
  SELECT cod, name, decimals
  FROM main.currencies
  WHERE code = _code
  INTO res;
  RETURN res;
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION api.delete_currency_by_code(
    _code   CHAR(3)
)
RETURNS api.currency_type
AS $$
DECLARE
  res api.currency_type;
BEGIN
  DELETE FROM main.currencies
  WHERE code = $1
  RETURNING code, name, decimals INTO res;
  RETURN res;
END;
$$
LANGUAGE plpgsql;
