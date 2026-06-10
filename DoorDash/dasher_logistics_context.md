# Dasher & Logistics — Team Context

Primer for the Dasher & Logistics DS team. Re-read before any session that targets this domain. Other DD cases will be general 3-sided marketplace; this doc deepens the supply / logistics side specifically.

> **Team mission:** Build the most efficient and reliable logistics system while giving Dashers the best gig-platform experience. Make Dashers' lives easier, improve quality + efficiency of logistics to lower delivery cost and grow consumer demand, and ensure logistics scales across verticals (food, grocery, retail).

---

## 1. The supply side of the marketplace

DoorDash is a 3-sided marketplace: **Consumers, Merchants, Dashers**. The Dasher & Logistics team owns the supply side — Dashers — and the matching layer that connects supply to demand.

Three first-order objectives, frequently in tension:

| Objective | Owner sees it as | Lever |
|---|---|---|
| **Delivery cost** (cost per delivery) | Lower = better margin, lower consumer fees | Batching, routing, Dasher pay model |
| **Consumer experience** (on-time rate, ETA accuracy, food quality) | Lower latency = higher NPS, retention, frequency | Assignment, ETA model, batching limits |
| **Dasher experience** (earnings per hour, app friction, predictability) | Higher = retention, lower acquisition cost | Pay floor, Peak Pay, dispatch quality, batching opt-out |

> Any case in this domain should explicitly name which side wins and which side pays the cost. Naming the tradeoff is half the answer.

---

## 2. Dasher lifecycle (the supply funnel)

```
Sign up → Background check → Onboarding → First delivery (Activation)
   → Early retention (D7, D30, D60)
   → Mature retained Dasher
   → Churn (no delivery in N consecutive weeks)
   → Reactivation
```

Key metrics by stage:

| Stage | Metric | Why it matters |
|---|---|---|
| Sign-up → Activation | **Activation rate** (% of signups that complete first delivery within X days) | Leading indicator of acquisition ROI; also reveals onboarding friction |
| Activation → D30 | **D30 retention** | Strongest predictor of LTV; early experience disproportionately determines retention |
| Mature | **Hours per week**, **Deliveries per active Dasher** | Capacity per Dasher — fewer Dashers needed if utilization is high |
| Mature | **Acceptance rate** | Affects matching efficiency, dispatch latency |
| Churn risk | **Earnings per active hour** (EPAH) | Strongest causal driver of churn; if EPAH drops, churn follows with a 4-6 week lag |
| Churn | **% Dashers with no delivery in 4 consecutive weeks** | Standard churn definition; use this denominator |

**Leading indicators of 4-week churn:**
- First-week deliveries (under ~3 deliveries in week 1 → much higher churn)
- First decline in EPAH (more than a 10-15% drop week over week)
- Acceptance rate collapse (Dasher stops engaging with offers)
- Drop in average shift length

---

## 3. The assignment problem (matching)

The core engine: a real-time assignment algorithm matches **incoming orders** to **available Dashers**. Conceptually similar to a bipartite matching problem solved every few seconds at city scale.

**Inputs to assignment:**
- Order: pickup location, drop-off, expected prep time, food type (heat-sensitive, fragile), promised ETA
- Dasher: current location, vehicle, current batch state, historical reliability, acceptance rate
- Market state: queue of waiting orders, available Dashers, current Peak Pay zones

**Optimization objective** (simplified):
Minimize total expected delivery cost + delay penalty, subject to:
- Each order assigned to ≤1 Dasher
- Each Dasher has bounded queue capacity
- ETA promises honored within tolerance

**Levers the team can pull:**
- Assignment policy (greedy vs lookahead, distance weights, ETA weights)
- Batching policy (when can two orders go to one Dasher)
- Acceptance-rate-based prioritization
- Peak Pay activation rules
- Geofencing of supply pools

---

## 4. Batching (most-asked area)

**Batching** = assigning one Dasher multiple orders from the same merchant (or nearby merchants) to deliver on one trip.

**Why it matters:**
- Increases Dasher EPAH (more deliveries per hour) → retention + acquisition efficiency
- Lowers delivery cost (one trip = N orders worth of pay/mileage spread across N)
- BUT trades off consumer ETA (each consumer waits longer than if it were a solo order)

**Typical batching dimensions to reason about:**
- Same merchant vs different merchants
- Drop-off proximity (radius, route convexity)
- ETA degradation budget per consumer
- Heat / food quality degradation
- Dasher acceptance: Dashers may decline batched orders if pay-to-effort ratio drops

**Common batching question framings:**
- "Should we batch more aggressively?" → quantify EPAH gain vs ETA loss + NPS impact
- "Batching acceptance rate dropped" → did pay model change, or did consumer ETA enforcement change?
- "Batched delivery ETAs degraded" → check route convexity, prep time variance, Dasher tier mix

---

## 5. ETA modeling

ETAs are predicted (and promised to consumers) at order placement. ETA accuracy directly drives:
- Consumer experience (NPS, refund rate)
- Assignment quality (over-promised = under-supply illusion)
- Dasher pay (some pay models tie to ETA)

**ETA prediction = sum of:**
- Time to assign a Dasher (queue/dispatch latency)
- Dasher transit to merchant
- Merchant prep time (the largest variance component, hardest to predict)
- Dasher wait at merchant
- Transit to consumer
- Handoff time

**Common ETA-related cases:**
- "ETA accuracy degraded YoY" → likely merchant prep time variance (new merchants, new menus, kitchen staffing)
- "ETAs are biased low in market X" → look at variance component; could be batching mix shift
- "Should we widen the ETA window?" → consumer trust vs conversion tradeoff

---

## 6. Peak Pay / supply incentives

When demand spikes (lunch, dinner, weather, events) the platform pays a per-delivery bonus to active Dashers to pull more supply online.

**Levers:**
- Peak Pay amount (per delivery)
- Geographic scope (zone-level vs market-level)
- Activation rule (forecast-based vs reactive)
- Duration (15 min, 1 hour blocks)

**Tradeoffs:**
- Too little → unfilled orders, longer ETAs, lost demand
- Too much → margin loss, Dashers learn to wait for Peak Pay (gaming)
- Wrong geography → Dashers move TO the Peak Pay zone, leaving adjacent zones short

**Standard case framings:**
- "Peak Pay spend is up but on-time rate isn't improving" → likely zone misallocation or saturation
- "Design an experiment for a new Peak Pay rule" → unit of randomization (zone-time vs Dasher), spillover risk

---

## 7. Dasher unit economics

For a single delivery:

```
Dasher pay = base pay + tip + (Peak Pay if applicable) + (mileage/time component, market-dependent)
Platform contribution = consumer fee + merchant commission − Dasher pay − support costs
```

What "good" looks like for the supply side:
- EPAH high enough that Dashers stay (varies by market, but the team tracks this against minimum wage benchmarks)
- Cost per delivery low enough that consumer prices remain competitive
- Margin retained for reinvestment

**The implicit recurring conflict:** consumer growth team wants lower fees / faster delivery; logistics team holds the line on Dasher pay (which protects supply) and on delivery cost (which protects margin).

---

## 8. Common case types you should be ready for

| Case type | Typical framing | What to lead with |
|---|---|---|
| **Metric drop** | "Dasher churn / EPAH / acceptance rate is down" | Decompose churn = numerator + denominator; segment by tenure × market; isolate change point |
| **ETA degradation** | "On-time rate dropped 4 pts" | Decompose ETA = assignment + transit + prep + wait; find the component with rising variance |
| **Launch decision** | "Should we ship new batching rule / assignment change?" | Define metric tree: efficiency (cost, EPAH) vs experience (ETA, NPS); design experiment with proper unit of randomization |
| **Experiment design** | "Test a new Peak Pay strategy" | Unit of randomization (Dasher vs zone-time), spillover, guardrails, MDE, runtime |
| **Capacity planning** | "Will supply hold for the holiday peak?" | Forecast demand and supply separately, identify market-hour bottlenecks |
| **Instrumentation gap** | "We can't measure X" | What event would prove the hypothesis? What event would falsify it? What is the minimal new logging required? |
| **Stakeholder ask** | "VP wants a recommendation by Friday" | Sequence: pin down decision, decompose, prioritize hypotheses by likelihood × speed-to-test, ship surgical fix |

---

## 9. Things that signal "depth" in this domain

When discussing a Dasher & Logistics case, these specifics signal you understand the system:

- Name the **unit of analysis correctly** (per delivery, per Dasher-hour, per zone-hour, per market-day)
- Distinguish **selection effects** from **causal effects** (e.g. "high-acceptance Dashers are also tenured — don't credit acceptance rate")
- Acknowledge **spillover / network effects** when discussing experiments (a Dasher in treatment affects orders not in treatment)
- Name a **leading indicator** for any lagging metric (first-week deliveries for 4-week churn; assignment queue length for ETA degradation)
- Quantify in **EPAH** when relevant — this is the supply-side currency
- Mention **the cross-functional conflict** (logistics vs consumer growth, logistics vs merchant) when proposing a recommendation
- Recognize that **acceptance rate is endogenous** to dispatch quality, not just Dasher behavior

---

## 10. Things to avoid

- Recommending changes to consumer-side fees without naming the supply-side consequence
- Treating churn as a single number without segmenting by tenure
- Designing experiments where the unit is Dasher when spillover within a zone is the dominant effect
- Assuming the merchant prep time is fixed — it isn't, and it's the largest ETA variance component
- Proposing "reduce batching" or "increase batching" without naming which consumer/Dasher tradeoff you're accepting
