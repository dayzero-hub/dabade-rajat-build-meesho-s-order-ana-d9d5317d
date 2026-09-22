-- Fails if a staged order line has no parent order, or a fact line points at a dimension row
-- that does not exist.
select 'no_parent_order' as problem, i.order_id, i.order_item_id
from {{ ref('stg_order_items') }} i
left join {{ ref('stg_orders') }} o on o.order_id = i.order_id
where o.order_id is null

union all

select 'no_customer' as problem, f.order_id, f.order_item_id
from {{ ref('fct_order_items') }} f
left join {{ ref('dim_customers') }} c on c.customer_key = f.customer_key
where c.customer_key is null

union all

select 'no_seller', f.order_id, f.order_item_id
from {{ ref('fct_order_items') }} f
left join {{ ref('dim_sellers') }} s on s.seller_key = f.seller_key
where s.seller_key is null

union all

select 'no_product', f.order_id, f.order_item_id
from {{ ref('fct_order_items') }} f
left join {{ ref('dim_products') }} p on p.product_key = f.product_key
where p.product_key is null
