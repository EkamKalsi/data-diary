# You are given a list of integers representing the daily number of products sold by a Shopify store 
# over a period of time.
# Write a function to find the maximum sum of any contiguous subarray within the list.

# Input: nums = [-2,1,-3,4,-1,2,1,-5,4]
# Output: 6
# Explanation: The subarray [4,-1,2,1] has the largest sum = 6


# Kadane's algorithm'
# Idea is for every number check if we should include that number in the subarray or start a new subarray.
# So, the rolling sum is creating a continuous sub array, but if adding the next makes the sum smaller then start afresh.
# Based on this decision making, we select what will be the max sum, the max sum up until now or the rolling sum.

def max_subarray_sum(nums):
    max_sum = nums[0]
    rolling_sum = nums[0]
    for num in nums[1:]:
        print('We are evaluating:', num)
        rolling_sum = rolling_sum + num
        if rolling_sum < num:
            rolling_sum = num
        max_sum = max(rolling_sum, max_sum)
        print('Rolling sum:', rolling_sum)
        print('Max sum:', max_sum)
    return max_sum

# max_subarray_sum([-2,1,-3,4,-1,2,1,-5,4])
max_subarray_sum([5,4,-1,7,8])