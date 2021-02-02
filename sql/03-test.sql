DROP SCHEMA IF EXISTS test CASCADE;
CREATE SCHEMA test AUTHORIZATION bob;
GRANT ALL ON SCHEMA test to bob;

CREATE TYPE test.result_type AS (
    name              VARCHAR(255)
  , status            BOOLEAN
  , description       JSON
);

---------------------------
----- C U R R E N C Y -----
---------------------------

CREATE OR REPLACE FUNCTION test.add_currency(
    _code      CHAR(3)
  , _name      VARCHAR(255)
  , _decimals  INTEGER
)
RETURNS test.result_type
AS $$
DECLARE
  res test.result_type;
  tmp api.currency_type;
  e6 text; e7 text; e8 text; e9 text;
BEGIN
  SELECT CONCAT('add currency', ' ', $1) INTO res.name;
  SELECT * FROM api.add_currency($1, $2, 2) INTO tmp;
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

-------------------
----- U S E R -----
-------------------

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

-------------------------
----- S Y M B O L S -----
-------------------------

CREATE OR REPLACE FUNCTION test.add_symbol(
    _ticker  VARCHAR(32)
  , _name    VARCHAR(255)
)
RETURNS test.result_type
AS $$
DECLARE
  res test.result_type;
  tmp api.symbol_type;
  e6 text; e7 text; e8 text; e9 text;
BEGIN
  SELECT CONCAT('add symbol', ' ', $1) INTO res.name;
  SELECT * FROM api.add_symbol($1, $2, 'EUR') INTO tmp; -- For tests, currency is hardcoded
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

CREATE OR REPLACE FUNCTION test.add_duplicate_symbol(
    _ticker  VARCHAR(32)
  , _name    VARCHAR(255)
)
RETURNS test.result_type
AS $$
-- We can add a symbol with duplicate name, it will be considered an update.
-- So if we should not expect an exception when inserting a duplicate symbol.
DECLARE
  res test.result_type;
  tmp api.symbol_type;
  e6 text; e7 text; e8 text; e9 text;
BEGIN
  SELECT CONCAT('add duplicate symbol', ' ', $1) INTO res.name;
  SELECT * FROM api.add_symbol($1, $2, 'EUR') INTO tmp;
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

CREATE OR REPLACE FUNCTION test.find_symbol(
  _ticker VARCHAR(32)
)
RETURNS test.result_type
AS $$
DECLARE
  res test.result_type;
  tmp api.symbol_type;
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

CREATE OR REPLACE FUNCTION test.delete_symbol(
  _ticker VARCHAR(32)
)
RETURNS test.result_type
AS $$
DECLARE
  res test.result_type;
  tmp api.user_type;
  e6 text; e7 text; e8 text; e9 text;
BEGIN
  SELECT CONCAT('delete symbol', ' ', $1) INTO res.name;
  SELECT * FROM api.delete_symbol_by_ticker($1) INTO tmp;
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

-------------------------------
----- P O R T F O L I O S -----
-------------------------------

CREATE OR REPLACE FUNCTION test.add_portfolio(
    _name      VARCHAR(255)
  , _owner     VARCHAR(255)
  , _balance   INTEGER
)
RETURNS test.result_type
AS $$
DECLARE
  res test.result_type;
  tmp api.portfolio_type;
  e6 text; e7 text; e8 text; e9 text;
BEGIN
  SELECT CONCAT('add portfolio', ' ', $1) INTO res.name;
  SELECT * FROM api.add_portfolio($1, $2, $3, 'EUR') INTO tmp; -- For tests, currency is hardcoded
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

CREATE OR REPLACE FUNCTION test.add_symbol_portfolio(
    _portfolio    VARCHAR(255)
  , _ticker       VARCHAR(32)
  , _quantity     INTEGER
  , _price        INTEGER
)
RETURNS test.result_type
AS $$
DECLARE
  res test.result_type;
  tmp api.portfolio_type;
  e6 text; e7 text; e8 text; e9 text;
BEGIN
  SELECT CONCAT('add ', $2, ' to portfolio ', $1) INTO res.name;
  SELECT * FROM api.update_symbol_portfolio($1, $2, $3, $4) INTO tmp; -- For tests, currency is hardcoded
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

-------------------
----- M A I N -----
-------------------

CREATE OR REPLACE FUNCTION test.main()
RETURNS SETOF test.result_type
AS $$
BEGIN
  CREATE TABLE test.results (
      name              VARCHAR(255)
    , status            BOOLEAN
    , description       JSON
  );
  INSERT INTO test.results SELECT * FROM test.add_currency('EUR', 'Euro', 2);                  -- we add a currency
  INSERT INTO test.results SELECT * FROM test.add_user('bob');                                 -- we add a user bob
  INSERT INTO test.results SELECT * FROM test.add_duplicate_user('bob');                       -- we add bob again
  INSERT INTO test.results SELECT * FROM test.find_user('bob');                                -- we check bob is in there
  INSERT INTO test.results SELECT * FROM test.add_symbol('AMD', 'AMD, Inc');                   -- we add a AMD symbol
  INSERT INTO test.results SELECT * FROM test.find_symbol('AMD');                              -- we check AMD is in there
  INSERT INTO test.results SELECT * FROM test.add_portfolio('bobs', 'bob', 100000);            -- we add a portfolio for bob
  INSERT INTO test.results SELECT * FROM test.add_symbol_portfolio('bobs', 'AMD', 3, 9000);    -- we add 3 shares of AMD
  RETURN QUERY SELECT * from test.results;
END;
$$
LANGUAGE plpgsql;


