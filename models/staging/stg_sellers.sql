select
    cast(seller_id as varchar)              as seller_id,
    cast(seller_zip_code_prefix as varchar) as seller_zip_code_prefix,
    cast(seller_city as varchar)            as seller_city,
    cast(seller_state as varchar)           as seller_state
from {{ source('raw', 'olist_sellers_dataset') }}
