# data-diary

Personal data science workspace — structured around product data science interview preparation. A reusable practice loop that adapts per company by dynamically loading whichever context files exist in the active company's folder.

## How the prep system works

Each target company gets its own folder (e.g. [DoorDash/](DoorDash/)). The skills auto-detect the active folder (most recently modified) and load whichever context files are present:

| File pattern | Purpose | Required? |
|---|---|---|
| `*business*context*` or `*business*understanding*` | General business model & metrics | for cases & SQL |
| `team_*_context.md` or `*_<team>_context.md` | Team-specific deep dive — biases ~30-40% of questions to team area | optional |
| `*values*.md` | Company values (used for behavioral scoring) | for behavioral |
| `*product_prep*.md` | Product/case practice log | created on demand |
| `*sql_prep*.ipynb` | SQL practice log | created on demand |
| `behavioral_prep.md` | Behavioral practice log | created on demand |
| `star_story*.md` | STAR story bank (your real stories, tagged to values) | for behavioral |
| `hiring_manager_questions.md` | Questions to ask the hiring manager | optional |
| `case_rubric.md` | Custom rubric override | optional — defaults to DD 4-dim |

## Slash commands

| Command | What it does |
|---|---|
| `/interviewer-mode` | Identifies active company, loads business + team context, biases topic toward Weak Areas in [learnings.md](learnings.md), states a time box, and asks one underspecified SQL or product case question. Appends it to the right prep doc/notebook. |
| `/behavioral-mode` | Picks a cross-functional persona (PM / Eng / Marketing / S&O) and a behavioral theme (partnerships / project mgmt / data / conflict), asks one question grounded in the company's values, and probes with 1-2 follow-ups. Logs to `behavioral_prep.md`. |
| `/feedback-mode` | Scores the most recent answer. Uses the DoorDash 4-dimension rubric for product cases (Business/Product Intuition, Structured Thinking, Depth of Solution, Organization & Clarity), a 4-dim SQL rubric, or a 5-dim behavioral rubric. Persists feedback inline. Auto-updates Weak Areas in [learnings.md](learnings.md). |
| `/add-learning` | Adds a new tip/pattern to [learnings.md](learnings.md) under the right category. |

## Recommended session flow

1. Skim relevant context files before starting (business context, team context, [learnings.md](learnings.md) Weak Areas).
2. `/interviewer-mode` or `/behavioral-mode` — get a question. Time yourself.
3. Write your answer in the `### My Answer` block (or solve in the SQL notebook).
4. `/feedback-mode` — get scored. Feedback persists inline.
5. If you scored <7 or learned something non-obvious, `/add-learning`.

## Active prep target — DoorDash (Jun 16-17 onsite)

- Team: Dasher & Logistics
- Context files in [DoorDash/](DoorDash/):
  - [Doordash Business Understanding](DoorDash/Doordash%20Business%20Understanding) — general 3-sided marketplace
  - [dasher_logistics_context.md](DoorDash/dasher_logistics_context.md) — team deep dive (assignment, batching, ETA, lifecycle, Peak Pay, unit economics)
  - [doordash_values.md](DoorDash/doordash_values.md) — 12 values reference
  - [star_story_bank.md](DoorDash/star_story_bank.md) — STAR stories (template, to fill in)
  - [hiring_manager_questions.md](DoorDash/hiring_manager_questions.md) — Part III questions (template, to fill in)
  - [doordash_product_prep.md](DoorDash/doordash_product_prep.md) — case practice log
  - [doordash_sql_prep.ipynb](DoorDash/doordash_sql_prep.ipynb) — SQL practice log
  - [behavioral_prep.md](DoorDash/behavioral_prep.md) — behavioral practice log

## Other folders

- [sql-questions-practice/](sql-questions-practice/) — standalone SQL exercises across Meta, Shopify, Yelp, Chime, DoorDash
- [python-coding-practice/](python-coding-practice/) — pandas/Python case studies (Chime A/B testing, Meta PUE, Yelp)
- [predictive-modeling-practice/](predictive-modeling-practice/) — modeling case studies (insurance claims, Poisson GLM)
- [learnings.md](learnings.md) — running tips, patterns, and Weak Areas list
