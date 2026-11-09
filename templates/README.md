# Templates

- `AGENTS.local.template.md`: the doctrine `fwt init` seeds into a repository the operator does not own
  when no `--seed` is given. `{{PLACEHOLDER}}` tokens are filled from the init arguments and the
  repository; the `<!-- fwt: ... -->` marker must be replaced by hand with the team's own rules, and
  `fwt doctor` fails while any placeholder or marker remains. The canary stays the last line:
  `doctor --live` asks each host for it to prove the whole file loaded.
- `beads-README.md`: copied to `.beads/README.md` so the team knows what the folder is.
- `CLAUDE.local.md`: the Claude import file; `init` prepends `@AGENTS.md` when the team has only an
  `AGENTS.md`.

Placeholders and where `init` gets them:

| Token | Source |
|---|---|
| `OWNER` | `--owner`, for example "Ryan Griffin (InStrand)" |
| `OWNER_SHORT` | `--owner-short`, else the first word of `--owner` |
| `TEAM` | `--team-name` |
| `REPO_NAME` | the remote URL, else the directory name |
| `TEAM_FILES` | the tracked instruction files found at the root (`CLAUDE.md`, `AGENTS.md`), as a list in backticks, or `none` |
| `GENERATED_FILE` | `AGENTS.md` when the team has none, else `AGENTS.override.md` |
| `TRUNK` | `--trunk`, else the default branch |
| `TRUNK_REASON` | `--trunk-reason`, one sentence on why `main` is not the trunk, else empty |
| `DEFAULT_BRANCH` | `--default-branch`, else `refs/remotes/origin/HEAD` |
| `PREFIX` | `--prefix` |
| `TEAM_RULE_1` | left for the operator; `doctor` fails until the marker above it is removed |
| `CANARY` | `canary-` plus eight hex digits from `od -An -N4 -tx1 /dev/urandom`, generated per repository |

The version key of the frontmatter is `flywheel-teams: 1`. `doctor` reports the pre-release spelling
`agents-local: 1` and `fwt sync` rewrites it.
