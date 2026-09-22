-- Grain: one row per order LINE (order_id + order_item_id). price and freight_value live on the
-- line in the source, so this is the only grain at which they add up without double counting.
--
-- Non-delivered orders (cancelled, unavailable, shipped, ...) are KEPT, with order_status carried
-- on the row and delivery_days / delivered_late left null. An analyst filters on
-- order_status = 'delivered' when they want delivery metrics; dropping the rows here would make
-- revenue and cancellation-rate questions unanswerable from the fact.
with items as (
    select * from {{ ref('stg_order_items') }}
),
orders as (
    select * from {{ ref('stg_orders') }}
),
customers as (
    select customer_id, customer_unique_id from {{ ref('stg_customers') }}
)
select
    items.order_id,
    items.order_item_id,
    md5(items.order_id || '-' || items.order_item_id)           as order_item_key,

    -- foreign keys
    md5(customers.customer_unique_id)                          as customer_key,
    md5(items.seller_id)                                       as seller_key,
    md5(items.product_id)                                      as product_key,
    cast(strftime(orders.purchased_at, '%Y%m%d') as integer)   as purchase_date_key,

    -- degenerate dimensions / context
    orders.order_status,
    orders.purchased_at,
    orders.delivered_to_customer_at,
    orders.estimated_delivery_at,

    -- measures
    items.price,
    items.freight_value,
    case
        when orders.order_status = 'delivered' and orders.delivered_to_customer_at is not null
        then date_diff('day', orders.purchased_at, orders.delivered_to_customer_at)
    end                                                        as delivery_days,
    case
        when orders.order_status = 'delivered' and orders.delivered_to_customer_at is not null
        then orders.delivered_to_customer_at > orders.estimated_delivery_at
    end                                                        as delivered_late
from items
inner join orders    on orders.order_id = items.order_id
inner join customers on customers.customer_id = orders.customer_id
