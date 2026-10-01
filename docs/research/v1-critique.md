# Design critique: Mobile Design System v1

**I rendered it.** I built a harness at `critique/harness.html`. It turns `tokens.json` into CSS variables (`gen-tokens.js` → `tokens.css`) and loads `bundle.css`, `bundle.js` and React 18 UMD. With it I composed a 390×844 wallet home and a transfer sheet, in light and dark. SF Pro isn't available on Linux, so Inter stands in for it, which is the Android font the system already specifies. Backdrop blur needed SwiftShader flags to render. I also built a proposal mock (`proposal.html` + `prop.css`) to check that the fixes below actually look right before recommending them. No source files were modified.

Screenshots are in `/tmp/claude-0/-home-user-DesignSystem/cc2b7154-d887-54c2-bcfd-712a2b398010/scratchpad/critique/shots/`:
- **As shipped:** `home-light.png`, `home-dark.png`, `sheet-light.png`, `sheet-dark.png`, `components-light.png`, `components-dark.png`, `crop-tabbar-light.png`, `crop-tabbar-dark.png`
- **Proposal:** `proposal-home-light.png`, `proposal-home-dark.png`, `proposal-sheet-light.png`, `proposal-sheet-dark.png`

---

## Verdict

The owner is right: this is iOS Settings with a blue swapped in. Almost every value is lifted straight from Apple:
- **Neutrals:** `#F2F2F7`, `#1C1C1E`, `#2C2C2E`, `#636366` are the iOS system grays. `#1D1D1F`, `#6E6E73`, `#86868B`, `#F5F5F7` are apple.com's marketing grays.
- **Type:** the 11 Dynamic Type roles, copied verbatim, including tracking.
- **Components:** each one maps to a stock Cupertino widget.

The craft is competent: contrast is checked, springs are specified, concentric radii are documented. But nothing in the system belongs to *this* product. "Apple-feel" has been read as "Apple's values". The real Apple feel is restraint, precision and a lot of care in a few places; it is not `#F2F2F7`.

On a real screen, three things give it away:
1. Blue is everywhere at once.
2. The home screen has two competing headlines: the "Wallet" large title and the 48px balance.
3. Section headers are 13px gray settings labels on a money screen.

### Bugs found in rendering (fix these first)
- **`.mds-row` overflows its group by 16px.** It has `width:100%` plus `padding-left:16px` and no `box-sizing`, so the trailing padding is eaten. Toggles sit flush against the group's right edge (measured: group right 374, toggle right 374), and chevrons and values are 16px too far right. Fix: `.mds-row { box-sizing: border-box; }`.
- **Button labels wrap.** "Top up" breaks onto two lines in a flex row. Fix: `.mds-btn { white-space: nowrap; }`, and give `lg` a `min-width` only when it isn't in a row.
- **The transfer sheet has two primary actions:** the prominent ✓ disc and the bottom "Send" button. Pick one; for money, keep the bottom CTA.
- **Wrong number format for Vietnamese.** "1,250,000 ₫" is en-US grouping; vi-VN is `1.250.000 ₫`. Never hardcode it: `NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0)`.
- **The sheet breaks the system's own concentric rule.** It is inset 8px from a display whose corners are about 55px, so its bottom corners should be 47px, not 32px.
- **Tab bar has no bottom content inset or fade.** List content collides with the glass.

---

## 1. Color

**Neutrals.** These are pure Apple grays, slightly blue (`#F2F2F7`). They read as "system default" because they are. Own a ramp instead: a faintly warm "paper" neutral, all derived from one ink, so every gray belongs to the same family.

| token | light | dark |
|---|---|---|
| bg-canvas | `#F4F3EF` | `#0D0D0C` (near-black, not `#000`) |
| bg-surface | `#FFFFFF` | `#1A1918` |
| bg-elevated (sheet) | `#F4F3EF` | `#1F1E1C` |
| bg-surface-elevated | `#FFFFFF` | `#2A2926` |
| bg-selected (thumbs) | `#FFFFFF` | `#3A3834` |
| fill-subtle / fill-strong | `rgba(31,28,22,.06)` / `.12` | `rgba(255,250,240,.07)` / `.12` |
| separator | `rgba(31,28,22,.09)` | `rgba(255,250,240,.10)` |
| fg-primary | `#1A1917` | `#F4F2ED` |
| fg-secondary | `#6B6760` (5.06:1 on canvas, 5.62:1 on white) | `#A3A099` (7.45:1 on canvas, 5.57:1 on `#2A2926`) |
| fg-tertiary | `#A9A59D` | `#6A6761` |
| border-control / icon-secondary | `#8C8881` (3.53:1 on white) | keep `#8E8E93`-ish → `#8A8780` |

**Accent.** `#0A60DD` is not a choice. It is iOS link blue darkened, and blue is also the default color of most Vietnamese banking and wallet apps (ZaloPay, VNPay, MB, VietinBank). Two moves:

1. **Primary actions in ink, not accent.**
   - New tokens: `ink` `#1A1917` / dark `#F4F2ED`; `on-ink` `#FFFFFF` / dark `#141312` (16.6:1); `ink-pressed` `#34322E` / dark `#D9D6CF`.
   - "Send" becomes a black capsule in light and a bone capsule in dark. This is the Apple Card / Apple Pay register, and it reads as premium immediately.
2. **One owned accent, spent sparingly.** I used ultramarine:
   - `accent` `#3B3BF0` (6.84:1 with white) / dark fill `#5B5BF5` (white text 4.93:1)
   - `accent-fg` `#3434D9` / dark `#A5A5FF` (7.88:1 on `#1A1918`)
   - `accent-soft` `#ECECFE` / dark `#24234D`

   The exact hue is the brand owner's call. The rule matters more than the hue: accent marks **selection, progress, "now", links and the signature moment**. It does not mark every button.

**How color is spent.** The current home shows six blue things at once: Top up, Send, Request, the salary tile, the tab and the button labels. After the fix there is one: the "today" bar in the chart, plus "See all". Category color goes into soft monogram tints instead, for example coffee `#F1E7DC` / `#7A4A21` and transport `#E2EFE6` / `#1F6B3B`, with dark equivalents at about 20% luminance.

**Status colors.**
- `success`: `#1C7A4A` light (5.34:1) / `#4CC38A` dark. This is less "iOS green" and pairs with the warm neutrals.
- Add `success-soft` `#E5F3EB` / `#15291F` for delta chips.
- `danger`: `#C8102E` / `#FF6B63`.

**Dark mode character.** Today it is `#000` plus `#1C1C1E` plus a `#636366` segmented thumb: exactly iOS. Make it near-black `#0D0D0C`, warm. Give raised surfaces a top highlight instead of shadow: `box-shadow: inset 0 0.5px 0 rgba(255,255,255,.06)`. Tune glass to `rgba(38,37,34,.66)`. It should read as lacquer, not as the system.

## 2. Typography

**Problems:**
- The system font only, with the iOS scale copied verbatim. Typography carries zero identity.
- `amount-display` 48/600/−0.5 at that size looks like a calculator. The `₫` is set at full size and weight; in SF and Inter it's an underlined đ, a heavy blob next to the digits.
- `flutter.md` applies SF's tracking table to Inter on Android. That is wrong: +0.4px at 34px is loose and amateurish in Inter.
- `large-title` "Wallet" plus the balance on one screen means two heroes.

**Fixes:**
- **Display face for money and hero titles only; SF for all UI.** I recommend **Be Vietnam Pro** 500/600 (OFL, made for Vietnamese diacritics; I rendered it). It keeps the Apple neo-grotesk register but has noticeably more character in the 1, 2 and 5. Bundle it in Flutter as `fontFamily: 'BeVietnamPro'`.
  - Caveat: the build I tested has **no `tnum`** (measured: `1111` and `0000` have different widths with `tnum` on). Use it for static hero amounts, where proportional digits actually look better at 40px and up. Keep SF/Inter tabular for list columns. Build the odometer from fixed-width digit slots.
  - If tabular display digits are mandatory, fall back to SF Pro Display / Inter Display at the same settings.
- **New numeric roles:**
  - `amount-hero` 52/56, weight 600, tracking −2.2px (≈ −4.2%)
  - `amount-entry` 60/64, 600, −2.6px
  - `amount-card` 24/30, 600, −0.7px
  - `amount-row` SF 17/22, weight 500, −0.3px, tnum
  - **Currency rule:** at 40px and above, `₫` at 0.5em, weight 500, `fg-secondary`, raised 0.62em (superscript), 0.12em gap. Under 24px, 0.72em on the baseline.
  - Minus is U+2212 `−`, not a hyphen; plus is explicit `+`.
- **Android/Inter tracking:** 34 → −0.7px, 28 → −0.5, 22 → −0.35, 20 → −0.3, 17 → −0.2, 15 → −0.1, 13 → 0, 11 → +0.1. Or use Inter's opsz axis.
- **Content-section headers** (not settings headers): `title-3` 20/25/600/−0.45, with a trailing plain link ("See all", 15/500, `accent-fg`) aligned to the 20px gutter. Keep 13px gray headers for settings and forms only.
- **Row titles on content lists:** 16/500/−0.31 with a 13/18 subtitle. Body 17/400 reads like a settings label.

## 3. Layout, density and rhythm

**Problems:**
- Everything sits at the same gutter with similar gaps, so the screen reads as one list.
- There are three left edges: title at 16, section header at 32, row text at 74.
- The segmented control floats on the home screen with no content it controls.
- 2-line transaction rows use a 30px tile, which is undersized.
- A chevron on every transaction row is noise.

**Fixes:**
- **Home has no large title.** The top bar holds a 36px ink avatar monogram, a greeting (13/16 secondary) and the name (15/600), with glass Search and Bell buttons on the right. The balance *is* the title.
- **Vertical rhythm:**
  - status bar → top bar 6
  - top bar → hero 28
  - eyebrow → amount 4
  - amount → delta chip 12
  - chip → actions 24
  - actions → insight card 36
  - card → section header 36
  - header → list 10
- Use a **20px gutter at ≥390pt width**. Use 16px for cards and groups, so content sits 4px inside the text gutter.
- **Actions:** `grid-template-columns: 1fr 1fr 50px; gap: 8px`, holding [Send (ink)] [＋ Top up (surface)] [More (circle)]. Use a 50px height everywhere. No three equal blue capsules.
- **Move Week/Month/Year into an insight card** (radius 22, padding 16): a compact segmented control with 13/600 labels and 4×10 segments, a 30-bar spend chart 56px tall with 2px bar radius and `fill-strong` bars, today in `accent`, future days at 35% opacity.
- **Transaction rows:**
  - leading: 40px circular monogram
  - padding 12/16, gap 12
  - no chevron; the whole row is tappable, as in Wallet's transaction list
  - subtitle format: "Category · time"
  - separator inset to the text start, 0.5px
- **Bottom of the screen:** add a fade `linear-gradient(transparent, var(--bg-canvas) 85%)`, 140px tall, under the tab bar. Set scroll bottom inset to tab bar height + 26 + 16.

## 4. Surfaces and depth

**Problems:**
- Flat gray-on-white with no edges. White groups on `#F2F2F7` are fine in light mode but turn to mush in dark.
- In light mode, glass at 0.78 over white content is just a gray smear.
- The selected tab is a `fill-subtle` gray capsule on glass: a muddy blob (`crop-tabbar-light.png`).

**Fixes:**
- **Surface edge, not shadow:** light `box-shadow: 0 0 0 0.5px rgba(31,28,22,.05)`; dark `inset 0 0.5px 0 rgba(255,255,255,.06)`.
- **Glass recipe.**
  - Fill: light `rgba(252,251,248,.72)` + `blur(24px) saturate(180%)`.
  - `shadow-glass`, light: `inset 0 .5px 0 rgba(255,255,255,.9), 0 0 0 .5px rgba(31,28,22,.06), 0 10px 30px -6px rgba(31,28,22,.18)`.
  - `shadow-glass`, dark: `inset 0 .5px 0 rgba(255,255,255,.12), 0 0 0 .5px rgba(255,255,255,.06), 0 12px 32px rgba(0,0,0,.6)`.
  - Flutter: `BackdropFilter(ImageFilter.blur(sigmaX: 24, sigmaY: 24))`. Add a 0.5px top highlight via `foregroundDecoration`.
- **One "thumb" language.** The selected tab, the segmented thumb and the toggle knob are all a raised `bg-selected` pill with `shadow-knob: 0 0 0 .5px rgba(31,28,22,.06), 0 2px 6px rgba(31,28,22,.14)`. A white thumb on glass reads crisp and premium (see `proposal-home-light.png`).
- **Radii:**
  - groups and cards 20 → 22
  - fields 12 → 14 (concentric with 22 at 8px inset)
  - tiles → circles for people and merchants; keep 10px squircles only for settings glyph tiles
  - sheet `32px 32px 47px 47px` when floating 8px inset

## 5. Components

| Component | Reads as stock because | 1–2 crafted details |
|---|---|---|
| **Button** | `CupertinoButton.filled` in blue; 5 variants at equal visual weight | Prominent = `ink` capsule, 600 / −0.3px. Press: scale 0.97 in 80ms ease-out; release with `spring.snappy`; fill to `ink-pressed`. Loading keeps the label width (spinner replaces the icon only; label → "Sending…"). Drop `gray`-with-blue-text; secondary = surface capsule with a 0.5px edge and `fg-primary` text. |
| **IconButton** | iOS 26 glass disc verbatim | Icon stroke 1.7 at 20px (now 2.2, too chunky against SF Regular). Pressed: scale 0.92 plus glass fill +6% opacity. Prominent ✓ only when no bottom CTA exists. |
| **ListSection / ListItem** | `CupertinoListSection.insetGrouped` exactly; 30px colored tile; chevron everywhere | Two row anatomies: **settings row** (30px glyph tile r10, 17/400, chevron 14px @ 2.0 stroke) and **content row** (40px monogram, 16/500 title, 13/18 subtitle, trailing amount 17/500 tnum, no chevron). Pressed row: instant `fill-subtle`, 250ms fade out. Fix `box-sizing`. |
| **TextField** | Web/Bootstrap: 15/600 label + 1px `#86868B` outline + "! error" | Filled, outline-less field: `bg-surface-elevated`, radius 14, height 50, 0.5px edge. Focus = 1.5px `accent` ring + 150ms fade. Error = 1.5px `danger` ring + a `exclamationmark.circle.fill` 13px glyph. Label 13/500 `fg-secondary` or inline placeholder-as-example. **Add an `AmountField`**: centered 60px display amount, 3×50px accent caret blinking at 1s steps, quick-add chips (+100K / +500K / +1M), "Available …" pill. |
| **Toggle** | `CupertinoSwitch`; off track invisible on white | Off track `fill-strong` (`rgba(31,28,22,.12)`). Knob stretches 28→34px wide while pressed (iOS detail), springs back with `snappy`. `haptic.selection` on commit, not on press. |
| **SegmentedControl** | Dark thumb `#636366` = iOS | Thumb `bg-selected` + `shadow-knob`. Compact variant (28px tall, 13/600 labels) for in-card filters. Selected label goes 500→600 with no width jump (reserve width with a hidden bold copy). |
| **NavigationBar** | Large title 34/700/+0.4: Settings.app | Root screens of content tabs get a custom header (avatar + greeting) or a display-face large title (Be Vietnam Pro 32/600/−0.9). Collapsed bar: glass + a 0.5px separator that fades in over 150ms only after scroll > 8px. |
| **TabBar** | Glass capsule + gray selected blob + stroke-weight-as-selection | Sliding white thumb (same as segmented). Unselected `fg-secondary` outline icons at 1.6 stroke; selected `fg-primary` **filled** icon + 600 label. Thumb slides with `snappy` and stretches `scaleX(1.08)` mid-flight. |
| **Sheet** | ✕ + title + ✓ discs + generic form | No trailing ✓; the bottom CTA owns the confirm. Recipient block (52px monogram, 17/600 name, 13 secondary bank •• 6789) above an amount hero. Concentric bottom radius 47. The presenting screen scales to 0.94 and rounds (`showCupertinoSheet` does this). |

**Icons.** The preview strokes run 2.0–2.6 at 16–24px, heavier than SF Symbols Regular. Normalize to 1.6–1.7 at 20–24px and 2.0 at 14px. The README says "filled for selected tab", but the bundle thickens the stroke instead. Implement the filled version.

## 6. Signature moment: "the number"

Make money itself the brand. Every amount, everywhere, uses the display face with the superscript-`₫` treatment, so a screenshot is recognizable without a logo. The one place richness is spent is the **send flow**:

1. **AmountField:** digits enter with a 120ms rise (y +6 → 0, opacity 0 → 1).
2. **Hold to send:** an ink capsule 56px tall. Holding fills it left→right with `accent` over **600ms linear** (linear because it represents time). The label is drawn twice, with the top copy clipped to the fill so the text inverts cleanly. `HapticFeedback.selectionClick` fires at 33% and 66%, `mediumImpact` at 100%. Releasing early springs the fill back (`smooth`). Face ID runs after the hold completes.
3. **Success:**
   - The capsule morphs into a 56px circle with a ✓ (width animates under `spring.smooth`).
   - The amount travels as a shared element (Flutter `Hero`) to the receipt, landing with `spring.bouncy` (0.5s, bounce 0.3), the only bounce in the app.
   - `haptic.success`.
4. **Back on home:** the balance **odometer-rolls** to the new value. Use fixed-width digit slots; each digit translates vertically, staggered 24ms right→left, under `spring.smooth`.

**Reduce Motion:** the hold becomes "Tap to send" + Face ID, and the roll becomes a 250ms cross-fade.

## 7. Motion and micro-interactions (beyond the signature)

- **Press feedback:** press-in at 80ms `ease-out` (not a spring; the finger must feel the response immediately). Release via `spring.snappy`. Buttons scale 0.97, icon buttons and tiles 0.92, rows get instant highlight with a 250ms fade-out.
- **Tab switch:** the thumb slides with stretch, and the icon swaps outline→fill on a 120ms cross-fade. No content slide between tabs.
- **List insert** (new transaction): the row height expands from 0 under `smooth`, the content fades in 150ms after a 100ms delay, and the new amount flashes a `success-soft` row background, fading out over 600ms.
- **Pull to refresh on the balance:** the chip text cross-fades to "Updated just now" (150ms), with no spinner when refresh takes under 300ms.
- **Loading:** static `fill-subtle` skeleton blocks pulsing opacity 1 ↔ 0.55 over a 1.2s ease-in-out. No shimmer gradient.
- **Web previews:** springs are approximated with `cubic-bezier(0.3,1.25,0.5,1)`. Use `linear()` spring curves from the token values instead, so the docs match the Flutter physics.

---

## Top 10 revisions (highest impact first)

1. **Owned warm neutral ramp:** canvas `#F4F3EF`/`#0D0D0C`, surface `#FFF`/`#1A1918`, raised dark `#2A2926`, fg `#1A1917`/`#F4F2ED`, secondary `#6B6760`/`#A3A099`. Retire every Apple system gray.
2. **Primary action = ink:** new `ink` `#1A1917`/`#F4F2ED` and `on-ink` `#FFF`/`#141312`. Accent (e.g. `#3B3BF0` / dark fill `#5B5BF5`, fg `#A5A5FF`) only for selection, progress, "now", links and the signature.
3. **Money typography:** Be Vietnam Pro 600 for amounts, hero 52/56/−2.2px, entry 60/64/−2.6px. `₫` at 0.5em, weight 500, secondary, raised 0.62em (0.72em on the baseline under 24px). vi-VN grouping `24.580.000`. True minus `−`.
4. **Fix the bugs:** `.mds-row { box-sizing: border-box }`, `.mds-btn { white-space: nowrap }`, a single confirm action in the sheet, sheet bottom radius 47px.
5. **Recompose home:** no large title; avatar + greeting bar; balance as hero; actions `1fr 1fr 50px` with an 8px gap; insight card with the segmented control and a 30-bar chart; "Activity" header at 20/600 + "See all"; rhythm 28/12/24/36/36/10.
6. **Content row anatomy:** 40px monogram with category tint, 16/500 title, 13/18 "Category · time" subtitle, 17/500 tnum amount, no chevron, 12px vertical padding. Settings rows keep 30px r10 tiles.
7. **One thumb language:** the tab bar, segmented control and toggle share a `bg-selected` raised thumb with `shadow-knob: 0 0 0 .5px rgba(31,28,22,.06), 0 2px 6px rgba(31,28,22,.14)`. Selected tab = filled icon + 600 label; the thumb slides with `snappy` and `scaleX(1.08)` stretch.
8. **Filled, outline-less TextField** (radius 14, 0.5px edge, 1.5px accent focus ring) plus a new `AmountField` component (centered 60px, accent caret, +100K/+500K/+1M chips, "Available" pill).
9. **Signature send flow:** 600ms linear hold-to-send with clipped inverted label, haptics at 33/66/100%, capsule→✓ morph, `Hero` amount to the receipt with `spring.bouncy`, odometer roll on the balance (24ms stagger).
10. **Depth and detail polish:**
    - surface edges: `0 0 0 .5px rgba(31,28,22,.05)` light, `inset 0 .5px 0 rgba(255,255,255,.06)` dark
    - glass fill `rgba(252,251,248,.72)` / `rgba(38,37,34,.66)` with a 0.5px top highlight
    - 140px canvas fade under the tab bar
    - icon strokes 1.6–1.7, filled selected states
    - correct Inter tracking on Android (34 → −0.7px, 17 → −0.2px)
