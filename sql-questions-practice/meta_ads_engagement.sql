select 
    date_trunc('week', timestamp) as week
    , platform
    , count(distinct ad_id) as total_ads --demand to buy users attention
    , count(distinct user_id) as total_users --supply of users attention
    , sum(case when event_type='impression' then 1 else 0 end) as total_impressions
    , sum(case when event_type in ('click', 'comment', 'share') then 1 else 0 end) as total_engagement_events
    , sum(case when event_type in ('click', 'comment', 'share') then 1 else 0 end)
    / sum(case when event_type='impression' then 1 else 0 end) as engagement_rate
from ad_events
group by 1, 2


select 
    date_trunc('week', ae.timestamp) as week
    , ae.platform
    , ad.ad_type
    , count(distinct ad_id) as total_ads --demand to buy users attention
    , count(distinct user_id) as total_users --supply of users attention
    , sum(case when event_type='impression' then 1 else 0 end) as total_impressions
    , sum(case when event_type in ('click', 'comment', 'share') then 1 else 0 end) as total_engagement_events
    , sum(case when event_type in ('click', 'comment', 'share') then 1 else 0 end)
    / sum(case when event_type='impression' then 1 else 0 end) as engagement_rate
from ads ad
inner join ad_events ae
on ad.ad_id = ae.ad_id
group by 1, 2, 3

select
    ad.ad_type
    , sum(win)/count(*) as win_rate -- of all auctions, how many were won
    , avg(aa.bid_price) as avg_bid_price
from ads ad
inner join ad_auctions aa
on ad.ad_id = aa.ad_id
where aa.platform='instagram'
group by 1
