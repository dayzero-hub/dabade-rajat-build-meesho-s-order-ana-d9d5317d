-- One row per real person (customer_unique_id). The raw customers table has one row per
-- ORDER (customer_id), so a person who ordered three times appears three times there and once here.
with ranked as (
    select
        c.customer_unique_id,
        c.customer_zip_code_prefix,
        c.customer_city,
        c.customer_state,
        row_number() over (
            partition by c.customer_unique_id
            order by o.purchased_at desc, c.customer_id
        ) as rn
    from {{ ref('stg_customers') }} c
    left join {{ ref('stg_orders') }} o on o.customer_id = c.customer_id
)
select
    md5(customer_unique_id) as customer_key,
    customer_unique_id,
    customer_zip_code_prefix,
    customer_city,
    customer_state
from ranked
where rn = 1
