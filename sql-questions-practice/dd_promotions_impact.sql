-- Context: DoorDash wants to analyze the impact of promotional offers on customer retention and order behavior.
-- Database Tables:

-- orders (order_id, customer_id, merchant_id, order_timestamp, subtotal, delivery_fee, total_amount)
-- customers (customer_id, signup_date, city, state)
-- promotions (promotion_id, promotion_name, discount_type, discount_amount, start_date, end_date)
-- order_promotions (order_id, promotion_id)

-- Question:
-- DoorDash ran several different promotions in January 2024 and wants to understand their effectiveness. 
-- Write a SQL query to:

-- Calculate the redemption rate for each promotion (percentage of customers who used the promotion at least once)
with eligible_customers as (
    select count(*) as total_customers
    from customers
    where signup_date < '2024-01-01'
)

select 
    op.promotion_id
    , count(distinct ord.customer_id) / (select total_customers from eligible_customers) as redemption_rate
from orders ord
inner join order_promotions op
on ord.order_id = op.order_id
where ord.order_timestamp between '2024-01-01' and '2024-01-31'
group by 1

-- For each promotion, calculate the average number of orders per customer in the 30 days after their first use of the promotion
with promotion_use_date as (
    select 
        op.promotion_id
        , ord.customer_id
        , min(ord.order_timestamp) as first_use_date
    from orders ord
    inner join order_promotions op
    on ord.order_id = op.order_id
    inner join customers cust
    on ord.customer_id = cust.customer_id
    where ord.order_timestamp between '2024-01-01' and '2024-01-31'
    and cust.signup_date < '2024-01-01'
    group by 1, 2 
), after_30days_metrics as (
    select
        pud.promotion_id
        , count(distinct ord.order_id) / count(distinct ord.custoemr_id) as avg_orders_per_customer_after_30days
    from promotion_use_date pud
    -- left join because we include all those customers who didnt order in next 30 days
    -- universe/denominator is all customers who used the promotion
    left join orders ord
    on ord.customer_id = pud.customer_id
    where (ord.order_timestamp between pud.first_use_date + interva 1 day and pud.first_use_date + interval 31 day)
    group by 1
), before_30days_metrics as (
    select
        pud.promotion_id
        , count(distinct ord.order_id) / count(distinct ord.custoemr_id) as avg_orders_per_customer_after_30days
    from promotion_use_date pud
    -- left join because we include all those customers who didnt order in next 30 days
    left join orders ord
    on ord.customer_id = pud.customer_id
    where (ord.order_timestamp between pud.first_use_date - interva 31 day and pud.first_use_date - interval 1 day)
    group by 1
)

select 
    a30.promotion_id
    , a30.avg_orders_per_customer_after_30days
    , b30.avg_orders_per_customer_before_30days
    , round((a30.avg_orders_per_customer_after_30days - b30.avg_orders_per_customer_before_30days)*100.0 / b30.avg_orders_per_customer_before_30days, 2) as percentage_change
from after_30days_metrics a30
inner join before_30days_metrics b30
on a30.promotion_id = b30.promotion_id
order by 4 desc


-- Compare this to the average number of orders per customer in the 30 days before their first use of the promotion
-- Calculate the percentage increase/decrease in order frequency
-- Order the results by the percentage change in order frequency (highest impact first)

-- Include only customers who signed up before January 1, 2024 to ensure they have sufficient history for the before/after comparison.