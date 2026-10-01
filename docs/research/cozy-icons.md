# Cosy hand-drawn icons for the wallet app: research and rendered comparison

**Short answer:** don't roughen the small UI icons. Keep nav and action icons (16–24px) clean, but make them rounder and chunkier. Use hand-drawn icons from about 28px up, in category tiles and illustrated moments. Build those with a perfect-freehand brush pipeline at build time, or with Doodle Icons (CC0) plus your own café glyphs.

I rendered the comparison and looked at every screenshot at 3–4× zoom. These sites were blocked by the proxy, so their rows below come from search summaries and are marked unverified: icons8.com, khushmeen.com, webalys.notion.site (Streamline's licence page), support.flaticon.com, help.streamlinehq.com and api.iconify.design. npm, pub.dev and raw.githubusercontent.com all worked. There is no Flutter SDK in this sandbox, so no Flutter package was compile-tested. I only checked their SDK constraints and pub scores.

## 1. Hand-drawn sets (licence first)

| Set | Licence | Attribution? | Shipping in an app bundle | Price | Count | Finance coverage | Café coverage | Formats / Flutter | Look |
|---|---|---|---|---|---|---|---|---|---|
| **Doodle Icons** (Khushmeen Sidhu) | **CC0 1.0** (stated in the theJian/doodle-icons README, which I read) | No | Yes, anything goes | Free | ~400–450 | home, wallet, 3 cards, bank, bill, cash, coin, piggy, safe, trend up/down, pie, send, download, bell, search, user, scan. "Qr" is actually a barcode | coffee cup ×2, cake, cookie, cocktail. **No croissant, bubble tea or latte art** | SVG. Viewboxes are non-square (e.g. 161×118), so you must normalise them. A Flutter `doodle_icons` 0.1.0 package exists in the GitHub repo but is **not on pub.dev**: use a git dependency or copy the SVGs. npm `doodle-icons` 1.1.0 is an old React 17 wrapper | Genuinely hand-drawn, thin, wobbly; the most charming of all |
| **Streamline Freehand**, free subset | **CC BY 4.0** (npm package metadata) | Yes, a link to streamlinehq.com | Allowed with credit | Free. Paid: Icons $19/mo annual or $39 monthly; Full Access $29/mo *(search summary)* | 1,000 free (22,349 in the paid set, *unverified*) | wallet, cards, bank, piggy, receipt, invoice, QR scan, bell, search, pie. No plain user glyph | **none** in the free subset | SVG; npm `@iconify-json/streamline-freehand` | Busy, illustrative; meant for 32px and up |
| Streamline paid sets (Freehand / Plump) | Commercial licence, no attribution. "100 unique icons per project" cap *(summary, unverified)* | No | Yes | as above | — | — | Plump has a coffee mug | SVG | Plump (free 1,499, CC BY) is cartoony rather than sketchy. **I found no Streamline "Kawaii" or "Doodles" icon set.** Their "hand-drawn" items are Elements and illustrations *(unverified)* |
| **Icons8**: Hand Drawn, Doodle / Doodle Line, Cute Outline, Pastel | Free tier: PNG up to 100px only, with a link to icons8.com where it is used. SVG needs a paid plan *(summaries; icons8.com blocked)* | Yes on free; no on paid | Paid plan only, realistically | Icons plan **$15/mo, 100 downloads/mo, then $0.20 per icon** *(summary)* | Very large | Complete | Has coffee and bakery glyphs | PNG free; SVG paid | Polished "hand-drawn" with a consistent style. Closest to a commercial ready-made option |
| **Flaticon** | Free licence needs "designed by {author} from Flaticon". **For mobile apps the credit must go on the credits page AND in the app-store description** *(support-page summary)* | Yes on free; no on Premium | Yes | Premium price **unverified** | Huge, but from many authors | Complete | Many café packs | SVG | Styles vary by author, so you have to stay inside one author's pack |
| **IconScout** | Free assets need attribution; paid removes it. Each pack has its own licence | Yes on free | Yes on paid | From about $12/mo annual *(unverified)* | Huge | — | Hand-drawn café packs exist | SVG/PNG | Varies |
| **OpenMoji** | **CC BY-SA 4.0** | Yes: "All emojis designed by OpenMoji – the open-source emoji and icon project." | Yes. **Any glyph you modify must be released under CC BY-SA** | Free | ~4,500 | house, purse, card, bank, receipt, QR, chart, bell, magnifier, bust, pig face (no piggy bank) | **croissant, bubble tea, hot beverage, latte macchiato, coffee bean** | SVG, colour and black-line versions | Thick-outline emoji. Not quite "outline icons"; small inside its box |
| **Excalidraw libraries** | MIT (the excalidraw-libraries repo) | No | Yes | Free | — | Thin: mostly diagram and wireframe parts | — | .excalidrawlib, export to SVG | Not a coherent icon set |
| **Open Peeps / Humaaans** (Pablo Stanley) | **CC0** | No | Yes | Free | Open Peeps: 584k combinations | People only | — | SVG/Figma | Open Peeps is black ink line (fits Ink); Humaaans is flat colour |
| **Hugeicons free** (not hand-drawn, but best for the chibi base and café glyphs) | **MIT** (checked locally) | No | Yes | Free | 6,065 | Complete | **croissant, bubble-tea-01/02, coffee-01…04, milk, cupcake, bread** | SVG; `hugeicons` 1.2.0 on pub.dev | Rounded, soft |
| Café-themed packs | Vecteezy, iStock, Dreamstime stock line art | Stock licences; Vecteezy free needs attribution *(unverified)* | — | — | — | — | Yes | — | **I found no free, consistent, permissively licensed café icon pack.** Use Hugeicons and Lucide café glyphs plus your own drawings |

## 2. Making any icon set look hand-drawn

- **Rough.js** (npm `roughjs` 4.6.6, MIT)
  - Works well at build time in Node: `generator.path(d)` gives you SVG paths.
  - Its default randomness is in absolute units, so on a 24-unit grid you have to scale it down (I used `maxRandomnessOffset` 0.45–0.7).
- **Flutter ports of Rough.js**
  - `rough` 0.1.1 (2020) is Dart-3-incompatible. Dead.
  - `rough_flutter` 0.1.2 (2025-09-09) is a maintained fork: Dart ≥3.0, 150/160 pub points, tagged null-safe and wasm-ready.
  - Its API only draws primitives (line, rect, ellipse, arc, linearPath, curvePath, polygon). **It cannot take SVG path data.** You would sample `Path.computeMetrics()` into points and feed those in.
  - Related but different: `hand_drawn_toolkit` 0.5.3 (MIT; sketchy borders, charts, notebook), `sketchy_design_lang` 0.4.0 (BSD-3), `skribble` 0.2.1 (MIT, needs Flutter ≥3.47, brand new), `rough_notation` 0.0.3, `drawably_flutter` 0.0.2.
- **SVG wobble** (feTurbulence + feDisplacementMap)
  - Easy in a browser. **`flutter_svg` 2.3.0 does not support feTurbulence**, so in Flutter it would mean baking the wobble into the geometry or writing a fragment shader.
  - At 24px it is barely visible, and at 16px it just looks blurry.
- **perfect-freehand** (npm 1.2.3, MIT)
  - Pub.dev port: `perfect_freehand` 2.5.2+1 (2026-01-26, Dart ≥3.1.3).
  - It outputs **filled polygons**, so the result can go into an icon font (`IconData`, takes `IconTheme` colour) or a `vector_graphics` asset.
- **Is "Phosphor paths, roughened at build time" a good approach? Not as stated.**
  - Phosphor's `@phosphor-icons/core` SVGs are filled outline shapes, not centre-lines. Rough.js on them traces both edges and you get double contours (row b0 in the sheet: it looks like a printing error).
  - What works: take **centre-line skeletons** (Lucide/ISC, Tabler/MIT, Hugeicons strokes/MIT, or your own), run them through a **seeded** perfect-freehand or Rough.js pass in Node, then compile with `vector_graphics_compiler` or build an icon font.
  - Use a fixed seed so the icons don't change between builds. Treat it as a design pass, not a filter: proof every glyph by eye.

## 3. "Ghibli / chibi" moments

- **Routes**
  - Best: commission an illustrator. A set of 6–10 spots (empty wallet, first saving, budget hit, success, offline, onboarding ×3) in warm gouache or watercolour. Get full copyright assignment or an exclusive app licence, plus layered or vector source files.
  - Middle: licensed packs (Creative Market, IconScout, Blush).
    - Creative Market's Standard licence caps "end products for sale" at 500 units, so an app would likely need **Extended**. Read each pack's terms.
    - Blush: free use without attribution, but SVG only on paid plans *(summary)*.
  - Free: Open Peeps / Humaaans (CC0) for people. Their style is flatter and more graphic than painterly.
- **IP caution**
  - Style alone isn't protected by copyright. Copying characters (Totoro, soot sprites, Kiki), recognisable scenes, or Ghibli's name or branding is a problem.
  - The 2025 "Ghibli-style" AI trend drew strong criticism. On 28 Oct 2025, CODA (whose members include Studio Ghibli) formally asked OpenAI to stop training Sora 2 on members' work without permission. AI Ghibli imitations are therefore a brand and ethics risk, even where they may be legal.
  - In briefs, write **"warm hand-painted, cosy, soft gouache, slice-of-life café"**, never "Ghibli". Don't use AI generation for these moments.
- **Animation in Flutter**
  - `rive` 0.14.11 (Flutter ≥3.28): interactive, state-machine mascots such as a steaming cup or a piggy that blinks.
  - `lottie` 3.6.1 (needs Flutter ≥3.41 / Dart ^3.11): After Effects loops.
  - `flutter_animate` 4.5.2 (last release 2024-11): entrances, bounce and shimmer on static art.

## 4. Café palette (WCAG contrast, computed)

| Token | Light | Dark |
|---|---|---|
| foam (canvas) | `#F6EEE2` | `#17110D` |
| milk (surface) | `#FFFAF2` | `#211813` |
| latte (neutral tile) | `#E8D5BC` | `#3A2B20` |
| caramel (primary accent / tile) | `#D9964A` | `#D9A35E` |
| espresso (ink) | `#2B1D15` | `#F4E9DA` |
| cocoa (secondary text) | `#6A4935` | `#C7AD95` |
| caramel-ink (emphasis text) | `#7E4C1C` | `#E5B77A` |
| matcha (tile) / matcha-ink (text) | `#9DB27C` / `#476030` | `#A9C08A` / `#A9C08A` |
| berry (accent / negative) / berry-tint (tile) | `#963A50` / `#F2D6D9` | `#E58A9C` / `#4A2730` |
| on-tile ink (dark mode, for caramel and matcha tiles) | — | `#1F150F` |

**Light mode**
- Espresso: 14.15 on foam, 15.67 on milk, 11.38 on latte.
- Cocoa: 6.97 on foam, 5.61 on latte.
- Caramel-ink: 6.21 on foam, 5.00 on latte.
- Matcha-ink: 6.12 on foam, 4.92 on latte.
- Berry: 6.05 on foam, 6.70 on milk, 4.86 on latte.
- Espresso icons: 6.52 on caramel tiles, 7.05 on matcha tiles.

**Dark mode**
- Ink: 15.60 on foam, 11.33 on latte.
- Cocoa: 8.77 on foam. Berry: 7.53 on foam. Caramel-ink: 10.14 on foam.
- On-tile ink: 7.98 on caramel, 9.04 on matcha.

**Pebble**
- Ink `#1A1712`: 15.46 on canvas `#F2EEE8`, 11.08 on marigold.

**Caveats**
- Tile backgrounds against the canvas are below 3:1: light caramel 2.17, light matcha 2.01, latte 1.24. That's fine for decorative tiles where the icon carries the meaning. An interactive control boundary on latte needs a border.
- The chibi accent fills (caramel 1.79 on milk) are decorative; the outline carries the ≥3:1.
- In dark mode, icons on caramel or matcha tiles **and on the caramel pill** must switch to the dark on-tile ink. I fixed this in the sheet after the first render showed light icons on the pill.
- The sheet still draws the latte heart in an earlier berry (`#A8435A`), which is decorative. Use the table values in tokens.

## 5. What the sheet shows, and what each approach is good for

| Row | Verdict | Works at |
|---|---|---|
| a. Phosphor Regular | Crisp baseline | 16–48 |
| b0. Rough.js on Phosphor fills | Double contours. Reject | — |
| b1. Rough.js sketchy (multi-stroke) | Muddy at 16–20; charming Excalidraw feel | 32+ |
| b2. Rough.js inked (single stroke) | Reads well. At 16px the wobble looks like a rendering bug | 24–48 |
| c1. SVG wobble filter | Nearly invisible at 24; blurry at 16; no Flutter support | 32+, web only |
| c2. perfect-freehand brush | Most "brush-pen" personality, bold. Gets blobby at 16 (QR, croissant) | 20–48; best on 28–48 tiles |
| d1. Doodle Icons | Truly hand-drawn; thin and light at 16; café gaps | 20–48 |
| d2. Streamline Freehand | Over-detailed for UI; no café glyphs | 32+ |
| d3. OpenMoji | Colourful emoji; small in its box | 24+ as stickers |
| e1. Chibi-lite (Phosphor Bold + caramel/marigold duotone fill) | Cute and fully legible. Best fit for Pebble | 16–48 |
| e2. Chibi (Hugeicons rounded 2.0 + faces/blush) | Friendly rounded strokes. The faces only read at 32px and up; at 24 they look like smudges | strokes 16–48; faces 32+ |

## 6. Recommendation

1. **UI icons (nav, actions, list rows, 16–24px): no roughening.**
   - Ink: Phosphor Regular or Light (`phosphor_flutter` 2.1.0, last released 2024-05; or the SVGs through `flutter_svg` 2.3.0 / `vector_graphics` 1.2.3).
   - Pebble and Café: chibi-lite. Use Phosphor Bold with a duotone accent fill (row e1), or Hugeicons stroke-rounded at 1.75–2.0 (`hugeicons` 1.2.0, MIT).
   - Never put faces on money actions such as send, receive or QR.
2. **Category tiles (28–40px glyph on a 48–56px tile): this is where the hand-drawn look goes.**
   - Option A (recommended): a build-time perfect-freehand pipeline over your own or Lucide/Hugeicons skeletons, seeded and proofed by eye, output as an icon font or `.vec`. Use `perfect_freehand` 2.5.2+1 only if you want live strokes.
   - Option B, fastest: Doodle Icons (CC0) plus about 4 custom café glyphs drawn to match. Normalise the viewboxes.
   - Kawaii faces are fine here for café and food categories.
3. **Moments (120–280px): commissioned warm gouache illustrations**, animated with Rive for interactive pieces, Lottie for loops and `flutter_animate` for entrances. Rough.js / perfect-freehand line art also works at this size for an Ink-style monochrome version.
4. **How it fits the directions**
   - Ink should stay precise; hand-drawn only in moments, as monochrome ink line work.
   - Pebble takes chibi-lite UI plus hand-drawn tiles naturally.
   - **Café works best as a palette variant of Pebble** (canvas→foam, ink→espresso, marigold→caramel) rather than a third direction. The shapes already fit.
5. **Risks**
   - Hand-drawn glyphs at 16px look broken.
   - Inconsistent sources: don't mix Doodle and Freehand in one surface.
   - CC BY attribution if you use Streamline free, and CC BY-SA if you modify OpenMoji.
   - `doodle_icons` isn't on pub.dev; pin a git commit.
   - `rough_flutter` is small and young (0.1.x) and can't parse SVG paths.
   - `lottie` 3.6.1 needs Flutter ≥3.41.
   - `flutter_animate` hasn't had a release since 2024-11.
   - The "Ghibli" wording in briefs and any AI imitation (see section 3).

## Files

All in `/tmp/claude-0/-home-user-DesignSystem/cc2b7154-d887-54c2-bcfd-712a2b398010/scratchpad/cozy-icons/`:
- Full sheets: `sheet-cafe.png`, `sheet-cafeDark.png`, `sheet-pebble.png`
- Zoomed crops: `zoom-cafe-grid.png`, `zoom-cafe-ladder.png`, `zoom-cafe-tiles.png`, `zoom-pebble-grid.png`, `zoom-pebble-ladder.png`, `zoom-pebble-tiles.png`
- Sources: `build.js` (generator), `shot.js`, `zoom.js`, `contrast.py`, `palette.py`, and the matching `sheet-*.html`

Each sheet has 11 treatment rows × 16 columns at 24px, a 16/20/24/32/48px size ladder, coloured category tiles and a bottom-bar pill. The latte-heart and bubble-tea glyphs were drawn for this study. In rows a–c the croissant uses the Hugeicons skeleton. The Rough.js and perfect-freehand rows use Lucide centre-line skeletons, because Phosphor doesn't ship centre-lines. ≈ marks the nearest available glyph and — marks a glyph the set doesn't have.

## Sources (blocked ones marked)

- Doodle Icons: https://github.com/theJian/doodle-icons (README read); https://community-en.eagle.cool/resource/doodle-icons-khushmeen ; https://khushmeen.com/icons.html (blocked)
- Streamline: https://icon-sets.iconify.design/streamline-freehand/ ; https://home.streamlinehq.com/pricing ; https://help.streamlinehq.com/en/articles/5634634 (blocked; terms from search summaries); https://webalys.notion.site/Streamline-Free-License-5b7339ddeb194dc8bb1b0e97aadc011f (blocked); https://superdevpro.com/icons/streamline-freehand (source of the 22,349 count, unverified)
- Icons8: https://icons8.com/license , https://icons8.com/pricing , https://icons8.com/icons/carbon-copy (all blocked; search summaries)
- Flaticon: https://www.flaticon.com/license/license.pdf ; https://support.flaticon.com/s/article/Apps-and-games-FI (blocked)
- IconScout: https://iconscout.com/free-icons ; https://toolradar.com/tools/iconscout (price unverified)
- OpenMoji: https://github.com/hfg-gmuend/openmoji (fetched); https://openmoji.org/faq/
- Excalidraw: https://github.com/excalidraw/excalidraw-libraries/blob/main/LICENSE
- People illustrations: https://www.openpeeps.com/ ; https://www.humaaans.com/
- Blush: https://blush.design/plans
- Creative Market: https://creativemarket.com/licenses/v2
- Ghibli and AI: https://techcrunch.com/2025/03/26/openais-viral-studio-ghibli-moment-highlights-ai-copyright-concerns/ ; https://variety.com/2025/digital/news/studio-ghibli-openai-sora2-japanese-trade-group-coda-letter-1236568751/ ; https://techcrunch.com/2025/11/03/studio-ghibli-and-other-japanese-publishers-want-openai-to-stop-training-on-their-work
- flutter_svg filters: https://github.com/flutter/packages/pull/11909
- pub.dev package API, read live: rough_flutter, rough, perfect_freehand, hand_drawn_toolkit, sketchy_design_lang, skribble, rive, lottie, flutter_animate, flutter_svg, vector_graphics, phosphor_flutter, hugeicons
- npm registry: roughjs, perfect-freehand, svg2roughjs, doodle-icons, @iconify-json/*

