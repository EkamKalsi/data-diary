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

---

## Q2 — DashMart Cannibalization

**Prompt:**
The DashMart GM messages you: *"We're expanding DashMart into 8 new cities next quarter where we already have strong restaurant coverage. My director is pushing back — she thinks DashMart will just steal orders from our restaurant merchants and won't grow total GOV. Can you help me make the case that it won't?"*

### Clarifying Questions
- why is the competition happening in the first place? Dashmart os more focused on grocery and convenience items. Mind explaning this?
- do we currently have any cities with similar attributes as these 8 cities where Dashmart is launched?
- what was the effect on GOV there? was it launched as an experiment etc?
- Can we assume restaurant coverage = % of local restaurants on DoorDash?
- Are we looking at GOV on a quarterly basis?
- Can we assume other sectors like expansion on Gvrocery, liquor and convenience dont see this competition?


### Situation
- GOV = # Orders * Average Order Value
- When we launch Dashmart, the follwing scenarios can arise
- [Overall increase] Orders remain same but AOV goes up because with convenience of Dashmart people are bundling orders, and then also from a single place like Dashmart they are ordering mutliple items. Here the steal isn't very visible
- [Overall increase] Orders go up and AOV goes up because with convenience of Dashmart people are ordering more
- [Overall increase] Orders go down, steal is happening here in terms of orders. People who used to place multiple orders for small things, now jsut do one with Dashmart. However, AOV goes up and becomes high enough that overall GOV remains high
- [Overall Flat] Orders decrease, but AOV goes up and they cancel each other
- [Overall Decrease] Orders go down, AOV goes down as people might not order that extra thing they were doing before when ordering from mutiple places
- One thing to add, there is a possibility that GOV might go down, but on Dashmart, DorDash has a higher take rate and hence we might be profitable on Contribution margin, but I am going to ignore the situation then.
- What we need here is to size out the existing size of these Dashmart orders.


### My Answer
- Framework: We can classify the current orders in these cities as:
    - Dashmart akin order: Can be replaced by Dashmart. based on item clafficiation. Assuming we have the entire inventory of dashmart easily available
    - Restaurant akin order: Food orders which cannot be accessed via Dashmart
- In the mix above there is a chance that Dashmart akin orders volume decreases when Dashmart comes into the picture. 
- But, people might order more now. How: Awareness leads to more orders, so orders per consumer increase. Also, bigger catalog leads to increase in AOV
- To size this out, we can use past cities, 
    - AOV for Dashmart order
    - total orders per consumer for consumers who order from Dashmart
- There is definitely cannibalization possible where orders get reduced,but hopefully we make it up in increase in AOV
- We can conduct observational sizing:
    GOV = num_orders * aov
    Scenario 1:
        - num_orders sees a 5% decrease
        - but AOV sees a 10% increase
    Secnario 2:
        - num_order and aov both see a 1-2% increase
- Launch recommendations: Sizing just paints a pciture of what could happen, in order to prove it out we should conduct an experiment.
    - Since cities differ in user characterisitics and behavior
    - We also need to factor in dasher availability here, if the market sustains these increase in orders
    - We can experiment on AOV as our main metric
    - Divide our user base such that only part of them get dashmart availability while others dont
    - In order to avoid spill over effects, we can conduct these in different markets so that dasher availability doesnt become an issue
    - At the end we are measuring if for Dashmart available users does the AOV increase as compared to non-Dashmart available users
    - Orders per customer would be a secondary metric
    - cancelations and churn rate would be guardrail metrics
    - Experiment is helping us identify the tradeoff on number of orders vs AOV increase

### Feedback

**Overall: 7.5 / 10**


| Dimension | Score | Note |
|---|---|---|
| Situation Assessment | 1.5/2 | GOV decomposition + scenario matrix was strong; missed flagging GM's advocacy framing |
| Clarifying Questions | 1.5/2 | Caught no-holdout issue; missed asking about consumer profile of 8 cities |
| Core Hypothesis | 1.5/2 | Correct and nuanced; should have been stated upfront before the framework |
| Metrics Chosen | 1.5/2 | Missing restaurant-specific GOV (the core question!) and new user acquisition |
| Final Output | 1.5/2 | Experiment design good but 8 cities has no power — use DiD on existing markets; no explicit recommendation to GM |

**Key takeaways:**
- Always separately track the metric the question is actually about (restaurant GOV, not total GOV)
- With ~8 market-level units, a new experiment has no power — use Difference-in-Differences on existing DashMart cities
- When a stakeholder asks you to "make the case" for a conclusion, explicitly reframe to "give an honest read"

---

## Q3 — Free Delivery for New Users

**Prompt:**
The consumer growth team comes to you: *"We want to test removing the delivery fee for first-time orders — right now it's $3.99. The hypothesis is that the fee is a friction point killing new user activation. How would you design this experiment, and how long would you run it?"*

### Clarifying Questions
- are we trying to test wether removing the fees leads to more conversion on user activation and hence more people would place the first order?
- how does the payback work here? Because fee is removed? we should be concerned about it, but how do we factor in, something like GOV per order?
- when does the user become aware of this fee removal, and how?
- only users who havent ever ordered are made aware of this fee removal?
- I think the main question here is, CVR vs GOV per order?

### Situation
- Only new users/never orders users see this experiment
- treatment users see $0 delivery fee
- core metrics here are:
    - CVR to first order: users who place first order/users in each variant
        - denominator is same in both
    - AOV: total order value/total orders
        - if it increases for treatment then Doordash would make more revenue per order and also have more orders
    - Reason AOV can increase is those first time users will be ordering again as well
- So, core tradeoff becomes CVR to first order vs AOV

### My Answer
- Launch an A/B test where treatment has no fees on the confirmation page
- Primary metric: AOV
- Secondary metric: CVR to first order
    - funnel drop offs on confirmation page
    - orders per consumer
- Guardrail: AOV as well, if people are not making more orders or less orders
- How long to run:
    - Given AOV is our core metric and also seasonality trend, I would like to bucket for two weeks
    - A key consideration is to randomize on users but also clustered randomization so that there is no SUTVA violation and delivery time isnt affected


### Feedback

**Overall: 6.5 / 10**

| Dimension | Score | Note |
|---|---|---|
| Situation Assessment | 1.5/2 | Correctly scoped; missing the LTV vs. CAC reframe — this is an acquisition subsidy, not a CVR vs. AOV tradeoff |
| Clarifying Questions | 1.5/2 | Solid; missing baseline activation rate (needed for power calc) and DashPass upsell context |
| Core Hypothesis | 1.5/2 | Correct but never stated explicitly; should be "LTV of incremental users > $3.99 subsidy cost" |
| Metrics Chosen | 1/2 | Hierarchy inverted — AOV listed as primary, but first-order CVR should be primary; contribution margin guardrail missing |
| Final Output | 1/2 | Duration reasoning weak (2 weeks too short for LTV signal); SUTVA concern overstated for this design; no explicit decision rule |

**Key takeaways:**
- This is a CAC vs. LTV problem — state it that way upfront, metric hierarchy follows automatically
- Primary metric = first-order CVR (activation); guardrail = contribution margin per user (payback)
- Duration: 4 weeks for primary metric, 60-day observation window for LTV metrics before permanent ship decision
- SUTVA/clustering needed for two-sided marketplace effects (Dasher earnings, social features) — not for a silent fee change on new users

---

## Stats & Experimentation Fundamentals

*Conversational Q&A — explain the concept, then connect it to a real DoorDash context.*

---

### Q-S5 — Regression to the Mean

**Prompt:**
The ops team identified the **10 worst-performing markets** by consumer NPS last quarter. They ran an 8-week targeted improvement program in those markets — better Dasher training, faster issue resolution, proactive outreach.

At the end of 8 weeks, average NPS in those 10 markets improved by **12 points**. The ops lead sends a company-wide email declaring the program a success and asking to roll it out to all markets.

Should you sign off on that? What's your concern?

#### My Answer
- regression to the mean in play here, we take the worst eprforming groups, perform an intervetion and note an improvement
- the reason these markets are worst performing markets because they are bad quality+bad luck
- there is chance that these markets would have reverted the bad luck and imporved naturally, however we note all imporvments to program which is incorret, hence no sign off
- if we were to do this, we should launch an experiment/phased rollout where we conduct porgam on a randomized set and then compare it against the ones who dont get it
- essentially, the programs might ahve been actually good, but right now its a measurement problem

---

### Q-S1 — Sample Size & Power

**Prompt:**
You're about to design an A/B test at DoorDash. Your PM asks: *"How many users do we need, and how long do we run it?"*

Walk me through exactly how you'd answer that — what inputs you need, what the tradeoffs are, and what happens to sample size if the PM says they want to detect a smaller effect.

#### My Answer
- Depends on what metric we are trying to target here mainly
- We want to establish the baseline value for this metric and understand if there is a time window in which that metric has limited movement/variation
- Once we have identified that, we can then try to udnerstand, or do scenario modeling on how much we can move this metric
- Once done, we identify for each of these lifts we identify using sample size calculator how much traffic we need ie number of users
- Once we have number of users, we can identify typically in how much time do we gain that traffic
- That is the minimum duration of the experiment
- We can control for seasonality as well by incorpoarting some extra time and then measure the effect
- if PM says we want to detect a small effect we typically need more traffic/users hence run it long
- Tradeoff becomes power of the experiment or the number of people we are bcuketing vs effect we can measure. If we bucket small group of people our power decreases and that leads to icnrease in Type II error i.e probability of accepting the null hypothesis even when it might be false

#### Feedback

**Overall: 7 / 10**

| Dimension | Score | Note |
|---|---|---|
| Input identification | 1.5/2 | Got baseline, MDE, traffic rate, seasonality — missing alpha entirely |
| Conceptual accuracy | 1.5/2 | Type II error correct; "variation" should be explicit metric variance (p(1-p) for CVR, σ² for continuous) |
| Tradeoff articulation | 1.5/2 | Direction right; missing the 1/δ² intuition — halving MDE quadruples N |
| Terminology precision | 1/2 | "Lift" should be MDE; power defined implicitly not explicitly |
| Practical grounding | 1.5/2 | Seasonality point was strong; missing a concrete DoorDash number to anchor the explanation |

**Key takeaways:**
- Four inputs: baseline+variance, MDE, alpha (0.05), power (0.80) — always name all four
- Sample size ∝ 1/δ² — halving MDE quadruples required N; this is the tradeoff interviewers test
- Always anchor with a real number: "If baseline CVR is 40% and MDE is 2pp, here's what that means for N"

---

### Q-S2 — p-value & Multiple Testing

**Prompt:**
Two-part question.

**Part A:** Your PM looks at the experiment results and says: *"Great, p=0.03 — that means there's a 3% chance our result is due to luck, right?"* How do you respond?

**Part B:** Your experiment tracked 1 primary metric and 6 secondary metrics. Three of the secondary metrics came back statistically significant at p<0.05. Should you trust all three results? Why or why not — and what would you do about it?

#### My Answer
- This is wrong, p-value is probability of observing the observed effect or even more extreme  given the null hypothesis is true.
- So, p=0.03 means there is a 3% chance that we observe this or an even extreme effect given the null hypothesis is true
- This measns it's not by luck that we observed this result and hence treatment does influence our core metric, how much it does that can be viewed in confidence interval.
- Also, I would like to check for Power if we have atleast 80% chance that the observed effect can be observed


- This is a multiple testing problem. If we are testing for multiple hypothesis we cannot straight away use the alpha=0.05 value
- There are corrections we can apply here, typically Bonferroni or Hochbergs depending on what we want to do here
- There is a random chance that these might be stat-sig as now we are testing for multiple hypothesis
- Bonferroni is more conservative whereas Hochberg is less and preferred

#### Feedback

**Overall: 7.5 / 10**

| Dimension | Score | Note |
|---|---|---|
| Part A — definition accuracy | 1.5/2 | Correct p-value definition; minor overstatement: "does influence" goes too far — say "sufficient evidence to reject null at α=0.05" |
| Part A — depth | 1.5/2 | CI mention was strong; power check is pre-experiment — post-experiment check is CI width |
| Part B — accuracy | 2/2 | Correctly identified FWER problem, named Bonferroni and Hochberg |
| Part B — quantification | 1/2 | Missing FWER formula: 1-(0.95)^7 ≈ 30% false positive chance with 7 metrics |
| Part B — recommendation | 1.5/2 | Missing the real fix: pre-register one primary metric; secondary sig results are hypotheses for the next experiment, not this ship decision |

**Key takeaways:**
- Never say treatment "does influence" from p-value alone — "sufficient evidence to reject null, 3% false positive risk remains"
- FWER with k tests at α: 1-(1-α)^k — with 7 metrics, ~30% chance of at least one false positive under pure noise
- Primary metric decides ship/no-ship; significant secondary results → next experiment's hypothesis, not current evidence

---

### Q-S4 — Simpson's Paradox

**Prompt:**
You're analyzing order frequency for DashPass vs. non-DashPass consumers. The aggregate numbers look clear:

- **DashPass members:** 2.1 orders/week on average
- **Non-DashPass members:** 1.8 orders/week on average

You bring this to your PM as evidence that DashPass drives higher engagement. Your skeptical colleague slices the data by market tier and sends you this back:

| Market Tier | DashPass avg orders/week | Non-DashPass avg orders/week |
|-------------|--------------------------|------------------------------|
| Tier 1 (large cities) | 2.3 | 2.5 |
| Tier 2 (mid cities) | 1.9 | 2.0 |
| Tier 3 (small cities) | 1.4 | 1.6 |

Non-DashPass members order more frequently in **every single tier** — yet DashPass members are higher in the aggregate. How do you explain this, and which number should your PM trust?

#### My Answer
- This is a classical case of Simpsons paradox where overall averages might differ from within segments
- For each of these segments what could be happening is mix-shift difference. 
- Metric in question = #orders per week/#consumers in the group
- For each of the segment #dashpass consumers< #non-dashpass consumers
- in smaller groups hence the non-dashpass group avg is higher, but on overall basis this changes
- these numbers should be complemented by %of consumers in each group on overall and segmented population and the results will be clear

#### Feedback

**Overall: 4.5 / 10**

| Dimension | Score | Note |
|---|---|---|
| Pattern recognition | 2/2 | Named Simpson's Paradox immediately and correctly — the hardest part, nailed it |
| Mechanism accuracy | 1/2 | Right idea (mix-shift), but imprecise — it's not about group *size*, it's about *distribution across tiers* |
| Answering the direct question | 0/2 | "Which number should your PM trust?" was explicitly asked and never answered |
| Business implication | 0.5/2 | Didn't flag that this is a selection bias problem — DashPass is not *causing* higher order frequency |
| Path forward | 1/2 | "Complement with % of consumers in each group" is the right direction but vague |

**Key takeaways:**
- The mechanism is about *distribution across tiers*, not group size: DashPass members are disproportionately in Tier 1 (where everyone orders more); non-DashPass spread across Tier 2/3. That Tier 1 concentration pulls up the DashPass aggregate — compare tier-weight breakdown to prove it
- Always answer the direct question: within-tier numbers are more trustworthy because they hold the confounding variable (market tier) constant; the aggregate is misleading and the PM should not cite it as evidence DashPass drives engagement
- Name the underlying problem: selection bias — high-frequency Tier 1 users self-select into DashPass; even within-tier is observational; only a randomized experiment can establish that DashPass *causes* higher order frequency

---

### Q-S3 — Peeking & Early Stopping

**Prompt:**
Your experiment has been running for 5 days out of a planned 4 weeks. You check the dashboard and your primary metric is already significant at p=0.02. Your PM pings you: *"This looks great — can we just call it and ship? Why wait another 3 weeks?"*

What do you tell them, and what's actually going on statistically?

#### My Answer
- how much power do we have here?
- What is the size of our confidence interval?
- My best is that in a case like this our confidence interval is very big
- And right no we dont even have enough power for the test
- What is essentially happening is that given the current data, our effect might be big enough that is it getting a small p-value.
- However, this might be happening as pull forward/novelty actually
- We should wait for 3 weeks and narrow our CI. The size of our CI is invsersely proportional to the number of people in the exepriment.


#### Feedback

**Overall: 5.5 / 10**

| Dimension | Score | Note |
|---|---|---|
| Situation assessment | 1/2 | Identified CI width and novelty effect; missed the central issue entirely |
| Statistical accuracy | 0.5/2 | Power framing is wrong here — the issue isn't power, it's that optional stopping inflates Type I error |
| Mechanism explanation | 1/2 | No mention of peeking problem: p-values fluctuate mid-experiment, stopping when significant is cherry-picking |
| Practical recommendation | 1.5/2 | "Wait 3 weeks" is right; CI-sample size relationship correct |
| Solutions / depth | 1.5/2 | No mention of sequential testing (O'Brien-Fleming, alpha-spending) as valid alternatives |

**Key takeaways:**
- Core issue is **optional stopping / peeking**: stopping when p<0.05 inflates actual Type I error to 30-40%
- Power is not the issue — if you're seeing p=0.02, you're detecting something; the detection itself isn't valid
- Use the coin-flip analogy with PMs: stopping at 7/10 heads looks significant but reverts to 50/50 by flip 100
- Valid solutions: (1) run to planned end, (2) sequential testing with adjusted thresholds, (3) Bayesian methods

---

## Q4 — Dasher Churn Spike

**Prompt:**
The VP of Dasher Supply pinged the data science team:

> *"Dasher churn is up 15% over the last six weeks. I need to understand why, and I need a recommendation by end of week."*

That's the full ask. Where do you start?

### Clarifying Questions
- What metric is being looked at here? and at what time interval?
    - Churn in case of dashers can be defined as dashers who canceled their accounts/total active dashers
    - But some clarification here?
- Also, this is happening over last-sixe weeks, is this happening every week or 6 weeks ago to now? i.e the time period/interval question?
- on the time interval and decline being YoY, is it the case that we are comparing recent 6 weeks mature for churn to their counterpart last year and noticing a 15% decline for each cohort?
- Is there a week by week breakdown available?
- Are there any macroeconomic or seasonality conditions which we are adjsuting for?
- Is it fair to say that the denominator in this condition i.e number of dashers remain similar and there is not a sudden reduction of dashers which is aritifically causing the churn to increase?
- Is it also fair to say that this is not a data reporting/events not being logged issue?
- This seems like a matching system problem. Confirming did we make any changes to matching system?


### Situation
- Dasher Churn = #Dashers who didn't do a single delivery W+1 to W+4 weeks following their last delivery/#Dashers who did a delivery in week W
- aggregated churn for recent 6 weeks this year vs last year same time is 15% down
- Churn = (#Dashers with no delivery for 4 consecutive weeks)/(#Dashers with delivery in W0)
- WoW breakdown, trend is building up every week. W1 -> 8%, W6 -> 22% up
- Pool of dashers available has increase, and churn too, that means definitely numerator has icnreased
- New dashers are seeing increased churn
- New dashers in urban areas seeing churn
- Main reason being new dashers are getting less orders
- order volume is up
- active dashers are up as well
- orders per dasher is down meaningfully

### Hypothesis
- Decision: churn is happening, it's YoY, which controls for seasonality. It's building WoW, asking to investigate and come up with a recommendation
- Confirm where is churn coming from?
    - Market segment: Urban vs sub-urban
    - Dasher segment: New vs retained dashers
- Prioriting dasher segment to understand if new dashers are churning out or retained dashers
    - For all dashers in this time period of 6 weeks, this year vs last year
    - Segment dashers into
        - New: 1-5th delivery in the measurement week
        - Med: 2-20th delivery in the measurement week
        - Experienced: >21st delivery in the measurement week
    - Identify which segment is churning the most
    - If all segments have equal churn, has the mix-shift of dashers changed?
- Identified new dashers are facing higher churn
- Segment further:
    - Are these new dashers churning more in urban or suburban areas?
    - Are we seeing high fraud percentages in this cohort?
- New dashers in urban markets facing churn, no fraud so genuine dashers
- Possible hypothesis:
    - Pricing changes?
    - Lack of orders?
    - Any macro-economic law/policy changes?
    - Any product communications or bugs like problem with paying system or comms not delivering information etc?
- Pricing changes leading to less earnings?
    - Dasher Earning = Dasher tip + Commission
    - Dasher tip, outside of platform control, but verify if volume has gone down, or avg. tip per order has reduced?
    - Commission, dependent on platform?
        - Has platform increase take rate taking from dasher earnings?
        - Has the commission structure changed, where restaurant earnings are more?
        - Unit economics per order can reveal this for the top 10 markets?
        - Comapring against last year?
- Lack of orders?
    - Weekly basis, order volume, consumer volume and active dashers
    - orders per dasher
    - orders per consumer
    - comparing against last year for the top 10 markets and observationally if the numbers have reduced
- From the two hypothesis we can verify what could be a leading indicator for this
- Orders per dasher being down is a good signal here
- Recommendation:
    - The matching system changes while successful for consumer experience and dasher utilization overall, did not help the new dashers
    - Now these new dashers are churning out and we see that in YoY metrics and also probably in avg. delivery time metrics as supply might be struggling
    - We should correctly evaluate the tradeoff here:
        - Consumer experience i.e %orders within estimated window vs dasher churn rate
        - Essentially, for each percentage of orders not delivered on time, how much churn we avoid
        - Also, for those orders not delivered in time, how far away are in the window
    - From here we can follow a few paths:
        - At the current point we are optimizing on the consumer experience, in the short-term we can revert to old version of the matching algorithm
        - In the meantime MLE team fixes the matching algorithm to also incorporate long term retention as one of the goals of the model


### My Answer

### Feedback

**Overall: 7.5 / 10**

| Dimension | Score | Note |
|---|---|---|
| Situation assessment | 1.5/2 | Correctly landed on matching algorithm as root cause; missing explicit framing of the downstream business risk and the cross-functional conflict between consumer and supply teams |
| Clarifying questions | 1.5/2 | Best part of the answer — metric definition, denominator check, data quality, WoW breakdown, and the matching system question were all strong; missed asking about competing gig platforms or new Dasher acquisition campaigns |
| Core hypothesis | 1.5/2 | Systematic elimination of pricing, macro, and bugs was methodical; slightly bottom-up rather than leading with a falsifiable top-down hypothesis |
| Metrics chosen | 1.5/2 | Orders per Dasher and earnings decomposition were right; missing the key early-warning metric: orders completed in first week of activation (leading indicator for 4-week churn) |
| Final recommendation | 1.5/2 | Tradeoff framing was good; revert + MLE fix is the right direction but too vague — missing a targeted intervention and experiment design for the fix |

**Key takeaways:**
- Frame the downstream business risk: new Dasher churn today = supply hole in urban markets 6–12 months from now, which collapses the same consumer experience the matching change was protecting
- "Orders completed in first week" is the leading indicator for 4-week churn — always identify the leading indicator for the lagging metric; this would have caught the problem during the experiment window before ship
- Make recommendations surgical: rather than "revert everything," propose a targeted intervention — guarantee a minimum order floor for Dashers in their first 10 deliveries (new Dasher activation boost), keeping experienced Dasher priority intact; then experiment before shipping



---

## Q5 — Marketplace Health

**Prompt:**
The CEO is reviewing last quarter's numbers for the top 20 markets. Three things stand out:

- **GOV up 18% YoY** — strong growth
- **Consumer NPS down 4 points YoY**
- **Dasher earnings per hour down 8% YoY**

She turns to you and asks: *"Is our marketplace healthy?"*

How do you answer that?

### Clarifying Questions
- How do we define healthy?
    - for a three-sided marketplace like DoorDash, healthy means the growth is sustainable — all three sides (consumers, Dashers, merchants) are getting enough value to stay engaged. A marketplace that's growing GOV by extracting value from one side to benefit another is not healthy; it's eating its own seed corn.
- what is the context here? what is the CEO trying to do here?
    - On context: The CEO is about to present to the board next week. She wants to know if the 18% GOV growth is something to celebrate, or if it's masking structural problems that will catch up with the business. She's not asking for an academic answer — she needs a clear yes/no with the evidence behind it.


### My Answer
- Definitely a few pitfalls here to think about:
    - why only look at top 20 markets?
    - this is my first reaction
- But assuming that is what we have to work with and it gets most of our value
- GOV growing is a good sign, but just by itself doesnt tell the full story, especially given NPS being down and dasher earnings also down
- Worry here is that GOV might have icnreased YoY, but the NPS being down and dasher earnings reducing is an early sign of things to come and growth actually slowing
- GOV going up could be a function of customer acquistion working well,
- However, NPPS going down shows signs of retention problem
    - Have we observed our 30/60/90D retention being down?
    - Has out LTV decreased?
- Same for dashers, their earnings are decreasing
    - This could be a sign of less orders being present i.e low demand
    - and hence, dashers might also start churning out of the system
- Possible hypothesis on this set of metric movement:
    - Poor customer acquistion: we are acuiring users who only make one order and never come back and leave bad reviews
    - Poor Product experience after first order: First order funnel looks healthy, but repeat order looks bad, leading to bad NPS
    - and these users dont tip
- The above two hypothesis lead to a big increase in total number of orders, eading to increase in GOV, but NPS and earnings being down since they are more dependent on quality and repetition of orders
- to confirm this we can look at a few metrics:
    - repeat orders: monthly/weekly cohort of customers who place an order in that time and then % of those who place repeat orders. compare this YoY
    - orders per consumer, monthly level, comapre YoY
    - NPS broken down by one time consumer orders vs repeat orders, compared YoY
    - Avg. tip per order broken down by one time consumer orders vs repeat orders, compared YoY
    - Mix-shift monhly level one-time orders vs repeat orders
    - In all of these we are trying to validate if one time orders have seen peaks this year and hence driving the NPS and earnings down
- If the above pans out to be true, we should inform the CEO, that we have mix-shift this year to one-time order consumers due to poor acquistion, leading to high GOV but downwards movements to NPS and Dasher Earnings
- If this continues, we could see churn in consumer and dasher side both which would lead to GOV decrease as well
- Recommendation is to improve:
    - acquistion quality
    - focus on retention rather than optimizing for first order
    - acquire customers focused on retention vs first time orders
    - this tradeoff is on % of first time orders vs 60D or 90D retention in short temr but eventually LTV
- Nuanced answer: Marketplace in this year shows strong GOV growth backed by acquistion efforts focused on first time order consumers, but there are red flags when it comes to retaining those users

    
### Feedback

**Overall: 8.5 / 10**

| Dimension | Score | Note |
|---|---|---|
| Situation assessment | 1.5/2 | Correctly framed GOV growth as masking quality deterioration on both sides; downstream GOV risk arrived mid-analysis rather than being flagged upfront |
| Clarifying questions | 1.5/2 | Top-20 bias catch and retention/LTV questions were strong; missed asking about acquisition channel mix (promos vs. organic) — that would have pointed to the hypothesis faster |
| Core hypothesis | 2/2 | Clean, parsimonious, and testable — one cause explains all three metrics simultaneously; the tip insight was the key unlock |
| Metrics chosen | 2/2 | Repeat order cohorts, orders per consumer, NPS by segment, avg tip by segment, mix-shift — comprehensive and directly tied to the hypothesis |
| Final recommendation | 1.5/2 | Nuanced CEO answer and acquisition/retention tradeoff were right; "improve acquisition quality" needs specific levers, and the recommendation lacks a forward-looking quantified framing |

**Key takeaways:**
- Ask about acquisition channels early — "are we running heavy promos?" is a single question that collapses the entire investigation; promo-driven users have a known profile: low retention, low tips, high churn
- Quantify forward risk for the CEO: state what continued deterioration means in concrete GOV terms ("new cohorts worth 20% less in LTV → need proportionally more acquisition to sustain growth, compounding the problem")
- Make recommendations specific: levers are (a) reduce promo depth so discount-seekers self-select out, (b) shift spend to channels with proven retention profiles, (c) add minimum order value before welcome offer applies — always state the tradeoff for each
