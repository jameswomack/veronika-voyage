# Veronika Voyage — AI Agent Context

This file is the canonical source of truth for `CLAUDE.md` / `AGENTS.md`
(symlinked by `.ai/scripts/setup-ai-symlinks.sh` — see [[.ai/README.md]]).
Read this before touching anything in this repo.

## What this repo is

A **static HTML/CSS/JS site, deployed via GitHub Pages, no build step, no
server**. It is a single-purpose personal project: a digital e-vite and trip
site for one event (Veronika's 60th birthday cruise). There is no framework,
no bundler. Every page is a hand-authored `.html` file with inline or
`<style>`/`<script>` blocks — `npm` exists only for tiny dev-time tooling
(`serve` for local preview, `markdownlint-cli2` for linting `.md` files; see
`package.json`), never to build or transform the site itself. GitHub Pages
serves `index.html`/`email.html`/`map/index.html` byte-for-byte, exactly as
committed — the `build` npm script is deliberately a no-op.

Do not introduce a bundler, framework, or a real build step unless
explicitly asked — that would be a large, unwanted change of direction for
a project this size. Adding a devDependency for a specific dev-tooling need
(another linter, a screenshot tool, etc.) is fine.

## Repo layout

```text
veronika-voyage/
├── index.html          the e-vite: envelope-open animation → invitation card.
│                        THIS is the link that gets shared (SMS/email/social).
├── email.html           a self-contained HTML fragment, hand-pasted into an
│                        email client's HTML/source view (Gmail "insert HTML",
│                        Apple Mail, etc.) to send a nicely formatted email
│                        invite. It is NOT served by GitHub Pages and is NOT
│                        linked from index.html — it exists purely so a human
│                        can copy its markup into an email compose window.
│                        Its job is to link OUT to the GitHub Pages index.html
│                        (the live site), not to duplicate the whole experience.
├── map/index.html        the interactive voyage map — linked from the gold
│                        button on the invitation card in index.html.
├── assets/              images (og-card.png for social link previews, and
│                        optional local photos — see "Photos" below).
└── .ai/                  AI agent context system (this directory).
```

Both `index.html` and `map/index.html` are served live at
`https://<username>.github.io/veronika-voyage/` (root) and
`.../veronika-voyage/map/` respectively — see the "Deploy" section of
`README.md`. `email.html` is the only file in the repo that is deliberately
**not** part of the deployed site.

## npm scripts (dev tooling only, not a build)

| Script | What it does |
|--------|--------------|
| `npm run dev` | Local preview via `serve` — `http://localhost:3000/` |
| `npm start` | Local preview via `python3 -m http.server 8989` (no `npm install` needed) |
| `npm run build` | No-op — this repo ships raw HTML, kept only so tooling that expects a `build` script doesn't break |
| `npm run lint:md` | `markdownlint-cli2` over all `.md` files |
| `npm run setup:ai` | Re-wires `.ai/`-sourced symlinks (repair only — they're committed, see [[.ai/README.md]]) |
| `npm run validate:ai` | Checks the symlinks + `.claude/settings.json` are correct |

`postinstall` also re-runs `setup:ai` automatically after `npm install`, as a belt-and-suspenders self-heal.

## GitHub Pages deployment model

- No CI build. Whatever is committed to `main` (root + `map/`) is what Pages
  serves, verbatim, from Settings → Pages → Deploy from branch → `main` / root.
- There is no staging environment. Treat `main` as production — this is why
  the worktree workflow (below) exists even for a project this small.
- `index.html` hardcodes its own canonical URL in three `SITE_URL` /
  `og:url` / `twitter:url`-style spots for social link-preview cards
  (iMessage, Facebook, X). If the GitHub Pages URL ever changes (repo
  rename, custom domain), all three occurrences need updating together —
  see `README.md` § "One find-and-replace edit".
- Link-preview caches (Facebook, iMessage) are sticky. After an OG-tag or
  `assets/og-card.png` change, the correct way to verify is Facebook's
  Sharing Debugger or appending `?v=2`, not just reloading the page.

## email.html's job, specifically

`email.html` exists because plain-text SMS/email links don't render a rich
preview everywhere, and some recipients (older relatives, work email) are
better reached with a nicely formatted HTML email than a bare link. When
editing it:

- Keep it a **self-contained, paste-ready fragment** — inline styles only
  (no external stylesheet, no `<script>`), because email clients strip
  `<head>`/`<style>` blocks and JS unpredictably.
- Its call-to-action must link to the live GitHub Pages `index.html` (using
  the same `SITE_URL` as the site), not attempt to reproduce the envelope
  animation or the map inline.
- Test changes by literally pasting the HTML into a Gmail "Insert HTML"
  compose window (or equivalent) before calling it done — a browser preview
  is not a reliable proxy for email-client rendering.

## Photos: three-tier loading

Each photo slot in `index.html` tries, in order: (1) a local file in
`assets/`, (2) a direct Google Drive hotlink, (3) a built-in designed
fallback (gold "V" medallion / illustrated band). See `README.md` for the
current Drive file IDs and how to swap `data-srcs`. The Claude preview
sandbox blocks all external images, so photo previews inside an agent's own
browser tooling will always show fallbacks — judge photos on the deployed
site.

## Personalization & RSVP

- `?to=Name` query param personalizes the invitation greeting; `?open=1`
  skips the envelope animation. Both are read client-side in `index.html`.
- RSVP is a `mailto:` + `tel:` link, not a form — there is no backend.

## Worktree workflow (mandatory for this repo too)

Same cycle as every other repo in this environment — see
[[.ai/workflows/worktree.md]] for the full steps. Even a static site
benefits from it: `main` is what's live on GitHub Pages the moment it's
pushed, so it should only ever receive tested, reviewed changes.

## Spec-driven development

`.ai/SPEC.md` is the living description of what's built and what's planned;
`.ai/CHANGELOG.md` records notable changes to the site or the `.ai/`
tooling itself. After a content or feature change, update both in the same
unit of work — see [[.ai/workflows/readme-maintenance.md]] for how this
interacts with keeping `README.md` accurate too.
