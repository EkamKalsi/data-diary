-- You're a Product Data Scientist at Shopify working with the following database tables that track merchant activity and performance:

-- **merchants**
-- - merchant_id (primary key)
-- - business_name (string)
-- - subscription_plan (string: 'basic', 'shopify', 'advanced')
-- - industry_category (string)
-- - country (string)
-- - created_at (timestamp)
-- - monthly_subscription_fee (decimal)
-- - active (boolean)
-- - churn_date (timestamp, null if still active)

-- **merchant_features**
-- - feature_id (primary key)
-- - merchant_id (foreign key to merchants)
-- - feature_name (string: 'shopify_payments', 'pos', 'shopify_shipping', etc.)
-- - activation_date (timestamp)
-- - deactivation_date (timestamp, null if still active)
-- - monthly_fee (decimal)

-- **merchant_performance**
-- - merchant_id (foreign key to merchants)
-- - month (date)
-- - gmv (decimal) - Gross Merchandise Value
-- - order_count (integer)
-- - total_revenue (decimal) - Revenue to merchant
-- - shopify_revenue (decimal) - Revenue to Shopify from this merchant
-- - average_order_value (decimal)
-- - refund_rate (decimal)
-- - abandoned_cart_rate (decimal)

-- ### Challenge:

-- The Product team is considering changes to the pricing strategy for Shopify's subscription plans. 
-- They want to understand how different merchant segments are currently performing 
-- and how changes might impact both merchant success and Shopify's revenue.

-- As the Data Scientist on this project:

-- 1. Write SQL queries to analyze merchant performance across different subscription plans and industry categories.

First we understand what does merchant performance mean?
  - merchant revenue overall
  - merchant revenue growth MoM
  - shopify revenue overall

with int_mom_growth as (
    select 
        mer.subscription_plan
        , mer.industry_category
        , mp.month as month_year
        , count(distinct mer.merchant_id) as total_merchants
        , count(distinct case when active=True and date_trunc(mer.churn_date)<>mp.month then mp.merchant_id end) as active_merchants
        , sum(total_revenue) as total_revenue
        , sum(order_count) as total_orders
        , sum(shopify_revenue) as total_shopify_revenue
        , count(distinct case when active=False and date_trunc(mer.churn_date)=mp.month then mp.merchant_id end)/count(distinct mer.merchant_id) as churn_rate
        , sum(shopify_revenue)/count(distinct mer.merchant_id) as avg_shopify_revenue_per_merchant
    from merchants mer
    left join merchant_performance mp
    on mer.merchant_id = mp.merchant_id
    where mp.month between date_trunc('month', current_date) - interval '12 months' and date_trunc('month', current_date)
    group by 1, 2, 3
), int_prev_mom_growth as (
    select
        *
        , lag(active_merchants) over(partition by subscription_plan, industry_category order by month_year) as prev_active_merchants
        , lag(total_revenue) over(partition by subscription_plan, industry_category order by month_year) as prev_total_revenue
        , lag(total_orders) over(partition by subscription_plan, industry_category order by month_year) as prev_total_orders
        , lag(total_shopify_revenue) over(partition by subscription_plan, industry_category order by month_year) as prev_total_shopify_revenue
        , lag(churn_rate) over(partition by subscription_plan, industry_category order by month_year) as prev_churn_rate
        , lag(avg_shopify_revenue_per_merchant) over(partition by subscription_plan, industry_category order by month_year) as prev_avg_shopify_revenue_per_merchant
    from int_mom_growth
), mom_growth as (
    select 
        * 
        , (active_merchants - prev_active_merchants)/prev_active_merchants as mom_growth_active_merchants
        , (total_revenue - prev_total_revenue)/prev_total_revenue as mom_growth_revenue
        , (total_orders - prev_total_orders)/prev_total_orders as mom_growth_order_count
        , (total_shopify_revenue - prev_total_shopify_revenue)/prev_total_shopify_revenue as mom_growth_shopify_revenue
        , (churn_rate - prev_churn_rate)/prev_churn_rate as mom_growth_churn_rate
        , (avg_shopify_revenue_per_merchant - prev_avg_shopify_revenue_per_merchant) as mom_growth_avg_shopify_revenue_per_merchant
    from int_prev_mom_growth
    where prev_total_revenue is not null
), overall_ecosystem as (
    select 
        mer.subscription_plan
        , mer.industry_category
        , count(distinct mer.merchant_id) as total_merchants
        , count(distinct case when mp.merchant is not null then mp.merchant_id end) as active_merchants
        , sum(total_revenue) as total_revenue
        , sum(order_count) as total_orders
        , sum(shopify_revenue) as total_shopify_revenue
        , count(distinct case when active=False and date_trunc(mer.churn_date)=mp.month then mp.merchant_id end)/count(distinct mer.merchant_id) as churn_rate
        , sum(shopify_revenue)/count(distinct mer.merchant_id) as avg_shopify_revenue_per_merchant
        , sum(shopify_revenue)/sum(total_revenue) as shopify_take_rate
    from merchants mer
    left join merchant_performance mp
    on mer.merchant_id = mp.merchant_id
    where mp.month between date_trunc('month', current_date) - interval '12 months' and date_trunc('month', current_date)
    group by 1, 2
)

select *
from mom_growth
order by month_year desc;

select *
from overall_ecosystem;


-- 2. Develop a segmentation approach to identify which merchants might benefit from (or be harmed by) potential pricing changes.

-- 3. Create a Python function that calculates the potential revenue impact of a pricing change scenario.

-- Let's approach this step by step. How would you begin analyzing this data?