-- Context: We want to analyze courier efficiency and delivery performance across different regions.
-- Database Tables:

-- deliveries (delivery_id, courier_id, order_id, pickup_time, dropoff_time, distance_miles)
-- couriers (courier_id, region_id, vehicle_type, signup_date)
-- regions (region_id, region_name, city, state)
-- orders (order_id, customer_id, merchant_id, order_total, order_time)

-- Question:
-- Write a SQL query to calculate the average delivery time (in minutes), average delivery distance, 
-- and average courier earnings per hour for each region and vehicle type (car, bike, scooter) 
-- during February 2024. Only include couriers who completed at least 10 deliveries that month. 
-- Order the results by region and then by average delivery time (fastest first).

-- Daily per hour, or hours in general?
-- how do we get courier earnings? is it order_total? If so, then to get average, do we divide by number of orders or deliveries?

with reqd_couriers as (
    select courier_id
    from deliveries
    where pickup_time between '2024-02-01' and '2024-02-29'
    group by 1
    having count(distinct delivery_id) >= 10
)

select 
    reg.region_name
    , cour.vehicle_type
    , sum(timestampdiff(dropoff_time, pickup_time, minute)) / count(distinct del.delivery_id) as avg_delivery_time
    , sum(del.distance_miles) / count(distinct del.delivery_id) as avg_delivery_time
    , count(distinct delivery_id)*4 + sum(del.distance_miles)*05 as total_earnings
    , count(distinct delivery_id)*4 + sum(del.distance_miles)*05 / sum(timestampdiff(dropoff_time, pickup_time, hour)) as avg_earnings_per_hour
from deliveries del
inner join couriers cour
on del.courier_id = cour.courier_id
inner join regions reg
on cour.region_id = reg.region_id
inner join reqd_couriers rc
on del.courier_id = rc.courier_id
where del.pickup_time between '2024-02-01' and '2024-02-29'
group by 1, 2
order by 1, 3