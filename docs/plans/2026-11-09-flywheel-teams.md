# flywheel-teams: plan of record

- **Date:** 2026-11-09
- **Owner:** Ryan Griffin
- **Status:** v1.1, bootstrap draft. Written on 2026-11-09 from four sources: the operator-overlay plan (v4.1, kept in the private engagement repository where the first client rollout is tracked), the July 2026 specifications for the flywheel profile, env reconciliation and gaps, the launcher scripts retired on 2026-10-14, and the 31 July 2026 review of beads shared by several people. One fresh-eyes review by a separate agent has been applied (section 13). No external-model review round has run yet; Ryan reviews this version next.
- **Tracking:** `fwt-*` beads in this repository (`br ready --json`, `bv --robot-triage`). The first client's rollout steps stay as beads in the engagement repository, which also keeps that client's doctrine seed. Nothing in this repository names a client.

## 1. Mission

flywheel-teams lets a person run the agent flywheel in repositories that other people also work in, without changing how the flywheel works for that person and without changing the repository for the other people.

The agent flywheel is the way of working built on Jeffrey Emanuel's tools: ntm for the swarm panes, beads (`br`) and `bv` for the work graph, Agent Mail for coordination between agents, dcg for command safety, and frankenterm as the terminal platform. Its doctrine lives in a committed `AGENTS.md`, its agents push verified commits to `main`, and its tracker is committed in `.beads/`. All of that assumes one operator in a repository they own, with no one else's agents reading the same files.

The project covers the situations that assumption leaves open:

1. **Overlay.** A repository the operator does not own, whose team has not adopted the flywheel. The doctrine cannot go in the team's instruction files, where their own agents would read it. Merging to `main` may deploy. The team keeps its own list of work. The operator overlay (M1) puts the doctrine in a local file both hosts load natively, keeps the team's files theirs, maps the swarm's trunk to a branch when `main` is the deploy, and gates every push.
2. **Team mode.** A repository the team owns, where several people each run the flywheel. Beads must merge through git without conflicts, claims must say who holds them, each person's swarm needs its own branch because Agent Mail is per machine, and contributors who never installed the flywheel must not be blocked by its guards. Team mode (M3) is the committed form of the same configuration.
3. **Transitions.** A team adopting the flywheel moves the doctrine from the local file into the committed one and uninstalls the overlay. An engagement ending leaves nothing behind but the committed beads. A person leaving releases their claims.

**Principle** (Ryan, 2026-10-24): once the overlay is installed and its config confirmed in a repository, running the flywheel there is just like running the flywheel anywhere. Every element in this plan maps to something the normal flywheel already does, or to a constraint the shared repository imposes. Anything else is removed or recorded in section 11 as a matter for the normal stack.

**Success** is observable per repository:

- `fwt doctor --live` is green on both hosts before a swarm runs.
- A swarm wave is pushed through the gate with no overlay or tooling file in any commit and no change to the team's instruction files.
- The agents followed no extra steps compared with a normal flywheel repository.
- For team mode: two people run swarms in one repository for a week with no beads conflict left for a human that the rule could have resolved, and no lost claim.

## 2. Who it is for

- First, Ryan at InStrand, running swarms in client repositories during engagements, and in his own template and product repositories where a second person now runs the flywheel.
- Then any flywheel operator who works in someone else's repository, or with others in the same one. The project is public and MIT licensed so that it can be installed with the same tools as the rest of the stack.

Non-goals: forking or replacing ntm, `br`, `bv`, Agent Mail, dcg or `ft`; changing the solo flywheel; process for its own sake; a hosted service or daemon; any runtime beyond bash and `jq` on the user's machine.

## 3. Vocabulary

| Term | Meaning here |
|---|---|
| Operator | The person running the flywheel in a repository. |
| Team | The people who own the repository and work in it without the flywheel. |
| Host | An agent CLI: Claude Code or Codex. |
| Terminal host | What runs the panes: ntm today, frankenterm when adopted. |
| Doctrine | The operator's flywheel rules, the content a normal `AGENTS.md` carries. |
| Instruction file | A file a host loads as instructions: `AGENTS.md`, `CLAUDE.md`, `CLAUDE.local.md`, `AGENTS.override.md`. |
| Default branch | The repository's `main` or equivalent. |
| Trunk | The branch the swarm treats as its `main`. Equal to the default branch in the normal flywheel. |
| Placement | Where the configuration lives: the overlay placement (local, excluded from git) or the team placement (committed). |
| Profile | The configuration in the team placement. |
| Guard | A PreToolUse hook that denies a tool call in a host. |
| Gate | A git `pre-push` hook that refuses a push. |
| Pack | A dcg rule pack. |
| Canary | A unique last line in the doctrine; a host that can quote it loaded the whole file. |
| Claim | `br update <id> --claim`, which sets the assignee to the actor and the status to in progress. |
| Ship bead | The last bead of a wave, whose job is to push the work or open its pull request (a term from the July 2026 profile specification). |

## 4. Decisions at bootstrap (2026-11-09)

Ryan's brief on 2026-11-09: make this a standalone project, set it up including the GitHub push, make the flywheel usable in it, and use expert judgement on the open decisions. The decisions taken under that brief, each reversible:

| # | Decision | Choice | Reason |
|---|---|---|---|
| D1 | Home | A standalone repository, `ryangriffinau/flywheel-teams`, rather than `tools/` in the skills repository. | One installer, one test suite, one version and one issue tracker for one capability. People outside Ryan's setup can install it. It is the shape the rest of the stack uses: tool in its own repository, thin skill in the library. |
| D2 | Name | Repository `flywheel-teams`; command `fwt`; beads prefix `fwt`. | Says what it is in the words flywheel users already use. `fwt` was free on PATH, npm and Homebrew on 2026-11-09, and the repository name was free on GitHub. `fw` is franken_whisper's binary, which the July specifications had assumed, so it is not used. |
| D3 | Licence | MIT. | The licence of Ryan's skills repository and of the tools this project composes. |
| D4 | Visibility | Public from the first push. | Ryan asked for an open-source project. The repository carries no client identifiers, and the pre-push hook refuses every push until a machine-level confidentiality list exists, then refuses any push whose commits or ref names contain a listed term (section 6.12). Going private later is one setting; going public later would still leave the history reviewable, so the gate exists from the first commit. |
| D5 | Team mode | In scope, as M3. Its specification (bead 19) and the beads-sharing tests (bead 20) can start now, because they are plan-space work. The build beads wait on M1's acceptance on the first client repository (bead 12). | The first client wave is the engagement's near-term need and sits on M1's path. Team mode has no customer waiting today beyond Ryan's own repositories, and its design depends on tests against the current `br`. |
| D6 | Configuration | One schema, a YAML subset with a stated grammar, in two placements: the frontmatter of `AGENTS.local.md` (overlay) and a committed `.flywheel/profile.yaml` (team). The legacy shell `.flywheel/profile` is read and migrated, never sourced. | The overlay already needs lists (protected paths, checks), which the shell format handles badly. One parser, one `doctor`, one set of keys. |
| D7 | Commands | `fwt init`, `fwt sync`, `fwt doctor [--live]`, `fwt uninstall` in M1; `fwt beads check`, `fwt init --team` and `fwt profile show` in M3. The earlier working name `flywheel-overlay` is retired. | One command for both placements keeps the principle: the same flywheel, configured for the repository it is in. |
| D8 | Client material | The first client's doctrine seed, rollout beads and GitHub-side proposal stay in the private engagement repository. This repository ships the generic template. | Confidentiality, and the template must not inherit one client's rules. |
| D9 | dcg | dcg stays per machine. A project `.dcg.toml` only enables packs for someone who already has dcg. Controls that must hold for everyone belong on the hosting platform's side and are the team's process decision, documented in section 6.5, not built here. | Verified with `dcg config` on 2026-11-09, which reports the project file as "enforcement-only". |
| D10 | frankenterm | Compatible by construction; `.ft/` and `ft.toml` join the excludes; the live check is an M2 bead. | Desk check of the README and source on 2026-11-09 (`docs/research/2026-11-09-frankenterm-compatibility.md`). |
| D11 | Codex size limit | `install.sh` sets `project_doc_max_bytes = 131072` in `~/.codex/config.toml` by default, after a backup and after showing the change. Ryan to confirm, because it changes a user's machine-level configuration. | Without it Codex truncates the generated file (section 6.1), and the operator's own 37 KB doctrines are already truncated today. |
| D12 | Shell guarding | Bash rules (`br agents --add`, redirects, `tee`, `sed -i` on protected files; hook bypass flags; worktrees) ship as dcg packs that `.dcg.toml` enables per repository. The PreToolUse guard handles only what dcg cannot see: Edit, Write, MultiEdit, NotebookEdit, `apply_patch`, and the refresh of a stale generated file. | dcg is the normal flywheel's shell guard. A second shell-command guard would be a mechanism the normal flywheel does not have. |

Decisions carried over from the overlay plan, made by Ryan on 2026-10-24 and 2026-11-09: install the machinery once per machine and keep it inert in a repository without configuration (O1); commit beads in the overlay repository (O2); in a repository whose `main` deploys, the trunk is a branch and the owner opens one pull request per wave or milestone into `main` (Q-A); the deploy guard is on for such repositories, with the condition that where the local layers are absent the team's own process must still handle deployment (Q-B).

## 5. Evidence

Facts the design rests on, with their source and date. Anything marked "re-verify" is a spike item (section 9, bead 1).

| Fact | Source |
|---|---|
| Claude Code loads `CLAUDE.md` plus `CLAUDE.local.md`, and an `@AGENTS.local.md` import inside it when that file is a real file, in `-p` mode too. When the imported file is a symlink resolving outside the repository, the import is not expanded. | Scratch repository probe, `claude -p`, 2026-10-24 |
| Codex reads one instruction file per directory: `AGENTS.override.md`, then `AGENTS.md`, then fallbacks. It follows a symlink. `project_doc_max_bytes` defaults to 32 KiB and applies to the combined size of `~/.codex/AGENTS.md` plus every directory's file on the path: Codex stops adding files once the combined size reaches the limit. `developer_instructions` did not surface in a probe. | Codex docs; scratch probe, `codex exec`, 2026-10-24; docs re-read 2026-11-09 |
| Claude Code reads `AGENTS.md` only when no `CLAUDE.md` or `CLAUDE.local.md` applies, unless the `instructionFiles` option of the built-in `cc-plugin-agents-md` plugin (set through `pluginConfigs`) is changed to `claude-md-and-agents-md`. | Claude Code memory docs, 2026-11-09 |
| Hook output is capped at 10,000 characters (Claude) and about 2,500 tokens (Codex), so hooks cannot carry a doctrine of normal size. | Hooks docs, 2026-10-24 |
| A normal doctrine is 27 to 37 KB (four of Ryan's repositories measured). | `wc -c`, 2026-10-24 |
| Both hosts accept the same PreToolUse deny JSON (`hookSpecificOutput.permissionDecision: deny`). The Codex matcher is a regular expression; `apply_patch` arrives as `apply_patch` with the patch text in `tool_input.command`. The existing agent-hooks installer merges one PreToolUse group per hook into `~/.claude/settings.json` and `~/.codex/hooks.json`, appends after existing groups because Codex trust keys are positional, and offers `--check`, `--dry-run` and `--uninstall`. | Codex hooks docs; `tools/agent-hooks/install.sh` in the skills repository |
| Git ignores `$GIT_DIR/hooks` when `core.hooksPath` is set. husky 9 sets it to `.husky/_` from a `prepare` script, so every `npm install` resets it. Seven of the thirty repositories under the operator's `~/Code/github` use husky. | `git help config`; repositories checked 2026-11-09 |
| Hosting platforms do not apply `.gitattributes` merge drivers when merging a pull request; a conflicting `issues.jsonl` must be merged locally. | GitHub community discussion 9288, checked 2026-11-09 |
| dcg 0.15.3: a project `.dcg.toml` is "enforcement-only" (it can enable packs, nothing else); custom packs are YAML under `~/.config/dcg/packs/` and listed in `[packs].enabled` of `~/.config/dcg/config.toml`; a pack has `destructive_patterns` with `pattern`, `explanation` and `denial_trailer`, and `safe_patterns`. dcg sees Bash only. | `dcg config`, pack files, 2026-11-09 |
| Ryan's normal doctrine: one tree and one branch, push by SHA (`git push origin <sha>:refs/heads/main`) through a pre-push gate that tests the pushed commit, never `git add -A`, never worktrees, agents and CI never write production, the owner deploys. | Template `AGENTS.md`, 2026-10-24 |
| The first client repository deploys to production on merge to `main`, and the operator's account has admin rights there, so the platform does not stop a push or merge by an agent acting with those credentials. Its team keeps one numbered list of open work and asked for no parallel list. | Read from the repository and its settings, 2026-10-24 and 2026-11-09 |
| Flywheel tooling writes `.ntm/`, `.bv/`, `.flywheel/`, `.doctor/` and `.agents/` into repository roots. frankenterm reads `.ft/` and `ft.toml` from the current directory. | Observed in Ryan's repositories; frankenterm README |
| frankenterm runs on its own terminal engine, treats ntm as adjacent tooling that spawns panes, keeps its work-claim queue in its own database, and has workflows that prompt agents to re-read `AGENTS.md` after compaction and at session start. ntm 1.37.2 has no `ft` backend. | README and source, 2026-11-09 |
| `br` 0.7.6: `br update --claim` is an atomic claim that sets the assignee to the actor and the status to in progress; the actor defaults to the login and `--actor` overrides it. `br sync --merge` is a three-way merge of `.beads/beads.base.jsonl`, the database and the JSONL, with `--force-db`, `--force-jsonl` and `--force` (newer timestamp) for semantic conflicts; the import guards reject conflict markers and invalid JSON and cannot be bypassed; `br coordination status` reports stale claims; `br sync` never runs git; there is no `source_repo_path` filter on `br ready` or `br list`. Root ids are `<prefix>-<hash>` and cannot collide across machines. | `br --help` family, 2026-11-09; multi-person review, 2026-07-31 |
| Child ids `<parent>.N` were a per-clone counter on `br` 0.2.x, so two clones adding a child to the same epic could both mint `.1`. Whether `br sync --import-only` rejects duplicate ids, and whether `br sync --flush-only` writes lines in a stable order, is untested. Re-verify (bead 20). | Retired launcher `references/setup.md` |
| Agent Mail is a per-machine localhost service. A swarm on one branch must not run on two machines at once. | Retired launcher `references/branching-model.md` |
| Ryan's template commits its guards for every contributor: husky `pre-commit` runs a file-reservation guard, staged lint, `ubs` and a secret scan; `pre-push` runs the full local gate on the pushed SHA and refuses moved refs. The template's reservation guard exits 1 when the Agent Mail runtime is missing unless `AGENT_MAIL_GUARD_MODE=warn`. | Template `scripts/ci/`, read 2026-11-09 |
| The July 2026 gaps specification required the reservation guard to "soft-pass with a one-line warning on machines WITHOUT the flywheel stack", so ordinary commits by teammates are never blocked. | `flywheel-gaps/PLAN.md` |
| Two of Ryan's repositories still carry a committed shell `.flywheel/profile` with `FLYWHEEL_MODE=team`. The scripts that read it were retired on 2026-10-14 with the launcher skill, superseded by the jsm `ntm` and `vibing-with-ntm` skills. The retired `setup` wrote `.gitattributes` with `.beads/issues.jsonl merge=union`. | Skills repository `deprecated/`, 2026-11-09 |
| A committed `.ntm/config.toml` once carried a machine-local absolute path into a shared repository. | `flywheel-gaps/PLAN.md`, item T3 |
| Codex loads a project-level `<repo>/.codex/hooks.json` once the project's `.codex/` layer is trusted, and `--dangerously-bypass-hook-trust` skips that trust. | Codex hooks docs, 2026-11-09 |

## 6. Design

### 6.1 Instructions in the overlay: `AGENTS.local.md`, loaded natively

- `AGENTS.local.md` at the repository root is the doctrine for this repository: the operator's normal flywheel sections, with `main` mapped to the trunk, plus a section about the team's files and process. It is a real file, because a symlink leaving the repository is not imported by Claude. It is excluded from git. Its seed and backup live wherever the operator keeps engagement material; `fwt init --seed <path>` copies it in and records the path, and `fwt sync` copies the live file back when run by hand. Without a seed, `init` fills `templates/AGENTS.local.template.md` from its arguments.
- **Claude Code:** a generated, excluded `CLAUDE.local.md` contains `@AGENTS.local.md`. When the team has only an `AGENTS.md`, it also contains `@AGENTS.md`, because a `CLAUDE.local.md` stops Claude reading `AGENTS.md` on its own. Claude loads the team's `CLAUDE.md` as usual.
- **Codex:** a generated, excluded file holds the team's instructions followed by `AGENTS.local.md` without its frontmatter, canary last. It is named `AGENTS.md` when the team has none, so that Codex reads it natively and every "read AGENTS.md" habit, including frankenterm's prompts, finds both the team's instructions and the doctrine. When the team has a tracked `AGENTS.md`, it is named `AGENTS.override.md`. Its first line is `<!-- fwt <version> generated; do not edit. sources: <team file> <git hash-object>, AGENTS.local.md <git hash-object>. Doctrine changes go in AGENTS.local.md. -->`. `git hash-object` is used because it exists wherever git does, while `sha256sum` does not exist on macOS.
- **Size:** the generated file is the team file plus the doctrine, 30 to 50 KB. The machine install raises Codex `project_doc_max_bytes` to 131072 (D11, section 6.8). `doctor` fails when the generated file plus `~/.codex/AGENTS.md` plus any instruction file in a parent directory exceeds the configured limit, because Codex applies the limit to the combined bytes.
- **Freshness:** `init` installs `post-checkout`, `post-merge` and `post-rewrite` hooks that run `fwt sync --quiet --no-seed`, so a pull that changes the team's file regenerates the Codex file. Doctrine edits by agents, normal flywheel behaviour, are picked up by `sync`, and by the guard, which refreshes a stale generated file on its next run. As with any `AGENTS.md`, changes reach new sessions and compactions, not a session's current context.
- **When the team adds an instruction file the overlay generates:** a `git pull` that would bring a tracked `AGENTS.md` into a checkout where the generated `AGENTS.md` sits untracked is refused by git before any hook runs. So the switch is not automatic. `doctor` warns when the fetched default branch adds such a file and prints the fix: `fwt sync --rename`, which renames the generated file to `AGENTS.override.md` (or removes a generated `CLAUDE.local.md` conflict) before the pull. If the team adopts `AGENTS.md` as its canonical file with `CLAUDE.md` as a one-line `@AGENTS.md`, that is the operator's conversation with the team, not an overlay requirement.

### 6.2 The team's files stay the team's: one guard and one pack

One PreToolUse hook, `hooks/agents-local-guard.sh`, installed once per machine for both hosts and inert unless `AGENTS.local.md` exists at the repository root:

- **Root and paths:** the repository root is `git -C "$(jq -r .cwd)" rev-parse --show-toplevel`; file paths resolve against `cwd`.
- **Denies edits** through Edit, Write, MultiEdit, NotebookEdit and Codex `apply_patch` (Add, Update, Delete and Move paths, parsed from `tool_input.command`) to any `AGENTS.md`, `CLAUDE.md` or `AGENTS.override.md` at any depth that `git ls-files --error-unmatch` reports as tracked, and to the two generated files at the root. The reason reads: "This repository's flywheel doctrine lives in AGENTS.local.md; the team's instruction files are theirs, and the generated files are rebuilt from it."
- **Refreshes** a stale generated Codex file (recorded hashes differ from the current sources) by running `fwt sync --quiet --no-seed` when `fwt` resolves on PATH, then allows the call; otherwise it leaves the file for `doctor` to report.
- **Fails open with no output** when `jq` is absent, the payload is not JSON, or `cwd` is not inside a repository; `doctor` reports the first two conditions.
- **Matchers:** Claude `Edit|Write|MultiEdit|NotebookEdit`; Codex `^apply_patch$`. Shebang `#!/bin/bash`, bash 3.2 compatible, because it is copied into `~/.claude` and `~/.codex` and runs without Homebrew.

The Bash side is a dcg pack, `packs/local.agents_local_guard.yaml` (D12): it denies `br agents` with `--add`, `--update` or `--remove`, which writes `AGENTS.md`, and shell writes (redirect, `tee`, `sed -i`) to the protected files. `init` enables it through the excluded `.dcg.toml` it writes in every overlay repository.

Why the guard exists: flywheel skills tell conductors to encode doctrine into `AGENTS.md` and to run `br agents --add`. In a normal repository that is correct. In an overlay it would put the doctrine in front of the team's own agents. This is the one behaviour the overlay has to redirect. Edits to `AGENTS.local.md` itself are allowed, as in any flywheel repository.

### 6.3 Local ignore rules

`init` appends to `.git/info/exclude`, between the marker lines `# >>> fwt >>>` and `# <<< fwt <<<`, which every worktree of the clone shares: the overlay's own files (`AGENTS.local.md`, `CLAUDE.local.md`, the generated Codex file, `.dcg.toml`); the tooling folders `.ntm/`, `.bv/`, `.flywheel/`, `.doctor/`, `.agents/`; and frankenterm's `.ft/` and `ft.toml`. `init` prints what it appended. `doctor` fails on any untracked, unignored top-level dot path, so new tooling folders are noticed before they are committed by mistake. `uninstall` removes only the marked block.

### 6.4 Beads, committed

`.beads/` is committed as in any flywheel repository, with the prefix the operator chooses. `init` adopts an existing `.beads/` or runs `br init --prefix`, and adds two files:

- `.beads/README.md`, from `templates/beads-README.md`: this is the operator's working tracker for their agents; the team's own list of open work stays where the team keeps it; nobody on the team needs to act on it; it is removed when the engagement ends if the team prefers.
- `.beads/.gitattributes` with `issues.jsonl linguist-generated=true`, so pull requests collapse the JSONL, and `issues.jsonl merge=union` so two clones adding different beads merge cleanly in local merges (section 6.10). The attribute always lives in `.beads/.gitattributes`, never in the team's root `.gitattributes`.

Nothing stops the team's agents using `br` here. What keeps them out is that nothing in their instructions or tooling points at it.

### 6.5 The git workflow: trunk, gate, deploy guard

- **Trunk.** The configuration names the branch the swarm treats as its `main`. In a repository whose `main` deploys on merge, that is a branch such as `<operator>/flywheel`. The doctrine's commands apply with the trunk substituted: `git push origin <sha>:refs/heads/<trunk>`. The operator opens one pull request per wave or milestone from the trunk into `main` and merges it. Merging is the deploy, so it stays the owner's, as `prod:deploy` does in the normal doctrine. Agents never open, approve or merge pull requests in the overlay placement.
- **Where the hooks go.** `init` installs the gate and the three sync hooks where git will run them. When `core.hooksPath` is unset and `.git/hooks/<name>` is absent, it writes `.git/hooks/<name>`. Otherwise it writes `.git/fwt-hooks/<name>`, a wrapper that runs the fwt check on a copy of stdin and then `exec`s the repository's own hook of the same name (from the previous `hooksPath`, or `.git/hooks`) with that stdin; sets `core.hooksPath` to `.git/fwt-hooks` in the clone's `.git/config`; and records the previous value under `fwt.teamHooksPath`. `uninstall` restores it. `doctor` fails when `core.hooksPath` no longer points at the wrapper directory, because husky's `prepare` script resets it on every `npm install`. The spike (bead 1) checks that husky's `.husky/_/<hook>` runner and lefthook tolerate being exec'd this way with stdin re-fed.
- **Pre-push gate.** The hook reads git's stdin (local ref, local SHA, remote ref, remote SHA), runs `git fetch --quiet origin` first (and warns when offline that the range may include upstream commits), and checks each pushed range: `<remote sha>..<local sha>`, or `<local sha> --not --remotes` for a new branch. Always: no overlay file or tooling folder in the commits; no change to the team's instruction files; no push to a protected branch (default: the default branch when a trunk is set). From the configuration: `protect_existing`, no modify, rename or delete of a matching path that exists at the merge base with `origin/<default>`, so an agent's own new files stay editable (the append-only migrations case); `prepush_checks`, each must exit 0, and an entry of the form `<glob> => <command>` runs only when the pushed commits touch matching paths. Declared checks run in a `git archive <sha>` extraction under `$TMPDIR` by default (`prepush_checks_in: archive`), so other agents' uncommitted edits in the shared tree are not what is tested; with `prepush_checks_in: worktree` they run in the working tree, and the gate refuses while `git status --porcelain` lists modified tracked files. On failure it prints the commit, the file and the check, and exits 1, with timings per check. Agents cannot skip it where the no-bypass pack is enabled: this project ships `packs/local.no_hook_bypass.yaml` (`git push --no-verify`, `git commit --no-verify` and `-n`, `SKIP_PREPUSH_VERIFY=`), which `install.sh` copies and `.dcg.toml` enables in every overlay repository.
- **Deploy guard** (optional, per repository, `deploy_guard: true`). A dcg pack, `packs/local.deploy_on_merge_guard.yaml`, enabled by the same `.dcg.toml`. It blocks `gh pr merge`, `gh api` calls to a `pulls/<n>/merge` path, `gh workflow run`, and the deploy commands of common platforms (`supabase functions deploy`, `supabase db push`, `netlify deploy`, `vercel --prod`, `wrangler deploy`, `convex deploy`). Each denial reads: "deploys go through the owner; approve once with `dcg allow-once <code>` if intended". It exists because the gate cannot see API merges and the platform will not refuse an admin's credentials.
- **Limits of the local layers.** The doctrine, the gate and the packs protect production from the operator's agents on the operator's machines, and from nobody else's. dcg is per machine; a project `.dcg.toml` only enables packs for someone who already has dcg. Where these layers are absent or switched off, the team's own process must still handle deployment. That means controls on the hosting platform's side, which apply to every person and every agent whatever their local tooling: a branch ruleset on `main` requiring a pull request with a review and the existing checks, with no bypass for administrators; and required reviewers on the production environment, with the deploy job declaring that environment, so a merge queues a deployment that a named person approves. These are the team's decisions. `fwt doctor` reports whether the default branch has such protection when `gh` is on PATH and authenticated, and says "not checked" otherwise. The tool does not set them.

### 6.6 Configuration: one schema, two placements

The schema is this YAML subset, parsed by `lib/config.sh`: a key is `[a-z][a-z0-9_-]*`; `key: value` splits on the first `: `; a value is a bare scalar, a single-quoted scalar, `true`, `false`, an integer, `[]`, a flow list `[a, b]` of bare scalars, or a block list of `  - item` lines; a `#` preceded by a space starts a comment, so a command containing `#` is single-quoted; no multi-line scalars, nesting, anchors or duplicate keys. Unknown keys, duplicates and anything else are rejected with the file and line number. A `prepush_checks` entry splits on the first ` => `. The version key is `flywheel-teams`; `doctor` reports the pre-release spelling `agents-local` and `sync` rewrites it. `fwt --version` is stamped in every generated header and installed hook; `doctor` warns when a stamp differs from the running version, and `sync` regenerates.

The same keys are valid in both placements. Keys marked M3 are parsed from M1 but used from M3.

```yaml
---
flywheel-teams: 1                 # schema version
owner: Ryan Griffin (InStrand)    # overlay only: who the doctrine speaks for
trunk: instrand/flywheel          # the branch the swarm treats as main; default: the default branch
protect_branches: [main]          # pushes refused; default: the default branch when trunk differs
protect_existing:                 # existing matching paths may not change (append-only areas)
  - db/migrations/*
prepush_checks:                   # each must exit 0; "<glob> => <cmd>" runs only when the glob is touched
  - npm test
  - db/* => scripts/check-migrations.sh
prepush_checks_in: archive        # archive (default) | worktree
deploy_guard: true                # enable packs/local.deploy_on_merge_guard.yaml for this repository
ship: owner                       # M3. owner: the operator opens PRs by hand (overlay default)
                                  #     agents: the ship bead opens the PR ready and merges per `merge`
merge: approval                   # M3. when-green | approval
reservation_guard: advisory       # M3. required | advisory, for the committed pre-commit guard
---
```

Placements:

- **Overlay:** the frontmatter of `AGENTS.local.md`, local and excluded. The frontmatter is stripped from the generated Codex file; Claude sees it through the import, which is harmless. `init` records `fwt.seed`, `fwt.trunk` and `fwt.generated` (the generated file's name) in the clone's `.git/config`.
- **Team:** a committed `.flywheel/profile.yaml`. `trunk` is not committed in this placement: each person's swarm runs on its own branch (section 6.10), so the trunk is the clone's current branch at `init`, recorded in `.git/config` under `fwt.trunk`. `.flywheel/profile.yaml` is the one tracked file under `.flywheel/`; everything else there stays ignored.
- **Legacy:** the shell `.flywheel/profile` (`FLYWHEEL_MODE`, `FLYWHEEL_WORKTREES`, `FLYWHEEL_PRECOMMIT`, `FLYWHEEL_PREPUSH`, `FLYWHEEL_PROJECTION_APP`, `FLYWHEEL_PROJECTION_TEAM`, `FLYWHEEL_ENV_REQUIRED`) is parsed, never sourced, and `fwt init --team` offers to write the YAML form beside it. Appendix A gives the mapping. Projection and env keys are carried as opaque values until Ryan decides in M4 whether those features return.

`doctor` fails while the doctrine still contains a `{{PLACEHOLDER}}` or an `<!-- fwt: -->` marker, so a half-filled template never reaches a swarm.

### 6.7 The command: `fwt`

Bash plus `jq`, at `bin/fwt`, with the shared code in `lib/`. Exit codes: 0 healthy, 1 findings, 2 could not run. Every command takes `[<repo>]` (default: the current repository) and `--json` where output is structured.

| Command | What it does |
|---|---|
| `fwt init [<repo>] --prefix <p> [--seed <path>] [--trunk <branch>] [--default-branch <b>] [--owner "..."] [--owner-short <name>] [--team-name "..."] [--trunk-reason "..."]` | Idempotent. Seeds `AGENTS.local.md` (from `--seed` or the template), replacing a symlink with a real copy and keeping the canary last. Writes `CLAUDE.local.md` and the Codex file. Appends the excludes. Sets up `.beads/` with README and attributes. Installs the git hooks as section 6.5 says. Writes `.dcg.toml` enabling the guard, no-bypass and no-worktrees packs, plus the deploy guard when configured. Records `fwt.seed`, `fwt.trunk` and `fwt.generated`. A re-run with a changed flag rewrites that frontmatter key and reports it. Ends by running `doctor`. |
| `fwt init --team [<repo>]` | M3. Writes `.flywheel/profile.yaml` (or migrates the legacy profile), `.beads/.gitattributes`, the committed guard set, and the per-clone settings; runs `doctor`. |
| `fwt sync [<repo>] [--quiet] [--no-seed] [--rename]` | Regenerates `CLAUDE.local.md` and the Codex file from current sources. Without `--no-seed`, when `fwt.seed` is set and the path exists, copies `AGENTS.local.md` to it and prints the destination; when the path is missing it says so and exits 0. `--rename` switches the generated file to `AGENTS.override.md` before a pull that brings a tracked `AGENTS.md`. The hooks call `fwt sync --quiet --no-seed`. |
| `fwt doctor [<repo>] [--live] [--json]` | Checks everything `init` set up: files present and current, combined Codex size within the limit, excludes in place, no stray dot path, `.beads/` tracked or ready to commit, guard installed (`install.sh --check`), packs enabled, git hooks ours and `core.hooksPath` still pointing at them, current branch is the trunk, no applying Claude settings file sets the `instructionFiles` option to `claude-md-and-agents-md`, no placeholder left in the doctrine, version stamps current, whether `ft` is installed and its paths excluded, whether the fetched default branch adds an instruction file the overlay generates, and whether the default branch has platform-side protection (information). `--live` adds the proof below. |
| `fwt uninstall [<repo>]` | Reverses `init`: `sync` first so the seed is current, then removes the local files, the marked exclude block, `.dcg.toml` and its hooks, restoring `core.hooksPath` from `fwt.teamHooksPath`. Committed beads stay. |
| `fwt beads check [<repo>] [--fix]` | M3. Finds duplicate ids and conflict markers in `.beads/issues.jsonl` after a merge, applies the newest-`updated_at` rule for duplicates, and leaves true same-bead edits for a human with the exact lines. Runs from the `post-merge` hook. |
| `fwt profile show [<repo>] --json` | M3. The resolved configuration: schema keys, placement, trunk, default branch, and the derived ship behaviour. |

Derived values at `init`: `DEFAULT_BRANCH` from `refs/remotes/origin/HEAD` unless given; `REPO_NAME` from the remote URL, else the directory name; `OWNER_SHORT` the first word of `--owner` unless given; `CANARY` is `canary-` plus eight hex digits from `od -An -N4 -tx1 /dev/urandom`; `TEAM_FILES` is the list of tracked instruction files found at the root, or `none`; `GENERATED_FILE` follows from it.

**`doctor --live`.** The guarantees should be evidence, not configuration, because native loading has quiet failure modes: a symlinked file Claude will not import, a Codex file truncated by the size limit, a stale generated file, an untrusted Codex hook. So:

1. In the repository, ask `claude -p` and `codex exec` for the canary on the last line of `AGENTS.local.md`. A correct answer proves each host loaded the whole doctrine natively; for Codex it also proves the file was not truncated.
2. Ask Codex for a known line from the team's file, proving the team instructions are in the generated file.
3. In a throwaway copy with a local bare remote: ask each host to push to the protected branch, which the gate must refuse; ask each host to edit the team's instruction file, which the guard must deny; remove what a failed probe created. Hosts run with the flags the spike records (for example `claude -p --permission-mode acceptEdits --allowedTools "Bash(git push *)"` and `codex exec --full-auto`), and a probe passes only when the gate's own refusal line or the guard's own reason appears in the transcript, so a host's permission prompt cannot pass for a refusal.
4. Report each host's result with the exact fix. Transcripts, which include the team's instructions, are logged under `${XDG_STATE_HOME:-~/.local/state}/flywheel-teams/` with mode 0600.

### 6.8 Machine install, once

`install.sh` links `bin/fwt` into `~/.local/bin`, registers the guard for both hosts with the agent-hooks installer's guarantees (merge by command path, append after existing groups, timestamped backups, idempotent, `--check`, `--dry-run`, `--uninstall`), copies the packs into `~/.config/dcg/packs/` without enabling any, and sets `project_doc_max_bytes = 131072` in `~/.codex/config.toml` (D11): the edit inserts the line before the first `[` line with `awk`, after a timestamped backup, only when the key is absent or lower; a symlinked `config.toml` is left alone and the line to add is printed, and `--check` returns 1 until it is present. Codex hooks must be trusted interactively in `/hooks`; the installer prints the step and `doctor` detects an untrusted hook. Nothing it installs does anything in a repository without configuration.

### 6.9 Terminal hosts: ntm today, frankenterm when adopted

frankenterm sits beside the agent CLIs: it observes and controls panes, reacts to events and keeps its own robot API, but it does not change how Claude Code or Codex load instructions, run hooks or use git, which is everything this project relies on. The only change is excluding `.ft/` and `ft.toml`. Its compaction and session-start workflows prompt agents to re-read `AGENTS.md`, which in an overlay repository is the generated file, so they land on the right content; that is one more reason to generate a real `AGENTS.md` rather than rely on `CLAUDE.local.md` alone. Not yet checked live, because `ft` was not installed on the machine used and ntm has no `ft` backend: the M2 bead runs `doctor --live` under `ft`, observes a compaction, and checks that `ft robot work` claims and `br` claims do not drift apart.

### 6.10 Team mode (M3)

Several people, each running the flywheel, in a repository the team owns. The design below is a proposal for Ryan to confirm in the M3 specification bead; it reuses the July 2026 decisions where they still hold and changes them where the stack has moved.

**Branch model.** Agent Mail is per machine, so a swarm on one branch must never run on two machines. Each person runs their swarm on their own workstream branch, which is that clone's trunk. The default branch is protected. Work reaches it by pull request: with `ship: agents`, the ship bead opens the PR ready (never draft, so CI and previews run), enables auto-merge when the repository supports it, and merges when green for changes the profile marks safe or waits for approval otherwise (`merge: when-green | approval`); the agent never block-polls CI. With `ship: owner`, the operator opens the PR by hand, as in the overlay. This keeps the solo flywheel's practices, one tree, leases, no worktrees, push by SHA, and changes only the last step: one pull request per workstream instead of a push to `main`.

**Beads shared through git.** `.beads/issues.jsonl` is one id-keyed record per line. `.beads/.gitattributes` with `merge=union` makes two clones adding different beads merge without a custom driver in local merges, pulls and rebases, and it works for teammates who never installed anything. It does not apply to a pull-request merge on the hosting platform, which ignores merge drivers: a workstream branch is rebased on the default branch locally before its pull request opens, or beads commits go to the default branch directly (bead 19 decides). A genuine same-id edit on both sides leaves two lines; whether `br sync --import-only` rejects duplicate ids, and whether the export order is stable, is tested in bead 20. `fwt beads check`, run by the `post-merge` hook, resolves duplicates by newest `updated_at` and leaves true conflicts for a human, which is the split `br sync --merge` already implements, applied at the git layer. Rules for people: commit `issues.jsonl` often and small, `br sync --flush-only` before committing, never hand-write a union-merge script.

**Actors on claims.** Every claim is `br update <id> --claim --actor <name>`, where the name is the Agent Mail name or the person's; a claim always has an assignee, because `--claim` sets it from the actor, so the check is on the name. The conductor runs `br coordination status` at wave start and releases stale claims by rule, not by hand. `doctor` fails when an in-progress bead's assignee is not a name in the Agent Mail roster or the profile's people list.

**Guards every contributor gets.** A committed pre-commit guard set, installed by the repository's own hook mechanism (husky, lefthook or `core.hooksPath`), with nothing depending on `fwt` being installed. The file-reservation guard honours `reservation_guard`: `required` exits 1 when the Agent Mail runtime is missing (the template's current behaviour), `advisory` prints one warning and passes (the July rule), and the team decides which. Codex users get the committed guard through `<repo>/.codex/hooks.json`, which Codex loads once the project's `.codex/` layer is trusted. The secret scan and lint stay the team's own. Machine-local paths never enter tracked files: `doctor` scans tracked tooling config for absolute home paths.

**Encode-time resolution.** Workers never read the profile. The conductor prompt reads it once when beads are encoded and writes the mode-specific behaviour into the ship bead, so each bead is self-contained. This project supplies the resolver (`fwt profile show --json`) and the ship-bead text; the conductor skill decides how to use them, in coordination with the maintained `p-flywheel-conductor-jsm`.

**Acceptance.** Two people run swarms in one repository for a week: no beads conflict left for a human that the rule could have resolved, no lost claim, no tooling file in a commit, CI green on a no-op PR. This repository and Ryan's template repository are the first two, subject to his answer on the decisions bead; this repository first needs `.gitignore` to track `.flywheel/profile.yaml` (done at bootstrap) and its `AGENTS.md` branch rule changed to per-person trunks for the week.

### 6.11 Transitions

- **Adoption.** The doctrine moves from `AGENTS.local.md` into the team's `AGENTS.md` through a normal pull request, the team installs the stack, then `fwt uninstall` removes the overlay and `fwt init --team` writes the committed profile. Beads stay where they are.
- **Engagement end.** `fwt uninstall`. The committed beads remain as history unless the team asks for their removal, which is the owner's deletion to make.
- **A person leaving.** `br coordination status`, release their claims, remove their workstream branch after its PR merges.

### 6.12 Confidentiality in a public project

Everything committed here is public. The repository never carries a client's name, repository or project identifiers, the names of people at a client, or client data. The pre-push hook refuses every push until a machine-level term list exists at `${XDG_CONFIG_HOME:-~/.config}/flywheel-teams/confidential-terms` (override with `FWT_CONFIDENTIAL_TERMS`) holding at least one term or the single line `no-terms`; then it refuses any push whose outgoing commits (diffs and messages) or ref names contain a listed term, ignoring case, with carriage returns stripped from the list. The list lives outside every repository, so one list covers all of an operator's public repositories and the terms themselves never reach GitHub. `scripts/dev-setup.sh` creates it empty; the operator fills it.

## 7. Repository layout, standards and contributions

`AGENTS.md` is the authority for agents working here. In short: `bin/fwt`, `lib/`, `hooks/` (the guard and `hooks/git/` templates), `packs/`, `templates/`, `install.sh`, `skill/` (M2), `test/`, `docs/`. Bash 3.2 compatible so the macOS `/bin/bash` runs the hooks; `jq` is the only parser; `shellcheck` clean; installers idempotent with backups and `--check`; no em dashes anywhere; plain language in every message an agent will read.

Outside contributions arrive as pull requests from forks; Ryan merges after the workflow is green. `main` takes direct pushes only from Ryan and his agents, each through the pre-push gate, so no branch ruleset requiring checks is placed on `main` (it would refuse the direct pushes the flywheel relies on).

## 8. Testing

- **Unit tests** in `test/*.test.sh`, run by `test/run.sh`, which fails on an empty suite and runs each test under the PATH bash and, when it is version 3.2, under `/bin/bash` too. Each test creates temporary repositories under `$TMPDIR`, with a local bare remote where pushes are involved.
- **The pre-push hook** runs `test/run.sh` from a `git archive <sha>` extraction of each pushed tip in `$TMPDIR`, so the pushed commit is what is tested, not the working tree.
- **Continuous integration:** a GitHub Actions workflow runs `test/run.sh` on `ubuntu-latest` and `macos-latest`, the second with `/bin/bash` 3.2 present, on every push and pull request.
- **Negative-control mutants** under `test/mutants/`: a guard that allows `CLAUDE.md` edits, a gate that skips `protect_branches`, a generator that omits the team's instructions, an installer that prepends its group, a pack without the `gh pr merge` rule, a parser that sources the file. Each must be caught by its test.
- **Fixtures** for both hosts' PreToolUse payloads (Claude `tool_input.file_path`, Codex `apply_patch` paths in `tool_input.command`, Bash `tool_input.command` as a string), dated, with a note when a host changes shape.
- **Live acceptance** with `FWT_TEST_LIVE=1`: `doctor --live` in a scratch repository, then on the first client checkout, then from a clean machine for the installer (M2).
- **Shape matrix** for the overlay: a team with `CLAUDE.md` only, `AGENTS.md` only, both, neither; and a repository with `core.hooksPath` set by husky.

## 9. Milestones and work breakdown

Each numbered item becomes one bead. Dependencies are stated; the graph must stay acyclic.

### M0: bootstrap (2026-11-09)

Written on 2026-11-09: the repository files (`AGENTS.md`, `README.md`, MIT licence, ignores and attributes, the pre-push hook with the confidentiality check and the archive-based test run, `test/run.sh` and the first test, `scripts/dev-setup.sh`, the doctrine template, the frankenterm note, the specs index, the CI workflow, this plan). M0 is complete when the beads of this section exist (`br ready --json` lists beads 1, 19 and 28 and the decisions bead; 5 waits on 1 and 20 on 19), the first commit is on `main`, the first push to `ryangriffinau/flywheel-teams` has passed the pre-push hook with a filled term list, and bead 28 confirms the workflow is green on both runners.

28. **CI confirmed.** After the first push, the workflow has run green on `ubuntu-latest` and `macos-latest`; if not, fix and re-run. Depends on nothing.

### M1: the operator overlay, accepted on the first client repository

1. **Spike: host behaviours.** Verify and record, with fixtures: PreToolUse denies take effect under ntm's permission-skipping flags for both hosts; Codex reads a 40 KB generated `AGENTS.md` in full with the raised limit (canary last); Codex reads `AGENTS.override.md` in place of a tracked `AGENTS.md`; which Claude subagent types and Codex spawned agents see `CLAUDE.local.md` and the local `AGENTS.md`; whether both hosts still hold the doctrine after compaction and on resume; whether `post-checkout`, `post-merge` and `post-rewrite` cover pull, rebase and checkout and whether a Codex session started right after a pull sees the fresh file; whether a project `.dcg.toml` enables a custom pack not enabled at user level and whether an unknown pack name leaves dcg working; the exact payload shapes; whether husky's `.husky/_/<hook>` runner and lefthook tolerate being exec'd from `.git/fwt-hooks` with stdin re-fed; the permission flags that let `claude -p` and `codex exec` attempt a push and an edit for `doctor --live`. Location independent; no dependencies.
2. **Library.** `lib/`: repository root and placement detection, the YAML-subset parser (section 6.6 grammar) with line-numbered errors, legacy profile reader, placeholder filling and leftover detection, hash-stamped generation with `git hash-object`, exclude management with markers, hook installation including the `core.hooksPath` wrapper, `.git/config` keys, version stamps, state directory. Depends on 1 for payload and hook facts.
3. **Guard hook** `hooks/agents-local-guard.sh` with its tests and a mutant that allows `CLAUDE.md` edits. Depends on 2.
4. **`install.sh`** with the agent-hooks installer's guarantees, pack delivery, the Codex limit change (D11), and tests including a mutant that prepends. Depends on 3.
5. **dcg packs** `local.agents_local_guard`, `local.no_hook_bypass`, `local.no_worktrees` and `local.deploy_on_merge_guard`, with blocked and allowed fixtures, compound commands, inside and outside a repository with `.dcg.toml`, and a mutant without the merge rule. Depends on 1 (project-layer enabling).
6. **`fwt init` and `fwt sync`** with the git hooks (both placements of them), the beads setup, the excludes, `.dcg.toml`, the recorded keys, `--no-seed` and `--rename`, and the four repository shapes plus the husky shape. Depends on 2 and 7; the final `doctor` call is wired in 8.
7. **Pre-push gate** `hooks/git/pre-push`, configured from the schema, with the fetch, the archive mode, one fixture per check, path-conditioned checks, a new-branch push, and a mutant that skips `protect_branches`. Depends on 2.
8. **`fwt doctor`** (static) with exit codes and JSON, including the combined Codex size, the `hooksPath` check, the `instructionFiles` key, version stamps and the rename warning. Depends on 4, 5, 6 and 7.
9. **`fwt doctor --live`.** Depends on 3, 4, 5 and 8.
10. **`fwt uninstall`** including `hooksPath` restoration. Depends on 6.
11. **Template finalised.** Placeholders complete and filled from the derived values, `doctor` fails on leftovers, `templates/README.md` current. Depends on 6.
12. **Operator install and first acceptance.** Ryan installs on his machine, trusts the Codex hook, runs `fwt init` with the client seed on the first client checkout, `doctor --live` passes on both hosts, beads are committed on the trunk through the gate, and a small wave is pushed. The client-specific steps are tracked privately; this bead records the generic outcome. Depends on 4, 9, 10 and 11.
13. **Docs for M1.** README usage, `CHANGELOG.md`, troubleshooting. Depends on 12.

### M2: packaged for others

14. **Skill.** `skill/flywheel-teams/SKILL.md` for `ryangriffinau/skills` with its catalogue row, status drafting, pointing at `install.sh`. Depends on 13.
15. **Fresh-machine install.** `install.sh` from a clean user account with honest exit codes: preflight that fails when a tool is missing, setup that reports what changed, verify that returns 1 when incomplete. Depends on 4 and 13.
16. **Second-repository trial** using only the docs; fix what slowed the trial; promote the skill to refining if it held. Depends on 14 and 15.
17. **frankenterm live check**: `doctor --live` under `ft`, a compaction observed, the session-start prompt does not lead to an edit of the generated file, claim drift checked, `doctor` reports `ft`. Depends on 9, and on Ryan installing `ft`.
18. **Release v0.1.0** with a tag, changelog and the installer tested from the tag. v0.1.0 ships without 17; the README says the frankenterm check is open. Depends on 16.

### M3: team mode

19. **Specification confirmed.** Ryan confirms or amends section 6.10: branch model, `ship` and `merge` semantics, `reservation_guard` policy, whether beads commits go to the workstream branch or the default branch given that platform merges ignore merge drivers, the committed file name, the resolver's contract with the conductor skill. Records the decisions on the bead. Depends on nothing; can start now. Blocks every other M3 bead.
20. **Beads sharing tests on the current `br`:** child id collision across two clones, duplicate lines after a union merge and what `br sync --import-only` does with them, export line order of `br sync --flush-only`, `br sync --merge` behaviour on duplicates, fresh-clone bootstrap, claims from two clones under `br coordination status`. Depends on 19.
21. **`fwt beads check`** and the `post-merge` hook, with fixtures from 20 and a mutant that keeps the older record. Depends on 20 and 12.
22. **Committed profile placement:** `fwt init --team`, legacy migration, `fwt.trunk` per clone, `.beads/.gitattributes`, `doctor` for the team placement including the machine-local path scan and the assignee check. Depends on 6, 8, 12 and 19.
23. **Committed guard set:** the reservation guard with `required` and `advisory` modes, installation through husky, lefthook or `core.hooksPath`, the Codex project hooks file, and tests for the stack-absent path. Depends on 12 and 19.
24. **Resolver and ship bead text:** `fwt profile show --json` and the mode-specific ship bead paragraphs, handed to the conductor skill. Depends on 22.
25. **Adoption walkthrough:** overlay to team on a scratch repository, documented step by step and tested. Depends on 22 and 10.
26. **First use in our own repositories:** this repository and Ryan's template repository run team mode for a week with two people; findings fixed. Depends on 21, 23, 24 and 25.
27. **Docs for M3** and release v0.2.0. Depends on 26.

### M4 candidates, undecided

The human-owned env store (`flywheel-env`), the Linear projection (`beads-linear-map`, `beads-linear-sync`) that Ryan's template still names as the human view of beads, a cross-repository portfolio view, and hardening of hook-disabling routes. Each has retired code to start from (Appendix B). Ryan decides after M3 whether any returns.

## 10. Risks and open questions

| Risk or question | Handling |
|---|---|
| A host changes its hook payload or instruction loading. | Dated fixtures; `doctor --live` catches it in the field; the spike records versions. |
| Codex hook trust is interactive, so no installer can finish it. | The installer prints the step; `doctor` detects an untrusted hook; the machine-install bead is Ryan's. |
| A repository's `core.hooksPath` (husky, lefthook) makes a hook in `.git/hooks` inert, and `npm install` resets it. | The wrapper directory and the `doctor` check in section 6.5; the husky shape in the test matrix. |
| Child ids collide across clones on the current `br`. | Tested first in M3 (bead 20); if they do, `fwt beads check` resolves and the docs say to create children from one clone or use root ids. |
| Platform pull-request merges ignore `merge=union`. | Rebase locally before the PR, or beads commits to the default branch (bead 19). |
| Agent Mail is per machine. | The branch model makes it a rule, not a surprise: one person, one branch, one machine. |
| Teammates without the stack are blocked by committed guards. | `reservation_guard: advisory`; the team chooses. |
| A client term reaches the public repository. | The pre-push term gate, which refuses pushes until the list exists, plus review before each push; the list is maintained per machine. |
| Pre-push gates slow pushes. | Checks are path-conditioned; the gate prints timings. |
| This plan has had one internal review and no external-model round. | Ryan's review next, then the review prompts from the planning workflow; beads are re-polished after each round. |

Questions for Ryan, in the bootstrap decisions bead: confirm D2 and D4 (name and public), which were acted on under his brief and are reversible by rename or by making the repository private; confirm D5 (M3 build after M1 acceptance) and D11 (the installer sets the Codex limit); say whether the Linear projection should return as M4; say whether this repository should be the first team-mode repository.

## 11. Normal-stack findings (not this project's work)

Found during the overlay reviews; they apply to every flywheel repository and belong in the operator's normal safety stack: a repository's `.claude/settings.local.json` with `disableAllHooks` turns off every hook including dcg, as does `claude --settings '{"disableAllHooks": true}'`, Codex `features.hooks=false` or Codex `--dangerously-bypass-hook-trust`; dcg cannot see MCP calls (Codex `node_repl`, connectors, the Artifact tool); Claude's `EnterWorktree` and worktree isolation bypass a Bash-only no-worktrees rule; `git stash --all` removes ignored files; Codex `project_doc_max_bytes` at its default truncates a 37 KB doctrine today; `~/.claude/CLAUDE.md` writing its import inside backticks never expands it; `.ft/` and `ft.toml` belong in every flywheel repository's `.gitignore`, and `ft robot work` claims need checking against `br` claims for drift. Recorded here so they are not lost; tracked by Ryan outside this project.

## 12. Relationship to the engagement repository

The private engagement repository keeps: the first client's doctrine seed (the operator's `AGENTS.local.md` for that checkout), the rollout beads (bring the checkout up to date, create the trunk, first acceptance, first wave, review the doctrine), and the proposal to that team about platform-side deployment controls. Its overlay plan v4.1 remains the record of how the design was reached, including what v3 contained and why each part changed. Its tooling beads (spike, guard, installer, pack, init and sync, gate, doctor, live doctor, uninstall, skill, trial, frankenterm) are closed there with a pointer to their `fwt` counterparts, so nothing is tracked twice.

## 13. Validation record

- **Principle check:** every element in section 6 maps to a normal-flywheel behaviour or a shared-repository constraint; the exceptions are listed in section 11. D12 moved the shell rules into dcg packs for this reason.
- **Grounding:** native loading probed on both hosts (2026-10-24); doctrine sizes measured; dcg's project layer read from `dcg config`; `br` 0.7.6 command surface read; the template's guards and the retired scripts read in full on 2026-11-09; frankenterm checked from its README and source; the Codex size-limit semantics, the `instructionFiles` key and the platform merge-driver behaviour checked against the docs during the fresh-eyes review.
- **Fresh-eyes review:** one round by a separate agent on 2026-11-09, 25 findings, applied in place; see the changelog entry.
- **Not done:** external-model review rounds; the spike; any live run under `ft`.

### Changelog

- **2026-11-09, v1.0:** first version, written at bootstrap.
- **2026-11-09, v1.1:** fresh-eyes review applied. Hooks installed through a `core.hooksPath` wrapper when a repository sets it (6.5); the term gate refuses pushes until a list exists, strips carriage returns and scans ref names (6.12, D4); tests run on the pushed commit and the suite fails when empty (8); the schema version key is `flywheel-teams`, with a stated grammar and version stamps (6.6); generated-file header and `git hash-object`, combined Codex size (6.1); the `AGENTS.override.md` switch is a manual `sync --rename` because git refuses the pull first (6.1); `init` inputs, derived values and recorded keys (6.7); gate fetch, archive mode and `gh` dependency (6.5); the guard's root, matchers and fail-open rules, with the Bash rules moved to dcg packs (6.2, D12); generic no-bypass and no-worktrees packs shipped (6.5); the Codex config edit specified and recorded as D11 (6.8); platform merges ignore merge drivers and the `br` duplicate-id behaviour is a test, not a fact (6.10); `br` claim and filter facts corrected (6.10, Appendix B); live probe flags, pass criterion and log permissions (6.7); the `instructionFiles` key named (6.7); CI workflow and the outside-contributor path (7, 8, bead 28); `.gitignore` tracks `.flywheel/profile.yaml`; dependency edges corrected in section 9; M0 restated as completion criteria; wording fixes under the owner's writing rules.

## Appendix A: legacy profile mapping

| Legacy key (shell `.flywheel/profile`) | Schema key | Note |
|---|---|---|
| `FLYWHEEL_MODE=solo` | `ship` not set; trunk is the current branch | Solo is the normal flywheel. |
| `FLYWHEEL_MODE=team` | `ship: agents`, `merge: approval` | The July text: PR ready, merge when green for safe changes, else with approval. `merge: when-green` is the explicit opt-in. |
| `FLYWHEEL_WORKTREES=false` | (constant) | Worktrees are never allowed; `packs/local.no_worktrees.yaml` enforces it where enabled. |
| `FLYWHEEL_PRECOMMIT=light|heavy` | not carried | The team's own hooks decide what pre-commit runs. |
| `FLYWHEEL_PREPUSH=full|none` | `prepush_checks` (empty list for none) | |
| `FLYWHEEL_PROJECTION_APP`, `FLYWHEEL_PROJECTION_TEAM` | carried as `projection.app`, `projection.team`, unused | Ryan decides in M4. |
| `FLYWHEEL_ENV_REQUIRED` | carried as `env_required`, unused | Ryan decides in M4. |
| `.flywheel/projects.tsv` | untouched | Belongs to the projection, M4. |

## Appendix B: retired launcher scripts and their fate

| Script | What it did | Fate |
|---|---|---|
| `flywheel-profile.sh` | Resolved the shell profile into variables, validating each value, never sourcing. | Replaced by `lib/config.sh` and `fwt profile show --json` (M3), same validation stance. |
| `flywheel-link.sh` (`preflight`, `bootstrap`, `link`, `setup`, `verify`, `list`) | Repository integration: `br init`, ntm init, husky lease guard, profile scaffold, ignores, `merge=union`, `AGENTS.md` check. | `fwt init --team` and `doctor` take over the repository integration; `install.sh` takes over preflight and verify with honest exit codes (M2). |
| `flywheel-kickoff.sh` | Printed the `ntm spawn` recipe with the mode baked into the init prompt. | The conductor skill owns spawning; `fwt` supplies the resolver output and ship-bead text (M3). |
| `file-reservation-guard.sh` (archived, soft-pass) | Pre-commit lease check for every contributor, passing with a warning when the stack is absent. | Returns as the committed guard with `reservation_guard: required|advisory` (M3). |
| `flywheel-ready.sh` | Filtered `br ready` to beads owned by this clone. | Not carried; `br ready --assignee` and `bv --robot-triage` cover it, and `br` 0.7.6 has no `source_repo_path` filter. Revisit if multi-clone machines need it. |
| `beads-linear-map`, `beads-linear-sync` | Linear project per epic, one-way status projection, idempotent and fail-open. | M4 candidate. |
| `flywheel-env` | Human-owned secret store with precedence and `FLYWHEEL_ENV_REQUIRED`. | M4 candidate. |
| `flywheel-remediate.sh` | Decommission audit and `.ntm/` untracking. | Its lessons are `doctor` checks (machine-local paths in tracked files, tooling folders ignored). |
