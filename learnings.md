# Interview Prep — Key Learnings

A running doc of tips and patterns from practice sessions. Add to this with `/add-learning`.

---

## Weak Areas

Topics scored below 7/10 in a recent session, or topics the candidate has flagged as shaky. `/interviewer-mode` should bias toward these first. Move topics out of this list once they hit 8+ on a subsequent attempt.

| Topic | Source | Last score | Status |
|---|---|---|---|
| Simpson's Paradox / stratification vs randomization | Q-S4 (DoorDash) | 4.5/10 | active retry |
| Peeking & early stopping / sequential testing | Q-S3 (DoorDash) | 5.5/10 | active retry |
| New-user incentive design & long-term value framing | Q3 (DoorDash) | 6.5/10 | active retry |
| Regression to the mean | Q-S5 (DoorDash) | unscored | needs feedback first |
| Difference-in-differences (DiD) | Q7 (DoorDash) | 6.5/10 | active retry |
| CUPED / variance reduction | gap in coverage | not practiced | needs first attempt |
| Network effects / SUTVA in marketplace experiments | Q8 (DoorDash) | 6.5/10 | active retry |

---

## SQL

| Tip | Detail |
|-----|--------|
| **Streaks / Gaps-and-Islands** | `date - ROW_NUMBER() OVER (PARTITION BY id ORDER BY date)` produces the same constant for consecutive days. A gap shifts the value. `GROUP BY` that constant to collapse each streak, then use `MIN/MAX/COUNT`. |

---

## Product / Metrics

| Tip | Detail |
|-----|--------|
| **Ambiguous situation framework** | Work backward from the decision: (1) identify who decides and what they need, (2) decompose the metric into components, (3) list all hypotheses and triage by likelihood × speed to rule out, (4) data quality check first (pipeline, denominator, instrumentation), (5) deep dive on top 1-2 hypotheses, (6) recommend with a clear action and caveats. Pruning the possibility space at each step prevents getting lost in an open-ended problem. |
| **Enumerate hypotheses upfront** | Before committing to the most obvious cause, briefly list all plausible explanations (product change, data issue, seasonality, external factors, cohort quality). Even if you dismiss most in one sentence, it shows systematic thinking and protects you if the primary hypothesis turns out to be wrong. |
| **Surgical fix over full revert** | When a product change caused a side effect, resist recommending a full rollback. Identify which population or condition the change harmed and patch that specifically — preserving the upside for everyone else. A full revert destroys proven gains; a targeted fix addresses the failure mode without sacrificing them. |
| **Form a prior before asking** | To get to hypotheses faster, map each metric signal to a side of the marketplace (consumer, Dasher, merchant) and force yourself to state a one-sentence hypothesis before asking any clarifying questions. Bottom-up elimination is slow; top-down priors are fast — you'll be wrong sometimes but you'll anchor the investigation immediately and ask sharper clarifying questions. |
| **Confirmation is not the finish line** | After validating a hypothesis, the full answer requires three more steps: (1) size it — quantify the impact in business terms, not just direction; (2) find the lever — name the specific action that changes it, not a vague direction; (3) state the tradeoff — every lever has a cost, quantify it. CEOs and PMs act on numbers and tradeoffs, not confirmed hypotheses. |

---

## Experimentation / A/B Testing

| Tip | Detail |
|-----|--------|
| **Power is pre-experiment** | Power (1-β) is set before the experiment to determine sample size. If the experiment is statistically significant at the planned end date, power is largely irrelevant to interpretation. Mid-experiment, what platforms show as "power" is really the live MDE — the smallest effect detectable with 80% power at the current sample size; as N grows, MDE shrinks. |
| **Non-sig result → check power** | If an experiment ends without statistical significance, power tells you whether the experiment was designed to detect the effect size you care about. An underpowered experiment (too few users enrolled) leaves the result ambiguous: could be no effect, or could be a real effect too small to detect. Always pre-specify power so a non-sig result is informative. |
| **Peeking inflates Type I error** | Checking significance mid-experiment and stopping when p<0.05 inflates the actual false positive rate well above 5% — this is the peeking/optional stopping problem. It's separate from power/sample size: even with a large sample, repeatedly testing and stopping when significant is cherry-picking a favorable moment. Solutions: run to planned end, use sequential testing (O'Brien-Fleming, alpha-spending), or Bayesian methods. |
| **Experiment window must cover metric window** | The experiment's runtime must be at least as long as the full observation window of every guardrail metric. If a churn metric needs 4 weeks to mature but the experiment runs for 3, churned users haven't been identified yet and the guardrail will pass silently. Always check: what is the latest a metric can signal harm, and does the experiment run long enough to observe it? |
| **Pre-register subgroups; still correct for multiplicity** | Pre-registering subgroups (deciding before the experiment runs) means you're testing a hypothesis, not mining data — so post-hoc subgroup findings are hypotheses only. But pre-registration alone doesn't fix multiple testing: 10 pre-registered subgroups at α=0.05 still gives ~40% FWER. Limit pre-registered subgroups to 1–3 with real hypotheses, and apply Bonferroni or BH correction when you have more. |
| **Regression to the mean needs a holdout** | Selecting extreme units (worst markets, lowest-rated Dashers) to intervene on means observed improvement is partly natural rebound, not just program effect — because observed value = true value + noise, and noise reverts. It's a measurement problem, not a "nothing works" claim: in a randomized experiment both groups revert equally, so the difference cancels out reversion and isolates the causal effect. Always keep a holdout even when targeting bad performers. |
| **DiD: state parallel trends first** | Before doing any DiD mechanics, say out loud: "The central assumption is that treatment and control would have trended similarly absent the intervention — I'll verify this with a pre-period trend check." Skipping this makes the whole analysis look ungrounded. Also: when markets were selected at their worst (low EPAH, high churn), flag regression to the mean immediately — matched controls must come from the same low-performance pool or the DiD overstates the effect. |
| **Randomize at the policy unit** | If a treatment applies to every user in a location (e.g., a market-wide earnings guarantee), randomize at the location (market) level — not the individual level. Individual-level randomization within the same market violates SUTVA: treated and control Dashers compete for the same order queue, so treatment spills over into control. Clean design: assign whole markets to treatment vs. control, matched on relevant confounders. |

---

## Python / Statistics

| Tip | Detail |
|-----|--------|
| **Aggregates lie; stratify; then randomize** | Aggregate averages can reverse within subgroups (Simpson's Paradox) when group compositions differ — always check the weighted breakdown. Stratifying by a known confound removes that specific bias but not unknown ones. Only randomization removes all confounds and supports causal claims. |
| **Spotting regression to the mean** | Any observed value = true underlying value + random noise. When you see improvement after selecting extremes, ask three questions: (1) Were these units selected because they were extreme? (2) Is there a control group that wasn't selected for being extreme? (3) Were they already trending back before the intervention? If yes to (1) and no to (2), the improvement is uninterpretable. Common triggers: worst markets, lowest-rated dashers, highest-complaint merchants, churned users who re-engage. |
