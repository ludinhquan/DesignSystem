# Icon language for Ink and Pebble: research, renders and recommendation

**Bottom line:** both directions should use **Phosphor** as the UI icon set and differ in weight, colour and the fun layer.
- **Ink:** Phosphor Regular for outlines, Fill for selected tabs, monochrome, with fun coming only from motion.
- **Pebble:** Phosphor Regular/Fill in the chrome and Duotone inside the colour tiles, plus **Microsoft Fluent Emoji 3D** for categories, empty states and success.

One package and one set of rules for custom glyphs serve both directions.

**Two things to know first:**
- **The official `phosphor_flutter` package does not compile on current Flutter.** Its latest version, 2.1.0 (2024‑05‑10), breaks on Flutter 3.44 or newer, where `IconData` became a `final` class. pub.dev shows it scoring 0/50 on static analysis because of this error. Use the community package `phosphoricons_flutter` 1.0.0, or better, ship your own icon font built from the Phosphor SVGs (details in the recommendation below).
- **SF Symbols can't be used.** Its licence allows use "SOLELY FOR CREATING USER INTERFACES… RUNNING ON APPLE'S iOS, iPadOS, macOS, tvOS OR watchOS". That rules out Android, so it can't be the icon set for a Flutter app.

npm, pub.dev and raw.githubusercontent.com were reachable, so the versions and licences below were checked there. The GitHub API, 3dicons.co and jsdelivr were blocked by the proxy, so 3dicons comes from search results only.

## 1. UI icon sets

Rendered stroke widths are at 24 px.

| Set | Licence | Count | Styles / stroke | Flutter package (pub.dev version, date) | Fill pairs for tabs | Finance coverage | Character (from the renders) |
|---|---|---|---|---|---|---|---|
| **Phosphor** | MIT | 1,512 × 6 weights (core 2.1.1) | Thin 0.75 / Light 1.125 / Regular 1.5 / Bold 2.25 / Fill / Duotone. The SVGs are outlined shapes, so you choose a weight rather than set a stroke width. | `phosphor_flutter` 2.1.0 (2024‑05‑10) does not compile on Flutter 3.44+. Use `phosphoricons_flutter` 1.0.0 (2026‑05‑22, MIT, built from core 2.0.8, duotone through a two‑layer Stack) instead. | Yes, all 1,512 | Complete: wallet, credit-card, bank, qr-code/scan, arrows-left-right, receipt/invoice, piggy-bank, chart-*, coins, hand-coins, target. No VND glyph. | Crisp and evenly weighted, round caps. The fill pairs are the most consistent of any set. Duotone looks crafted. |
| **Solar** (480 Design) | CC BY 4.0, attribution required | ~1,470 per style × 6 | Linear 1.5, Line Duotone, Bold, Bold Duotone, Broken, Outline | `solar_icons` 0.2.0 (2026‑09‑28, BSD‑3 wrapper, icon font, 50 likes) | Yes (Linear/Bold) | Good: card-send/receive/transfer, bill-list, qr-code, money-bag, safe. **No piggy bank, no bank.** | Super-rounded and charming (the house has a smile), but quirky. Bold Duotone rendered in a single colour looks muddy grey, both on Ink and on the colour tiles. |
| **Hugeicons** | MIT for the free set | 6,027 free | Free set is **stroke-rounded only**. Stroke width is adjustable (`strokeWidth`). Solid, bulk, duotone and twotone are Pro. | `hugeicons` 1.2.0 (2026‑09‑18, SVG-based) | **No** in the free set | The best: money-send/receive, money-saving-jar, invoice, qr-code-scan, savings, bank | Soft and closest to SF Symbols in feel at 1.6. Pro reportedly costs $99 a year or $1,197 lifetime (from search results, not verified). |
| **Lucide** | ISC | 2,121 (1.49.0) | Outline only. Package weights 100–600 map to strokes 0.5 / 1.0 / **1.55** / 2.0 / 2.5 / 3.0 (checked in the package's build script). | `lucide_icons_flutter` 3.1.21 (2026‑10‑01) | **No** | Good: wallet, credit-card, landmark, scan-qr-code, receipt, piggy-bank, coins, banknote-arrow-up, goal | Precise but generic. The circle-arrow-out glyphs read badly as send/receive. |
| **Fluent System** | MIT | ~2,474 regular and 2,510 filled at 24 px | Regular and Filled, drawn separately at 16/20/24/28/32/48 (real optical sizes). There is also a "color" style (~890 SVGs). Stroke is fixed at about 1.5. | `fluentui_system_icons` 1.1.273 (2025‑01‑31, Flutter Favorite). This lags npm 1.1.343. | Yes | Good: wallet, payment, building_bank, scan_qr_code, receipt, savings, data_trending, arrow_swap. No receive arrow in a circle at 24 px. | Closest to SF Symbols in geometry, but the fills are heavy and some glyphs (piggy, scan, receipt) are clumsy. |
| Tabler (not rendered) | MIT | 5,166 outline, 1,054 filled | Stroke 2 by default, adjustable in the SVG | `flutter_tabler_icons` 1.43.0 (2024‑09‑28; stale, the font has a fixed stroke) | Only partial | Very broad. **The only set with `currency-dong`.** | Neutral and a little technical |
| Iconoir (not rendered) | MIT | 1,383 regular, 288 solid | Stroke 1.5 | `iconoir_flutter` 7.12.1 (2026‑08‑12, SVG widgets) | Few | piggy-bank, send/receive-dollars, scan-qr-code, coins | Light and editorial |
| Remix (not rendered) | Apache‑2.0 (the pub wrapper is tagged MIT) | ~3,229 SVGs (line and fill) | Line and Fill pairs | `remixicon` 4.9.3 (2026‑04‑04) | Yes | bank-card, qr-scan, bill, exchange, safe, hand-coin | Neutral and slightly heavy |
| Material Symbols (not rendered) | Apache‑2.0 | 4,264 (v2.960) | Variable: FILL 0–1, weight 100–700, grade, optical size 20–48. Outlined, Rounded and Sharp. | `material_symbols_icons` 4.2960.0 (2026‑07‑23) | Yes, and fill can be animated as a variable | Complete (savings, account_balance_wallet, qr_code_scanner, receipt_long, add_card) | Unmistakably Android, so wrong for both directions |
| CupertinoIcons | MIT | ~1.2k (not verified) | Outline and fill | `cupertino_icons` 2.0.0 (2026‑09‑29; needs Flutter 3.44 / Dart 3.12 and `cupertino_ui`) | Partial | Thin (not verified) | Older iOS style, not current SF Symbols |
| SF Symbols | Apple licence | n/a | 9 weights, variable | `sf_symbols` 0.6.1: iOS/macOS only, draws nothing on other platforms. Supports bounce, pulse and variableColor (iOS 17) and wiggle, rotate and breathe (iOS 18). | n/a | n/a | **Apple OS only, never on Android.** The excerpt I found says nothing on redrawing. Tracing them into your own set would be a derivative of Apple's work; this is my reading, so get legal advice before doing it. |

## 2. Fun / 3D sets

| Set | Licence | Format and size | Consistency | Flutter |
|---|---|---|---|---|
| **Fluent Emoji 3D** (Microsoft) | **MIT** (LICENSE checked) | PNG 256 px, **20–46 KB each** (measured on 30 downloads). Color and Flat SVG and High Contrast versions also exist. | Excellent: clay-like with top-left light, warm. Has local-fit objects: 🛵 motor scooter, 🧋 bubble tea, 🧧 red envelope. | `Image.asset` with `cacheWidth`. Re-export at 128 px WebP for tiles. |
| Fluent Emoji Flat | MIT | SVG, a few KB; 3,174 in the Iconify set | Good, but less special | `flutter_svg` 2.3.0 or `vector_graphics` |
| Noto Animated Emoji | CC BY 4.0 (attribution required) | Lottie 15–97 KB, WebP 512 px 185–304 KB (measured). ~714 animated. | Flat Google style, so it clashes with the Fluent 3D look | `animated_emoji` 3.3.0 or `lottie` 3.6.1 |
| 3dicons.co | CC0 according to search results (**unverified: site blocked, GitHub README returned 404**) | PNG, .blend; 4 colour styles × 3 camera angles | Glossy and generic | Image assets |
| OpenMoji | CC BY‑SA 4.0 (share-alike, so avoid) | SVG | Hand-drawn outline | — |
| Twemoji | CC BY 4.0 | SVG | Flat, associated with the X brand | — |
| LottieFiles | Lottie Simple License: commercial use OK, no attribution, no redistribution as standalone files | Lottie | Quality varies a lot | `lottie` 3.6.1 |
| useAnimations (~90 icons) and Unicorn Icons (Rive/Lottie) | MIT / "free" according to third-party summaries (**unverified**) | Lottie, Rive | Micro-interactions | `lottie`, `rive` |
| Streamline 3D, Iconscout 3D | Paid (not checked) | PNG | — | — |

## 3. Animation options

- **Tab select (both directions):** stack the Regular and Fill glyphs and switch with `AnimatedSwitcher`, fading and scaling 0.85→1.0.
  - Ink: 200 ms ease-out.
  - Pebble: a spring with slight overshoot (easeOutBack, or Flutter's `SpringSimulation`), plus the marigold pill sliding (`AnimatedContainer` / `AnimatedAlign`).
  - Add `HapticFeedback.selectionClick()` and honour `MediaQuery.disableAnimations`.
- **SF-like bounce and replace:** `flutter_animate` 4.5.2, e.g. `.animate(target: sel).scaleXY(end: 1.12, duration: 120.ms).then().scaleXY(end: 1/1.12)`. For "replace", fade, scale and blur in the switcher.
- **Draw-on checkmark (Ink success):** a `CustomPainter` with `PathMetric.extractPath`. Alternatives are `iconic_morph` 1.10.0 (morph and draw-on, but very new: 3 likes) or `not_static_icons` 0.54.0 (animated Lucide icons, MIT).
- **Hero icons and onboarding:** Rive state machines with a `selected` input, `rive` 0.14.11 (2026‑08‑03, MIT). Use this for custom hero icons rather than the whole icon set.
- **Celebration (Pebble):** animate the Fluent 3D PNG itself with flutter_animate (spring scale, a ±8° wobble, confetti in palette colours). Don't mix in Noto Lottie, because the styles clash.
- **Material Symbols** could animate `Icon(fill:)` through a `TweenAnimationBuilder`. It is the only real variable-fill option, but its Android look rules it out.
- **`sf_symbols` 0.6.1** only works on iOS and macOS, so don't build the system on it.

## 4. Crafting rules

1. **Grid:** 24 px with a 2 px safe area, so the live area is 20 × 20.
   - Key shapes: circle Ø20, square 18, portrait rectangle 16 × 20, landscape rectangle 20 × 16.
   - Corner radius 2 px (16 units on Phosphor's 256 grid).
2. **Keep the rendered stroke constant (optical sizing) by changing weight as size changes.**
   - Phosphor stroke = weight units ÷ 256 × px.
   - Regular: 1.5 at 24, 1.63 at 26, 1.25 at 20 (too light), 1.0 at 16.
   - Bold: 1.5 at 16, 1.69 at 18.
   - Light: 1.5 at 32.
   - Thin: 1.5 at 48.
   - So: tab 26 Regular, nav and list 24 Regular, buttons and inline 16–18 Bold, empty states 48 Thin. Everything lands at about 1.5–1.7 px, which matches the stems of SF Pro and Be Vietnam Pro Regular text.
3. **Colour:**
   - UI icons are a single colour: ink, or a muted ink for secondary.
   - The selected state only gets the accent (Ink) or the marigold pill (Pebble).
   - Duotone is only allowed inside tiles. Full colour or 3D only in "moments".
4. **Category tiles:**
   - Squircle with radius ≈ 0.33 × size: 44 tile with a 22 glyph (lists), 60 tile with a 28 glyph (grids).
   - A glyph sits on a saturated field (Marigold, Tomato, Sky, Mint, Lilac) and is always ink.
   - 3D sits on a **pastel** version of the same field at 0.6 × tile size (36 in 60), because the 3D art has built-in padding.
5. **Mixed sets and custom glyphs:**
   - Draw on Phosphor's 256 grid with a 16-unit stroke and round caps and joins.
   - Make three versions: Regular (stroke), Fill (solid with knock-outs) and Duotone (a 20%-opacity fill layer).
   - Proof at 16, 24 and 32 px, outline the strokes, then compile into the same icon font as everything else.
   - Use Tabler's `currency-dong` only as a reference.

## 5. Recommendation

### Ink
- **Set:** Phosphor Regular for outlines and **Fill** for selected tabs (all 12 tested glyphs have true pairs). Monochrome, never Duotone in the UI.
- **Delivery:** for production, build your own `AppIcons` font from `@phosphor-icons/core` 2.1.1 (MIT) plus your custom glyphs, using fantasticon or IcoMoon. Expose it as `abstract final class AppIcons { static const IconData house = IconData(0xE001, fontFamily: 'AppIcons'); … }`, which is the pattern Flutter's breaking-change doc recommends. For a quick start, use `phosphoricons_flutter` ^1.0.0.
- **Stroke:** Phosphor can't hit exactly 1.6 at 24. I suggest restating the spec as "rendered 1.5–1.7 px" and reaching it with the size/weight rules in section 4.
- **Runner-up:** Hugeicons Pro (stroke-rounded at 1.6 plus solid-rounded), if paying for it is acceptable. Hugeicons free has no fills.
- **Fun layer:** fun comes from motion: the fill-bounce on tabs and an ultramarine draw-on check for success.
  - Optionally allow Fluent Emoji 3D in at most three places: the success sheet, the first-run empty state and "goal reached". Never in the chrome.
  - Other empty states use Phosphor Thin at 48 px in `#B9B5AC`.

```
icon-family            AppIcons (Phosphor 2.1.1 + custom)
icon-size-tab          26   weight regular / fill(selected)   ≈1.63px
icon-size-nav          24   regular                           1.5px
icon-size-list         24   regular, in 40 tile #EFEDE7 r10
icon-size-button       18   bold                              ≈1.69px
icon-size-inline       16   bold                              1.5px
icon-size-empty        48   thin                              1.5px
icon-color             #1A1917 · secondary #8A8780
icon-color-selected    #3B3BF0 (fill glyph + label 600)
icon-motion-select     200ms easeOut, scale .85→1
```

### Pebble
- **UI set:** Phosphor again, so there is one pipeline.
  - Chrome: Regular at 24, ink.
  - Selected tab: a marigold `#FFC233` pill holding an ink **Fill** glyph and its label.
  - Category and quick-action tiles: **Duotone** glyph in ink on the saturated fields. This was clearly the best of the duotone options; Solar Bold Duotone came out muddy.
- **Fun set: Fluent Emoji 3D (MIT).**
  - Each category maps to exactly one 3D emoji plus one Phosphor glyph fallback. The fallback is used at 20 px and below, and in monochrome contexts such as push notifications, widgets and dense charts.
  - Allowed: the category picker and grid (60 tile, 36 emoji, pastel field); transaction rows (40 tile, 24 emoji, one per row at most); empty states (96–120); success and goal reached (96–128 with a flutter_animate spring); onboarding (160).
  - Never in tab bars, nav bars, buttons, inputs or the amount display.
  - Ship 128 px WebP for tiles and 256 px for moments, using `cacheWidth`. Pebble's soft shadows should fall down and to the right, to match the emoji's top-left light.

```
icon-size-tab 24 · tab-pill marigold #FFC233 h40 r20 · glyph fill ink #1A1712
icon-size-nav 24 regular · icon-size-inline 16 bold
tile-sm 44 r14 glyph 22 duotone · tile-lg 60 r20 glyph 28 duotone | emoji3d 36 on pastel
tile-fields  #FFC233 #FF6B4A #8EC5FF #9FE3C1 #C9B8FF · pastel #FFE3A3 #FFC7B8 #D3E8FF #D5F4E4 #E6DEFF
emoji-moment 96–128 · motion spring overshoot 1.1, 320ms
```

- **Packages:**
  - Phosphor: `phosphoricons_flutter` 1.0.0 (MIT) or the vendored font (MIT).
  - Fluent Emoji: vendored assets from microsoft/fluentui-emoji (MIT; put the MIT notice on the licences screen).
  - Supporting: `flutter_svg` 2.3.0, `vector_graphics` (BSD‑3), `flutter_animate` 4.5.2 (BSD‑3), `rive` 0.14.11 (MIT), `lottie` 3.6.1 (MIT).

## 6. Custom glyphs to draw

Two drafts are rendered in the sheets:
- **VND coin:** a đ inside a circle, with a Fill knock-out.
- **QR transfer (VietQR):** scan-frame corners, a finder square and an up-right arrow. At 16 px this needs simplifying (drop the finder).

Still to draw:
- Top-up (wallet with +)
- 24/7 bank transfer (bank with lightning)
- Split bill (receipt with people)
- Savings jar / goal (Phosphor has no jar)
- Lì xì (envelope). In 3D, Fluent's 🧧 can be used.
- Mobile top-up (phone with +)

## 7. Files

All in `/tmp/claude-0/-home-user-DesignSystem/cc2b7154-d887-54c2-bcfd-712a2b398010/scratchpad/icons/`:
- **Full sheets:** `ink.png`, `pebble.png`
- **3× close-ups:** `crops/ink-0…6.png` and `crops/pebble-0…8.png`.
  - Ink: 0 Phosphor, 1 Solar, 2 Hugeicons, 3 Lucide, 4 Fluent, 5 custom glyphs, 6 Fluent Emoji 3D.
  - Pebble: 0–4 the same UI sets, 5 custom glyphs, 6 Fluent Emoji 3D, 7 Fluent Emoji Flat, 8 3D vs duotone category tiles. The three moment cards (success, empty, goal) appear only in the full `pebble.png`.
- **Source:** `ink.html`, `pebble.html`, `build.py`, `shot.js`, `crop.js`, `custom/*.svg`, `assets/fluent3d/*.png`
- `node_modules/` (570 MB) and `pkgs/` (50 MB) can be deleted.

## 8. Sources

- pub.dev API and package pages, each checked for version, date and licence: phosphor_flutter, phosphoricons_flutter, lucide_icons_flutter, hugeicons, solar_icons, fluentui_system_icons, iconoir_flutter, flutter_tabler_icons, remixicon, material_symbols_icons, cupertino_icons, sf_symbols, animated_emoji, rive, lottie, flutter_animate, flutter_svg, not_static_icons, iconic_morph.
- npm: @phosphor-icons/core 2.1.1, lucide-static 1.49.0, @tabler/icons 3.48.0, iconoir 7.12.1, @iconify-json/solar 1.2.13 (CC‑BY‑4.0), @hugeicons/core-free-icons 4.3.5, @fluentui/svg-icons 1.1.343, @iconify-json/fluent-emoji-flat, remixicon 4.9.1.
- Licence files read raw from GitHub: microsoft/fluentui-emoji (MIT), phosphor-icons/flutter (MIT), lucide (ISC), openmoji (CC BY‑SA), noto-emoji (OFL / Apache), twemoji (CC BY).
- Flutter breaking change, IconData marked final: https://docs.flutter.dev/release/breaking-changes/icondata-class-marked-final · https://github.com/phosphor-icons/flutter/pull/62 (whether it has merged is unverified)
- SF Symbols licence: https://developer.apple.com/forums/thread/739523 · https://developer.apple.com/forums/thread/757407
- Hugeicons: https://hugeicons.com/docs/integrations/flutter · https://hugeicons.com/pricing (price from search results, unverified)
- Solar licence: https://solar-icons.vercel.app/docs/v2/community/license
- 3dicons: https://3dicons.co/about (CC0 per search results, unverified, site blocked)
- Noto animated emoji: https://googlefonts.github.io/noto-emoji-animation/ · https://github.com/google/fonts/issues/7011
- LottieFiles licence: https://lottiefiles.com/page/license
- useAnimations: https://www.gooddesign.tools/tools/useanimations (MIT claim unverified) · Unicorn Icons: https://unicornicons.com/license (unverified)
