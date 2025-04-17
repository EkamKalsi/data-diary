-- You’re given two tables:
-- user_activity

-- user_id

-- activity_date (DATE)

-- activity_type ("search", "view", "call", "review")

-- user_signup

-- user_id

-- signup_date (DATE)

-- Prompt:
-- Write a query to find the conversion rate for users who wrote a review within 7 days of signup, broken down by signup week.

select 
    date_trunc('week', us.signup_date) as signup_week
    , count(distinct us.user_id) as total_signups
    , count(distinct 
        case
            when ua.activity_type='review'
            and date_diff('day', us.signup_date, ua.activity_date) <= 7
            then ua.user_id 
        end
    ) as converted_users
    , count(distinct 
        case
            when ua.activity_type='review'
            and date_diff('day', us.signup_date, ua.activity_date) <= 7
            then ua.user_id 
        end
    ) / count(distinct us.user_id) as conversion_rate
from user_signup us
left join user_activity ua
on us.user_id = ua.user_id
group by 1
