# Premium, Apple-adjacent visual craft for a finance app: research report (Oct 2026)

## How this was researched
- **Most design sites were blocked by the proxy.** apple.com, 9to5mac, macstories, medium, blakecrosley.com, benji.org, figma and rsms.me all returned EGRESS_BLOCKED. Most case-study facts below therefore come from **WebSearch result summaries**, not from reading the pages. Each claim keeps the URL the summary cited.
- **Some things I checked directly:**
  - pub.dev package metadata (versions and dates as of 2026-10-01).
  - Google Fonts files: I downloaded the TTFs and inspected their OpenType features and digit widths with fontTools.
  - Flutter `stable` branch source on raw.githubusercontent.
  - WCAG contrast ratios for every proposed palette, computed with a script.
- **Hex and type values from "DESIGN.md" aggregator sites need care.** These are shadcn.io/design, oh-my-design.kr, refero, designmd and blakecrosley. They mostly describe the company's **marketing website**, not the app. I mark them **[aggregator, web-site tokens, unverified for app]**.

---

## 1. Case studies: the 2–3 decisions that make each app recognizable

### Award context
| Year | Relevant ADA facts |
|---|---|
| 2024 | Copilot Money was an **Innovation finalist**. Apple's text: "approachable interface and high-quality animations… colorful, elegant, easy-to-parse charts." Arc Search and finity are reported as **Interaction finalists** (sources conflict; treat as unverified). Visuals winner: Rooms. Interaction winner: Crouton. [apple newsroom 2024](https://www.apple.com/newsroom/2024/06/apple-announces-winners-of-the-2024-apple-design-awards/), [developer.apple.com/design/awards/2024](https://developer.apple.com/design/awards/2024/) |
| 2025 | Opal was a **Social Impact finalist** ([opalapp.com](https://opalapp.com/blog/apple-design-award-finalist)). Visuals winner: Feather. Interaction winner: Taobao (Vision Pro). Other finalists: iA Writer, Mela, Lumy, Denim. [apple newsroom 2025](https://www.apple.com/newsroom/2025/06/apple-unveils-winners-and-finalists-of-the-2025-apple-design-awards/) |
| 2026 | **Tide Guide** won Visuals & Graphics. **Moonlitt** won Interaction. **Structured** was an Inclusivity finalist. **(Not Boring) Camera** was a Visuals finalist. The Outsiders (Gentler Stories) was an Interaction finalist. Both winners were singled out for Liquid Glass integration. [apple newsroom 2026](https://www.apple.com/newsroom/2026/06/apple-reveals-winners-of-the-2026-apple-design-awards/), [macrumors finalists](https://www.macrumors.com/2026/05/18/apple-design-award-finalists-2026/) |

**What the judges rewarded in 2026:**
- Tide Guide: "full-screen charts filled with custom animations… aquatic theme, and **sky-matching palette**". The palette follows the colour of the sky through the day.
- Moonlitt: "easy onboarding and best-in-class Liquid Glass integration".

**The pattern:** recent ADAs reward **one strong idea for colour or data**, executed natively, over decoration.

### Finance and wallet apps
| App | Signature decisions |
|---|---|
| **Copilot Money** | (1) Ultra-dark **navy** canvas `#000814`, not grey-black, so chart colours pop. (2) Strict semantic colour: green = income, red = spend, blue = net worth, yellow = pending. (3) Charts are the main interaction layer (Swift Charts, scrubbable). Text is slightly transparent rather than pure white. Animated budget dials, a Face ID confirmation animation, haptics on tap. [blakecrosley guide, via search only](https://blakecrosley.com/guides/design/copilot-money), [Apple dev article](https://developer.apple.com/articles/copilot-money), [Money with Katie](https://moneywithkatie.com/copilot-review-a-budgeting-app-that-finally-gets-it-right/) |
| **Revolut** (Revolut 10, 2024) | (1) **Per-account backgrounds and wallpapers** plus themes, so each account is recognisable by its colour field. (2) Aeonik Pro brand face, display at weight 500, line-height 1.0, tight negative tracking [aggregator]. (3) Interactive **3D cards**: 360° flip, metallic reflections, lighting that responds to orientation. Built with SceneKit on iOS and Filament on Android. 3D-effect metal cards shipped for 50M customers. [Revolut 10 blog](https://www.revolut.com/blog/post/revolut-10/), [Revolut eng: 3D cards iOS](https://medium.com/revolut/interactive-3d-cards-for-revolut-ios-app-90a79921c159), [X](https://x.com/Revolut/status/1860041860992885160) |
| **Monzo** | (1) **One-colour discipline**: Hot Coral `#FF4F40`, with an interface about 95% achromatic so coral keeps its attention value. (2) Two faces: **Oldschool Grotesk** (rounded, "wood-block printing" warmth) for headlines, and **Monzo Sans** (custom Universal Sans) for UI. (3) Deep navy and soft white as supporting neutrals. [Creative Review](https://www.creativereview.co.uk/monzo-branding-ragged-edge/), [deck.gallery](https://www.deck.gallery/blog/monzo-brand-guidelines-breakdown/) |
| **Cash App** (2025 language) | (1) A fluorescent Cash Green field with only black and white otherwise. (2) **Cash Sans**, a custom cut of Klim's Söhne with **rounded punctuation**. (3) 650+ new icons, user-specific visuals on payment and card screens, "custom motion and responsive feedback throughout", and a widget-based home. Success screen: full green field, big white type, filled check. A ~730ms check-draw timing appeared in one search snippet [unverified]. [Design Compass](https://designcompass.org/en/2025/12/03/cash-apps-new-design-language-and-ai-moneybot/), [Creative Bloq](https://www.creativebloq.com/design/branding/cash-apps-new-brand-guidelines-make-style-guides-fun) |
| **Robinhood** (2024 rebrand by COLLINS) | (1) **Capsule Sans**, a refined Maison Neue with a custom hooked R. (2) A palette of black, white and neutrals with "purposeful pops of **Robin Neon**". (3) Dark heroes `#0E0E0E` / `#1B1B1B` [aggregator]. Its **Ticker** odometer text view is open source (Apache-2.0). **Caution for finance:** Robinhood **removed confetti in 2021** after regulators criticised "gamification". [Robinhood newsroom](https://newsroom.aboutrobinhood.com/a-visual-identity-that-better-reflects-our-vision/), [github.com/robinhood/ticker](https://github.com/robinhood/ticker), [CNBC](https://www.cnbc.com/2021/03/31/robinhood-gets-rid-of-confetti-feature-amid-scrutiny-over-gamification.html) |
| **Mercury** | (1) Custom **Arcadia / Arcadia Display**, with body type at an off-standard ~420–480 weight [aggregator]. (2) Dark-native charcoal `#171721` / `#1E1E2A`, off-white ink `#EDEDF3` rather than white [aggregator]. (3) A single cobalt or indigo `#5266EB`, reserved for the primary action. [blakecrosley](https://blakecrosley.com/guides/design/mercury), [shadcn.io/design/mercury](https://www.shadcn.io/design/mercury) |
| **Ramp** | (1) A black-and-white editorial system with **one highlighter yellow-lime** accent. (2) Lausanne as the single-weight neo-grotesk, plus a serif (Burgess) for editorial display. (3) A warm sand canvas `#F4F2F0` [aggregator]. [fontsinuse](https://fontsinuse.com/uses/38468/ramp-identity), [shadcn.io/design/ramp](https://www.shadcn.io/design/ramp) |
| **Wise** | (1) Forest green `#163300` covers most surfaces; electric lime `#9FE870` appears only on CTAs and active states. (2) **Wise Sans** display, with glyphs drawn from world scripts (a B from a Davao City sign, a G influenced by Thai), plus Inter for UI. [Creative Review](https://www.creativereview.co.uk/wise-rebrand-ragged-edge/), [Wise design blog](https://medium.com/transferwise-design/going-everywhere-meet-the-new-wise-design-system-863731563f71) |
| **Family** (crypto wallet, Benji Taylor) | Principles: **simplicity, fluidity, delight**. (1) **Dynamic trays**: sheets that grow and shrink to their content and morph into full screens; buttons morph into trays. (2) **Text morphing** on shared letters, e.g. "Continue" becomes "Confirm" by keeping "Con". (3) Card-to-screen morph transitions. [benji.org/family-values](https://benji.org/family-values), [60fps.design](https://60fps.design/shots/family-wallet-card-morph-to-screen-transition) |
| **Apple Card / Wallet** | The card **changes colour with spending categories**: Food & Drink orange, Shopping yellow, Travel green, Transportation blue, Entertainment pink, Services purple, Health red. A card with no balance shows white. The physical card is laser-etched titanium with no printed numbers. Colour comes from data, not decoration. [techjaja](https://techjaja.com/why-is-the-apple-card-a-chameleon-check-out-what-each-color-means/), [apple.com/apple-card](https://www.apple.com/apple-card/) |
| **Phantom** (wallet) | A ghost mascot as companion, periwinkle `#AB9FF2` with deep `#3C315B`, multi-tone gradients, stickers, 3D illustration, and "playful motion". It shows how to use purple without the generic AI look: tie it to a mascot and **pair it with deep, desaturated tones**. [Phantom blog](https://phantom.com/learn/blog/introducing-phantom-s-new-brand-identity) |

### Non-finance apps worth borrowing from
| App | Signature decisions |
|---|---|
| **Flighty** (ADA 2023 Interaction) | (1) Visual language borrowed from **airport signage**. (2) **15 smart states** ("far out", "head to airport", "at gate", …) that change what is shown. In the Dynamic Island, the flight becomes a progress bar and circular duration chart. (3) A 2025 "**glowing glass**" Live Activity with a visual flight path and vibrant status colour. [Apple Behind the Design](https://developer.apple.com/news/?id=970ncww4), [X](https://x.com/Flighty/status/1967632929343017412) |
| **Arc Search** | **Pinch-to-summarize**: the page folds "origami-style" into a summary, with subtle haptics. The transition went viral. "Browse for Me" builds a new page from 6 sources. [TechCrunch](https://techcrunch.com/2024/02/23/arc-browsers-new-ai-powered-pinch-to-summarize-feature-is-clever-but-often-miss-the-mark/) |
| **Things 3** | (1) The **Magic Plus** button can be dragged into a list and **deforms like a liquid** as you move it. (2) A custom in-house animation toolkit. (3) Off-white canvas with a faint blue cast and one cobalt accent [aggregator]. Recent update: more corner rounding and glassy buttons. [9to5Mac](https://9to5mac.com/2017/05/18/things-3-mac-iphone-ipad-watch/), [apphuntt review](https://apphuntt.wordpress.com/2018/08/07/things-3-for-ios-review/) |
| **Linear Mobile** | Native Swift and Kotlin. The Oct 2025 refresh added a **custom frosted glass material** and a bottom toolbar. Themes are generated in **LCH from 3 inputs (base, accent, contrast)**, producing 100+ variables. Selected rows regenerate the theme against the new base colour. [Linear changelog](https://linear.app/changelog/2025-10-16-mobile-app-redesign), [How we redesigned the Linear UI](https://linear.app/now/how-we-redesigned-the-linear-ui) |
| **Airbnb** (May 2025) | Dropped flat icons for **3D clay-like animated icons**, delivered in a custom **"Lava"** format (light video with alpha). Examples: the house door opens and the porch light turns on; the hotel bell rattles; the balloon's burner fires. [Bloomberg](https://www.bloomberg.com/news/articles/2025-06-13/apple-airbnb-ditch-flat-app-icons-for-new-3d-ui-design), [Medium deep dive](https://medium.com/@waldobear002/airbnbs-new-lava-icon-format-a-technical-deep-dive-b2604626c7e0) |
| **Opal** | Rendered **3D gems** as milestones, always on **pure black**. Gem colour encodes focus time, red encodes distraction. A "first gem" unlock animation. Brand rules forbid recolouring or adding effects to the gems. [screensdesign](https://screensdesign.com/showcase/opal-screen-time-control), [brandkit.opal.so](https://brandkit.opal.so/) |
| **(Not Boring)** | Utilities built like games: 3D, physics, haptics, **custom sound for every weather event** (by Thomas Williams), and **collectible skins**. [Apple Behind the Design](https://developer.apple.com/news/?id=9ab1g4r3), [notbor.ing](https://notbor.ing/) |
| **Partiful** | Black as the primary action colour. Invitation cards **scattered at tilted angles** over gradient washes, like a physical party surface. TWK Lausanne at −0.04em tracking for headings [aggregator]. Themed animated backgrounds. [refero](https://styles.refero.design/style/6db1057d-3457-4173-9184-df160415f060) |
| **Bear 2** | A custom face, **Bear Sans**, based on Clarika and mixing its geometric and grotesque cuts. Some glyphs come from the grotesque cut (G K Q a k t u y); M g 3 4 were redrawn. It keeps the Avenir heritage. [Bear blog](https://blog.bear.app/2023/08/learn-about-our-new-custom-font-bear-sans/) |
| **Structured** | A single vertical timeline where each task is a physical block sized by duration. Colour and icons per task. [App Store](https://apps.apple.com/us/app/structured-daily-planner-todo/id1499198946) |
| **Craft** | Nested **cards** with 5 layouts, each with its own font, background colour and image. [Craft help](https://support.craft.do/hc/en-us/articles/10293992410780-Document-Styling) |

**Patterns across these apps:**
- One owned accent on a 90–95% achromatic interface: Monzo, Mercury, Ramp, Wise, Things.
- A custom or customised display face beside a neutral UI face: Monzo, Wise, Cash, Robinhood, Mercury, Bear.
- Colour that carries meaning: Apple Card categories, Tide Guide's sky, Revolut's per-account backgrounds, Opal's gem colours.
- One physical or "object" moment: Revolut's 3D card, Opal's gems, Airbnb's Lava icons, Things' liquid button.

---

## 2. Typography with identity

### Display and UI pairing
Keep body and dense UI in **SF Pro**, the system face, so the app still reads as Apple. Use a characterful face only for screen titles, hero balances and editorial moments. Every premium example uses this split: Monzo, Wise (Wise Sans + Inter), Ramp (Burgess + Lausanne), Bear.

### Free/OFL candidates (all on Google Fonts)
I downloaded the repo variable files and checked their features and digit widths.

| Face | Axes | Numeral facts | Best use |
|---|---|---|---|
| **Newsreader** | opsz 6–72, wght 200–800 | **Digits tabular by default** (all 1100 units); has `tnum`, `pnum` | Serif hero balances that can animate without jitter. Best serif choice for money. |
| **Instrument Serif** | static Regular + Italic | **Proportional digits, no `tnum`** | Static headlines and editorial italics only. Do not use for tickers. |
| **Fraunces** | opsz 9–144, wght, SOFT, WONK | Proportional, **no `tnum`** | Warm display headings. Static numbers only. |
| **Bricolage Grotesque** | opsz 12–96, wdth 75–100, wght 200–800 | `tnum`, `lnum`, `onum` | Characterful grotesk display with optical sizes |
| **Mona Sans** / Hubot Sans | wdth 75–125, wght 200–900 | `tnum`, ss01–08 | Wide, confident display |
| **Geist** + **Geist Mono** | wght 100–900 | Geist: `tnum`, ss01–11. Mono: tabular by nature. | Precise "instrument" look |
| **Inter Tight** | wght 100–900 | `tnum`, `zero`, `case`, cv01–11, ss01–05 | Tight display companion to SF |
| **Space Grotesk** | wght 300–700 | `tnum`, `zero`, ss01–05 | Techy display |
| **Funnel Display**, **Schibsted Grotesk** (`zero`), **Manrope**, **Young Serif**, **Gloock** | various | all have `tnum` | Alternatives |
| **Hanken Grotesk** | wght 100–900 | Digits tabular by default, no toggle | Robust numbers |

**Flutter font gotcha (verified):** the font files the Google Fonts API serves are **stripped of stylistic features**.
- Inter Tight from the API exposed only `dnom frac numr pnum tnum`.
- The repo file adds `case`, cv01–cv11, ss01–05, `sups` and `zero`.
- **Fix:** bundle the full OFL variable TTFs from `github.com/google/fonts` as assets rather than fetching them at runtime. google_fonts 9.0.0 supports asset bundling.
- Set features with `TextStyle(fontFeatures: [FontFeature.tabularFigures()], fontVariations: [FontVariation('opsz', 72), FontVariation('wght', 500)])`.

### How to treat money
1. **Tabular figures** for anything that updates, sits in a column, or animates. Proportional figures are fine for a static hero, where kerning of "1" looks better. NumberFlow, the reference web implementation, forces `tabular-nums` for exactly this reason ([number-flow.barvian.me](https://number-flow.barvian.me/)).
2. **De-emphasise cents:** about 55–60% of the integer size, same baseline (or top-aligned for a "price tag" feel), in text-secondary colour. One fintech guide uses 60 SemiBold integer with 36 cents ([fintech typography](https://medium.com/design-bootcamp/the-elements-of-fintech-typography-part-1-readable-money-b6c1226acbde), [floow.design](https://www.floow.design/blog/how-to-design-a-fintech-app-screen)).
3. **Currency symbol:** about 50–60% size, one weight lighter, secondary colour, tight 2–4pt gap.
4. **Large-display tracking:** −2% to −4% at 40pt and above, as in the 112px −2.24px headline cited for Copilot's site and Revolut's −2.72px at 136px [aggregator].
5. **Signs and colour:** use a true minus U+2212 and a "+" for inflows. Prefer **neutral colour for outflows** and accent or green for inflows; this avoids a sea of red.
6. **Formatting:** format with `intl` `NumberFormat.currency` per locale.
7. **Hidden balances:** use a fixed-width mask ("••••") so layout doesn't shift.
8. **Ticker motion:** animate only digits that change, right to left, with a 15–25ms stagger.

---

## 3. Colour with character
- **Tint the neutrals.** Pure #333/#666/#999 reads as "wireframe mud". Add 2–3% chroma from the brand hue to every neutral; production systems are about 90% tinted neutrals ([uxmagic](https://uxmagic.ai/blog/ui-color-palette-apps-scalable-system)). Things uses a blue-cast off-white, Ramp a warm sand canvas, Mercury a violet-cast charcoal, Copilot a navy black.
- **Own one accent and ration it.** Monzo keeps its interface about 95% achromatic. Mercury reserves cobalt for the single primary action. Wise uses lime only on CTAs and active tabs. Rule: the accent never encodes gain or loss, and it appears at most once or twice per screen.
- **Fintech colour clichés to avoid:**
  - Neon green or lime is now shared by Robinhood, Wise, Ramp and Cash.
  - Cobalt or indigo by Mercury and Revolut.
  - Purple gradients read as generic AI.
- **Dark mode:**
  - Avoid `#000` for content screens. Material's baseline is `#121212`, and **elevated surfaces get lighter** ([Material via justcreative](https://justcreative.com/dark-mode-design/)).
  - The premium move is a **tinted black**: Copilot `#000814` (navy), Mercury `#171721` (violet-charcoal), or a warm brown-black.
  - Use off-white ink (Mercury `#EDEDF3`; Copilot uses translucent white).
  - Pure black is reserved for object showcases: Opal's gems.
  - Lift each elevation level by 4–6 L* (OKLCH or LCH) and add a hairline.
- **Gradients that don't look AI-generated:** they must **mean something**.
  - Apple Card: spend categories. Tide Guide: the sky at this hour. Revolut: a per-account wallpaper.
  - Interpolate in OKLCH, keep adjacent hues within about 60°, and use deep or desaturated end stops.
  - Add **grain at 3–6%** to kill banding.
  - Confine gradients to one hero area or the card face, never behind body text.
  - Linear generates whole themes from base, accent and contrast in LCH; that is a good model for a token generator.

---

## 4. Surfaces and depth beyond flat iOS
- **Hairlines:** a 1 physical-pixel border at about 8% ink, in both modes.
- **Dark-mode lip:** add a **1px top inner highlight at about 6% white** so the edge reads as a physical lip without blur ([technique writeup](https://codefronts.com/design-styles/css-dark-mode-ui/oled-card/)).
- **Shadows:** two layers instead of one heavy shadow. Ambient: 0 1 2 at 5–6%. Key: 0 8 24 at 6–10%. Tint the shadow toward the canvas hue, not black. In dark mode, drop shadows and use tonal steps.
- **Light source:** keep one, top-left or top-centre. Highlights sit on top edges, shadows fall down. Specular sheens on cards follow that same source; tie them to gyroscope tilt only on hero objects.
- **Glass done well (Apple's Liquid Glass guidance):**
  - Glass is for the **navigation and controls layer floating over content**, never for content itself.
  - It reads through **lensing and specular highlights**.
  - Larger glass becomes "thicker": deeper shadow, more refraction ([WWDC25 Meet Liquid Glass](https://developer.apple.com/videos/play/wwdc2025/219/)).
  - Linear Mobile uses a custom frosted material for depth.
  - In Flutter: `BackdropFilter(ImageFilter.blur(sigma 20–30))` clipped by `ClipRSuperellipse`, a 70–80% surface tint and a hairline.
  - For true refraction: `liquid_glass_renderer` 0.2.0-dev (pre-release), or native platform views via `cupertino_native_better` 1.6.0 / `native_liquid_glass` 0.3.1.
  - Flutter's built-in Cupertino will not get iOS 26 glass in-core; that work is moving to separate packages ([flutter#170310](https://github.com/flutter/flutter/issues/170310)).
- **Shape:**
  - Use continuous corners. Flutter ≥3.32 has `RoundedSuperellipseBorder`, `ClipRSuperellipse` and `Canvas.drawRSuperellipse` ([Flutter 3.32](https://blog.flutter.dev/whats-new-in-flutter-3-32-40c1086bab6e)); `figma_squircle` 0.6.3 is the fallback.
  - Nested radii: inner = outer − padding.
- **Grain:** 3–6% monochrome noise on hero and card fields only ([byteframe](https://www.byteframe.app/blog/the-role-of-noise-grain-in-modern-ui-presentation)). In Flutter, tile a 128px noise PNG with `BlendMode.softLight`, or use a `FragmentShader` (`flutter_shaders`).

---

## 5. Micro-interactions and motion that signal quality

### Motion rules (Emil Kowalski's standards)
Source: [STANDARDS.md](https://github.com/emilkowalski/skills/blob/main/skills/review-animations/STANDARDS.md).
- **Press:** scale 0.97 (range 0.95–0.98), 100–160ms, ease-out.
- **Easing:** never ease-in on UI. Strong ease-out is `cubic-bezier(0.23,1,0.32,1)`; an iOS-style drawer curve is `cubic-bezier(0.32,0.72,0,1)`.
- **Duration:** UI animations stay under 300ms; modals and drawers 200–500ms.
- **Springs:** Apple-style `duration 0.5, bounce 0.1–0.3`. Springs keep velocity when interrupted, so use them for gestures.
- **Entrances:** never scale from 0; start at 0.9–0.97 plus fade.
- **Crossfades:** add a ~2px blur during the fade to hide double images.
- **Frequency:** don't animate actions done 100+ times a day; save delight for rare moments.

### Flutter implementation (versions verified on pub.dev, Oct 2026)
| Need | Technique / package |
|---|---|
| Number roll / ticker | `number_flow` 1.0.4 (NumberFlow port), `animated_flip_counter` 0.3.4 (decimals and negatives), `animated_digit` 3.3.3. Or custom: per-digit `ClipRect` + `SlideTransition`, digit slots sized by `TextPainter` to the widest digit, `FontFeature.tabularFigures()`. Robinhood's Ticker (Android) is the reference behaviour. |
| Springs | `motor` 1.1.0 (springs and curves in one API), `springster` 1.0.2; or `SpringSimulation` + `AnimationController.animateWith` |
| Press state | `Listener` or `GestureDetector` onTapDown → scale 0.97 over 120ms ease-out; release with a spring. Tighten the shadow on press. |
| Haptics | Flutter **stable** `HapticFeedback` now includes `successNotification`, `warningNotification`, `errorNotification`, plus `selectionClick`, `light`/`medium`/`heavyImpact` (verified in the flutter/flutter stable source). `haptic_feedback` 0.8.0 adds iOS-like patterns on Android; `gaimon` 1.5.0 adds custom patterns. |
| Haptic pairing | `selectionClick` per detent on chart scrub and pickers (throttled). `lightImpact` on primary press. `successNotification` exactly when the success visual lands. `errorNotification` with a shake. |
| Skeleton → content | `skeletonizer` 3.0.0 builds the skeleton from the real widgets, so there is no layout shift. Crossfade 200ms with a 2px blur, or `shimmer` 4.0.0. |
| Shared element | `Hero` with a custom `flightShuttleBuilder`. `heroine` 0.7.2 for spring-based heroes and drag-to-dismiss. `animations` 3.0.0 `OpenContainer` for card→detail container transforms. |
| Family-style trays | `smooth_sheets` 1.2.0 or `wolt_modal_sheet` 0.11.0, with `AnimatedSize` + `AnimatedSwitcher` inside so the sheet height morphs. For text morph (Continue→Confirm) I found no established package; build it with per-glyph diffing in a `CustomPainter` or Row of glyphs. |
| Gradients / fields | `mesh` 0.5.0 (shader mesh gradients) |
| Illustration motion | `rive` 0.14.11 (state machines, interactive); `lottie` 3.6.1 |
| Live surfaces | `live_activities` 2.6.0 (Dynamic Island), `home_widget` 0.10.0 |
| Tilt / specular | `sensors_plus` 7.1.0 to drive the highlight gradient angle |

---

## 6. Signature moments: what they are and how they're built
| App | Moment | How it's built |
|---|---|---|
| Arc Search | Pinch → page folds origami-style into a summary, with haptics | A gesture-driven 3D fold plus subtle haptics; the visual buys time while the AI result loads |
| Family | Tray morphs; "Continue"→"Confirm" letter morph | A small tray system with shared-element morphs; text diffing on shared letters |
| Revolut | Rotate a 3D metal card in-app | SceneKit (iOS) and Filament (Android), lighting tied to orientation |
| Opal | First gem unlocks on pure black | A pre-rendered 3D gem on a dark stage, as reward and paywall payoff |
| Things 3 | Drag the Magic Plus, which deforms like liquid | Custom animation toolkit, velocity-based deformation |
| Flighty | Live Activity / Dynamic Island cycling through 15 states | A state machine drives the glanceable layouts; airport-signage styling |
| Airbnb | Icons come alive (door opens, bell rattles) | The "Lava" alpha-video format |
| (Not Boring) | Every weather event has its own sound, haptic and 3D scene | Game-engine approach; collectible skins |
| Cash App | Full-bleed green "sent" screen with a big check | Solid colour field, oversized type, check draw (timing unverified) |
| Tide Guide | The palette follows today's sky | Colour tokens are a function of time and sun position |

**Finance caution:** keep celebration **proportionate and non-gamified**. Robinhood removed confetti under regulatory pressure. Celebrate completion and safety (money arrived, a goal reached), not trading activity.

---

## 7. Three art directions
All contrast ratios are computed WCAG ratios against the surface. Text-3 lands at about 3.5–3.9:1, so use it only for large or meta text.

### A. **Ledger**: editorial paper and ink
**Idea:** a well-kept private bank ledger. Warm paper, serif numbers, ruled hairlines, and an ink-green accent that marks only money coming in and primary actions.

| Token | Light | Dark |
|---|---|---|
| Canvas | `#F6F3EC` | `#15130F` (warm black) |
| Surface | `#FFFDF8` | `#1E1B16` |
| Surface-2 (inset) | `#EFEBE2` | `#27231D` |
| Hairline | `#1B1A17` @10% | `#F2EDE3` @9% |
| Text 1 / 2 / 3 | `#1B1A17` (17.1) / `#5E5A52` (6.8) / `#8C877C` (3.5) | `#F2EDE3` (14.7) / `#ABA597` (7.0) / `#7C766A` (3.8) |
| Accent ("Ledger green") | `#1F5A44` (7.9; white on accent 8.1) | `#7FCBA4` (9.0) |
| Negative | `#A63A2B` | `#E58A78` |

- **Type:**
  - Balances and titles: **Newsreader** (opsz 72, wght 420–500). Its default tabular digits let it animate.
  - Rare editorial italics: **Instrument Serif Italic**, static only.
  - Body and UI: SF Pro.
  - Cents at 55% in text-2.
- **Shape:** restrained radii: 10 cards, 6 chips, continuous corners. Lists use **ruled lines** instead of cards, with a **double rule** under totals.
- **Depth:** no drop shadows. Tone plus hairlines only. 3% paper grain on the canvas only.
- **Motion:** calm. 200–260ms strong ease-out, no bounce. Digits roll vertically right to left with a 20ms stagger. Screens crossfade with an 8px rise.
- **Signature moment, "Receipt & stamp":**
  - On payment success the amount types out in serif.
  - A dashed perforation draws across (`CustomPainter`, 300ms).
  - An ink "PAID" stamp in accent lands from 1.08→1.0 scale with `heavyImpact`, then `successNotification`.
  - The receipt can be dragged to tear off and share.
- **Avoids stock iOS by:** a serif money voice, paper warmth, and rules instead of grouped inset lists.

### B. **Instrument**: graphite cockpit, dark-first
**Idea:** money as a precision instrument, in the spirit of Flighty, Linear and Mercury. Cool graphite, monospaced figures, states shown as live tracks, and one signal-orange accent.

| Token | Light | Dark (primary) |
|---|---|---|
| Canvas | `#F3F4F6` | `#0A0C0F` |
| Surface | `#FFFFFF` | `#13161B` |
| Surface-2 (raised) | `#EBEDF0` | `#1A1E25` |
| Hairline / inner highlight | `#0E1116` @8% / none | white @8% border + **1px top highlight white @6%** |
| Text 1 / 2 / 3 | `#0E1116` (18.9) / `#4B5361` (7.8) / `#6E7686` (4.6) | `#E8EBF0` (15.2) / `#9BA3B0` (7.1) / `#6B7380` (3.8) |
| Accent ("Signal orange") | fill `#FF7A1A` with ink `#0E1116` text (7.3); as text `#B84600` (5.4) | `#FF7A1A` (7.0) |
| Positive / negative | `#11875A` / `#D23B3B` | `#3DDC97` / `#FF6B6B` |

The accent is never used for amounts.

- **Type:**
  - Display: **Geist** 600 at −2% tracking.
  - All figures, IDs and overline labels: **Geist Mono** (labels 11pt caps at +6% tracking).
  - Body: SF Pro.
  - Alternative pair: Inter Tight + JetBrains Mono.
- **Shape:** 12 cards and 8 controls (superellipse), full pills for status. Visible structure: chart tick marks, segmented progress bars, 4pt grid.
- **Depth:** tonal elevation (+5 L* per level), hairline plus top inner highlight, no shadows in dark mode. Glass only on the floating tab bar and toolbar (blur sigma 24, 75% surface tint).
- **Motion:** fast and exact. 120–180ms, critically damped springs with no bounce. Changed digits flip like a split-flap board; unchanged digits stay still. Chart scrub ticks `selectionClick` at each point. A pulsing "live" dot.
- **Signature moment, "Transfer flight strip":**
  - A Flighty-style status capsule for money in motion: Initiated → Clearing → Arrived, as a segmented track with an ETA countdown.
  - It mirrors to the Dynamic Island and Lock Screen via `live_activities`.
  - On arrival, the segment fills with a 1s sweep, then `successNotification`.
- **Avoids stock iOS by:** mono numerics, a cockpit hierarchy, orange where you expect blue, and live states.

### C. **Pebble**: tactile objects in warm daylight
**Idea:** accounts and cards are physical, colourful objects (Revolut cards, Opal gems, Airbnb clay) on a warm, sunlit table. Soft and friendly, yet restrained: colour lives only on the objects.

| Token | Light | Dark |
|---|---|---|
| Canvas | `#F2EEE8` | `#17140F` |
| Surface | `#FFFFFF` | `#221E18` |
| Surface-2 | `#F8F5F0` | `#2C271F` |
| Text 1 / 2 / 3 | `#1A1712` (17.9) / `#5F584D` (7.0) / `#8F877A` (3.6) | `#F5F0E8` (14.6) / `#B3AA9C` (7.2) / `#837A6D` (3.9) |
| Accent ("Marigold") | fill `#FFC233` with ink `#1A1712` text (11.1) | same `#FFC233` |
| Positive / negative | `#1E7A4C` / `#C2412D` | `#6FD39B` / `#FF8A73` |
| Object colour fields (per account, user-picked) | Marigold `#FFC233`, Tomato `#FF6B4A`, Sky `#8EC5FF`, Mint `#9FE3C1`, Lilac `#C9B8FF`, Graphite `#2B2925` | same, with a 6% darker gradient end stop |

- **Type:**
  - Headings and balances: **Bricolage Grotesque** (opsz 96, wdth 88, wght 700, `tnum` on).
  - Body: SF Pro; SF Pro Rounded for chips.
  - Alternatives: Funnel Display, Mona Sans in a wide width.
- **Shape:** generous radii: 26 cards, 18 tiles, full pills, superellipse throughout. Cards on Home stack with a 12pt peek and fan out on scroll.
- **Depth:**
  - Real two-layer shadows tinted by the object's colour (0 1 2 @6%, 0 10 28 @10%).
  - A 1px top inner highlight at 40% white on coloured objects.
  - A specular gradient that moves with gyroscope tilt (`sensors_plus`), lit from top-left.
  - 4% grain on object faces.
  - Canvas stays flat.
- **Motion:** springy but short (bounce 0.15–0.2). Press scales to 0.96 and the shadow tightens. Number roll with a small overshoot. Cards move between list and detail via `heroine`.
- **Signature moment, "Tap to pay":**
  - On payment success the card dips toward the screen like a tap on a reader, with a scale and shadow squash.
  - A marigold ring ripples out once, and `successNotification` fires.
  - The amount rolls into place.
  - Monthly, the card's face gradient shifts toward the dominant spending category, Apple Card style.
- **Avoids stock iOS by:** objects instead of grouped lists, colour encoding identity and data, and warm light.

**How the three differ:**
| | Ledger | Instrument | Pebble |
|---|---|---|---|
| Light / temperature | Warm paper | Cool graphite | Warm sunlight |
| Number voice | Serif | Mono | Rounded grotesk |
| Depth | Rules and tone | Hairlines and tonal steps | Shadows and specular |
| Motion | Calm ease-out | Instant critically-damped springs | Gentle bounce |
| Accent | Ink green | Signal orange | Marigold |

None of them uses iOS blue `#007AFF`, grouped inset lists as the main pattern, or a purple gradient.

---

## Things I could not verify
- Exact hex and type values from aggregator sites; they describe marketing websites.
- Cash App's ~730ms check-draw timing.
- Whether Arc Search and finity were 2024 Interaction finalists (sources conflict).
- Details inside blocked pages: Benji Taylor's essay, Apple's Behind the Design article for Flighty, Revolut's Medium engineering posts. I relied on their search snippets.

