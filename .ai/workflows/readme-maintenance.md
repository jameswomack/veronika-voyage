# README.md Maintenance

`README.md` is the human-facing setup/deploy doc — not the AI-agent context file (that's
`.ai/shared/repo-context.md`, symlinked as `CLAUDE.md`/`AGENTS.md`). It documents things
that drift easily because they're data, not code:

- The current Google Drive file IDs and their mapping to photo slots (`data-srcs` values
  in `index.html`).
- The `SITE_URL` find-and-replace instructions and the 3 occurrences that need it.
- RSVP contact info (`mailto:`/`tel:`).
- How photo three-tier loading behaves and Drive sharing requirements.
- Local preview and GitHub Pages deploy steps.

## Source of truth

`README.md` itself is the source — there is no separate generator or template. This
project is small enough that a single hand-maintained file is the right amount of
tooling; the goal of this workflow is not automation but making sure it doesn't silently
go stale.

## Keeping it in sync

`.ai/hooks/readme-freshness-reminder.sh` fires on `PostToolUse(Edit|Write)` for
`index.html`, `email.html`, `map/index.html`, and `assets/*`. It inspects the diff and
prints an advisory (non-blocking) reminder when the change plausibly touches something
README.md documents: `data-srcs`, `SITE_URL`/`og:url`, `og-card`, a `drive.google` link,
or a `mailto:`/`tel:` value — and README.md itself has no pending changes in the working
tree.

When you see that reminder:

1. Check whether the specific fact README.md states (a Drive file ID, the canonical URL,
   the RSVP contact) is still accurate.
2. Update README.md in the same commit/unit of work if it's stale.
3. If the reminder was a false positive (e.g. you changed styling near a `mailto:` link
   without touching the link itself), no action needed — it's advisory, not a gate.

## What NOT to do

Don't build a script that regenerates README.md from `index.html` — the mapping between
Drive file IDs and "which photo is currently in use" is a human decision (which candidate
photo looks best), not something derivable from the DOM. Keep this workflow as
"reminder + human judgment," not automation.
