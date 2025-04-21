-- Can you help us understand engagement patterns for new group joiners? 
-- I’d like to know, for users who joined a group in the past 7 days, 
-- what % of them returned and either liked, commented, or posted in that same group within 3 days of joining?”

-- Also, break this down by group size bucket (small: <100, medium: 100–1,000, large: >1,000).

-- Schema

-- group_memberships
-- Column	Type
-- user_id	STRING
-- group_id	STRING
-- join_date	DATE

-- group_events
-- Column	Type
-- user_id	STRING
-- group_id	STRING
-- event_type	STRING
-- event_time	DATETIME

-- groups
-- Column	Type
-- group_id	STRING
-- group_size	INT

select 
    case
        when g.group_size < 100 then 'small'
        when g.group_size >= 100 and g.group_size <= 1000 then 'medium'
        else 'large'
    end as group_size_bucket
    , count(distinct case when ge.event_type in ('like', 'comment', 'post') and date_diff('day', gm.join_date, ge.event_time) <= 3 then gm.user_id end) as engaged_users
    , count(distinct gm.user_id) as total_users
    , count(distinct case when ge.event_type in ('like', 'comment', 'post') and date_diff('day', gm.join_date, ge.event_time) <= 3 then gm.user_id end) / count(distinct gm.user_id) as engagement_rate
from group_memberships gm
left join group_events ge
on gm.user_id = ge.user_id
and gm.group_id = ge.group_id
inner join groups g
on gm.group_id = g.group_id
where gm.join_date between current_date - 6 and current_date
group by 1