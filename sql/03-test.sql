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
  tmp api.portfolio_symbol_type;
  e6 text; e7 text; e8 text; e9 text;
BEGIN
  SELECT CONCAT('add ', $2, ' to portfolio ', $1) INTO res.name;
  SELECT * FROM api.update_portfolio_symbol($1, $2, $3, $4) INTO tmp; -- For tests, currency is hardcoded
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

CREATE OR REPLACE FUNCTION test.check_portfolio_balance(
    _portfolio   VARCHAR(255)
  , _expected    INTEGER
)
RETURNS test.result_type
AS $$
DECLARE
  res test.result_type;
  _balance INTEGER;
  e6 text; e7 text; e8 text; e9 text;
BEGIN
  SELECT CONCAT('check balance', ' ', $1) INTO res.name;
  SELECT balance FROM api.find_portfolio_by_name($1) INTO _balance;
  IF _balance = $2 THEN
    res.description := json_build_object();
    res.status := TRUE;
  ELSE
    res.description := json_build_object('code', 'invalid price', 'expected', $2, 'actual', _balance);
    res.status := FALSE;
  END IF;
  RETURN res;
EXCEPTION
  when others then get stacked diagnostics e6=returned_sqlstate, e7=message_text, e8=pg_exception_detail, e9=pg_exception_context;
  res.description := json_build_object('code',e6,'message',e7,'detail',e8,'context',e9);
  res.status := FALSE;
  RETURN res;
END;
$$
LANGUAGE plpgsql;

-----------------------
----- E V E N T S -----
-----------------------

CREATE OR REPLACE FUNCTION test.add_event(
    _ticker    VARCHAR(32)
  , _price     INTEGER
)
RETURNS test.result_type
AS $$
DECLARE
  res test.result_type;
  tmp api.event_type;
  e6 text; e7 text; e8 text; e9 text;
BEGIN
  SELECT CONCAT('add event', ' ', $1) INTO res.name;
  SELECT * FROM api.add_event($1, $2) INTO tmp;
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

CREATE OR REPLACE FUNCTION test.check_last_price(
    _ticker    VARCHAR(32)
  , _price     INTEGER
)
RETURNS test.result_type
AS $$
DECLARE
  res test.result_type;
  tmp INTEGER;
  e6 text; e7 text; e8 text; e9 text;
BEGIN
  SELECT CONCAT('check price', ' ', $1) INTO res.name;
  SELECT * FROM api.find_last_price_by_ticker($1) INTO tmp;
  IF tmp = $2 THEN
    res.description := json_build_object();
    res.status := TRUE;
  ELSE
    res.description := json_build_object('code', 'invalid price', 'expected', $2, 'actual', tmp);
    res.status := FALSE;
  END IF;
  RETURN res;
EXCEPTION
  when others then get stacked diagnostics e6=returned_sqlstate, e7=message_text, e8=pg_exception_detail, e9=pg_exception_context;
  res.description := json_build_object('code',e6,'message',e7,'detail',e8,'context',e9);
  res.status := FALSE;
  RETURN res;
END;
$$
LANGUAGE plpgsql;

-----------------------
----- O R D E R S -----
-----------------------

CREATE OR REPLACE FUNCTION test.add_order(
    _type      main.order_type
  , _portfolio VARCHAR(255)
  , _ticker    VARCHAR(32)
  , _quantity  INTEGER
)
RETURNS test.result_type
AS $$
DECLARE
  res test.result_type;
  tmp api.order_type;
  e6 text; e7 text; e8 text; e9 text;
BEGIN
  SELECT CONCAT('add order for symbol', ' ', $3) INTO res.name;
  SELECT * FROM api.add_order($1, $2, $3, $4) INTO tmp;
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
  INSERT INTO test.results SELECT * FROM test.check_portfolio_balance('bobs', 100000);         -- we check we still have the money
  INSERT INTO test.results SELECT * FROM test.add_symbol_portfolio('bobs', 'AMD', 3, 5000);    -- we add 3 shares of AMD
  INSERT INTO test.results SELECT * FROM test.check_portfolio_balance('bobs', 85000);          -- we check we still have the money
  INSERT INTO test.results SELECT * FROM test.add_event('AMD', 9000);                          -- we add a price for AMD
  INSERT INTO test.results SELECT * FROM test.check_last_price('AMD', 9000);                   -- we check we have the right price for AMD
  INSERT INTO test.results SELECT * FROM test.add_order('buy', 'bobs', 'AMD', 1);              -- we check we have the right price for AMD
  INSERT INTO test.results SELECT * FROM test.check_portfolio_balance('bobs', 76000);          -- we check we still have the money
  INSERT INTO test.results SELECT * FROM test.add_event('AMD', 10000);                         -- we check we have the right price for AMD
  INSERT INTO test.results SELECT * FROM test.check_last_price('AMD', 10000);                  -- we check we have the right price for AMD
  INSERT INTO test.results SELECT * FROM test.add_order('sell', 'bobs', 'AMD', 3);             -- we check we have the right price for AMD
  INSERT INTO test.results SELECT * FROM test.check_portfolio_balance('bobs', 106000);         -- we check we still have the money
  -- For some unexplained reason, if I insert a second price, it will have the same timestamp as the first and the test 'last price' will fail.
  -- I tried with PERFORM pg_sleep(.5)... to no avail.
  RETURN QUERY SELECT * from test.results;
END;
$$
LANGUAGE plpgsql;


