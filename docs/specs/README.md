# Specifications this project builds on

The team-mode design in the plan of record (section 6.10) reuses decisions from three specifications
written in July 2026 for the flywheel launcher skill, and from one review. They live in Ryan's public
skills repository and are referenced, not copied, so that their history stays in one place.

| Source | Where | What it decided |
|---|---|---|
| Flywheel profile, implementation plan v2 | `ryangriffinau/skills`, `docs/specs/flywheel-profile/PLAN.md` | A per-repository `.flywheel/profile` as the single declarative contract for flywheel behaviour, read only at the edges (kickoff, ship bead, project sync), never by the core loop. Parsed, never sourced. `FLYWHEEL_MODE=solo` commits and pushes to the working branch; `team` opens the pull request ready and merges when green, without block-polling CI. Absent file means solo defaults. |
| Flywheel env reconciliation | `ryangriffinau/skills`, `docs/specs/flywheel-env-reconciliation/PLAN.md` | A human-owned `flywheel-env` store with precedence (process, repository local, repository `.env` read-only, global), `FLYWHEEL_ENV_REQUIRED`, and the Linear projection as a project-level endgame step, never inside the worker loop. |
| Flywheel gaps | `ryangriffinau/skills`, `docs/specs/flywheel-gaps/PLAN.md` | Lessons from the first flywheel run in a third-party repository: the reservation guard must soft-pass with one warning on machines without the stack; setup owns repository integration, and is complete when the next swarm run makes zero unexpected tracked-file changes and CI stays green on a no-op pull request; honest exit codes for preflight, setup and verify; never commit machine-local paths. |
| Beads with several people | A private product repository, `docs/reviews/beads-multi-person-collaboration.md`, 2026-07-31 | Root ids are hashes and cannot collide; `br sync --merge` is a real three-way merge; the gap is at the git layer, where an id-keyed merge with newest `updated_at` winning would make the common case automatic. Always pass `--actor`; never hand-write a union-merge script. |

The launcher skill and its scripts were retired on 2026-10-14 (`deprecated/flywheel-local-launcher/` in
the skills repository), superseded by the maintained `ntm` and `vibing-with-ntm` skills. Appendix B of
the plan says what each retired script becomes here.
