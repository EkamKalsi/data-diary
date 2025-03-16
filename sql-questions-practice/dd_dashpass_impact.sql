-- I'll pose a SQL question similar to what you might encounter in your DoorDash interview:

-- ## DoorDash SQL Interview Question

-- **Context:** DoorDash is analyzing customer retention and the impact of our subscription service, DashPass.

-- **Database Tables:**
-- - `orders` (order_id, customer_id, merchant_id, order_time, subtotal, delivery_fee, tip, total_amount, is_dasher_rated)
-- - `customers` (customer_id, signup_date, city, state, referral_source)
-- - `dashpass_subscriptions` (customer_id, subscription_start_date, subscription_end_date, subscription_status)
-- - `merchants` (merchant_id, merchant_name, cuisine_type, commission_rate, onboarding_date, city, state)

-- **Part 1: Basic Analysis**
-- Write a query to find the average order value, average tip amount, and average delivery fee for DashPass vs. non-DashPass orders in February 2024. Include the count of orders in each category.

-- Is average order value same as total_amount?
-- dashpass is linked to a customer_id, but a custoemr can have both kinds of orders, do we take that into consideration?
WITH int_final_view AS (
    SELECT 
        ord.*,
        CASE 
            WHEN dashpass.subscription_start_date <= ord.order_time
            AND (dashpass.subscription_end_date IS NULL OR ord.order_time <= dashpass.subscription_end_date)
            THEN 1 
            ELSE 0 
        END AS is_dashpass_order
    FROM orders ord
    LEFT JOIN dashpass_subscriptions dashpass
        ON ord.customer_id = dashpass.customer_id
    WHERE ord.order_time BETWEEN '2024-02-01' AND '2024-02-29'
)

SELECT 
    is_dashpass_order,
    AVG(total_amount) AS avg_order_value,
    AVG(tip) AS avg_tip_amount,
    AVG(delivery_fee) AS avg_delivery_fee,
    COUNT(DISTINCT order_id) AS order_count
FROM int_final_view
GROUP BY is_dashpass_order;


-- **Part 2: Retention Analysis**
-- For customers who placed their first order in October 2023, calculate the 30-day, 60-day, and 90-day retention rates
-- , comparing DashPass subscribers vs. non-subscribers. A customer is considered retained if they place at least one order within the respective period after their first order.
with reqd_customers as (
    select 
      customer_id
      , min(order_time) as first_order_time
    from orders
    group by 1
    having min(order_time) between '2023-10-01' and '2023-10-31'
), subscription_status as (
    select 
      rc.custoemr_id
      , case 
          when ds.subscrition_start_date is null then 0
          when ds.subscription_start_date <= rc.first_order_time
          and (ds.subscription_end_date is null or ds.subscription_end_date > rc.first_order_time)
            then 1 
            else 0
        end as is_subscribed
    from reqd_customers rc
    left join dashpass_subscriptions ds
    on rc.customer_id = ds.customer_id
), int_retention_orders as (
    select 
     ord.customer_id
     , case 
        when ord.order_time <= rc.first_order_time + interval 30 day then 1
        else 0
     end as is_30_day_order
     , case 
        when ord.order_time between rc.first_order_time + interval 31 day and rc.first_order_time + interval 60 day  then 1
        else 0
     end as is_60_day_order
     , case 
        when ord.order_time between rc.first_order_time + interval 61 day and rc.first_order_time + interval 90 day  then 1
        else 0
     end as is_90_day_order
    from orders ord
    inner join reqd_customers rc
    on ord.customer_id = rc.customer_id
    where ord.order_time > rc.first_order_time
), retention_orders as (
    select 
        customer_id
        , case when sum(is_30_day_order) > 0 then 1 else 0 end as is_30_day_order
        , case when sum(is_60_day_order) > 0 then 1 else 0 end as is_60_day_order
        , case when sum(is_90_day_order) > 0 then 1 else 0 end as is_90_day_order
    from int_retention_orders
    group by 1
)

select 
    ss.is_subscribed
    , sum(ro.is_30_day_order) / count(distinct ro.customer_id) as 30_day_retention_rate
    , sum(ro.is_60_day_order) / count(distinct ro.customer_id) as 60_day_retention_rate
    , sum(ro.is_90_day_order) / count(distinct ro.customer_id) as 90_day_retention_rate
from subscription_stats ss
inner join retention_orders ro
on ss.customer_id = ro.customer_id

-- **Part 3: Cohort Performance**
-- DoorDash wants to understand if DashPass affects ordering patterns from different restaurant types. 

-- Write a query that:
-- 1. Identifies the top 3 cuisine types by order volume
-- 2. For each of these cuisine types, compares the average orders per customer per month between DashPass subscribers and non-subscribers
-- 3. Calculates the percentage difference in order frequency
-- 4. Orders the results by the cuisine type with the largest DashPass impact

-- How would you like to approach this question?

with top_cuisines as (
    select
        mer.cuisine_type
        , count(distinct ord.order_id) as order_count
    from orders ord
    inner join merchants mer
    on ord.merchant_id = mer.merchant_id
    order by 2 desc
    limit 3
), int_dashpass_orders as (
    select 
        mer.cuisine_type
        , date_trunc(ord.order_time, month) as order_month_year
        , case
            when ds.subscription_start_date is null then 0
            when ds.subscription_start_date <= ord.order_time
            and (ds.subscription_end_date is null or ds.subscription_end_date > ord.order_time)
                then 1
                else 0
        end as is_subscribed
        , count(distinct ord.order_id) as order_count
        , count(distinct ord.customer_id) as customer_count
        , count(distinct ord.order_id) / count(distinct ord.customer_id) as orders_per_customer
    from orders ord
    left join dashpass_subscriptions ds
    on ord.customer_id = ds.customer_id
    inner join merchants mer
    on ord.merchant_id = mer.merchant_id
    inner join top_cuisines tc
    on mer.cuisine_type = tc.cuisine_type
    group by 1, 2, 3
), dashpass_orders as (
    select 
        *
        , lag(orders_per_customer) over (partition by cuisine_type, order_month_year order by is_subscribed) as non_subscribed_orders_per_customer
    from int_dashpass_orders
)

select 
    cuisine_type
    , avg(round((orders_per_customer - non_subscribed_orders_per_customer)*100.0 / non_subscribed_orders_per_customer,2)) as pct_diff
from dashpass_orders
where is_subscribed = 1
order by 2 desc