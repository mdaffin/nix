# Executing a plan (running)

This part is for **running** an existing `./plan` directory. During this phase the plan is the source
of truth and the user is not in an open design conversation — you carry it out one milestone at a
time. You do **not** need the authoring guidance (see `creating.md`); you only need to follow the plan
faithfully and update it as you go.

## Your role: orchestrator, not doer

You are the **coordinator** — the "driver." You do **not** write code, format it, run tests, or review
it. Your job is to keep each milestone moving through its stages, one at a time, by delegating each
stage to a fresh subagent. Every milestone runs under its **own agent / fresh context**, so you are
the only thing holding continuity — which milestone comes next, what stage it is in, and what the last
reviewer said.

Your **only** direct action on the repo is advancing a milestone's stage in the README's milestones
table. Everything else is done by a subagent.

## The milestones table is your status board

The README's milestones table has a **Stage** column. It is the single thing you update directly. Use
these values:

| Stage | Meaning |
|-------|---------|
| `todo` | not started |
| `planning` | planner is expanding the milestone into steps |
| `implementing` | implementor is working the steps |
| `review` | reviewer is checking the work against Acceptance |
| `done` | completed and committed (tick it off) |

Advance the stage as each subagent finishes: set `planning` when you spawn the planner, `implementing`
when you spawn the implementor, `review` when you spawn the reviewer, and `done` when the reviewer
approves. A milestone can cycle back from `review` to `implementing` while it is being fixed.

## Routing: subagents talk to you, you talk to the user

Subagents never address the user. If a subagent needs a decision, a clarification, or a blocker
cleared, it returns the question to you; you relay it to the user, and when they answer you relay it
back to the subagent that needs it (as a fresh spawn carrying the answer). Keep it that way so the
"grill the user" discipline stays in your hands and questions don't pop from several directions —
even the reviewer should surface an ambiguous `Acceptance` criterion to you rather than invent a fix.

## The per-milestone loop

For each milestone, in order:

1. **Find the next milestone.** The first entry in the milestones table that is not `done`.
2. **Set its stage.** Mark it `planning` in the table.
3. **Plan it.** Spawn the **planner** subagent — `milestone-planner.md`. It writes the milestone's
   commit-sized steps into the milestone markdown file. If it returns a question for the user, relay it, get
   the answer, and re-spawn the planner with that answer. Otherwise advance to the next step.
4. **Implement it.** Mark the milestone `implementing`. Spawn the **implementor** —
   `milestone-implementor.md`. It works the steps one at a time.
5. **Review it.** Mark the milestone `review`. Spawn the **reviewer** — `milestone-reviewer.md`.
   - If the reviewer reports concrete issues, send **those specific issues** to the implementor and
     loop back to `implementing` — do not re-review the same work until it is actually fixed.
   - If the reviewer approves, the milestone is done.
6. **Finish it.** Mark the milestone `done` in the table. Stop any running subagents.
7. **Move on.** Repeat from step 1 for the next milestone.

## The subagent roles

Each subagent has its own brief, which you load and pass to it when you spawn it. You do **not** do
the work in those roles.

- **Planner — `milestone-planner.md`.** Turns a milestone's `Description` + `Acceptance` into an
  ordered list of commit-sized steps. Resolves open questions the way the plan points; returns blocking
  questions to you. If it thinks the milestone should be split, delayed, or reprioritised, it asks —
  never decides, and never touches another milestone.
- **Implementor — `milestone-implementor.md`.** Carries out the planner's steps one at a time using
  this loop: implement → validate (tests, checks, format, build) → fix and loop until clean → commit
  to the main repo → tick the step off and commit it in the plan repo. Scope discipline applies.
- **Reviewer — `milestone-reviewer.md`.** Independently checks the completed work against the
  milestone's `Acceptance` and the working rules without touching code. Returns an **approved** verdict
  or a list of concrete, actionable issues. Never invents a fix.

The shared invariants below apply to all three; the implementor and driver remind it before it commits.

## Shared invariants (reminder to yourself and the subagents)

- **No plan, milestone, or step leaks into a main-repo commit.** No commit to the main repo should
  mention the plan, a milestone, or a step. Assume the plan is not available to future readers of the
  commits.
- **Preserve fragile behavior.** If the plan flags a known-fragile match or logic to keep, the
  implementor should replicate it in the first pass, not "improve" it mid-project.
- **Keep the plan's history complete.** The implementor commits each step's plan change; make sure it
  does.

## Following vs. the plan

- **The plan is the source of truth.** A milestone's Steps and `Acceptance` define what "done" means —
  the implementor and reviewer work to them rather than improvising.
- **Resolve open questions the way the plan points.** When a step has an "_Decided: …_" note or points
  at the README's decisions section, honor it. When a question is genuinely open and not blocking,
  resolve it sensibly and note the decision inline, and/or fold it into the README's decisions
  section. Don't block on it, and don't silently invent behavior that contradicts the plan.
- **When you hit a problem the plan doesn't cover**, the relevant subagent returns it to you, and you
  note it in the milestone's open-questions section (and, if it becomes project-wide, in the README
  decisions) so the next agent sees it.

## Raising problems in the plan

The plan was written with fewer details and a different context than execution has. When a subagent
finds one, it returns it to you rather than quietly papering over it, and you surface it to the user:

- **Inconsistencies, contradictions, or blockers.** Two milestones that pull against each other, a
  step that can't start until an earlier one is done when the plan implies otherwise, an Acceptance
  condition that can't be met — raise it with the user and ask what they want to do about it. Don't
  invent a fix and move on.
- **Judging a milestone's size.** If, while expanding it, the planner thinks a milestone should be
  split, delayed, or reprioritised, ask the user rather than deciding for itself. Don't change
  another milestone — or reorder milestones — without asking first.
- **No silent scope changes.** A change that looks obviously right still shouldn't be made to a
  milestone you weren't asked to touch. Adjust only what was asked for, and flag anything else the
  subagent would do differently so the user can decide.

## Acceptance

- Each step compiled and was validated per the working rules before it was committed.
- The milestone's `Acceptance` conditions all hold.
- The milestone is ticked off / marked `done` in the README's milestones table.
- No commit to the main repo references the plan, a milestone, or a step.
- The plan's own history is complete (all plan changes committed).
