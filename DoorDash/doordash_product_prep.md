# DoorDash Product / DS Interview Prep

Each question is an ambiguous, open-ended scenario — the kind a DS2 at DoorDash would face from a PM, ops lead, or their manager. Work through it conversationally, then invoke `/feedback-mode` when ready.

**Feedback rubric (5 dimensions, each scored out of 2):**
- Situation assessment
- Clarifying questions asked
- Core hypothesis
- Metrics chosen
- Final output / recommendation

---

## Q1 — DashPass Conversion Drop

**Prompt:**
A PM pings you on Slack: *"Hey, our DashPass free-trial-to-paid conversion rate dropped 8 points last week. Can you look into it?"* That's all the context you have.


### Clarifying Questions
- I am guessing this metric is defined on a weekly basis as: # people who had a free trial and converted to paid/ #people who had a free trial. Is that the right definition?
- If the definition is right, then the drop is from Week N to Week N+1, the value dropped 8 points, as an example: 50% to 42%

### Situation
- correct definition: # people who had a free trial ending this week and converted / # of people who had a free trial ending this week
- single week drop
- pushed a change to reminder email sequence last tuesday
- The metric can go down WoW, if the numerator decreases or the denominator increases:
- Simple terms, conversions can drop, while free trial ending members remain same, or free trial ending members can increase, and conversions remain same.
- No Data Eng or Prod Eng problems
- Denominator remains constant
- drop on the CVR side
- CTA on Day 1 email reduced by 7% points

### My Answer
- Observational analysis possible, where we can break each week's CVR as organic vs coming from CTA vs coming from email open
- We can do a prioritization model here:
    - if somebody has clicked on CTA -> coming from CTA
    - if somebody ahs opened -> Email Open
    - if somebody has done none -> organic bucket
- For each week, we can understand the mix-shift between these and CVR% for each segments
- We compare past week's average value to the drop week
- We should be able to identify that mix-shift has changed where there might be more organic CVR in the drop week
- Also the CVR for the CTA segments is most likely dropped as well due to small volume
- This explains the gap observationally
- We can model out if comms werent changed how it would have looked like
- To identify how much of it is mix-shift vs how much is CVR based, we can model the scenario as 
- Mix-shift: take dropped week mix-shift and use CVR from past, this is overall CVR drop due to mix-shift
- CVR drop: take past week's avg. baseline mix-shift and apply current week's CVR. this would inform the drop due to CVR
- The framework would explain the overall drop
- On the basis of this we can take a few actions:
    - There is a high possibility that the #CVR fro Email open and CTA bucket have decreased, main aim here should be to conduct changes like these in proper experiment so that we can measure the effect scientifically.
    - So, revert the comms, launch an experiment

### Feedback
- enumerate all hypothesis before going into a deep dive on a single one
- for example in something like this, it could be seasonality, external factors, cohort quality type etc.


