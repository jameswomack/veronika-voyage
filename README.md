# Veronika at Sixty · A South Pacific Voyage

An interactive keepsake map of the Anthem of the Seas round trip from Sydney
(11–19 December 2026), made for Veronika's 60th birthday invitations.

Everything lives in a single `index.html` — no build step, no dependencies to
install. Leaflet is inlined right in the file (no CDN needed); the fonts load from Google Fonts and the basemap streams from
CARTO's free tile service, so it just needs to be served as a static page.

## Features

- Real geography — Natural Earth coastlines rendered as a midnight nautical chart,
  with a 5° graticule and engraved-style coastal glow
- Gold course line: dotted "planned course" + solid line that draws as the ship sails
- A ship that auto-sails the loop, or step it port-to-port with the helm controls
  (buttons, timeline clicks, or ← / → arrow keys; spacebar toggles play)
- Hover/tap any port for day, date, and docked/tendered times
- A coral star in the Coral Sea marking 12 Dec — the birthday itself, celebrated at sea
- Subtle bobbing ship animation, respectful of `prefers-reduced-motion`
- Responsive down to phones (the invitation crowd will mostly open it on one)

## Share it

### GitHub Pages (free, permanent link)
1. Create a repo (e.g. `veronika-voyage`) and add `index.html` to the root.
2. Repo → Settings → Pages → Source: "Deploy from a branch" → `main` / root.
3. Your link: `https://<username>.github.io/veronika-voyage/`

### Vercel (free, nicer URL)
1. `npm i -g vercel` (or use vercel.com's drag-and-drop "Add New Project").
2. From this folder: `vercel --prod`
3. Optionally rename the project so the URL reads something like
   `veronika-at-sixty.vercel.app`.

### Self-host + ngrok (quick and temporary)
```bash
python3 -m http.server 8080     # from this folder
ngrok http 8080                 # share the https URL it prints
```

## Tweaking

All itinerary data is one array (`STOPS`) near the top of the script in
`index.html` — names, dates, times, and the birthday flag are plain text there.
Colors are CSS variables in `:root`. The autoplay pace is set in `playLeg()`
(`span * 26` — raise for slower, statelier sailing).

## Credits

Coastlines: Natural Earth (public domain). Leaflet 1.9.4 (BSD-2).
Fonts: Italiana, Cormorant Garamond, Josefin Sans (OFL, embedded via Fontsource).
