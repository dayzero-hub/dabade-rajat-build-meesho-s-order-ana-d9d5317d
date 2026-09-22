# Meesho order analytics warehouse

A dbt project that turns Meesho's raw marketplace tables into a clean, tested **star schema**,
built on an embedded **DuckDB** warehouse. There is no database server and no Docker — the whole
warehouse is a single `.duckdb` file that `dbt build` rebuilds from the CSVs.

The story is Meesho's; the underlying data is the public **Brazilian E-Commerce (Olist)**
dataset — a real marketplace of thousands of small sellers, which is why it fits. Treat the
columns as Meesho's.

## 1. Install the tools

You need **Python 3.10+** and **git**. From the repo root:

```bash
python3 -m venv .venv && source .venv/bin/activate
pip install dbt-duckdb        # pulls dbt-core and DuckDB
```

## 2. Get the data

The CSVs are **not** in this repo — you download them once from Kaggle. It is a free account.

1. Open the dataset: https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce
2. Sign in (free), press **Download**, and unzip it.
3. Copy these **seven** files into `seeds/raw/` in this repo — the names must match exactly:

   ```
   seeds/raw/olist_orders_dataset.csv
   seeds/raw/olist_order_items_dataset.csv
   seeds/raw/olist_customers_dataset.csv
   seeds/raw/olist_sellers_dataset.csv
   seeds/raw/olist_products_dataset.csv
   seeds/raw/olist_order_payments_dataset.csv
   seeds/raw/olist_order_reviews_dataset.csv
   ```

   The download contains a couple of extra files (geolocation, a category translation) — you
   do not need them for this project. `seeds/raw/` is tracked with a `.gitkeep`; the CSVs
   themselves are gitignored, so they stay on your machine and are never pushed.

## 3. Build it

```bash
dbt seed          # loads the CSVs in seeds/raw/ into the warehouse
dbt build         # runs every model and every test
```

On a fresh clone, before you have written any models, `dbt build` is a green no-op — nothing to
seed if you have not downloaded yet, and no models to run. That is the "it works before I change
anything" check. Once the data is in place, `dbt seed` loads the seven raw tables and you are
ready to start ticket 1.

`make build`, `make seed`, `make docs` and `make clean` wrap the same commands.

## Layout

```
dbt_project.yml     project config — model paths and materialisations
profiles.yml        project-local profile pointing dbt at a local .duckdb file
seeds/raw/          where the seven CSVs go (downloaded from Kaggle; gitignored)
models/
  staging/          stg_* — one per raw table, views, clean + rename only
  marts/            dim_* and fct_* — the star schema you build
tests/              singular tests (e.g. the fact grain)
```

## Common problems

- **`dbt seed` loads nothing** — the CSVs are not in `seeds/raw/` yet, or the filenames do not
  match the list above. Check step 2.
- **`Could not find profile`** — run dbt from the repo root, where `profiles.yml` lives.
- **A stale warehouse** — delete `meesho.duckdb` (or `make clean`) and rebuild; nothing is
  precious, `dbt build` recreates it from the CSVs.
