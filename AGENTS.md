# AGENTS.md: flywheel-teams

The durable law of this repository for agents, Claude or Codex, solo or in a swarm. General rules
live in `~/.agents/AGENTS.md`. Re-read this file after context compaction.

---

## RULE 0 - THE FUNDAMENTAL OVERRIDE PREROGATIVE

If I (Ryan) tell you to do something, even if it goes against what follows below, YOU MUST LISTEN TO ME.

## RULE NUMBER 1: NO FILE DELETION

**YOU ARE NEVER ALLOWED TO DELETE A FILE WITHOUT EXPRESS PERMISSION.** Even a new file that you yourself
created. List files or folders you think should go and ask for clear, written permission. Moving, renaming
and restoring files is allowed.

Agent-owned artefacts (screenshots, captures, scratch configs, fixture output, evidence files) may be
replaced or removed by the agent that produced them. Source code, docs, beads and other agents' files
stay under RULE 1.

## Irreversible Git & Filesystem Actions: DO NOT EVER BREAK GLASS

1. **Absolutely forbidden commands:** `git reset --hard`, `git clean -fd`, `rm -rf`, or any command that
   can delete or overwrite code or data, unless Ryan provides the exact command and states in the same
   message that the irreversible consequences are understood and wanted.
2. **No guessing.** If you are unsure what a command might delete or overwrite, stop and ask.
3. **Safer alternatives first.** In the shared tree, `git stash` takes every agent's uncommitted work:
   never run it. Never `git restore` or `git checkout` a file you did not author.
4. **Restate and confirm** any authorised destructive command verbatim, with what it affects, before
   running it, and record the authorising text, the command and the time.

---

## This repository

- flywheel-teams is a public, MIT-licensed project owned by Ryan Griffin. Everything committed here is
  public. Never commit a client's name, a client's repository or project identifiers, the names of people
  at a client, or any client data. Say "the first client repository" or "a client monorepo". The pre-push
  hook refuses every push until the machine-level file
  `${XDG_CONFIG_HOME:-~/.config}/flywheel-teams/confidential-terms` (`FWT_CONFIDENTIAL_TERMS` overrides
  the path) holds a term or the line `no-terms`, then refuses any push whose commits or ref names
  contain a listed term. `scripts/dev-setup.sh` creates it; keep it current. It then runs
  `test/run.sh` on the pushed commit.
- The plan of record is `docs/plans/2026-11-09-flywheel-teams.md`. Work is tracked as `fwt-*` beads in
  `.beads/`. Dated desk checks live in `docs/research/`, with their sources. Specifications imported from
  earlier work live in `docs/specs/` and are source material, not the plan.
- Everything a user installs is bash plus `jq`, runs under the macOS `/bin/bash` (3.2) as well as a
  current bash, and is `shellcheck` clean. The hooks run inside Claude Code and Codex, so they must start
  fast, read all of stdin, and never print anything but the hook JSON the hosts accept.
- This repository runs the normal flywheel on itself: beads prefix `fwt`, trunk `main`, Agent Mail with
  this checkout's absolute path as the project key. When team mode (M3) exists, this repository adopts it
  first.
- Outside contributions arrive as pull requests from forks; Ryan merges after the CI workflow is green.
  `main` takes direct pushes only from Ryan and his agents, each through the pre-push gate.

### Layout

| Path | Holds |
|---|---|
| `bin/fwt` | The CLI entry point |
| `lib/` | Shared bash library: repository root, frontmatter, file generation, excludes, hooks |
| `hooks/` | The PreToolUse guard for both hosts, and the git hook templates under `hooks/git/` |
| `packs/` | dcg packs the project ships, enabled only where a repository asks for them |
| `templates/` | The doctrine template, the beads README, the Claude import file |
| `install.sh` | Machine install: links the CLI, registers the guard, delivers the packs, raises Codex `project_doc_max_bytes`; `--check`, `--dry-run`, `--uninstall` |
| `skill/` | The thin skill published to `ryangriffinau/skills` (M2) |
| `test/` | `run.sh`, `*.test.sh`, `fixtures/`, `mutants/` |
| `docs/` | `plans/`, `research/`, `specs/` |
| `.github/workflows/test.yml` | CI: `test/run.sh` on Ubuntu and macOS on every push and pull request |

---

## Project Mission

flywheel-teams lets a person run the agent flywheel (Claude Code and Codex swarms under ntm or
frankenterm, with beads, Agent Mail and dcg) in repositories that other people also work in, without
changing how the flywheel works for that person and without changing the repository for the other people.
The flywheel was designed for one operator in a repository they own. This project covers the situations
that design leaves open:

1. A repository the operator does not own, whose team has not adopted the flywheel (the operator
   overlay). The doctrine lives in the operator's checkout only, the team's instruction files stay
   theirs, and the deploy boundary is respected.
2. A repository the team owns, where several people each run the flywheel (team mode). Shared beads
   merge without conflicts, claims carry the actor, and the git flow is the team's.
3. The transitions between them: a team adopting the flywheel, and an engagement ending.

Principle (Ryan, 2026-10-24): once the overlay is installed and its config confirmed in a repository,
running the flywheel there is just like running the flywheel anywhere.

### Milestones

1. M0, bootstrap (2026-11-09): this repository, the plan and the beads; complete when the first push is
   on GitHub and the CI workflow is green on both runners.
2. M1, operator overlay, accepted on the first client repository: `fwt init`, `sync`, `doctor --live`
   and `uninstall`; the guard hook; the pre-push gate; the optional deploy-guard pack; the machine
   install. Known when `init` plus `doctor --live` pass on that checkout and a swarm wave is pushed through
   the gate.
3. M2, packaged for others: the skill, the installer from a clean machine, a second-repository trial
   using only the docs, the frankenterm live check, release v0.1.0.
4. M3, team mode: the merge driver for `.beads/issues.jsonl`, actor-tagged claims, the committed
   profile (the same config schema as the overlay frontmatter, in the team placement), the
   pull-request flow, and a committed guard set every contributor gets. Known when two people run
   swarms in one repository for a week without a beads conflict or a lost claim.

### Non-goals

- Forking or replacing any flywheel tool. ntm, br, bv, Agent Mail, dcg and ft stay as they are; this
  project configures and composes them.
- Changing the flywheel's doctrine for a solo operator in their own repository.
- Process for its own sake. Every element must map to something the normal flywheel already does, or to
  a constraint the shared repository imposes.
- A hosted service, a daemon, or anything that needs a runtime beyond bash and jq on the user's machine.

---

## Who decides

Ryan decides: the mission and the plan of record; what is published, released and versioned; the content
of the doctrine template (it carries his rules); deleting files (RULE 1); anything that changes a user's
machine-level configuration by default; which client repository is used for acceptance.

Within a bead, the working agent or the conductor decides implementation details: structure, tests,
fixtures, tool choices, bead mechanics. Record each decision and its reason on the bead and report it as a
decision Ryan may veto.

A question for Ryan is one of his decisions or a fact only he knows. Ask it as one short question in the
reply, record it on the bead, and keep working on everything else.

---

## The shared tree (Agent Flywheel)

- **One working tree, one branch (`main`). NEVER create or use git worktrees.** Agents coordinate by
  reserving files through Agent Mail before they edit, using this checkout's absolute path as the project
  key.
- **Beads is the tracker** (prefix `fwt`, committed in `.beads/`).

The loop, per bead:

1. Pick: `bv --robot-triage` (never bare `bv`; it opens a TUI) or `br ready`. Confirm with
   `br show <id> --json`. Claim with `br update <id> --claim`. Take the highest-priority ready bead, not
   the most comfortable one.
2. Reserve every file you will edit through Agent Mail, with the bead id in the reason.
3. Implement with tests. Run `test/run.sh` and review your own diff with fresh eyes.
4. Commit and push (rules below), then mail the conductor the bead id, the commit SHA and a short evidence
   line. The conductor closes the bead (Honest credit).

Committing in a tree that other agents are editing at the same moment:

- The index is shared. Never `git add -A` or `git add .`, and never clear or unstage a peer's entries.
- Before you stage, run `git status` and `git diff <file>` on every path, and stage only files you touched
  in this session. Run `git status` again immediately before every commit.
- Commit as your Agent Mail name, with explicit paths:
  `AGENT_NAME=<MailName> git commit -m "<scoped message>" -- <paths>`. Brand-new files:
  `git add -- <new paths> && AGENT_NAME=<MailName> git commit -m "<scoped message>" -- <paths>`. Never
  bypass a hook.
- Commit messages cite the bead id.
- Set `GIT_EDITOR=:` and `GIT_SEQUENCE_EDITOR=:` for rebases. Never amend without written approval.
- Commit as soon as your unit verifies.
- Fetch your Agent Mail inbox right before every push and honour any push hold. Push the verified commit
  by SHA: `git push origin <sha>:refs/heads/main`. The pre-push hook runs the tests and the
  confidentiality check; a refusal is a defect in the commit.
- Never revert, restore or overwrite a peer's in-progress work; report a contaminated commit instead.

Tools: `br`, `bv` (robot flags only), `ntm`, Agent Mail, `cass`, `ubs`, `shellcheck`, and `dcg` (it
blocks destructive commands; follow its safer alternative, never work around it).

---

## Honest credit (binding for agents and humans alike)

The purpose of agent work here is working, installable capability. Process serves that outcome and never
becomes the product.

- **Closes come only from the conductor, after independent review.** Never close your own bead or a
  peer's. Never close a red bead: if verification is blocked, leave the bead open and name the blocker on
  the bead and in Agent Mail.
- **Real code and real tests ship in the same bead.** Forbidden: faked tests, weakened assertions,
  goldens regenerated to match broken output, hard-coded success paths, editing the spec instead of
  implementing it, and narrowing scope while claiming full success.
- **Every behaviour carries a planted negative that must fail.** A guard, a gate check or an installer
  guarantee ships with a negative-control mutant under `test/mutants/` that the test must catch.
- **No fixture presented as live proof.** `doctor --live` results come from the real CLIs. When the live
  route is blocked, the bead says BLOCKED and names the missing thing.
- **Never weaken a gate to get green.** Do not edit a check, baseline, allowlist or tolerance so a failing
  change passes.
- **Evidence is what the command examined.** Never silence stderr in a command you cite. A run over zero
  files or zero tests is not a pass.
- **Security findings** are described by location and impact, never as a working exploit, and never with
  secrets, tokens or personal data in a bead.
- **Solo session, no conductor:** close only after re-running the bead's tests and planted negatives
  against its original acceptance criteria, with a close reason that says "solo: self-verified, not
  independently reviewed".

---

## Code rules

- Every script starts with `#!/usr/bin/env bash` and `set -euo pipefail`, except hook scripts installed
  into a host's home, which use `#!/bin/bash` so they run without Homebrew. Both must pass under bash 3.2:
  no `mapfile`, no associative arrays, no `${var,,}`.
- `jq` is the only parser. No Python, Node or Rust at runtime. YAML frontmatter is the small subset the
  template uses (scalars and one-level lists), parsed by the shared library, and `doctor` rejects anything
  else.
- Installers never edit a user's config without a timestamped backup, are idempotent, append new hook
  groups after existing ones (Codex trust keys are positional), and offer `--check`, `--dry-run` and
  `--uninstall`. These are the guarantees of the existing agent-hooks installer; keep them.
- A hook's deny output is the JSON both hosts accept:
  `{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"..."}}`.
  Reasons tell the agent what to do instead. Stay well under 10,000 characters (Claude) and about 2,500
  tokens (Codex).
- Nothing in this project circumvents dcg, a git hook, or a host's permission system, and nothing adds a
  rule that the normal flywheel does not have for the same situation.
- Temporary repositories for tests live under `$TMPDIR`; tests never touch a real repository or the user's
  `~/.claude` or `~/.codex`.
- Plain language everywhere, including comments and denial messages. No em dashes. Australian English in
  docs. Do not call something built, done, secure or synced before it is.

---

## Testing

- `test/run.sh` runs every `test/*.test.sh` under the PATH bash and, when `/bin/bash` is 3.2, under it
  too, then `shellcheck` over the scripts. An empty suite fails. The pre-push hook runs it from a
  `git archive` of the pushed commit; green is the bar for every push.
- Each test file creates its temporary repositories, with a local bare remote where pushes are involved,
  and removes only what it created.
- Live probes with `claude -p` and `codex exec` are opt-in with `FWT_TEST_LIVE=1`, because they cost
  tokens and need both CLIs. They are the acceptance tests, not the unit tests.
- Fixtures for both hosts' hook payloads live in `test/fixtures/`. When a host changes its payload shape,
  the fixture changes with a dated note.

---

## Docs

- `README.md` is for users and stays honest about status. The plan is for builders. `CHANGELOG.md`
  records each release.
- Writing rules for anything a reader outside this session will see: plain language, no em dashes, no
  invented labels, no figurative phrasing, no deferred naming ("to be listed later"), and no overclaiming
  words.

---

## Where to look

| Question | Where |
|---|---|
| What are we building and why | `docs/plans/2026-11-09-flywheel-teams.md` |
| What is ready to work on | `br ready --json`, `bv --robot-triage` |
| What the doctrine template says | `templates/AGENTS.local.template.md` |
| What frankenterm changes | `docs/research/2026-11-09-frankenterm-compatibility.md` |
| Earlier team-mode specs | `docs/specs/` |

---

## Beads quick reference

```bash
bv --robot-triage                 # start here: ranked picks, quick wins, blockers, health
bv --robot-next                   # the single top pick and its claim command
br ready --json                   # unblocked work
br show <id> --json               # full bead, with dependencies
br update <id> --claim            # claim
br create --title="..." --type=task --priority=2
br dep add <issue> <depends-on>   # <issue> waits on <depends-on>
br comments add <id> "evidence or decision, with its reason"
br sync --flush-only              # export the DB to .beads/issues.jsonl
```

- Priority is a number: 0 critical, 1 high, 2 medium, 3 low, 4 backlog.
- Swarm workers never run `br close`; see Honest credit.
- Session end: `git status`, stage your own paths, `br sync --flush-only`, commit, fetch your inbox, push
  to `main` by SHA.
