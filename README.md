# Veronika at Sixty — E-vite + Voyage Map

One little website, two experiences:

```
index.html          ← the e-vite (envelope → invitation). THIS is the link you share.
map/index.html      ← the interactive voyage map (linked from the invite's gold button)
assets/og-card.png  ← the social preview image (iMessage / Facebook / X link cards)
assets/veronika.jpg ← photo slot: portrait of Veronika       (you add this)
assets/couple.jpg   ← photo slot: Veronika & Mark together    (you add this)
assets/sydney.jpg   ← photo slot: Sydney seascape footer      (you add this)
```

## Deploy (GitHub Pages)
1. In your `veronika-voyage` repo, upload ALL of these files/folders
   (drag the whole unzipped folder contents in — GitHub's uploader keeps folders).
2. Settings → Pages → Deploy from branch → main / root (as before).
3. Your share link is simply: `https://<username>.github.io/veronika-voyage/`

## One find-and-replace edit in index.html (30 seconds)
- Replace `SITE_URL` (3 occurrences) with your real Pages URL, no trailing slash,
  e.g. `https://yourname.github.io/veronika-voyage`
  → this is what makes iMessage/Facebook/X show the pretty preview card.
- (Both Royal Caribbean links are already wired in, from the VBDay26 doc.)

## Photos — three-tier loading, zero required work
Each photo slot tries, in order:
1. a local file in `assets/` (veronika.jpg / couple.jpg / sydney.jpg) — if you add one
2. a direct Google Drive hotlink (already wired for the portrait and couple shot)
3. the built-in designed fallback (gold "V" medallion / section hides / illustrated harbour band)

Currently hotlinked from your Drive:
- Portrait  → "Pic-4-V_185A1095_WA Export Awards.JPG" (V_Solo folder)
- Couple    → "IMG_0709.jpeg" (V+M folder)
- Seascape  → no Drive pick yet; illustration shows until you add assets/sydney.jpg
  or give me the filename to wire.

**Requirement for hotlinks:** the Drive files must be shared "Anyone with the
link — Viewer" (the folder link you have suggests they are). Quick check: open
`https://drive.google.com/thumbnail?id=1_I9jsUDpQ0xDtp71ulKcJ1-noAHTZ7nD&sz=w1600`
in an incognito window — if the photo appears, you're set.

**To swap which photo is used:** edit the `data-srcs` attribute in index.html and
change the `id=` value. Your candidate IDs:
- V_Solo: Pic-4-V…Awards `1_I9jsUDpQ0xDtp71ulKcJ1-noAHTZ7nD` · Facetune `1Vq_uKfTxGnF3-pePNLuv3t0mvjIFhkuw`
  · IMG_4413 `1NzHIPYbCuPL0xQ1HkABDgXGDWGMEJnR3` · IMG_4319 `1Tl8SErOC5OJq1cGV7ZjyGyl8pTO8fjrM`
  · IMG_3515 `1WJTLR1rSNlFZGw02UlthXBuh8KCLa8x_` · IMG_3248 `1yA8I9IpCVO-HfiK424L3SBQDHM-Qzsgm`
  · IMG_2118 `1SQyQnTtYTVulmFY4FbYYO0yWPwjwtTm2`
- V+M: IMG_0709 `1kh_7lJ3aqIk7ZM5gcPfvcEWDgJftgpDu` · IMG_5316 `1KJlcHIMn3DCQXzYNtKmbsMCU90UZ_SLG`
  · IMG_5073 `1i4pL8JcQ-i4UGeWwLCNJgblllucOLYAO` · IMG_5008 `17fYA6hDVPXidyYAoDW5ONfue_dGSIxdD`
  · IMG_3192 `19Uoba-uhbnetir2eulX5JvLOAfOKyIje`

For maximum reliability long-term (Drive hotlinks depend on sharing staying on),
dropping real files into `assets/` remains the gold-standard path — the local file
always wins when present. Keep each under ~500 KB (~1600px wide) for fast mobile loads.

**Note on the Claude preview pane:** its sandbox blocks *all* external images,
so previews there always show the fallbacks. Judge photos on the deployed site.

## Personalising per recipient
Append `?to=` to the link for each text/email:
- `.../?to=Ashley%20and%20Molly` → "To ASHLEY AND MOLLY"
- no parameter → "To OUR DEAR FAMILY & FRIENDS"
Also: `?open=1` skips the envelope and goes straight to the invitation.

## How the previews behave
- **iMessage / WhatsApp / Facebook / LinkedIn:** read the og: tags → show og-card.png with the title. 
- **X (Twitter):** reads the twitter: tags → large image card.
- **Plain SMS (green-bubble):** no previews, just the URL — the envelope makes up for it on arrival.
- **Email:** paste the link (Gmail/Apple Mail auto-preview), or embed
  `assets/og-card.png` as a clickable image linking to the site for a rich look.
Preview caches are sticky: use Facebook's Sharing Debugger or just append `?v=2`
to bust a stale preview after changes.

## RSVP details baked in
- mailto: womackmarkw@gmail.com (subject pre-filled "RSVP — Veronika's 60th Birthday Cruise")
- tel: +61 429 111 363
