CREATE EXTENSION pg_trgm;
CREATE EXTENSION pgcrypto;

-- For aggregating tags
-- See https://stackoverflow.com/questions/31210790/indexing-an-array-for-full-text-search
--
CREATE OR REPLACE FUNCTION textarr2text(TEXT[])
  RETURNS TEXT LANGUAGE SQL IMMUTABLE AS $$SELECT array_to_string($1, ',')$$;

SET CLIENT_MIN_MESSAGES TO INFO;
SET CLIENT_ENCODING = 'UTF8';

DROP SCHEMA IF EXISTS main CASCADE;
CREATE SCHEMA main AUTHORIZATION bob;
GRANT ALL ON SCHEMA main to bob;
SET SEARCH_PATH = main;

-- Assumed a unique exchange.
-- So symbols have a currency attached.

CREATE TABLE IF NOT EXISTS main.users (
  id UUID PRIMARY KEY DEFAULT public.gen_random_uuid(),
	name VARCHAR(255) NOT NULL UNIQUE,
  balance INTEGER
);

ALTER TABLE main.users OWNER TO bob;

CREATE TABLE IF NOT EXISTS main.currencies (
  code CHAR(3) PRIMARY KEY,
	name VARCHAR(255) NOT NULL UNIQUE,
	decimals INT NOT NULL
);

ALTER TABLE main.currencies OWNER TO bob;

CREATE TABLE IF NOT EXISTS main.symbols (
  id UUID PRIMARY KEY DEFAULT public.gen_random_uuid(),
  ticker VARCHAR(32),
  currency CHAR(3) REFERENCES main.currencies(code) ON DELETE RESTRICT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE main.symbols OWNER TO bob;

CREATE TABLE IF NOT EXISTS main.portfolios (
  id UUID PRIMARY KEY DEFAULT public.gen_random_uuid(),
	description TEXT,
	owner UUID REFERENCES main.users(id) ON DELETE RESTRICT,
  balance INTEGER,
  currency CHAR(3) REFERENCES main.currencies(code) ON DELETE RESTRICT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE main.portfolios OWNER TO bob;

CREATE TABLE IF NOT EXISTS main.portfolio_symbol_map (
  portfolio UUID REFERENCES main.portfolios(id) ON DELETE RESTRICT,
  symbol UUID REFERENCES main.symbols(id) ON DELETE RESTRICT
);

ALTER TABLE main.portfolio_symbol_map OWNER TO bob;

CREATE TYPE main.order_type AS ENUM ('buy', 'sell');

CREATE TABLE IF NOT EXISTS main.orders (
  id UUID PRIMARY KEY DEFAULT public.gen_random_uuid(),
  type main.order_type,
  portfolio UUID REFERENCES main.portfolios(id) ON DELETE RESTRICT,
  symbol UUID REFERENCES main.symbols(id) ON DELETE RESTRICT,
  price INTEGER,
  currency CHAR(3) REFERENCES main.currencies(code) ON DELETE RESTRICT,
  quantity INTEGER
);

ALTER TABLE main.orders OWNER TO bob;

CREATE TABLE IF NOT EXISTS main.events (
  id UUID PRIMARY KEY DEFAULT public.gen_random_uuid(),
  symbol UUID REFERENCES main.symbols(id) ON DELETE RESTRICT,
  price INTEGER,
);

ALTER TABLE main.portfolio_symbol_map OWNER TO bob;

CREATE TABLE IF NOT EXISTS main.stats (
  symbol UUID REFERENCES main.symbols(id) ON DELETE RESTRICT,
  stat_date DATE NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
  open INTEGER,
  high INTEGER,
  low INTEGER,
  close INTEGER
  volume INTEGER,
  price INTEGER
);

ALTER TABLE main.stats OWNER TO bob;
