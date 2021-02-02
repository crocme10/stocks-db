## Development loop

Edit sql code, where possible add a tests.

Commit

make {major, minor, patch}-prerelease

./test.sh

psql -U bob -h localhost stocks -c "drop table if exists test.results; select * from test.main();"
