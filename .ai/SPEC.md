# Veronika Voyage — Living Specification

> **Last Updated:** 2026-08-09
> **Status:** Live
> **Owner:** James Womack

This is the single source of truth for what this site is, what's been built, and what's
next. All AI agents, all contributors, all planning starts here.

---

## 1. Product Overview

A static, single-purpose site: a digital e-vite and trip site for one event (Veronika's
60th birthday cruise). No backend, no database, no build step — three hand-authored HTML
pages deployed as-is via GitHub Pages, plus one HTML fragment meant to be pasted into an
email client.

**Core thesis:** the link *is* the invitation. It has to render a rich, personal preview
wherever it lands (iMessage, Facebook, X, email), open into a delightful envelope
animation, and hand off cleanly to trip logistics (the voyage map, the cruise line
booking link, RSVP contact info) — all with zero moving parts to operate or maintain.

### Tech Stack

| Layer | Technology |
|-------|-----------|
| **Pages** | Hand-authored HTML, inline/`<style>`/`<script>` — no framework |
| **Hosting** | GitHub Pages, `main` branch / root, no CI build |
| **Images** | Local files in `assets/`, or Google Drive hotlinks as fallback |
| **RSVP** | `mailto:` / `tel:` links — no form, no backend |
| **Dev tooling** | `npm` (`serve`, `markdownlint-cli2`) — dev-time only, `build` script is a deliberate no-op |

### Repo Structure

```text
veronika-voyage/
├── index.html          # the e-vite (envelope → invitation). THIS is the shared link.
├── email.html           # paste-ready HTML fragment for email clients; links to index.html
├── map/index.html        # interactive voyage map, linked from index.html's gold button
├── assets/              # og-card.png (social preview) + optional local photos
└── .ai/                  # AI agent context system (this file lives here)
```

See `.ai/shared/repo-context.md` for the full explanation of each file's job, and
`README.md` for the human-facing setup/deploy instructions (Drive photo IDs, SITE_URL
find-and-replace, personalization params).

---

## 2. Feature Registry

### Status Key

- `[SHIPPED]` — live and working
- `[PARTIAL]` — built, needs polish
- `[PLANNED]` — planned, no content yet

### 2.1 Core Site

| ID | Feature | Status | Key Files | Notes |
|----|---------|--------|-----------|-------|
| F-001 | Envelope-open → invitation animation | `[SHIPPED]` | `index.html` | Slow envelope opening animation (2x + .3s), see CHANGELOG |
| F-002 | Interactive voyage map | `[SHIPPED]` | `map/index.html` | Linked from the invitation's gold button |
| F-003 | Social link-preview cards (OG/Twitter) | `[SHIPPED]` | `index.html`, `assets/og-card.png` | 3x `SITE_URL` occurrences must stay in sync |
| F-004 | Three-tier photo loading | `[SHIPPED]` | `index.html` | local file → Drive hotlink → designed fallback |
| F-005 | Recipient personalization (`?to=`) | `[SHIPPED]` | `index.html` | Falls back to "OUR DEAR FAMILY & FRIENDS" |
| F-006 | Skip-envelope param (`?open=1`) | `[SHIPPED]` | `index.html` | |
| F-007 | RSVP via mailto/tel | `[SHIPPED]` | `index.html` | `womackmarkw@gmail.com`, `+61 429 111 363` |
| F-008 | Click-gated cruise booking info | `[SHIPPED]` | `index.html` | Booking instructions behind a click-triggered popover (`cruise-info-*`) |
| F-009 | HTML email fragment (paste-ready) | `[SHIPPED]` | `email.html` | Inline styles only; links out to the live GitHub Pages `index.html` |

### 2.2 Roadmap

| ID | Feature | Status | Notes |
|----|---------|--------|-------|
| S-001 | `.ai/` agent-context system | `[SHIPPED]` | This directory — see `.ai/CHANGELOG.md` |

---

## 3. Deployment

1. Push to `main` — GitHub Pages (Settings → Pages → Deploy from branch → `main` / root)
   serves the repo root and `map/` verbatim, no build.
2. Share link: `https://<username>.github.io/veronika-voyage/`.
3. After any URL-affecting change (repo rename, custom domain), update all three
   `SITE_URL`/`og:url`/`twitter:url` occurrences in `index.html` together.
4. Link-preview caches are sticky — use Facebook's Sharing Debugger or `?v=2` to bust a
   stale preview after an OG-tag or `assets/og-card.png` change.

---

## 4. Working Agreements

- **Worktree workflow.** All edits happen in a sibling worktree on its own branch —
  `main` is what's live on GitHub Pages, treat it as production. See
  `.ai/workflows/worktree.md`.
- **Spec-driven development.** After any content or feature change, update this file and
  add a `.ai/CHANGELOG.md` entry in the same unit of work.
- **README freshness.** README.md documents Drive photo IDs, SITE_URL replacement, and
  RSVP contact info — keep it in sync per `.ai/workflows/readme-maintenance.md`.
- **No build system.** Do not introduce a framework, bundler, or npm dependency without
  being explicitly asked.

---

## ID Reservations

IDs are claimed via `.ai/scripts/claim-spec-id.sh <F|B|C|S> "<description>"` before
creating a worktree, so parallel agents never collide. See `.ai/tools/claim-id.sh` for
the prefix registry.

| ID | Description | Branch | Reserved at |
|----|-------------|--------|-------------|
