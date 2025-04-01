# Given an array of integers nums and an integer target, 
# return the indices of the two numbers such that they add up to the target.

# You may assume that each input would have exactly one solution, and you may not use the same element twice.

def two_sum(nums, target):
    sort_arr = sorted(nums)
    left = 0
    right = len(nums) - 1
    while left<right:
        if sort_arr[left] + sort_arr[right] == target:
            return [left, right]
        elif sort_arr[left] + sort_arr[right] < target:
            left = left + 1
        else:
            right = right - 1
    return None

def two_sum_optimized(nums, target):
    num_dict = {}
    for i in range(len(nums)):
        diff = target - nums[i]
        if diff in num_dict:
            return [num_dict[diff], i]
        num_dict[nums[i]] = i
    return None



print(two_sum_optimized([2,7,11,15], 9)) # [0, 1]