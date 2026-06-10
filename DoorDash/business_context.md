# DoorDash Business Framework

A mental model for reasoning about DoorDash as a business, then about the Dasher & Logistics team specifically. Read this **before any case session** to anchor your thinking.

This doc stays at the framework level. For tactical detail (formulas, levers, common case framings), see [dasher_logistics_context.md](dasher_logistics_context.md). For unstructured personal notes, see [Doordash Business Understanding](Doordash%20Business%20Understanding).

---

# Part 1 — DoorDash as a business

## 1.1 What DoorDash is, in one paragraph

DoorDash is a logistics platform that matches three groups — **consumers** who want something delivered, **merchants** who can supply it, and **Dashers** who can transport it — in cases where direct fulfillment is uneconomical. It started in restaurant delivery and is expanding into the broader category of **local commerce** (grocery, retail, pharmacy, alcohol). The business works because shared delivery infrastructure lets fixed costs spread across many orders.

## 1.2 The three sides and what each wants

| Side | What they want | What they're willing to give up |
|---|---|---|
| **Consumer** | Fast, cheap, reliable delivery from a wide selection | Some convenience for lower fees |
| **Merchant** | More orders, low operational overhead, customer data | Commission % off the top of each order |
| **Dasher** | Predictable earnings, flexible hours, low app friction | Total autonomy, in exchange for steady volume |

The platform's central challenge: keep all three sides alive at once. A change that helps one side usually costs another. Most DS work at DoorDash is about quantifying that tradeoff.

## 1.3 How money moves

**Revenue (inflows):**
- **Merchant commission** — % of each order value. Largest revenue source.
- **Consumer fees** — delivery fee + service fee per order.
- **DashPass** — subscription that waives delivery fees; defers revenue but lifts frequency.
- **Advertising** — merchants pay for visibility in the app.
- **Owned inventory** (DashMart, etc.) — margin from end-to-end ownership of certain verticals.

**Costs (outflows):**
- **Dasher pay** — largest single cost.
- **Refunds + customer support** — driven by failure rate.
- **Marketing + acquisition** — across all three sides.
- **R&D + platform engineering** — building and running the system.

**The unit-economic question:** for a single order, does revenue cover Dasher pay + support + refunds + a share of fixed cost? When yes, the order is contribution-positive. When framing recommendations, always state the unit-economic impact.

## 1.4 The growth flywheels

DoorDash compounds via two interconnected loops:

- **Selection loop:** more merchants → more selection → more consumers → more orders per merchant → more merchants want in
- **Density loop:** more orders in a zone → batching becomes feasible → cost per delivery drops → fees stay low and Dashers earn more → more consumers and Dashers attracted

Most strategic decisions trace back to feeding one of these loops. When asked "why does this matter?", connecting your recommendation to a flywheel is a strong move.

## 1.5 Main tradeoffs at the company level

Recurring tensions every DS person encounters:

| Tension | Concrete example |
|---|---|
| **Speed vs cost** | Batching lowers cost but extends consumer ETA |
| **Growth vs margin** | Promo-driven acquisition lifts volume now, hurts contribution |
| **Consumer fees vs Dasher pay** | The platform can subsidize one side, not both fully |
| **Coverage vs density** | Expand to thin markets vs reinforce dense ones |
| **Short-term metric vs long-term LTV** | A discount lifts conversion today, depresses retention next month |
| **One side's KPI vs another's** | Lower fees lift consumer volume, but compress merchant margin or Dasher pay |

Naming the right tension is half the answer in a case study.

## 1.6 Main entities — pick the unit of analysis first

The most common framing mistake is starting an analysis at the wrong unit. Before discussing metrics, name the entity:

| Entity | When to use it |
|---|---|
| **Order / delivery** | Anything tied to one transaction (ETA, cost, refund, NPS rating) |
| **Consumer** | Frequency, retention, LTV, churn |
| **Merchant** | Volume, retention, store health |
| **Dasher** | Earnings, retention, acceptance, churn |
| **Dasher-hour** | Supply efficiency, utilization, capacity |
| **Zone-time** (e.g., "downtown SF, Fri 7-7:30 pm") | Local marketplace state, Peak Pay, experiments |
| **Market (city)** | Launch decisions, market-level changes |
| **Cohort (signup week)** | Lifecycle and retention analysis |

A Dasher-level effect averaged across all hours is a different story than a zone-time imbalance. Name the unit explicitly.

## 1.7 Time periods that matter

| Window | Used for |
|---|---|
| **Seconds–minutes** | Dispatch, assignment, Peak Pay activation |
| **Daily** | Order volume, market health, ops dashboards |
| **Weekly** | Cohort retention, market reviews, experiment readouts |
| **4-week / monthly** | Churn definitions, mature retention metrics |
| **Quarterly** | Strategic reviews, planning, large experiments |
| **Annual / YoY** | Seasonality adjustment, strategic planning |

When discussing a trend, always state the window. "Churn is up 15%" means nothing without it.

## 1.8 Measurement design philosophy

Five principles that show up again and again:

1. **Decompose before discussing change.** Almost every DoorDash metric is a ratio. Name the numerator and denominator separately — compositional shifts often explain a headline.
2. **Randomize where possible.** Observational comparisons in a marketplace are nearly always contaminated by selection or spillover. When randomization isn't possible, use DiD or matched-market designs — but state the assumption.
3. **Pick the right unit of randomization.** Individual randomization fails under marketplace spillover. Cluster (zone-time), switchback, or matched-market designs are often required.
4. **Define guardrails up front.** A change to one side of the marketplace can hurt another. Pre-specify what "bad" looks like on the other two sides.
5. **Pre-register the analysis plan.** Especially in a ship-first culture, write the analysis plan before reading results to avoid HARKing and peeking.

---

# Part 2 — Dasher & Logistics team

## 2.1 Where the team sits in DoorDash

DoorDash's DS organization splits roughly by surface: Consumer, Merchant, Marketplace, **Logistics**, New Verticals, Ads, Internal Tools. The Dasher & Logistics team is the supply-side counterpart to Consumer growth.

It owns:
- The Dasher's entire lifecycle on the platform
- The matching layer between orders and Dashers
- Logistics efficiency and unit cost
- The Dasher product (the Dasher app)

It does NOT own consumer growth, merchant relationships, or restaurant selection — but it interfaces with all of them constantly. Most cross-functional conflict for this team is with Consumer growth (who wants faster, cheaper) and Finance (who wants lower cost per delivery).

## 2.2 What the team owns vs influences

| Owns directly | Influences |
|---|---|
| Dasher activation, retention, churn | Consumer ETA (via assignment) |
| Assignment algorithm policy | Consumer NPS (via delivery quality) |
| Batching policy | Merchant accept rate (via Dasher reliability) |
| Peak Pay rules | Marketplace efficiency (joint with Consumer DS) |
| Dasher pay structure | Unit economics (joint with Finance) |
| ETA modeling | Capacity planning (joint with Ops) |
| Dasher app experience | Forecasting (joint with Strategy) |

When a recommendation crosses from "owns" into "influences," call out the partnering team.

## 2.3 The mental model of "supply"

"Supply" is not a single number. Useful decomposition:

- **Capacity** = total Dasher-hours available in market X at time T
- **Utilization** = fraction of those hours actively delivering
- **Effective supply** = capacity × utilization × geographic match quality
- **Reliability** = % of accepted offers actually completed on time

Most "we need more supply" conversations actually want more *effective* supply. That's often cheaper to get via better utilization (smarter assignment, better batching) than via acquiring more Dashers.

## 2.4 Key tradeoffs the team navigates

| Tradeoff | Concrete example |
|---|---|
| **Batching aggressiveness** | More batching → lower cost + higher EPAH → longer consumer ETA |
| **Assignment greedy vs lookahead** | Assign now (fast) vs hold briefly for a better match (slower but more efficient) |
| **Peak Pay spend vs supply growth** | Pay more in the moment vs invest in long-term acquisition/retention |
| **Acceptance enforcement vs Dasher autonomy** | Enforce → predictable supply, lower satisfaction; loose → freer but noisier supply |
| **New-Dasher protection vs experienced-Dasher utilization** | Steering orders to new Dashers builds retention but slows down experienced Dashers |
| **Short-term EPAH vs long-term Dasher LTV** | A pay floor lifts today's EPAH but may permanently shift cost structure |
| **Logistics cost vs consumer experience** | Saving a cent per delivery may cost 30 seconds of ETA |

## 2.5 Main entities for logistics decisions

| Entity | When |
|---|---|
| **Delivery / order** | Per-delivery cost, ETA accuracy, batched vs solo |
| **Dasher** | Earnings, retention, acceptance rate, churn |
| **Dasher-hour** | Utilization, supply available |
| **Dasher tenure cohort** | Activation, D7 / D30 / D90 retention |
| **Zone-time** | Marketplace state, Peak Pay, experiment unit |
| **Market** | Launch decisions, market-level pay changes |

The unit-of-analysis question is THE source of most subtle Dasher & Logistics mistakes. A Dasher-level effect averaged across all hours is a different story than a zone-time imbalance.

## 2.6 Time periods specific to logistics

| Window | Used for |
|---|---|
| **Seconds–minutes** | Dispatch, assignment, Peak Pay activation, real-time demand spike response |
| **Hour** | Shift-level supply, peak management (lunch/dinner) |
| **Day-of-week** | Predictable demand patterns (Friday dinner ≠ Tuesday lunch) |
| **Week** | Dasher retention cohorts, market-level supply health |
| **4 weeks** | Churn definition, mature retention metrics |
| **Quarter / YoY** | Seasonality, strategic capacity planning |

The leading-vs-lagging framing matters here: anything measured on a 4-week window lags real-time signals. First-week deliveries leads 4-week churn; assignment queue length leads ETA degradation.

## 2.7 Measurement design for logistics decisions

Three things to drill into anytime you propose an experiment or analysis on the supply side:

1. **Unit of randomization.** Individual-Dasher randomization almost always violates SUTVA — a treated Dasher's behavior affects orders available to control Dashers in the same zone. Default to zone-time, switchback, or matched-market designs. Justify if you choose otherwise.

2. **Spillover boundary.** State explicitly which entities can interact. A Peak Pay change in zone A may pull Dashers from zone B — the experiment is contaminated. Either include the adjacent area in treatment, or measure the leakage.

3. **Guardrails on the other two sides.** Every logistics change should pre-specify tracking for: consumer ETA / NPS, merchant accept-rate / refund rate, AND the supply effect. Measuring only supply means you can't tell whether you've shifted cost to someone else.

---

# Quick reference — when to use what

| Situation | What to anchor on |
|---|---|
| Open-ended "is X healthy?" | Decompose by entity (consumer / merchant / Dasher), then by time window |
| Metric drop / spike | Numerator vs denominator first, then segment by entity tenure and market |
| Experiment proposal | Unit of randomization → guardrails → MDE/runtime |
| Launch decision | Which flywheel does this feed? What does it cost on the other two sides? |
| Stakeholder ask | Pin the decision being made → name the tension → recommend with a tradeoff |
| Capacity question | Decompose supply into capacity × utilization × match quality |
