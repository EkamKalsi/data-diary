-- Case Study: Facebook's Registration Funnel Analysis
-- Background:
-- You're a Product Data Scientist at Facebook focused on acquisition. 
-- The team has noticed that registration completion rates have been declining over the past quarter,
-- particularly in emerging markets. 
-- The Head of Growth has asked you to analyze the registration funnel to identify the main drop-off points 
-- and determine if there are significant differences across user segments.


-- Questions to solve:

-- What SQL would you write to analyze the conversion rates at each step of the registration funnel?
-- How would you segment this data to identify which user groups are experiencing the most friction?
-- How would you quantify the tradeoff between reducing registration friction (to improve completion rates) versus maintaining enough verification to ensure user quality?

-- user_acquisition
-- user_id (string) - unique identifier for the user
-- acquisition_timestamp (timestamp) - when the user first arrived at Facebook
-- acquisition_source (string) - how the user discovered Facebook (organic, paid_search, app_store, referral, etc.)
-- device_type (string) - mobile_android, mobile_ios, desktop, etc.
-- country (string) - country code
-- utm_campaign (string) - marketing campaign identifier (if applicable)


-- registration_events
-- event_id (string) - unique identifier for the event
-- user_id (string) - user identifier
-- event_timestamp (timestamp) - when the event occurred
-- event_name (string) - name of the registration step 
--   Possible values: 
--   - 'registration_start'
--   - 'email_entered'
--   - 'phone_entered'
--   - 'verification_sent'
--   - 'verification_complete'
--   - 'basic_profile_complete'
--   - 'registration_complete'
-- event_success (boolean) - whether the step was successful
-- error_type (string) - if there was an error (null if successful)

-- user_profile
-- user_id (string) - user identifier
-- registration_complete (boolean) - whether registration was completed
-- registration_timestamp (timestamp) - when registration was completed
-- verification_method (string) - 'none', 'email', 'phone', or 'both'
-- age_range (string) - user's age range
-- gender (string) - user reported gender
-- profile_photo_added (boolean) - whether user added a profile photo during registration

-- early_user_activity
-- user_id (string) - user identifier
-- day_number (integer) - days since registration (0 = registration day)
-- session_count (integer) - number of sessions on that day
-- friends_added (integer) - number of friends added that day
-- feed_views (integer) - number of feed items viewed
-- content_created (integer) - pieces of content created
-- reactions_given (integer) - number of reactions given
-- is_active (boolean) - whether user was active at all that day

with users_last_registration_attempt as (
    select 
        date_trunc('quarter', ua.acquisition_timestamp) as quarter_date
        , user_id
        , age_range
        , gender
        , last_value(registration_timestamp) over(partition by date_trunc('quarter', ua.acquisition_timestamp), user_id order by registration_timestamp) as last_registration_timestamp
        , last_value(registration_complete) over(partition by date_trunc('quarter', ua.acquisition_timestamp), user_id order by registration_timestamp) as last_registration_complete
        , last_value(verification_method) over(partition by date_trunc('quarter', ua.acquisition_timestamp), user_id order by registration_timestamp) as last_verification_method
        , last_value(profile_photo_added) over(partition by date_trunc('quarter', ua.acquisition_timestamp), user_id order by registration_timestamp) as last_profile_photo_added
    from user_profile up
    where up.registration_timestamp >= '2024-10-01'
    group by 1, 2, 3, 4
), overall_metrics_country as (
    select 
        ulra.quarter_date
        , ua.country
        , count(distinct ua.user_id) as total_users
        , count(distinct case when last_registration_complete then ulra.user_id end) as total_registered_users
        , count(distinct case when last_registration_complete then ulra.user_id end) / count(distinct user_id)::float as registration_rate
    from user_acquisition ua
    left join users_last_registration_attempt ulra
    on ua.user_id = ulra.user_id
    where ua.country in ('IN', 'BR', 'ID', 'PH', 'NG', 'MX', 'VN', 'EG', 'TH', 'ZA')
    group by 1, 2
), overall_metrics_user_demographics as (
    select 
        ulra.quarter_date
        , ua.device_type
        , ulra.age_range
        , ulra.gender
        , count(distinct ua.user_id) as total_users
        , count(distinct case when last_registration_complete then ulra.user_id end) as total_registered_users
        , count(distinct case when last_registration_complete then ulra.user_id end) / count(distinct user_id)::float as registration_rate
    from user_acquisition ua
    left join users_last_registration_attempt ulra
    on ua.user_id = ulra.user_id
    where ua.country in ('IN', 'BR', 'ID', 'PH', 'NG', 'MX', 'VN', 'EG', 'TH', 'ZA')
    group by 1, 2, 3, 4
), overall_metrics as (
    select 
        ulra.quarter_date
        , count(distinct ua.user_id) as total_users
        , count(distinct case when last_registration_complete then ulra.user_id end) as total_registered_users
        , count(distinct case when last_registration_complete then ulra.user_id end) / count(distinct user_id)::float as registration_rate
    from user_acquisition ua
    left join users_last_registration_attempt ulra
    on ua.user_id = ulra.user_id
    where ua.country in ('IN', 'BR', 'ID', 'PH', 'NG', 'MX', 'VN', 'EG', 'TH', 'ZA')
    group by 1
), registration_funnel_analysis as (
    select 
        re.event_name
        , count(dsitinct ulra.user_id) as total_users_attempted
        , count(distinct case when re.event_success then re.user_id end) as total_users_completed
        , count(distinct case when re.event_success then re.user_id end) / count(distinct ulra.user_id)::float as completion_rate
    from user_acquisition ua
    left join users_last_registration_attempt ulra
    on ua.user_id = ulra.user_id
    left join registration_events re
    on ua.user_id = re.user_id
    where ua.country in ('IN', 'BR', 'ID', 'PH', 'NG', 'MX', 'VN', 'EG', 'TH', 'ZA')
    and ulra.registration_complete=False
    -- proxy to find the failed regitration timestamp
    and timestamp_diff('minute', ulra.last_registration_timestamp, re.event_timestamp) < 60
    and ulra.quarter_date = '2025-01-01'
    group by 1
    order by 4 desc
), registraion_funnel_error_steps as (
    select 
        re.event_name
        , re.error_type
        , count(dsitinct ulra.user_id) as total_users_error_faced
        , count(distinct ulra.user_id)/max(rfa.total_users_attempted) as error_rate
    from user_acquisition ua
    left join users_last_registration_attempt ulra
    on ua.user_id = ulra.user_id
    left join registration_events re
    on ua.user_id = re.user_id
    where ua.country in ('IN', 'BR', 'ID', 'PH', 'NG', 'MX', 'VN', 'EG', 'TH', 'ZA')
    and ulra.registration_complete=False
    -- proxy to find the failed regitration timestamp
    and timestamp_diff('minute', ulra.last_registration_timestamp, re.event_timestamp) < 60
    and ulra.quarter_date = '2025-01-01'
    and re.event_success=False
    inner join registration_funnel_analysis rfa
    on re.event_name = rfa.event_name
    group by 1,2 
), verificaiton_quality_relation as (
    select 
        up.verification_method
        , up.profile_photo_added
        , count(eua.is_active)/count(distinct up.user_id) as proportion_active_users
        , count(eua.friends_added)/count(distinct up.user_id) as friends_added_per_user
        , count(eua.feed_views)/count(distinct up.user_id) as feed_views_per_user
        , count(eua.session_count)/count(distinct up.user_id) as session_count_per_suer
    from user_profile up
    inner join early_user_activity eua
    on up.user_id = eua.user_id
    where up.registration_complete=true
    amd eua.days_since_registration<7
)





Story arpund the data:
- Overall metrics would confirm the hypothesis that the registration completion rates have been declining over the past quarter, particularly in emerging markets.
- The overall_metrics_country would narrow it down to a certain country where the registration completion rates have been declining.
- The registration_funnel_analysis would identify the main drop-off points in the registration funnel.
- The registraion_funnel_error_steps would identify the main drop-off points in the registration funnel and the error associated with it.
- The overall_metrics_user_demographics would identify which user groups are experiencing the most friction.
- Tradeoff between user friction and user quality can be quantified by comparing various verificaiton methods and propfile photo added, and seeing their engagement in platform for first 7 days
- If the engagement left for an extra step is less, we could remove that step
- Measuring engagement by active suers, friends added, feed views, session count per user