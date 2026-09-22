.PHONY: build seed docs clean

# `make build` runs the whole project end to end: load the seeds, then run every model and
# every test. On a fresh clone with no CSVs yet it is a green no-op — nothing to seed, no
# models to run — which is exactly the "does it build before I change anything" check.
build:
	dbt build

# Load the CSVs in seeds/raw/ into the warehouse. Does nothing until you have downloaded them
# (see README).
seed:
	dbt seed

docs:
	dbt docs generate

clean:
	dbt clean
	rm -f meesho.duckdb meesho.duckdb.wal
