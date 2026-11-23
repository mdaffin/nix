# Creating a plan (authoring)

This part is for **building** a `./plan` directory. During this phase you are in a back-and-forth with
the user to arrive at an overall design, then break it into ordered, self-contained milestones. You
do **not** need the execution guidance (see `executing.md`); your only concern is making the plan
good enough that an agent can run it later without you.

## Why this shape

- **Milestones are small enough for a single agent.** Each milestone is scoped to fit one agent's
  session — enough to move a meaningful slice forward, short enough to finish and commit cleanly.
  Every milestone is meant to be run with a **fresh agent / fresh context**, so no milestone may
  rely on knowledge that only exists in another agent's working memory.
- **Milestones are self-contained.** Each compiles and is ideally usable/testable on its own, so the
  work is always in a shippable state and a stuck step doesn't block the rest.
- **One step = one commit.** Every step is written to be a standalone commit, so progress is tracked
  granularly and anything can be reverted or inspected.
- **Decisions are captured in context.** The README's "decisions" section and each milestone's "open
  questions" section record the answers to open problems where they were decided, so the reasoning is
  preserved and the plan stays living.
- **It is a separate repo.** The `./plan` directory is often its own git repo, so plan history never
  interferes with the main repo's commits.

## Overall workflow for creating a plan

Work through these five steps. Grill the user about every detail at each step — a plan written from
assumptions is just a list of mid-execution detours. Don't move on until the user is satisfied.

1. **Understand the project and write the description + goal.** Get an overall idea of what the
   project is and what it should do. Write a project description and a goal. If these are not clear
   from the initial prompt, query the user for details. Nail down **when the plan is considered
   done** — the exit criteria — so both of you know what "finished" looks like.
2. **Stay inside the plan repo.** During the planning phase make **no changes outside the plan
   repo** — no new work, no feature branches, no edits to the main repo's code. Nothing the plan
   describes has been approved yet, so the main repo must stay untouched. And never suggest
   *starting* implementation work during planning: don't say "start by…", don't pre-stage any of
   the work. When implementation can start, a new context will be created to do it — planning ends
   the moment the plan is ready to hand off.
3. **Front-load any upfront documents the work needs.** Ask whether there are designs, project
   layouts, APIs, or interfaces worth solidifying before the milestones. The right artifact depends
   on what you're doing:
   - A **REST/HTTP API** → flesh out the routes, request/response shapes, and error behavior.
   - A **library** → work out the public surface / endpoints or how a user may call into it.
   - A **CLI** → work out how it would be called on the commandline, what flags/arguments are needed,
     any subcommands?
   - Almost anything user-facing → work out the user's cases — the curl requests they'd issue, or the
     calls they'd make to the library.
   Ask the user about these and guide them until an acceptable document exists. There may be no need
   for this if it is a refactor, port, or similar where the design is already decided — but capture
   that existing design so it isn't lost.
4. **Scope the milestones at a high level.** Decide roughly how many milestones there are, how the
   work groups or splits, and in what order they must run. Confirm the high-level overview with the
   user.
5. **Break each milestone into steps.** Work out the pieces each milestone needs and split them into
   smaller sub-parts that each make sense as a separate commit. This is a coarse outline at planning
   time (see below) — the detailed, commit-sized steps are finalized at execution.

## The directory layout

A typical `./plan` directory looks like this:

```
plan/
├── README.md              # overview, milestones table, working rules, decisions
├── <slug>.md              # optional: extra details, designs, layouts, full inventory / reference doc etc
└── NN-<milestone-slug>.md # one per milestone, ordered, e.g. 01-cli-and-status.md
```

- The **README is the index** and holds the cross-cutting context that no single milestone owns.
  Anything that interacts with the plan should read this file first.
- Extra details can be stored in other, non-numbered markdown files. This may include an overall
  design doc, test cases, project layout, upstream references, etc. Different projects will require
  different ones. These hold details that don't fit into a milestone and cover the whole project.
- Milestone files are **zero-padded numbered prefixes** (`01-`, `02-`, …) so they sort into
  execution order.

## The README (`plan/README.md`)

The README is the entry point. It should contain:

1. **Goal + done criteria.** What is being done and where (e.g. "Port X into a Rust binary in this
   repo"), plus an explicit statement of when the plan is considered finished — the exit criteria.
   This is the thing the user should be grilled about first.

2. **"What it does" (brief).** A short, high-level description of the system's purpose and behavior.
   Keep it high-level — the milestones hold the detail. This is the shared mental model.

3. **Extra details list.** A list of any extra files in the plan with a short description.

4. **Milestones table.** A table listing every milestone with its number, file link, and a one-line
   description. This is the roadmap; tick them off as they complete.
   `| # | Milestone | File | Description |`

5. **Constraints & decisions.** Two things that belong together — "don't get this wrong" material:
   - **Cross-cutting invariants.** Shared helpers, invariants, or traps that every milestone must
     respect — the things most likely to go wrong. Call these out explicitly so no milestone drifts.
   - **Decisions.** Project-wide open questions, along with answers to them. Keep this list in sync
     as new decisions arrive mid-work.

6. **Working rules & validation.** The non-negotiable operating rules (see below) and how the project
   is validated — the formatter, compiler, tests, and builder for the step. Include the rule that
   every step must pass validation before it is committed.

## The milestone files (`plan/NN-slug.md`)

At **planning time**, a milestone is scoped to three parts — enough for a fresh agent to own it but
not so much that it pins down details that may change:

1. **Description (a few sentences).** What this milestone implements and *why it sits where it does*
   in the sequence — what it enables, what depends on it, why it is the smallest useful slice now.
   Call out which prior milestone it builds on. Flag the single most error-prone part.

2. **Acceptance (done criteria).** Bullet points that define "done" — observable, testable
   conditions that must hold before the milestone is marked complete, including what must be run to
   validate them (build, tests, a scratch repo, an offline path). Make them concrete (what the
   command does, how it degrades, what is testable offline vs. only against a live/authoritative
   system). Acceptance is the gate the executing agent uses, so keep it solid and unambiguous.

3. **Open questions.** Remaining uncertainties that a fresh agent would need resolved before it can
   start. When one is resolved, note the decision inline ("_Decided: …_") and/or fold it into the
   README's decisions section.

The granular, commit-sized **Steps** are expanded at the start of execution (see `executing.md`)
rather than at planning — this is the deliberate delay described below. Don't move a milestone's
open questions off the table prematurely; if a milestone can't start until its questions are
answered, say so.

## The working rules

These are the rules that make the pattern hold. Put them in every plan's README (README item 6):

- **Verify at every step.** Run the formatter, compiler, tests, and builder for each step and fix
  anything reported *before* you commit.
- **Commit every step as completed.** Each step is a standalone commit. Tick it in the milestone
  checklist when done. Never group multiple steps into one commit.
- **Keep milestones self-contained.** Each must compile and be ideally testable on its own; a stuck
  step shouldn't leave the tree broken.
- **Milestones run with a fresh agent.** Each milestone is small enough for one agent to tackle in a
  single session with a fresh context; design for that.
- **Never reference the plan in the main repo's commits.** No commit to the main repo should mention
  the plan, a milestone, or a step. Assume the plan is not available to future readers of the
  commits.
- **Mark milestones complete in the README** as soon as they are committed.
- **Keep the plan's history intact** — commit every change to the plan itself, so its own history is
  complete.

## Asking the user questions

When we ask the user a question during planning, don't just present an open problem:

- **Include suggestions.** Offer concrete options, not a blank question. The user should be able to
  pick or combine.
- **Recommend an answer.** Lead with the best option and give a short reason it wins. This keeps the
  conversation moving and gives the user something concrete to agree with or override.
- **Keep it answerable.** Frame questions so the user can respond in a line or two — they don't need
  to know the internals, just to judge the trade-offs.

## Raising problems in the plan

A plan is written from the user's guidance, so it will contain rough edges. When execution (or
planning) finds one, surface it rather than quietly papering over it:

- **Inconsistencies, contradictions, or blockers** in the plan — two milestones that pull against
  each other, a step that can't start until an earlier one is done when the plan implies otherwise,
  an Acceptance condition that can't be met — raise it with the user and ask what they want to do.
- **A milestone planning agent's own judgment** — if it thinks a milestone should be split, delayed,
  or reprioritised, it should ask the user rather than deciding for itself.
- **No silent scope changes.** A planning agent must not change another milestone without asking
  first, even if the change looks obviously right. Adjust only what was asked for, and flag anything
  else it would do differently.

## Delaying the step detail (why milestones have no steps yet)

The plan is written for execution by a different agent with a fresh context. Fixing every commit
detail up front wastes effort: details that never get built, and decisions made before the context
that would exist later. So planning defines **what** and **when** (Description + Acceptance), and
execution defines **how** (Steps). Each milestone therefore runs a `plan → execute → review` loop:
expand the milestone into commit-sized steps, work them one at a time, then review — all under a
fresh agent. Details can change over the course of execution without the plan being wrong.

The trade-off: **Acceptance must be concrete at planning** — it is the gate that tells the executing
agent when the milestone is done and what to validate, so it can't stay fuzzy.

## Copying the pattern for a new project

When planning a different project, keep the *structure* and *discipline* — don't drop the milestones
table, the acceptance gate, the per-commit steps, or the invariants/decisions capture. Adapt the
*content*: the "Verify at every step" commands to the project's toolchain (Rust → `cargo …`; Node →
`pnpm test`/`eslint`; etc.), and the milestone slicing to the project's natural seams. Not every
project needs a `layout.md` or a separate git repo — include those when they help.

## Anti-patterns to avoid

- **One giant milestone.** If a milestone file is a wall of uncommitted steps, slice it smaller.
- **Steps that aren't commits.** If steps don't each end in a commit, the tree isn't always shippable.
- **Hiding decisions.** Unwritten ad-hoc decisions made mid-work are lost; record them where the next
  agent will see them.
- **Coupling milestones.** A milestone that can't compile/test without a later one defeats the
  "always shippable" property.
- **Over-specifying.** A plan is a guide, not a contract. Leave room to resolve open questions
  sensibly on the fly.
