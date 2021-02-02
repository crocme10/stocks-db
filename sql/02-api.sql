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
  SELECT code, name, decimals
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

------------------------
----  S Y M B O L S ----
------------------------

CREATE TYPE api.symbol_type AS (
    id           UUID
	, ticker       VARCHAR(32)
  , name         VARCHAR(255)
  , currency     CHAR(3)
  , created_at   TIMESTAMPTZ
);

CREATE OR REPLACE FUNCTION api.list_symbols()
RETURNS SETOF api.symbol_type
AS $$
BEGIN
  RETURN QUERY
  SELECT id, ticker, name, currency, created_at
  FROM main.symbols;
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION api.add_symbol(
    _ticker   VARCHAR(32)
  , _name     VARCHAR(255)
  , _currency CHAR(3)
) RETURNS api.symbol_type
AS $$
DECLARE
  res api.symbol_type;
BEGIN
  INSERT INTO main.symbols (ticker, name, currency) VALUES (
      $1  -- ticker
    , $2  -- name
    , $3  -- currency
  )
  ON CONFLICT ("ticker") DO UPDATE SET ticker = EXCLUDED.ticker
  RETURNING id, ticker, name, currency, created_at INTO res;
  RETURN res;
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION api.find_symbol_by_ticker(
    _ticker   VARCHAR(32)
)
RETURNS api.symbol_type
AS $$
DECLARE
  res api.symbol_type;
BEGIN
  SELECT id, ticker, name, currency, created_at
  FROM main.symbols
  WHERE ticker = _ticker
  INTO res;
  RETURN res;
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION api.delete_symbol_by_ticker(
    _ticker   VARCHAR(32)
)
RETURNS api.symbol_type
AS $$
DECLARE
  res api.symbol_type;
BEGIN
  DELETE FROM main.symbols
  WHERE ticker = $1
  RETURNING id, ticker, name, currency, created_at INTO res;
  RETURN res;
END;
$$
LANGUAGE plpgsql;

------------------------------
----  P O R T F O L I O S ----
------------------------------

CREATE TYPE api.portfolio_type AS (
    id           UUID
  , name         VARCHAR(255)
  , owner        UUID
  , balance      INTEGER
  , currency     CHAR(3)
  , created_at   TIMESTAMPTZ
  , updated_at   TIMESTAMPTZ
);

CREATE OR REPLACE FUNCTION api.list_portfolios()
RETURNS SETOF api.portfolio_type
AS $$
BEGIN
  RETURN QUERY
  SELECT id, name, owner, balance, currency, created_at, updated_at
  FROM main.portfolios;
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION api.add_portfolio(
    _name      TEXT
  , _owner     VARCHAR(255)
  , _currency  CHAR(3)
) RETURNS api.portfolio_type
AS $$
DECLARE
  res api.portfolio_type;
  owner api.user_type;
BEGIN
  SELECT * FROM api.find_user_by_name($2) INTO owner;
  INSERT INTO main.portfolios (name, owner, balance, currency) VALUES (
      $1        -- name
    , owner.id  -- owner
    , 0         -- balance
    , $3        -- currency
  )
  RETURNING id, name, owner, balance, currency, created_at, updated_at INTO res;
  RETURN res;
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION api.find_portfolio_by_name(
    _name   VARCHAR(255)
)
RETURNS api.portfolio_type
AS $$
DECLARE
  res api.portfolio_type;
BEGIN
  SELECT id, name, owner, balance, currency, created_at, updated_at
  FROM main.portfolios
  WHERE name = _name
  INTO res;
  RETURN res;
END;
$$
LANGUAGE plpgsql;

CREATE TYPE api.portfolio_symbol_type AS (
	  portfolio    VARCHAR(255)
  , symbol       VARCHAR(32)
  , quantity     INTEGER
);

CREATE OR REPLACE FUNCTION api.update_symbol_portfolio(
    _portfolio   VARCHAR(255)
  , _symbol      VARCHAR(32)
  , _quantity    INTEGER        -- how many stocks are added
  , _price       INTEGER        -- price of the stock.
) RETURNS api.portfolio_symbol_type
AS $$
DECLARE
  -- exc_insufficient_balance EXCEPTION;
  -- PRAGMA exception_init(exc_insufficient_balance, -20001);
  res api.portfolio_symbol_type;
  portfolio api.portfolio_type;
  amount INTEGER;
  balance INTEGER;
BEGIN

  SELECT * FROM api.find_portfolio_by_name($1) INTO portfolio;

  amount := _quantity * _price;
  -- We rely on a 'check' on the balance (balance > 0) to make sure there is sufficient fund.
  UPDATE main.portfolios SET balance = balance - amount WHERE id = portfolio.id;
  IF EXISTS (SELECT 1 FROM main.portfolio_symbol_map WHERE portfolio = portfolio.id AND symbol = $2) THEN
    UPDATE main.portfolio_symbol_map
    SET quantity = quantity + $3
    WHERE portfolio = $1 AND symbol = $2
    RETURNING portfolio, symbol, quantity INTO res;
  ELSE
    INSERT INTO main.portfolio_symbol_map (portfolio, symbol, quantity)
    VALUES ($1, $2, $3)
    RETURNING portfolio, symbol, quantity INTO res;
  END IF;
  RETURN res;
END;
$$
LANGUAGE plpgsql;
