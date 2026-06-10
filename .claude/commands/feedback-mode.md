You are now in **Feedback Mode**.

Detect the company, question type, and rubric from context.

---

## Step 1 — Identify the target prep doc/notebook and load context

1. Find the active prep folder (most recently modified, or matching the in-flight session).
2. **Load context files from the active folder before scoring — read whichever exist:**
   - Business context (file matching `*business*context*` / `*business*understanding*`)
   - Team context (file matching `team_*_context.md` etc.) — if present, score "metrics chosen" and "business intuition" against the team's specific framings, not just the company's general business model
   - Custom rubric (`case_rubric.md`) — if present, overrides the default rubric below
   - Values reference (`*values*.md`) — required for behavioral feedback

3. Route to the right log file:
   - SQL feedback → `*sql_prep*.ipynb` in active folder
   - Product/case feedback → `*product_prep*.md` in active folder
   - Behavioral feedback → `behavioral_prep.md` in active folder

If ambiguous, ask the user.

---

## Type 1 — SQL Feedback

The candidate's SQL solution is complete. Your job:

1. Read their solution from the notebook (or conversation if pasted).
2. Rate the solution out of 10.
3. Break down across four dimensions — score and one-sentence reasoning each:
   - **Correctness** — right result, edge cases included
   - **Efficiency** — joins, windows, CTEs efficient; no redundant scans
   - **Readability / structure** — CTE naming, logical decomposition
   - **Edge cases / robustness** — NULLs, ties, empty groups, time-zone, denominator-zero
4. Give 2-3 concrete, actionable improvements with code examples.
5. If strong (8+), say so and what made it good.
6. Note pacing if over time box.

**Persist in the notebook.** Locate the `### Feedback` placeholder cell after the candidate's solution and overwrite with: overall score, 4-dim table, key takeaways, pacing note. If no placeholder, append a new markdown cell.

---

## Type 2 — Product / Case Study Feedback (DoorDash rubric default)

The candidate's product/case answer is complete. Your job:

1. Read their answer from the product prep doc (under the relevant `### My Answer`) or from the conversation.
2. Rate out of 10.
3. **Apply the DoorDash 4-dimension case rubric** (this is the actual rubric used in DD case interviews). Score each dimension and give one sentence of reasoning:

   - **Business / Product Intuition** — Did they define success metrics relevant to the business? Did they reflect the 3-sided marketplace (or whatever the company's business model is)? If a team context is loaded, did they ground in team-specific metrics and tradeoffs?
   - **Structured Thinking** — Did they ask the right clarifying questions before diving in? Did they think high level before details? Did they avoid jumping to a single hypothesis?
   - **Depth of Solution** — Did they go beyond surface-level decomposition into specific data they'd pull, specific analyses (experiments, predictive, statistical) they'd run, and specific tradeoffs (cannibalization, network effects, spillover)?
   - **Organization & Clarity** — Was the answer organized, "thinking out loud" without jumping concepts? Did they guide the conversation rather than wait to be probed?

4. Give 2-3 concrete, actionable improvements — specific things they should have said or done differently. Quote the company's actual business terms (e.g. "EPAH", "P0/P1 pickups", "Peak Pay zone") if a team context is loaded.
5. If strong (8+), say so and what elevated it.
6. Note pacing if over time box.
7. Keep feedback direct — no filler.

**Persist in the doc.** Write the overall score, 4-dim table, key takeaways, and pacing note under a `### Feedback` subsection in the relevant question section.

---

## Type 3 — Behavioral Feedback

The candidate's behavioral answer is complete. Your job:

1. Read their answer from `behavioral_prep.md` under the relevant question, or from the conversation.
2. Rate out of 10.
3. Score across five dimensions:

   - **STAR completeness** — Did they cover Situation, Task, Action, Result with appropriate weighting (Action and Result should dominate)?
   - **Values alignment** — Did the story map cleanly to 1-2 of the company's values (loaded from the values file)? Did they name a value naturally or did the value show implicitly without forcing it?
   - **Data / quantification** — Did they ground the story in real numbers (dollar impact, percent change, users affected)? DS interviewers want to see DS thinking even in behavioral.
   - **Self-awareness** — Did they include what they'd do differently, a tradeoff they accepted, or a mistake they recovered from?
   - **Communication clarity** — Was the story concise (~90s baseline, ~2-3 min with detail), well-paced, no rambling?

4. Give 2-3 concrete improvements. Reference specific values from the values file when relevant.
5. If strong (8+), say what elevated it.
6. Note pacing.

**Persist in `behavioral_prep.md`** under a `### Feedback` subsection in the relevant question section.

---

## After feedback (all types)

1. If the overall score is **below 7**, append the topic tag to the **Weak Areas** section of `learnings.md` (if not already there).
2. If the score is **8 or above** and the topic was previously listed as weak, ask the user if they'd like to remove it from Weak Areas.
3. Ask: "Want to try another question, revisit this one, or extract a learning with `/add-learning`?"
