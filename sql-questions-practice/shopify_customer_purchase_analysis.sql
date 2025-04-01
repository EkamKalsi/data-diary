orders table
users table


Task 1:
For each user who has made at least one purchase, calculate:

Their first purchase date
The number of days from signup to their first purchase
The total amount spent
The number of orders



Output the results with these columns:
user_id
first_purchase_date
days_to_first_purchase
total_amount_spent
total_orders

Identify the users who spent more than $500 in total within 14 days of their signup date.


select 
    ord.user_id
    , min(ord.order_date) as first_purchase_date
    , datediff(usr.signup_date, min(ord.order_date)) as days_to_first_purchase
    , sum(ord.total_amount) as total_amount_spent
    , count(distinct ord.order_id) as total_orders
from orders ord
inner join users usr
on ord.user_id = usr.user_id
group by 1




select 
    ord.user_id
    , sum(ord.total_amount) as total_amount_spent
from orders ord
inner join users usr
on ord.user_id = usr.user_id
where ord.order_date between user.signup_date and user.signup_date + interval '14 days'
group by 1
having sum(ord.total_amount) > 500