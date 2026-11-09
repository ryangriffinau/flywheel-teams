# flywheel-teams

Run the agent flywheel in repositories you share with other people.

The agent flywheel is the way of working built around Jeffrey Emanuel's tools:
[ntm](https://github.com/Dicklesworthstone/ntm) for the swarm panes,
[beads](https://github.com/Dicklesworthstone/beads_rust) and
[bv](https://github.com/Dicklesworthstone/beads_viewer) for the work graph,
[Agent Mail](https://github.com/Dicklesworthstone/mcp_agent_mail) for coordination,
[dcg](https://github.com/Dicklesworthstone/destructive_command_guard) for command safety, and
[frankenterm](https://github.com/Dicklesworthstone/frankenterm) as the terminal platform. It assumes one
operator in a repository they own. flywheel-teams covers the situations that assumption leaves open.

## Status

Planning. Nothing is installable yet. The plan of record is
[docs/plans/2026-11-09-flywheel-teams.md](docs/plans/2026-11-09-flywheel-teams.md), and the work is
tracked as `fwt-*` beads in `.beads/` (`br ready`).

## The three situations

1. **Overlay.** A repository you do not own, whose team has not adopted the flywheel. Your doctrine cannot go in
   their `AGENTS.md`, where their own agents would read it, and merging to their `main` may deploy. The
   operator overlay puts the doctrine in a local `AGENTS.local.md` that Claude Code and Codex load
   natively, keeps the team's files theirs with one guard, maps the swarm's trunk to a branch when `main`
   is the deploy, and gates every push.
2. **Team mode.** A repository your team owns, where several people run the flywheel. Beads must merge without
   conflicts, claims must say who holds them, and the git flow is the team's rather than one person's
   push to `main`. Team mode is the committed form of the same configuration.
3. **Transitions.** A team adopting the flywheel moves the doctrine from the local file into the
   committed one and uninstalls the overlay. An engagement ending leaves nothing behind but the committed
   beads.

Principle: once the overlay is installed and its config confirmed in a repository, running the flywheel
there is just like running the flywheel anywhere.

## What it will install

Per machine, once: the `fwt` command, one PreToolUse guard hook for both hosts, and an optional dcg pack
that stays off until a repository asks for it.

Per repository: `fwt init` writes the local files, the excludes, the git hooks and the beads setup;
`fwt doctor --live` proves both hosts loaded the doctrine and that the gates hold, before any swarm runs;
`fwt sync` keeps the generated files current; `fwt uninstall` reverses it.

## Roadmap

| Milestone | Scope |
|---|---|
| M1 | The operator overlay, accepted on the first client repository |
| M2 | Packaged for others: skill, installer, second-repository trial, frankenterm live check, v0.1.0 |
| M3 | Team mode: beads merge driver, actor-tagged claims, committed profile, pull-request flow, committed guards |

## Contributing

Read `AGENTS.md` first; it is the contract for agents and people alike. Run `scripts/dev-setup.sh` once
after cloning; it activates the pre-push gate and creates the machine-level confidentiality term list,
which must hold a term or the line `no-terms` before any push. `test/run.sh` must pass before every push,
and the CI workflow runs it on Ubuntu and macOS.

## Licence

MIT. Copyright (c) 2026 Ryan Griffin.
