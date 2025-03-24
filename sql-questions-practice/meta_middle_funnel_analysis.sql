-- Middle Funnel Analysis
-- You're a Data Scientist on Facebook's Product Analytics team. 
-- The team has launched a redesigned "Groups Discovery" feature two months ago to improve middle funnel engagement.
-- Your manager has asked you to evaluate if this new feature is improving 
-- user activation and engagement, particularly for new users in their first 28 days.
-- feature was launched on January 15, 2025
-- You have access to the following tables:

-- users
-- user_id (integer) - unique identifier
-- registration_date (date) - when user registered
-- country (string) - user's country
-- age_group (string) - age bracket ('18-24', '25-34', etc.)
-- device_type (string) - 'ios', 'android', 'web'

-- groups_discovery
-- user_id (integer) - user identifier
-- date (date) - date of interaction
-- discovery_version (string) - 'old' or 'new' version of discovery feature
-- group_id (integer) - ID of group discovered/viewed
-- action_type (string) - 'view', 'join', 'post', 'comment', 'react'
-- session_id (string) - identifier for user session

-- user_activity
-- user_id (integer) - user identifier
-- date (date) - date of activity
-- day_number (integer) - days since registration (0 = registration day)
-- session_count (integer) - number of sessions on this day
-- time_spent_min (integer) - minutes spent on platform this day
-- feature_used (string) - feature used ('feed', 'groups', 'marketplace', etc.)
-- content_created (boolean) - whether user created content


with expriemnt_cohorts as (
    select 
        user_id
        , min(date) as first_interaction_date
        , min(discovery_version) as exp_cohort
    from groups_discovery
    where date between '2025-01-15' and '2025-01-15' + interval '28 days'
    group by 1
), engagement_metrics as (
    select 
        ec.exp_cohort
        , count(distinct u.user_id) as total_users
        , sum(ua.session_count)/count(distinct u.user_id) as avg_sessions_per_day_per_user
        , sum(ua.time_spent_min)/count(distinct u.user_id) as avg_time_spent_per_user
        , count(distinct case when ua.content_created then u.user_id end) / count(distinct u.user_id)::float as content_creation_rate
    from users u
    inner join expriemnt_cohorts ec
    on u.user_id = ec.user_id
    left join user_activity ua
    on u.user_id = ua.user_id
    where ua.date between ec.first_interaction_date
    and '2025-01-15' + interval '28 days'
    group by 1
), retention_metrics as (
    select 
        ec.exp_cohort
        , date_trunc('week', ua.date) as weekly_date
        , ua.date as daily_date
        , count(distinct u.user_id) as total_users
        , count(distinct ua.user_id) as dau
        , sum(count(distinct ua.user_id)) over(partition by ec.exp_cohort order by ua.date rows between unbounded preceding and current row) as wau
        , count(distinct ua.user_id) / sum(count(distinct ua.user_id)) over(partition by ec.exp_cohort order by ua.date rows between unbounded preceding and current row) as stickiness
    from users u
    inner join expriemnt_cohorts ec
    on u.user_id = ec.user_id
    left join user_activity ua
    on u.user_id = ua.user_id
    where ua.date between ec.first_interaction_date
    and '2025-01-15' + interval '28 days'
    -- proxy for active user
    and ua.time_spent_min > 1
    group by 1, 2, 3
)


Story around the data:
- We are looking at the impact of the new feature on user engagement and activation
- Here are some hypothesis:
    engagement:
        - time spent increases -> primary metric
        - sessions increase
        - diversity in features used increases -> guardrail, shouldnt decrease in test group
        - content created increases
    activation:
        - DAU, WAU and stickiness increases
- Along with looking at overall numbers, we can segment the data by country, age_group, device_type and registration_date(age in app) to see if the impact is consistent across different segments
- Tradeoffs:
    - Introducing the new version should decrease the app diversity
    - Introducing the new version shouldnt decrease the time spent on the app, a 2-tail t-test could help with this
    - We also want to be careful of novelty effects, so tracking these numbers on a weekly basis, should start off with high values, but slowly stabilize to acceptable values
    
