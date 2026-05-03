# Interview Prep — Key Learnings

A running doc of tips and patterns from practice sessions. Add to this with `/add-learning`.

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

---

## Experimentation / A/B Testing

| Tip | Detail |
|-----|--------|
| **Power is pre-experiment** | Power (1-β) is set before the experiment to determine sample size. If the experiment is statistically significant at the planned end date, power is largely irrelevant to interpretation. Mid-experiment, what platforms show as "power" is really the live MDE — the smallest effect detectable with 80% power at the current sample size; as N grows, MDE shrinks. |
| **Non-sig result → check power** | If an experiment ends without statistical significance, power tells you whether the experiment was designed to detect the effect size you care about. An underpowered experiment (too few users enrolled) leaves the result ambiguous: could be no effect, or could be a real effect too small to detect. Always pre-specify power so a non-sig result is informative. |
| **Peeking inflates Type I error** | Checking significance mid-experiment and stopping when p<0.05 inflates the actual false positive rate well above 5% — this is the peeking/optional stopping problem. It's separate from power/sample size: even with a large sample, repeatedly testing and stopping when significant is cherry-picking a favorable moment. Solutions: run to planned end, use sequential testing (O'Brien-Fleming, alpha-spending), or Bayesian methods. |

---

## Python / Statistics

| Tip | Detail |
|-----|--------|
