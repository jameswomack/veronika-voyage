# Veronika Voyage — Gemini Code Assist Context

**Project:** Static e-vite + trip-map site for one event, deployed on GitHub Pages.
**Stack:** Plain HTML/CSS/JS. No framework, no bundler. `npm` exists only for
dev-time tooling (`serve`, `markdownlint-cli2`) — never to build the site.

See `.ai/shared/repo-context.md` (this file's canonical source) for the full
repo layout, GitHub Pages deploy model, and what `email.html` is for.

## Mandatory: spec-driven development

After any content or feature change, update `.ai/SPEC.md` and add an entry to
`.ai/CHANGELOG.md` in the same unit of work. `.ai/SPEC.md` is the single
source of truth for what's built and planned — if you don't update it, the
next agent starts from a lie.

## Worktree workflow

All edits happen in a sibling git worktree on its own branch — never
directly on `main`. See `.ai/workflows/worktree.md` for the exact commands.

## Core principles for this repo

1. **No build step.** Files are served byte-for-byte by GitHub Pages.
2. **Email fragment discipline.** `email.html` must stay a self-contained,
   inline-styled fragment (no `<style>`/`<script>` blocks) — email clients
   strip both.
3. **SITE_URL consistency.** The canonical Pages URL appears in multiple
   `og:`/`twitter:` meta spots in `index.html` — keep them in sync.
4. **Test visually.** For any visual change, run `npm run dev` (or `npm start`
   for no-install `python3 -m http.server`) and check it in a real browser
   before calling it done.
