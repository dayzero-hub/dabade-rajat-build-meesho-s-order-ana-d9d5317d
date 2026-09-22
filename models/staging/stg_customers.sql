-- customer_id is per ORDER (a new one is minted for every order); customer_unique_id is the real person.
select
    cast(customer_id as varchar)              as customer_id,
    cast(customer_unique_id as varchar)       as customer_unique_id,
    cast(customer_zip_code_prefix as varchar) as customer_zip_code_prefix,
    cast(customer_city as varchar)            as customer_city,
    cast(customer_state as varchar)           as customer_state
from {{ source('raw', 'olist_customers_dataset') }}
