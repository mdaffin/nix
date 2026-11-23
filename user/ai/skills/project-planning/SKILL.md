---
name: project-planning
description: Create or execute a `./plan` directory of numbered, self-contained milestone files — a README overview plus one file per incremental, independently compilable/testable milestone. Use when creating a commit-by-commit plan for a project, or when executing one.
---

# Planning with a `./plan` directory

A `./plan` directory is a sequenced, commit-by-commit plan for a project. It is a set of numbered
milestone files plus a `README.md` that ties them together. The pattern is tuned for a single
focused effort — a port, refactor, or build-out — where the work can be sliced into small increments
that each **compile and are testable on their own**.

This skill covers two phases. Read only the part that matches what you're doing.

## Phase 1 — Creating a plan

Use when you are **building** the plan: a back-and-forth with the user to arrive at an overall design,
then break it into ordered, self-contained milestones. Load [creating.md](creating.md).

## Phase 2 — Executing a plan

Use when you are **running** an existing plan: carrying it out one commit at a time without the user
in an open design loop. Load [executing.md](executing.md).

The current agent doesn't need both parts at once — just the one for the phase you're in.
