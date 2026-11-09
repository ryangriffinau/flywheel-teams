# frankenterm and the operator overlay: compatibility check

- **Date:** 2026-11-09
- **Asked by:** Ryan, 2026-11-09: does the overlay stay compatible with flywheels run under frankenterm, which has the same foundational process?
- **Sources:** the frankenterm README (296 KB, fetched 2026-11-09 from `Dicklesworthstone/frankenterm`, default branch `main`, last pushed 2026-11-09), the repository tree, `install.sh`, and the workflow handlers in `crates/frankenterm-core/src/workflows/`. Nothing was run live: `ft` was not installed on the machine used, and ntm 1.37.2's help mentions no `ft` or WezTerm backend.
- **Related:** the plan of record, section on terminal hosts, and the M2 bead for the live check.

## What frankenterm is (facts from its README and source)

- `ft` describes itself as "a swarm-native terminal platform designed to observe, control, and audit large fleets of concurrent AI coding agents". It runs on its own vendored terminal engine, an in-tree fork of WezTerm's mux, termwiz and term crates. It is not an abstraction over other multiplexers: "use cases that require driving a different mux backend (tmux, Zellij, kitty)" are listed under "when ft might not be ideal". Its glossary still lists `tmux:<socket>` as a possible pane domain, inherited from WezTerm.
- Its parts: a watcher that captures pane output into SQLite with full-text search; a pattern engine that detects events such as compaction, usage limits, auth prompts and session end; built-in workflows that react to those events; a policy gate for the actions `ft` itself takes (send, wait-for, missions, transactions); a JSON robot API, an MCP server and a web API; a native macOS app and an iOS client.
- It positions `ntm` as adjacent tooling: "ft is the swarm-native terminal platform; ntm handles pane spawning + lifecycle for the agent fleet."
- It integrates with the stack the flywheel already uses: beads (`br`, `bv`), Agent Mail reservations, `cass` and `rch`. Incident bundles include a snapshot of `.beads/issues.jsonl`. Its own work-claim queue (`ft robot work`) lives in its SQLite database, not in `.beads/`.
- Configuration precedence: `--config`; then `$FT_WORKSPACE/.ft/config.toml`, `.ft/ft.toml` or `ft.toml`; then the same three names in the current directory; then the platform default under `~/Library/Application Support/ft/` on macOS or `~/.config/ft/` elsewhere. Data lives in `~/.local/share/ft`. Mission contracts default to `.ft/mission/active.json`.
- The installer verifies a signed release and places `ft`, the mux server and the PTY guardian under `~/.local/bin`. The README says `cargo install` is not an installation path.
- Two built-in workflow handlers refer to `AGENTS.md`. `HandleCompaction` fires on `session.compaction` detections; the source comment says "the agent may have lost important project context, so we prompt the agent to re-read key files like AGENTS.md". `HandleSessionStartContext` builds a prompt that ends "Keep AGENTS.md + README.md + current bead acceptance criteria in focus" and "If uncertain on next work, run: bv --robot-triage".

## What the overlay touches, and whether ft touches the same thing

| Overlay element | Depends on | ft's effect |
|---|---|---|
| `AGENTS.local.md`, `CLAUDE.local.md`, the generated `AGENTS.md` | How Claude Code and Codex load instruction files | None. `ft` does not launch the agent CLIs or change their configuration. Its compaction and session-start prompts name `AGENTS.md`, which in an overlay repository is the generated file (team instructions plus doctrine), so the prompts land on the right content. |
| The guard hook (PreToolUse on both hosts) | The agent CLIs' hook systems | None. `ft`'s policy gate governs `ft`'s own actions, not shell commands inside an agent. dcg stays the shell guard. |
| Local excludes | `.git/info/exclude` | One addition. `ft` reads `.ft/` and `ft.toml` from the current directory, so both need excluding or they would appear as untracked files in the team's repository. |
| Committed beads | `br` and git | None found. `ft` reads `.beads/issues.jsonl` for incident bundles; its claims live in its own database. |
| The pre-push gate | git hooks | None. |
| The deploy-guard dcg pack | dcg | None. |
| The trunk mapping | The doctrine and the gate | None. |

## Judgement

- The overlay is compatible with `ft` by construction, because `ft` sits beside the agent CLIs rather than between them and the repository. The one concrete change is the two excluded paths, now in the plan and in the `init` bead.
- `ft` strengthens the case for generating a real `AGENTS.md` in overlay repositories. Its re-read prompts assume a real `AGENTS.md` at the workspace root. A design that relied on `CLAUDE.local.md` alone would have missed them.
- Not verified live, so these stay open until `ft` is installed: that the compaction prompt reaches a Claude pane and the agent re-reads the generated file; that `ft robot work` claims and `br update --claim` do not drift apart in a swarm (a matter for the normal flywheel stack, not the overlay); and how panes are launched, since ntm has no `ft` backend today. These form the M2 live-check bead.
- The same conclusion holds for any flywheel repository: `.ft/` and `ft.toml` belong in the tooling paths its `.gitignore` carries.
