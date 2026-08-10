# Cursor Rules — Veronika Voyage

You are working on a small, static HTML/CSS/JS site (an e-vite + trip map for
one event), deployed via GitHub Pages with no build step and no
`package.json`. Full context: `.ai/shared/repo-context.md`.

## Project Context

**Type:** Static site, hand-authored HTML
**Stack:** HTML/CSS/JS only — no framework, no bundler
**Deployment:** GitHub Pages, `main` branch / root

## Mandatory: Spec-Driven Development

**After implementing ANY change, you MUST update `.ai/SPEC.md`:**

1. Update feature status from `[PLANNED]` → `[SHIPPED]`.
2. Add a `.ai/CHANGELOG.md` entry describing what changed and why.

**When new work is identified or requested, add it to `.ai/SPEC.md` §4**
(Roadmap) with a unique ID and `[PLANNED]` status. Claim an ID first via
`.ai/tools/claim-id.sh` if working across multiple parallel worktrees.

`.ai/SPEC.md` is the single source of truth. If you don't update it, the
next agent starts from a lie.

## Core Principles

1. **No build system.** Never add a bundler, framework, or npm dependency
   without being explicitly asked — this repo is intentionally zero-tooling.
2. **`email.html` stays a paste-ready fragment.** Inline styles only, no
   `<style>`/`<script>` blocks, links out to the live GitHub Pages URL.
3. **Worktree discipline.** All edits happen in a sibling worktree on its
   own branch (`.ai/workflows/worktree.md`); never edit `main` directly.
4. **Visual verification.** Serve locally (`python3 -m http.server`) and
   check real-browser rendering before calling a visual change done.
