-- One row per calendar day from the first purchase to the last estimated delivery.
with bounds as (
    select
        cast(min(purchased_at) as date)                                   as start_date,
        cast(greatest(max(purchased_at), max(estimated_delivery_date_fallback)) as date) as end_date
    from (
        select purchased_at, coalesce(estimated_delivery_at, purchased_at) as estimated_delivery_date_fallback
        from {{ ref('stg_orders') }}
    )
),
days as (
    select cast(unnest(generate_series(start_date, end_date, interval 1 day)) as date) as date_day
    from bounds
)
select
    cast(strftime(date_day, '%Y%m%d') as integer) as date_key,
    date_day,
    year(date_day)                    as year,
    quarter(date_day)                 as quarter,
    month(date_day)                   as month,
    monthname(date_day)               as month_name,
    week(date_day)                    as week_of_year,
    day(date_day)                     as day_of_month,
    dayofweek(date_day)               as day_of_week,
    dayname(date_day)                 as day_name,
    dayofweek(date_day) in (0, 6)     as is_weekend,
    strftime(date_day, '%Y-%m')       as year_month
from days
