DO $$
BEGIN
  CREATE ROLE bob WITH LOGIN PASSWORD 'secret';
  EXCEPTION WHEN DUPLICATE_OBJECT THEN
  RAISE NOTICE 'Not creating role ''bob'' -- it already exists';
END
$$;
