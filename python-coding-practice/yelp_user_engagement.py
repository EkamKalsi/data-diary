# For each user, find the category they are most engaged with, 
# based on the number of activities (any type)
# If there's a tie, return any one.

import pandas as pd
user_activity = pd.DataFrame({
    'user_id': [...],
    'activity_date': [...],  # datetime
    'category': [...],       # e.g., 'Restaurants', 'Home Services', 'Auto Repair'
    'activity_type': [...],  # e.g., 'search', 'view', 'call', 'review'
})

activity_count = user_activity.groupby(['user_id', 'category']).size()
activity_count = activity_count.reset_index()
activity_count.columns = ['user_id', 'category', 'activity_count']


def get_category_rank(group):
    group['activity_rank'] = group['activity_count'].rank(method='first')
    return group['category'][group['activity_rank'] == 1].values[0]

return_df = activity_count.groupby('user_id').apply(get_category_rank)
return_df = return_df.reset_index()
return_df.columns = ['user_id', 'most_engaged_category']

#####################Category retention##############################

def get_user_flag(group):
    first_activity_date = group['activity_date'].min()
    second_activity_date = group['activity_date'].sort_values().iloc[1]
    if (second_activity_date - first_activity_date).dt.days <= 7:
        return 1
    return 0

def get_category_stats(group):
    return pd.Series({
        'total_users': group.shape[0]
        , 'retained_users': group[group['retention_flag'] == 1].shape[0]
        , 'retention_rate': group[group['retention_flag'] == 1].shape[0] / group.shape[0]
    })

user_cat_flag = user_activity.groupby(['category', 'user_id']).apply(get_user_flag)
user_cat_flag = user_cat_flag.reset_index()
user_cat_flag.columns = ['category', 'user_id', 'retention_flag']

category_stats = user_cat_flag.groupby('category').apply(get_category_stats).reset_index()
category_stats.columns = ['category', 'total_users', 'retained_users', 'retention_rate']

##################### Rolling 7-day actegory users ##############################
def get_rolling_sum(group):
    group['rolling_users'] = group.rolling(window=7, on='activity_date').sum()
    return group


user_size_df = user_activity.groupby(['category', 'activity_date']).size().reset_index()
user_size_df.columns = ['category', 'activity_date', 'user_count']
rolling_df = user_size_df.groupby('category').apply(get_rolling_sum).reset_index()
rolling_df = rolling_df[['category', 'activity_date', 'rolling_users']]

##################### Median Conversion time per user ############################

def get_conversion_time(group):
    first_activity = group['activity_date'].min()
    conversion_df = group[group['activity_type'].isin(['call', 'review'])]
    if len(conversion_df)==0:
        return 0
    else:
        conversion_activity = conversion_df['actvity_date'].min()
        return (conversion_activity - first_activity).days


conversion_user = user_activity.groupby('user_id').apply(get_conversion_time).reset_index()
conversion_user.columns = ['user_id', 'days_to_conversion']

