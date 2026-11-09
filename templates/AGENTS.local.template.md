---
flywheel-teams: 1
owner: {{OWNER}}
trunk: {{TRUNK}}
protect_branches:
  - {{DEFAULT_BRANCH}}
protect_existing: []
prepush_checks: []
deploy_guard: false
---

# AGENTS.local.md: {{REPO_NAME}} (operator overlay)

The durable law of this checkout for {{OWNER_SHORT}}'s agents, Claude or Codex, solo or in a swarm. It plays the part
`AGENTS.md` plays in any flywheel repository. This repository belongs to {{TEAM}}, whose team does not use the flywheel,
so this file lives only in this checkout and the team's instruction files stay theirs. General rules live in
`~/.agents/AGENTS.md`. The team's own instruction files, if it has any ({{TEAM_FILES}}), are also loaded and bind you
in full. Re-read this file after context compaction.

---

## RULE 0 - THE FUNDAMENTAL OVERRIDE PREROGATIVE

If I ({{OWNER_SHORT}}) tell you to do something, even if it goes against what follows below, YOU MUST LISTEN TO ME.

## RULE NUMBER 1: NO FILE DELETION

**YOU ARE NEVER ALLOWED TO DELETE A FILE WITHOUT EXPRESS PERMISSION.** Even a new file that you yourself created. List
files or folders you think should go and ask for clear, written permission. Moving, renaming and restoring files is
allowed. Where the team's own rules are stricter, they apply: a deletion request goes to {{OWNER_SHORT}}, who takes it to
the team.

Agent-owned artefacts (screenshots, captures, scratch configs, fixture output, evidence files) may be replaced or removed
by the agent that produced them. Source code, docs, beads and other agents' files stay under RULE 1.

## Irreversible Git & Filesystem Actions: DO NOT EVER BREAK GLASS

1. **Absolutely forbidden commands:** `git reset --hard`, `git clean -fd`, `rm -rf`, or any command that can delete or
   overwrite code or data, unless {{OWNER_SHORT}} provides the exact command and states in the same message that the
   irreversible consequences are understood and wanted.
2. **No guessing.** If you are unsure what a command might delete or overwrite, stop and ask.
3. **Safer alternatives first.** In the shared tree, `git stash` takes every agent's uncommitted work: never run it. Never
   `git restore` or `git checkout` a file you did not author.
4. **Restate and confirm** any authorised destructive command verbatim, with what it affects, before running it, and
   record the authorising text, the command and the time.

---

## This checkout and the team's process

- **Instruction files.** The team's instruction files ({{TEAM_FILES}}) are the team's. Never edit one, and never
  create or edit a tracked `AGENTS.md` or `CLAUDE.md`. `{{GENERATED_FILE}}` in this checkout is generated from them
  plus this file so that Codex sees both: never edit it, and never run `br agents`. Flywheel doctrine changes go in this file. A skill or prompt that says to put
  doctrine in `AGENTS.md` means this file here.
- **The trunk.** The swarm's trunk is the branch `{{TRUNK}}`, and everything the flywheel normally does on `main`
  happens there. {{TRUNK_REASON}} {{OWNER_SHORT}} opens pull requests from the trunk into `{{DEFAULT_BRANCH}}` and merges
  them: merging is the deploy, and deploying is always the owner's action. Never push to `{{DEFAULT_BRANCH}}`, and never
  open, approve or merge a pull request.
- **Production.** Agents never write production: no deploy commands, no database or function changes against a live
  project, no MCP writes to it. Ask before anything that touches a production environment.
- **The team's rules that agents most often break** (source: {{TEAM_FILES}}):
  <!-- fwt: replace this list with the team's own rules, each with the file and line it comes from. doctor fails while this marker remains. -->
  - {{TEAM_RULE_1}}
- **The pre-push gate** runs on every push and refuses: overlay or tooling files in a commit, changes to the team's
  instruction files, pushes to a protected branch, edits to protected existing paths, and a red declared check. Treat a
  refusal as a defect in the commit, not an obstacle. Never bypass it.

---

## The shared tree (Agent Flywheel)

- **One working tree, one branch (`{{TRUNK}}`). NEVER create or use git worktrees.** Agents coordinate by reserving
  files through Agent Mail before they edit, using this checkout's absolute path as the project key.
- **Beads is the swarm's tracker** (prefix `{{PREFIX}}`, committed in `.beads/`). It is the operator's working tracker,
  not the team's own list of work, which stays wherever the team keeps it.

The loop, per bead:

1. Pick: `bv --robot-triage` (never bare `bv`; it opens a TUI) or `br ready`. Confirm with `br show <id> --json`. Claim
   with `br update <id> --claim`. Take the highest-priority ready bead, not the most comfortable one.
2. Reserve every file you will edit through Agent Mail, with the bead id in the reason.
3. Implement with tests. Run the team's own checks that cover your change, and review your own diff with fresh eyes.
4. Commit and push (rules below), then mail the conductor the bead id, the commit SHA and a short evidence line. The
   conductor closes the bead (Honest credit).

Committing in a tree that other agents are editing at the same moment:

- The index is shared. Never `git add -A` or `git add .`, and never clear or unstage a peer's entries.
- Before you stage, run `git status` and `git diff <file>` on every path, and stage only files you touched in this
  session. Run `git status` again immediately before every commit.
- Commit as your Agent Mail name, with explicit paths: `AGENT_NAME=<MailName> git commit -m "<scoped message>" -- <paths>`.
  Brand-new files: `git add -- <new paths> && AGENT_NAME=<MailName> git commit -m "<scoped message>" -- <paths>`.
  Never bypass a hook.
- Commit messages cite the bead id.
- Set `GIT_EDITOR=:` and `GIT_SEQUENCE_EDITOR=:` for rebases. Never amend without written approval.
- Commit as soon as your unit verifies.
- Fetch your Agent Mail inbox right before every push and honour any push hold. Push the verified commit by SHA:
  `git push origin <sha>:refs/heads/{{TRUNK}}`.
- Never revert, restore or overwrite a peer's in-progress work; report a contaminated commit instead.

Tools: `br`, `bv` (robot flags only), `ntm`, Agent Mail, `cass`, `ubs`, and `dcg` (it blocks destructive commands;
follow its safer alternative).

---

## Honest credit (binding for agents and humans alike)

The purpose of agent work here is working, deployable capability. Process serves that outcome and never becomes the
product.

- **Closes come only from the conductor, after independent review.** Never close your own bead or a peer's. Never close a
  red bead: if verification is blocked, leave the bead open and name the blocker on the bead and in Agent Mail.
- **Real code and real tests ship in the same bead.** Forbidden: faked tests, weakened assertions, goldens regenerated to
  match broken output, hard-coded success paths, editing the spec instead of implementing it, and narrowing scope while
  claiming full success.
- **Every behaviour carries a planted negative that must fail.** A fix that changes guards, permissions or RPC behaviour
  ships with a test that fails before the fix and passes after it.
- **No fixture presented as live proof.** When the live route is blocked, the bead says BLOCKED and names the missing
  thing.
- **Never weaken a gate to get green.** Do not edit a check, baseline, allowlist or tolerance so a failing change passes.
- **Evidence is what the command examined.** Never silence stderr in a command you cite. A run over zero files or zero
  tests is not a pass.
- **Security findings** are described by location and impact, never as a working exploit, and never with secrets,
  tokens or personal data in a bead.
- **Solo session, no conductor:** close only after re-running the bead's tests and planted negatives against its original
  acceptance criteria, with a close reason that says "solo: self-verified, not independently reviewed".

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
- Session end: `git status`, stage your own paths, `br sync --flush-only`, commit, fetch your inbox, push to the trunk.

Overlay canary: {{CANARY}}
