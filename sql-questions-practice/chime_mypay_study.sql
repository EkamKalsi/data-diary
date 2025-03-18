-- # Chime Data Analyst Technical Interview Case Study

-- ## Background:
-- Chime has recently expanded the MyPay early wage access feature to more states. 
-- The feature allows eligible users to access up to $500 of their pay before their regular payday
-- with no mandatory fees (optional $2 fee for instant access). 
-- The product team wants to understand the feature's performance and impact on both user financial health and business metrics.

-- ## Available Data:
-- You have access to the following tables in Chime's database:

-- **users**
-- - user_id 
-- - signup_date
-- - state
-- - acquisition_channel
-- - churn_date (NULL if still active)

-- **direct_deposits**
-- - user_id
-- - deposit_date
-- - deposit_amount
-- - is_payroll (boolean)

-- **mypay_advances**
-- - user_id
-- - advance_date
-- - advance_amount
-- - is_instant (boolean)
-- - repaid_date

-- **transactions**
-- - user_id
-- - transaction_date
-- - transaction_amount
-- - merchant_category
-- - is_card_transaction (boolean)

-- ## Scenario:
-- The Product Manager for MyPay has asked you to analyze the feature's performance since launch.
-- This includes understanding usage patterns, impact on user behavior, and business outcomes. 
-- Your analysis will inform decisions about potential feature changes and expansion strategy.

-- ## Interview Task:
-- Please analyze the data to provide insights about MyPay's performance. 
-- You can use SQL to query the data and share your analytical approach. 
-- Feel free to walk through your thought process and ask clarifying questions as needed.

-- Some areas to consider (but not limited to):
-- - User adoption and engagement patterns
-- - Impact on direct deposit retention
-- - Effect on card usage and transaction behavior
-- - Relationship between MyPay usage and financial health indicators
-- - Business impact in terms of revenue and user retention

-- I'll be evaluating your approach to the problem, SQL proficiency, analytical thinking, and ability to connect data insights to business outcomes.


Framework:
Overall impact of the feature:
    Before launch vs After launch:
        - Direct Impact
            - avg(amount_saved) per user
            - avg(revenue) per user
            - avg(mypay_transactions) per user
            - delta users(volume only)
        
        - Indirect Impact
            - delta_card_users
            - avg(card_transaction_amount) per user
            - avg(card_transactions) per user



with direct_overall_impact as (
    select 
        case
            when advance_date between '2024-01-15' and '2024-02-29' then 'Initial Launch'
            when advance_date between '2024-03-01' and '2024-05-14' then 'Mid Launch'
            when advance_date>='2024-05-15' then 'Final Launch'
        end as launch_phase
        , count(distinct u.user_id) as total_user
        , count(distinct mpa.user_id) as user_volume
        , count(distinct mpa.user_id)/count(distinct u.user_id) as proportion_mypay_users
        , sum(mpa.advance_amount)/count(distinct mpa.user_id) as total_advance_amount_saved
        , sum(distinct case when mpa.is_instant then 1 else 0 end)*2/count(distinct mpa.user_id) as mypay_direct_revenue_per_user
        , count(*)/count(distinct mpa.user_id) as mypay_transactions_per_user
    from users u
    left join mypay_advances mpa
    on u.user_id = mpa.user_id
    where advance_date>='2024-01-15'
    group by 1
), mypay_user_flag as (
    select advance_date
        , mpa.user_id
    from users u
    inner join mypay_advances mpa
    on u.user_id = mpa.user_id
    where advance_date>='2024-01-15'
)
, indirect_overall_impact as (
    select 
        case
            when transaction_date < '2024-01-15' then 'Before Launch'
            when transaction_date between '2024-01-15' and '2024-02-29' then 'Initial Launch'
            when transaction_date between '2024-03-01' and '2024-05-14' then 'Mid Launch'
            when transaction_date>='2024-05-15' then 'Final Launch'
        end as launch_phase
        , case when muf.user_id is not null then 1 else 0 end as is_mypay_user
        , count(distinct t.user_id) as card_users_volume
        , count(distinct t.user_id)/count(distinct u.user_id) as proportion_card_users
        , sum(t.transaction_amount)/count(distinct t.user_id) as card_transaction_amount_per_user -- possible revenue
        , sum(case when t.is_card_transaction then t.card_transaction_amount end)/count(distinct t.user_id) as interchange_revenue_per_user
        , count(*)/count(distinct t.user_id) as card_transactions_per_user
    from users u
    left join transactions t
    on u.user_id = t.user_id
    left join mypay_user_flag muf
    on u.user_id = muf.user_id
    and t.transaction_date>muf.advance_date
    group by 1,2
    --where t.transaction_date>='2024'
), direct_deposit_impact as (
    select 
        case
            when deposit_date < '2024-01-15' then 'Before Launch'
            when deposit_date between '2024-01-15' and '2024-02-29' then 'Initial Launch'
            when deposit_date between '2024-03-01' and '2024-05-14' then 'Mid Launch'
            when deposit_date>='2024-05-15' then 'Final Launch'
        end as launch_phase
        , case when muf.user_id is not null then 1 else 0 end as is_mypay_user
        , count(distinct dd.user_id)/count(distinct u.user_id) as proportion_dd_users
        , count(case when dd.is_payroll then dd.user_id)/count(distinct u.user_id) as proportion_payroll_users
    from users u
    left join direct_deposits dd
    on u.user_id = dd.user_id
    left join mypay_user_flag muf
    on u.user_id = muf.user_id
    and dd.deposit_date>muf.advance_date
    group by 1,2
    --where dd.deposit_date>='2024'
)

select *, card_users_volume/user_volume as proportion_card_users
from indirect_overall_impact
inner join direct_deposit_impact
left join direct_overall_impact 


- The above analysis could be divided into the following:
    - State: Essentially new states vs existing states how is th ehealth of the metrics
    - New users vs Retained users: Based on signup_date
    - thinking of other segments
- Using this analysis:
    - Based on launch_phase, we evaluate the following:
        - Prportion of users entering into direct deposit, and direct deposit with payroll, expected increase->more customers
        - Proportion of users now having cards should increase->more customers and indirect revenue
        - We are going to save extra amount per user now through MyPay->financial health
        - We are going to earn extra revenue per user now through MyPay->business health
        - We are going to have more transactions per user now through MyPay->business health
        