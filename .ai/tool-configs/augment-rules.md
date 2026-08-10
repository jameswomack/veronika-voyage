# Augment Code — Project Rules

**Project:** Veronika Voyage
**Type:** Static e-vite + trip-map site for one event, deployed via GitHub Pages

---

## Project Context

Plain HTML/CSS/JS, no framework, no bundler. `npm` exists only for dev-time
tooling (`serve`, `markdownlint-cli2`) — never to build the site. `index.html`
is the e-vite (envelope → invitation), `map/index.html` is the linked voyage
map, and `email.html` is a self-contained fragment meant to be hand-pasted
into an email client's HTML compose view — it is not part of the deployed
site. Full detail: `.ai/shared/repo-context.md`.

**Key facts:**

- Deployment: GitHub Pages, `main` branch / root, no CI build.
- `index.html` embeds its canonical URL (`SITE_URL`) in three OG/Twitter
  meta spots for social link previews — keep them in sync on any URL change.
- Personalization via `?to=Name` query param; `?open=1` skips the envelope
  animation. No backend — RSVP is `mailto:`/`tel:`.

---

## Mandatory: Spec-Driven Development

**After implementing ANY change, you MUST update `.ai/SPEC.md`:**

1. Update feature status from `[PLANNED]` → `[SHIPPED]`.
2. Add a `.ai/CHANGELOG.md` entry.

**When new work is identified, add it to `.ai/SPEC.md` §4 (Roadmap)** with a
unique ID and `[PLANNED]` status.

`.ai/SPEC.md` is the single source of truth. If you don't update it, the
next agent starts from a lie.

---

## Worktree Workflow

All edits happen in a sibling git worktree on its own branch — never
directly on `main`. See `.ai/workflows/worktree.md`.
