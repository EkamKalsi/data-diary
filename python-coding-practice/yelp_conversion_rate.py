# You’re given two tables:
# user_activity

# user_id

# activity_date (DATE)

# activity_type ("search", "view", "call", "review")

# user_signup

# user_id

# signup_date (DATE)

# Prompt:
# Write a query to find the conversion rate for users who wrote a review within 7 days of signup, broken down by signup week.

import pandas as pd

user_activity = pd.DataFrame({
    'user_id': [...],
    'activity_date': [...],  # as datetime
    'activity_type': [...],  # one of: 'search', 'view', 'call', 'review'
})

# user_signup
# Signup info for each user
user_signup = pd.DataFrame({
    'user_id': [...],
    'signup_date': [...],  # as datetime
})


def get_user_flag(group):
    if group['activity_type']=='review' and ~pd.isnull(group['activity_date']):
        if (group['activity_date'] - group['signup_date']).dt.days <= 7:
            return 1
    return 0

def get_conversion_stats(group):
    return pd.Series({
        'total_signups': group.shape[0]
        , 'converted_users': group[group['conversion_flag'] == 1].shape[0]
        , 'conversion_rate': group[group['conversion_flag'] == 1].shape[0] / group.shape[0]
    })

merged_df = pd.merge(user_signup, user_activity, how='left', on='user_id')
merged_df['signup_week'] = merged_df['signup_date'].dt.to_period('W').apply(lambda r: r.start_time)
temp_df = merged_df.groupby(['signup_week', 'user_id']).apply(get_user_flag)
temp_df = temp_df.reset_index()
temp_df.columns = ['signup_week', 'user_id', 'conversion_flag']
conversion_df = temp_df.groupby('signup_week').apply(get_conversion_stats)
conversion_df = conversion_df.reset_index()
conversion_df.columns = ['signup_week', 'total_signups', 'converted_users', 'conversion_rate']