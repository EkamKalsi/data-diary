-- DoorDash SQL Interview Question - Marketplace Efficiency
-- Context: You're analyzing DoorDash's marketplace dynamics to optimize Dasher efficiency and merchant operations.
-- Database Tables:

-- deliveries (delivery_id, order_id, dasher_id, pickup_time, dropoff_time, delivery_status, distance_miles)
-- orders (order_id, customer_id, merchant_id, order_time, order_total, num_items, estimated_prep_time_min)
-- dashers (dasher_id, dasher_city, dasher_state, signup_date, vehicle_type)
-- merchants (merchant_id, merchant_name, merchant_city, merchant_state, cuisine_type, average_prep_time_min)

-- Part 1: Dasher Efficiency (Easy)
-- Calculate the average delivery time (in minutes) and average distance per delivery 
-- for each vehicle type (bike, car, scooter) during the last week of February 2024. 
-- Also include the count of deliveries for each vehicle type. 
-- Order the results by average delivery time in ascending order.

select 
    dash.vehicle_type
    , avg(timestamp_diff(del.pickup_time, del.dropoff_time, minute)) as avg_delivery_time
    , avg(del.distance_miles) as avg_distance
    , count(distinct del.delivery_id) as delivery_count
from deliveries del
inner join dashers dash
on del.dasher_id = dash.dasher_id
where del.pickup_time between '2024-02-22' and '2024-02-29' --leap year
group by 1
order by 3;

-- Part 2: Merchant Wait Time (Medium)
-- DoorDash wants to identify merchants where Dashers are waiting too long for orders to be ready.
-- Write a SQL query to find the top 10 merchants with the longest average wait times.
-- Wait time is defined as the difference between the scheduled pickup time (order_time + estimated_prep_time_min) 
-- and the actual pickup_time.
-- Only include merchants with at least 30 deliveries in February 2024.
-- Return the merchant name, cuisine type, average wait time in minutes, 
-- percentage of orders where Dashers waited more than 5 minutes, 
-- and total delivery count, 
-- sorted by average wait time in descending order.

with int_late_merchants as (
    select 
        mer.merchant_id
        , mer.merchant_name
        , ord.order_id
        , del.delivery_id
        , mer.cuisine_type
        , timestamp_diff(ord.order_time + interval ord.estimatedprep_time_min minute, del.pickup_time, minute) as wait_time
    from deliveries del
    inner join orders ord
    on del.order_id = ord.order_id
    inner join merchants mer
    on ord.merchant_id = mer.merchant_id
    where ord.order_time between '2024-02-01' and '2024-02-29'
)

select 
  max(merchant_name) as merchant_name
  , max(cuisine_type) as cuisine_type
  , avg(wait_time) as avg_wait_time
  , count(distinct case when wait_time > 5 then order_id end) / count(distinct order_id) as pct_orders_late
  , count(distinct delivery_id) as delivery_count
from int_late_merchants
group by merchant_id 
having count(distinct del.delivery_id) >= 30
order by 3 desc


-- DoorDash is trying to optimize Dasher allocation during peak hours. 
-- They want to understand which areas experience the highest order density during the dinner rush (5-8 PM) on weekdays vs. weekends.
-- Write a SQL query that:

-- Calculates the number of orders per hour during dinner rush (5-8 PM) for each merchant_city
-- Compares weekday vs. weekend order patterns
-- Identifies the "peak hour" (the hour with the most orders) for each city
-- Calculates the ratio of Dashers to orders during each city's peak hour

-- Return the city, 
-- whether it's a weekday or weekend, 
-- the peak hour, 
-- orders during peak hour, 
-- number of unique dashers active during that hour, 
-- and the dasher-to-order ratio. 
-- Sort by orders during peak hour in descending order.

-- easy to identify, for each city, from orders wither its a weekday or weekend, the peak hour, orders
-- to identify dashers active at that time, we can use left join from dashers to deliveries
-- calcualte for each dasher_city, weekday/weekend, each peak hour, how many dashers are active or not

select 
    dash.dasher_city
    , case when extract(DAYOFWEEK from ord.order_time) between 2 and 6 then 'weekday' else 'weekend' end as day_type
    , extract(hour from ord.pickup_time) as peak_hour
    , count(distinct del.dasher_id)  as busy_dashers_count
    , count(distinct dash.dasher_id) - count(distinct del.dasher_id) as active_dashers_count
    , count(distinct ord.order_id) as orders_count
    , (count(distinct dash.dasher_id) - count(distinct del.dasher_id))/count(distinct ord.order_id) as dasher_order_ratio
    , rank() over( partition by dash.dasher_city,extract(hour from ord.pickup_time partition by count(distinct ord.order_id)    )
from dashers dash
left join deliveries del
on dash.dasher_id = del.dasher_id
inner join orders ord
on del.order_id = ord.order_id
where extract(hour from ord.order_time) between 17 and 18
group by 1, 2, 3
order by 6 desc;