# Apple-style mobile design system: research report (verified October 2026)

**How this was checked.** Almost every value below comes from Apple primary sources. I read the HIG pages, Apple API reference pages and WWDC transcripts directly from developer.apple.com (the HIG's JSON data endpoint returns the same content as the rendered page). Most third-party sites were blocked by the network proxy. So when Apple doesn't publish a number, I mark it **UNVERIFIED** rather than guess.

**Platform baseline.** iOS 26 introduced Liquid Glass at WWDC25. iOS 27 refined it at WWDC26; that is covered in §9.

### Source keys (each value is tagged with one of these)

| Key | URL |
|---|---|
| T | https://developer.apple.com/design/human-interface-guidelines/typography (updated Dec 16 2025) |
| C | https://developer.apple.com/design/human-interface-guidelines/color (updated Jun 9 2025 and Dec 16 2025) |
| DM | https://developer.apple.com/design/human-interface-guidelines/dark-mode |
| M | https://developer.apple.com/design/human-interface-guidelines/materials |
| L | https://developer.apple.com/design/human-interface-guidelines/layout |
| A | https://developer.apple.com/design/human-interface-guidelines/accessibility |
| MO | https://developer.apple.com/design/human-interface-guidelines/motion |
| H | https://developer.apple.com/design/human-interface-guidelines/playing-haptics |
| B | https://developer.apple.com/design/human-interface-guidelines/buttons |
| SH | https://developer.apple.com/design/human-interface-guidelines/sheets |
| TB | https://developer.apple.com/design/human-interface-guidelines/tab-bars |
| TO | https://developer.apple.com/design/human-interface-guidelines/toolbars (the navigation bar now lives here; /navigation-bars returns 404) |
| LT | https://developer.apple.com/design/human-interface-guidelines/lists-and-tables |
| TF | https://developer.apple.com/design/human-interface-guidelines/text-fields |
| SC | https://developer.apple.com/design/human-interface-guidelines/segmented-controls |
| TG | https://developer.apple.com/design/human-interface-guidelines/toggles |
| CM | https://developer.apple.com/design/human-interface-guidelines/context-menus |
| AL | https://developer.apple.com/design/human-interface-guidelines/alerts |
| AS | https://developer.apple.com/design/human-interface-guidelines/action-sheets |
| SF | https://developer.apple.com/design/human-interface-guidelines/sf-symbols |
| IC | https://developer.apple.com/design/human-interface-guidelines/icons |
| W356 | https://developer.apple.com/videos/play/wwdc2025/356/ ("Get to know the new design system") |
| W219 | https://developer.apple.com/videos/play/wwdc2025/219/ ("Meet Liquid Glass") |
| W323 | https://developer.apple.com/videos/play/wwdc2025/323/ ("Build a SwiftUI app with the new design") |
| W284 | https://developer.apple.com/videos/play/wwdc2025/284/ ("Build a UIKit app with the new design") |
| W23S | https://developer.apple.com/videos/play/wwdc2023/10158/ ("Animate with springs") |
| W18F | https://developer.apple.com/videos/play/wwdc2018/803/ ("Designing Fluid Interfaces") |
| W26S | https://developer.apple.com/videos/play/wwdc2026/269/ ("What's new in SwiftUI", 2026) |
| W26U | https://developer.apple.com/videos/play/wwdc2026/278/ ("Modernize your UIKit app", 2026) |
| API | https://developer.apple.com/documentation/swiftui/… and /uikit/… (the specific symbol is named inline) |
| FL | https://raw.githubusercontent.com/flutter/flutter/master/packages/flutter/lib/src/cupertino/colors.dart (secondary source; see §2.3) |
| INTER | https://raw.githubusercontent.com/rsms/inter/master/README.md and the rsms/inter docs/index.html |

---

## 1. Typography

### 1.1 Dynamic Type at the default size ("Large"), iOS and iPadOS [T]

The weight, size and leading columns come straight from the HIG table. The tracking column is my lookup of each size in the HIG SF Pro tracking table (§1.2).

| Style | Weight | Size (pt) | Leading (pt) | Emphasized weight (`.bold()`) | Tracking |
|---|---|---|---|---|---|
| Large Title | Regular | 34 | 41 | Bold | +0.40 pt (+12/1000 em) |
| Title 1 | Regular | 28 | 34 | Bold | +0.38 pt (+14) |
| Title 2 | Regular | 22 | 28 | Bold | −0.26 pt (−12) |
| Title 3 | Regular | 20 | 25 | Semibold | −0.45 pt (−23) |
| Headline | Semibold | 17 | 22 | Semibold | −0.43 pt (−26) |
| Body | Regular | 17 | 22 | Semibold | −0.43 pt (−26) |
| Callout | Regular | 16 | 21 | Semibold | −0.31 pt (−20) |
| Subhead | Regular | 15 | 20 | Semibold | −0.23 pt (−16) |
| Footnote | Regular | 13 | 18 | Semibold | −0.08 pt (−6) |
| Caption 1 | Regular | 12 | 16 | Semibold | 0 |
| Caption 2 | Regular | 11 | 13 | Semibold | +0.06 pt (+6) |

**Scaling across the Dynamic Type range** [T]

| Setting | Body size / leading | Large Title size / leading |
|---|---|---|
| xSmall | 14 / 19 | 31 / 38 |
| Small | 15 / 20 | 32 / 39 |
| Medium | 16 / 21 | 33 / 40 |
| Large (default) | 17 / 22 | 34 / 41 |
| xLarge | 19 / 24 | 36 / 43 |
| xxLarge | 21 / 26 | 38 / 46 |
| xxxLarge | 23 / 29 | 40 / 48 |
| AX1 | 28 / 34 | 44 / 52 |
| AX2 | 33 / 40 | 48 / 57 |
| AX3 | 40 / 48 | 52 / 61 |
| AX4 | 47 / 56 | 56 / 66 |
| AX5 | — | 60 / 70 |

I extracted the full per-style table for every setting and can supply it.

**Size floor and default** [T][A]
- Default text size is 17 pt; the minimum is 11 pt.
- Avoid the Ultralight, Thin and Light weights. Prefer Regular, Medium, Semibold or Bold.

**Large titles in practice.** The table lists Large Title as Regular, but the system navigation bar renders it in the emphasized (Bold) weight. This is an observation, **UNVERIFIED** in docs.

**iOS 26 change.** Typography is "bolder and left-aligned to improve readability in key moments like alerts and onboarding" [W356].

### 1.2 SF Pro tracking table, iOS (selected rows) [T]

| Size (pt) | 1/1000 em | pt |
|---|---|---|
| 6 | +41 | +0.24 |
| 8 | +26 | +0.21 |
| 10 | +12 | +0.12 |
| 11 | +6 | +0.06 |
| 12 | 0 | 0 |
| 13 | −6 | −0.08 |
| 14 | −11 | −0.15 |
| 15 | −16 | −0.23 |
| 16 | −20 | −0.31 |
| 17 | −26 | −0.43 |
| 18 | −25 | −0.44 |
| 19 | −24 | −0.45 |
| 20 | −23 | −0.45 |
| 21 | −18 | −0.36 |
| 22 | −12 | −0.26 |
| 23 | −4 | −0.10 |
| 24 | +3 | +0.07 |
| 28 | +14 | +0.38 |
| 34 | +12 | +0.40 |
| 40 | +10 | +0.37 |
| 48 | +8 | +0.35 |
| 60 | +4 | +0.26 |
| 72 | +2 | +0.14 |
| 80 and up | 0 | 0 |

The HIG also has separate tables for SF Pro Rounded, New York and others.

### 1.3 SF Pro Text vs Display, and optical sizing
- **Dynamic optical sizes.** SF and New York ship as variable fonts with "dynamic optical sizes, which merge discrete optical sizes (like Text and Display) and weights into a single, continuous design" [T]. You don't need to choose Text or Display unless your design tool can't handle variable fonts [T].
- **Tracking adjusts automatically in code.** In a running app the system adjusts tracking at every size. In mockups you may need to apply the tracking table yourself [T].
- **Range.** Nine weights (Ultralight to Black), plus Condensed and Expanded widths and a Rounded variant [T]. SF Pro supports more than 150 languages (https://developer.apple.com/fonts/).
- **Display at 20 pt and above.** The old rule of thumb ("SF Pro Display at 20 pt+, Text below 20 pt") is no longer stated in the current HIG. Treat it as **UNVERIFIED** legacy guidance.
- **Don't bundle SF.** "Don't embed system fonts in your app" [T, developer note].
- **Licensing.** I could not read the SF font license in this session (it ships inside the download DMG). It's commonly reported to restrict SF to Apple-platform UI mockups. **UNVERIFIED**; check it before using SF on Android or the web.

### 1.4 Cross-platform recommendation
- **iOS:** use the system font through text styles. You get Dynamic Type, Bold Text and optical sizing for free [T].
- **Android and web:** use Inter.
  - It's a variable font with weights 100–900, built for screens, with a tall x-height for small-size legibility [INTER].
  - It has an optical-size axis running from "text" to "display": ink traps at small sizes, cleaner curves at large sizes [INTER]. That makes it the closest open analogue to SF's dynamic optical sizing.
  - It includes tabular numbers and slashed-zero features [INTER].
  - Use the same size and leading tokens as §1.1. Apply SF-like negative tracking from about 13 to 23 pt and slight positive tracking from 28 pt up.
  - Inter's old "dynamic metrics" tracking formula page has been removed (it is now a 404 in the repo). **UNVERIFIED**; tune the tracking visually.
- **Custom fonts on iOS** must implement Dynamic Type and Bold Text themselves [T].

---

## 2. Color

### 2.1 System colors, iOS 26 values [C]
Values were updated June 9 2025 and come from the HIG swatch alt-text. "IC" means Increased Contrast.

| Color | Light | Dark | IC light | IC dark |
|---|---|---|---|---|
| Red | #FF383C | #FF4245 | #E9152D | #FF6165 |
| Orange | #FF8D28 | #FF9230 | #C55300 | #FFA056 |
| Yellow | #FFCC00 | #FFD600 | #A16A00 | #FEDF43 |
| Green | #34C759 | #30D158 | #008932 | #4AD968 |
| Mint | #00C8B3 | #00DAC3 | #008575 | #54DFCB |
| Teal | #00C3D0 | #00D2E0 | #008198 | #3BDDEC |
| Cyan | #00C0E8 | #3CD3FE | #007EAE | #6DD9FF |
| Blue | #0088FF | #0091FF | #1E6EF4 | #5CB8FF |
| Indigo | #6155F5 | #6D7CFF | #564ADE | #A7AAFF |
| Purple | #CB30E0 | #DB34F2 | #B02FC2 | #EA8DFF |
| Pink | #FF2D55 | #FF375F | #E7124D | #FF8AC4 |
| Brown | #AC7F5E | #B78A66 | #956D51 | #DBA679 |
| systemGray | #8E8E93 | #8E8E93 | #6C6C70 | #AEAEB2 |
| systemGray2 | #AEAEB2 | #636366 | #8E8E93 | #7C7C80 |
| systemGray3 | #C7C7CC | #48484A | #AEAEB2 | #545456 |
| systemGray4 | #D1D1D6 | #3A3A3C | #BCBCC0 | #444446 |
| systemGray5 | #E5E5EA | #2C2C2E | #D8D8DC | #363638 |
| systemGray6 | #F2F2F7 | #1C1C1E | #EBEBF0 | #242426 |

**Notes from the HIG** [C]
- "Avoid hard-coding system color values"; they may change between releases.
- Supply light, dark and increased-contrast variants for every custom color.
- "Even if your app ships in a single appearance mode, provide both light and dark colors to support Liquid Glass adaptivity."

**Key finding: the default iOS 26 blue fails WCAG AA for text**

| Pair | Contrast | Verdict |
|---|---|---|
| Blue #0088FF on white | 3.52:1 | Fails 4.5:1 for body text |
| White text on #0088FF | 3.52:1 | Fails 4.5:1 for body text |
| Old blue #007AFF on white | 4.02:1 | Fails 4.5:1 |
| IC blue #1E6EF4 on white | 4.57:1 | Passes |
| Green #34C759 on white | 2.22:1 | Fails |
| Red #FF383C on white | 3.57:1 | Fails |

I computed these myself with the WCAG formula. For a brand accent used in text links or small labels, choose something at least as dark as the IC variants.

### 2.2 Semantic roles and hierarchy [C][DM]
- **Backgrounds.** There are two sets, system and grouped, each with primary, secondary and tertiary levels. Use the grouped set for grouped or inset lists [C].
- **Foreground.** label, secondaryLabel, tertiaryLabel, quaternaryLabel, placeholderText, separator (lets content show through), opaqueSeparator, link [C].
- **Base vs elevated in dark mode.** "The base colors are dimmer, making background interfaces appear to recede, and the elevated colors are brighter, making foreground interfaces appear to advance." The system switches to elevated automatically for sheets, popovers and multitasking [DM].
- **Contrast floor.** Minimum 4.5:1; aim for 7:1 for custom colors, especially small text [DM].

### 2.3 Semantic color values [FL]
**Caveat.** Apple doesn't publish these values in the HIG or API docs. These come from Flutter's CupertinoColors, which mirrors the iOS 13+ UIKit values. **UNVERIFIED for iOS 26 or 27**; check them against Apple's iOS 26 UI kit.

| Token | Light | Dark (base) | Dark (elevated) | IC light | IC dark |
|---|---|---|---|---|---|
| label | #000000 | #FFFFFF | #FFFFFF | #000000 | #FFFFFF |
| secondaryLabel | rgba(60,60,67,.60) #3C3C4399 | rgba(235,235,245,.60) #EBEBF599 | same as base | α .68 | α .68 |
| tertiaryLabel | rgba(60,60,67,.30) #3C3C434C | rgba(235,235,245,.30) | same as base | α .38 | α .38 |
| quaternaryLabel | rgba(60,60,67,.18) #3C3C432D | rgba(235,235,245,.16) #EBEBF528 | same as base | α .26 | α .24 |
| placeholderText | rgba(60,60,67,.30) | rgba(235,235,245,.30) | same as base | | |
| systemFill | rgba(120,120,128,.20) | rgba(120,120,128,.36) | same as base | α .28 | α .44 |
| secondarySystemFill | rgba(120,120,128,.16) | rgba(120,120,128,.32) | same as base | | |
| tertiarySystemFill | rgba(118,118,128,.12) | rgba(118,118,128,.24) | same as base | | |
| quaternarySystemFill | rgba(116,116,128,.08) | rgba(118,118,128,.18) | same as base | | |
| systemBackground | #FFFFFF | #000000 | #1C1C1E | #FFFFFF | #000000 (elevated #242426) |
| secondarySystemBackground | #F2F2F7 | #1C1C1E | #2C2C2E | #EBEBF0 | #242426 (elevated #363638) |
| tertiarySystemBackground | #FFFFFF | #2C2C2E | #3A3A3C | #FFFFFF | #363638 (elevated #444446) |
| systemGroupedBackground | #F2F2F7 | #000000 | #1C1C1E | #EBEBF0 | #000000 |
| secondarySystemGroupedBackground | #FFFFFF | #1C1C1E | #2C2C2E | #FFFFFF | #242426 |
| tertiarySystemGroupedBackground | #F2F2F7 | #2C2C2E | #3A3A3C | #EBEBF0 | #363638 |
| separator | rgba(60,60,67,.29) #3C3C4349 | rgba(84,84,88,.60) #54545899 | *(see note)* | α .37 | α .68 |
| opaqueSeparator | #C6C6C8 | #38383A | #38383A | | |
| link | #007AFF | #0984FF | | | |

- **Elevated separator looks wrong.** Flutter lists the elevated dark separator as rgba(210,210,210,.6). That is probably a Flutter quirk; don't adopt it.
- **link is out of date.** It still shows the pre-iOS 26 blue. In iOS 26 it is presumably the new blue (**UNVERIFIED**).
- **Measured contrast:**

| Pair | Contrast |
|---|---|
| secondaryLabel on white | 3.44:1 |
| secondaryLabel on #F2F2F7 | 3.29:1 |
| tertiaryLabel on white | 1.72:1 |
| secondaryLabel (dark) on black | 6.36:1 |

  Apple's secondary text in light mode is below 4.5:1, so use it only for non-essential text.

### 2.4 Tint and accent under Liquid Glass [C][W219]
- **Glass has no color of its own.** It takes color from the content behind it.
- **Tint only the primary action, and tint the background.** Apply color to the background rather than to symbols or text, as the system does with the Done button. "Refrain from adding color to the background of multiple controls."
- **Bar labels are monochrome by default.** Toolbar and tab bar labels flip dark or light against the content underneath.
- **Colorful content means a monochrome UI.** In apps with colorful content, use monochrome bars or a strongly differentiated accent. In apps with mostly monochrome content, your brand color makes a good accent.
- **How tinting works.** Choosing a tint generates a range of tones mapped to the brightness of the content underneath. Use the system tinting, not solid fills, which look opaque and break the material [W219].

---

## 3. Layout and spacing

| Item | Value | Status / source |
|---|---|---|
| Minimum hit target | 44×44 pt (absolute minimum 28×28) | [A][B] |
| Spacing around controls | ~12 pt for bezeled elements; ~24 pt around the visible edges of borderless ones | [A] |
| Default subview layout margins | 8 pt each side | API: UIView.directionalLayoutMargins |
| Root view margins | System minimum plus safe area. Apple's docs show 20 pt only as an example; 16 pt (compact) and 20 pt (regular, large iPhones) is common practice | API: systemMinimumLayoutMargins; 16/20 split **UNVERIFIED** |
| Readable width | readableContentGuide; width depends on the Dynamic Type size | API |
| Safe areas | Always respect them (Dynamic Island, bars, home indicator) | [L] |
| 8 pt grid | Not an Apple rule; Apple publishes no grid for iOS. A fine internal convention (8 with a 4 half-step) that matches the 8 pt default margin | **UNVERIFIED** |
| Toolbar or nav title length | Under 15 characters | [TO] |
| Segments per segmented control | 5 or fewer on iPhone | [SC] |
| Tabs | 5 or fewer by default (iPad customization guidance) | [TB] |
| Nav bar 44 pt; large-title bar 96 pt; tab bar 49 pt + 34 pt home indicator; list row minimum 44 pt | Pre-iOS 26 community values | **UNVERIFIED**; Apple doesn't document them. In iOS 26 bars are floating Liquid Glass and transparent by default, so measure from Apple's iOS 26 UI kit (https://developer.apple.com/design/resources/) |
| Device screen sizes | The layout page was rewritten on Sep 9 2026 and no longer contains the device tables | [L] |

### Shape system (iOS 26) [W356][W323][W284][TO]
- **Three shape types:**
  - **Fixed:** a constant radius.
  - **Capsule:** radius = height ÷ 2.
  - **Concentric:** radius = parent radius − padding.
- **Where capsules appear.** Bars, buttons, sliders, switches and the corners of grouped table views. "Bordered buttons now have a capsule shape by default" [W323].
- **Phones vs larger screens.** On phones, put a capsule button near a screen edge with extra margin. On iPad and Mac, use a concentric shape aligned to the window [W356].
- **Fallback radius.** Use a concentric shape with a fallback radius for components that sometimes stand alone [W356]. APIs: SwiftUI `ConcentricRectangle` / `.containerConcentric` with `concentric(minimum:)`; UIKit `cornerConfiguration = .containerRelative`.
- **Sheets.** A button at the bottom of a sheet should share the sheet's corner center [W323]. Standard toolbar items, text fields, headers and footers are already concentric with bar corners [TO].
- **Watch for pinched or flared corners** in nested containers [W356].
- **Continuous corners ("squircle").** SwiftUI `RoundedRectangle(cornerRadius:style:)` defaults to `style: .continuous` [API: roundedrectangle/init(cornerradius:style:)]. UIKit uses `layer.cornerCurve = .continuous`. Use continuous everywhere.
- **Specific radii.** Apple publishes none for iOS cards, sheets or buttons. The only explicit numbers in the HIG are for visionOS (16 pt alert accessory). Pre-iOS 26 folklore (about 10 pt for inset-grouped cells, about 13–14 pt for alerts) is **UNVERIFIED**, and iOS 26 radii are larger and concentric. For tokens:
  - Capsule for buttons and chips.
  - Concentric for anything nested inside a sheet, card or bar.
  - A fixed card radius chosen so that inner radius = outer − padding.

---

## 4. Materials and depth

### 4.1 Liquid Glass [M][W219][W356]
- **What it is.** A functional layer for controls and navigation that floats above content. Don't use it in the content layer, except for transient states of sliders and toggles while they're being touched.
- **Never stack glass on glass.** For elements on top of glass, use fills, transparency and vibrancy instead.
- **Variants:**
  - **Regular** (default) blurs content and adjusts its luminosity. Use it for anything with text: alerts, sidebars, popovers.
  - **Clear** is highly translucent and only for controls over rich media. Add a **35% dark dimming layer** if the content underneath is bright.
  - Clear needs all three conditions: media-rich content underneath, a dimming layer that won't harm the content, and bold, bright content on top [W219].
- **Size-adaptive behavior:**
  - Small elements such as nav bars and tab bars flip between light and dark with the content behind them.
  - Large elements such as menus and sidebars don't flip, and become more opaque.
  - Sheets: partial-height sheets are inset with a glass background. At full height they become opaque and anchor to the screen edge [W323].
- **Scroll edge effects** replace hairlines and bar backgrounds. Use only one per view [W356].
  - *Soft* is the default on iOS. *Hard* is for pinned headers, mostly on macOS [W356].
  - API: `ScrollEdgeEffectStyle .automatic/.soft/.hard` [API].
  - Remove custom bar backgrounds; on iOS 26 bars are transparent by default [W284].
- **SwiftUI APIs.**
  - `glassEffect(_:in:)` defaults to `.regular` in a `Capsule`.
  - `Glass` has `.regular`, `.clear`, `.identity`, `.tint()` and `.interactive()`.
  - `GlassEffectContainer(spacing:)` morphs nearby glass shapes into each other.
  - Button styles `.glass` and `.glassProminent`.
- **UIKit APIs.** `UIButton.Configuration` adds `glass()`, `prominentGlass()`, `clearGlass()` and `prominentClearGlass()` [API].

### 4.2 Standard materials, for the content layer [M]
- **iOS levels:** ultraThin, thin, regular (default), thick. SwiftUI's `Material` also has `ultraThick` and `bar` [API: swiftui/material].
- **Thicker vs thinner.** Thicker gives better contrast for fine text. Thinner keeps more context visible.
- **Choose by meaning, not by the color it produces.**
- **Vibrancy levels:**
  - Labels: label, secondary, tertiary, quaternary. Avoid quaternary on thin and ultraThin.
  - Fills: fill, secondary, tertiary.
  - Separators: one level.
- **Exact blur radius and opacity values are not published.** **UNVERIFIED**; don't fake them, use the platform materials.

### 4.3 Shadow vs layering
- **Glass handles its own shadows.** Liquid Glass shadows are adaptive: more opaque over text, lighter over plain light backgrounds. Larger glass casts deeper shadows [W219].
- **Hierarchy comes from layout and grouping, not decoration.** Remove the extra backgrounds and borders you've added to bar items [W356].
- **Modality comes from a dimming layer** paired with glass [W356].
- **Dark mode depth comes from base vs elevated colors** [DM].
- Apple publishes no shadow tokens. Recommendation: essentially no shadows in the content layer, and depth from background levels instead.

---

## 5. Motion and haptics

### 5.1 Springs [API][W23S][W18F]

| Preset | Duration (perceptual) | Bounce | Damping ratio ζ | Stiffness / damping at mass 1 (derived) |
|---|---|---|---|---|
| `.smooth` | 0.5 s | 0 | 1.0 | k 157.9 / c 25.1 |
| `.snappy` | 0.5 s | 0.15 | 0.85 | k 157.9 / c 21.4 |
| `.bouncy` | 0.5 s | 0.30 | 0.70 | k 157.9 / c 17.6 |
| `.default` (iOS 17+) | response 0.55 | dampingFraction 1.0 | 1.0 | k 130.5 / c 22.8 |
| `.interactiveSpring` | response 0.15 | dampingFraction 0.86 | 0.86 | blendDuration 0.25 |
| `spring(response:dampingFraction:)` defaults | 0.5 | 0.825 | | |

**Where these numbers come from**
- **Base bounce values.** The API docs give the preset duration (0.5) and each preset's base bounce: smooth 0, snappy 0.15, bouncy 0.3.
- **Conversion check.** Apple's `Spring` docs say Spring(duration 0.5, bounce 0.3) gives mass 1.0, stiffness 157.9, damping 17.6. That matches k = (2π/d)², c = 4π(1−bounce)/d and ζ = 1 − bounce, which is how I derived the other rows. Use this conversion for Android and web.
- **Prior to iOS 17**, the default animation was easeInOut [API].

**Guidance**
- "When you're not sure, use a spring with bounce 0." About 15% bounce feels brisk without bouncing; about 30% is noticeably bouncy. Start by choosing a duration you like, then adjust bounce [W23S].
- Start at 100% damping. Use about 80% only when a gesture carries momentum, for example the Now Playing swipe-dismiss [W18F].
- Springs keep their velocity when retargeted. Make every animation interruptible and never block input ("Let people cancel motion") [MO][W23S].
- Avoid custom motion on frequent interactions. Keep feedback animations brief and precise [MO].
- Fixed curve durations such as 0.25 or 0.35 s are not published by Apple (**UNVERIFIED**). Use springs with about 0.3–0.5 s perceptual duration.

### 5.2 Haptics [H][API]
- **System controls already play haptics:** toggles, sliders, pickers.
- **Generators:**
  - Notification: success, warning, error. Use for the outcome of a task.
  - Impact: light, medium, heavy, soft, rigid. Use to give a physical feel to something visual, like snapping into place.
  - Selection: use while a value is changing.
- **SwiftUI** `sensoryFeedback` (iOS 17+) offers success, warning, error, selection, increase, decrease, levelChange, alignment, pathComplete, start, stop and impact(weight:intensity:).
- **Rules:**
  - Use patterns only for their documented meaning, and consistently.
  - Pair haptics with the visual and match their intensity and sharpness.
  - Don't overuse them. Prefer short haptics for discrete events.
  - Make haptics optional, and pair audio cues with haptics [A].

---

## 6. Core components (iOS 26 behavior)

**Navigation bar** [TO][W284]
- A navigation bar is now a "toolbar". Large titles collapse to a standard title on scroll and return at the top.
- In iOS 26, large titles sit at the top of the scroll view and scroll underneath the bar. There is also a new `largeSubtitleView`.
- Use the standard Back and Close symbols, not text labels.
- One primary action uses `.prominent` (tinted). It sits on the trailing side and is often a blue checkmark.
- No more than about three groups.
- Don't put a text button next to a symbol button. Text buttons, Done, Close and prominent buttons each get their own glass background; image buttons share one.

**Tab bar** [TB][W323][W356]
- Floats at the bottom on Liquid Glass and is for navigation only, never actions.
- Always label tabs, ideally with single words. Use filled SF Symbols.
- A dedicated Search tab can sit at the trailing end.
- It can minimize on scroll (`tabBarMinimizeBehavior`).
- An accessory view is for persistent features such as a mini player, not screen-specific actions like checkout.
- Badges are for critical information only. Don't hide or disable tabs.
- The HIG says tab labels are 11 pt; I couldn't verify that number.

**Sheets** [SH][W323][W284]
- Detents: `large` (always supported) and `medium` (about half height), plus custom (`fraction`, `height`).
- Show the grabber when the sheet can be resized, and support swipe-to-dismiss. If there are unsaved changes, confirm with an action sheet.
- Cancel goes leading, Done goes trailing. Never show Cancel, Done and Back together. Always pair Done with Cancel or Back. One sheet at a time.
- Partial-height sheets are inset glass. Sheets can morph out of their source button with a zoom transition.
- Remove custom `presentationBackground`.

**Lists** [LT][API]
- Use the inset grouped style (`UITableView.Style.insetGrouped`, "grouped sections are inset with rounded corners") with grouped background colors.
- Rows grow with Dynamic Type.
- A disclosure indicator means drill-in; the info button is only for more detail.
- Don't combine an index with trailing accessories.

**Buttons** [B][API][W323]
- **Hierarchy:** one or two prominent buttons per view. Distinguish options by style, not size.
- **Roles:** normal, primary (accent color), cancel, destructive (red). Never give a destructive action the primary role.
- **Styles:**
  - UIKit: plain, gray, tinted, filled, bordered, borderedTinted, borderedProminent, plus the glass variants.
  - SwiftUI: plain, borderless, bordered, borderedProminent, glass, glassProminent.
- **Sizes:**
  - SwiftUI `ControlSize`: mini, small, regular, large, extraLarge ("support for extra large sized buttons" is new).
  - UIKit `UIButton.Configuration` has a `buttonSize` property.
  - Corner styles: fixed, dynamic, small, medium, large, capsule.
  - Apple publishes no point heights. Large of about 50 pt is **UNVERIFIED**.
- **Activity indicator in button:** show it with a changed label, for example "Checking out…".
- **Press state:** a custom button must always have one.

**Text fields** [TF]
- Placeholder text plus a separate label. Secure fields for passwords. Clear button on the trailing side.
- Choose the keyboard type to match the input. Validate at the right moment.
- Stack fields vertically at consistent widths.

**Segmented control** [SC]
- Equal-width segments, 5 or fewer on iPhone.
- Text or icons, not both. Use nouns for labels.
- Use for closely related subviews; use a tab bar for app sections.

**Toggles** [TG]
- Use a switch only inside a list row; no label is needed there.
- Default color is green; change it to your accent only if contrast holds. Note white on green #34C759 is 2.22:1.
- Outside lists, use a toggle-style button.

**Context menus** [CM]
- Few items, at most about three groups, and only one level of submenu.
- Hide unavailable items rather than dimming them. Destructive items go last, in red.
- Use icons from the standard icon set. A preview should match the item's shape.
- Every action must also exist elsewhere in the UI.

**Alerts vs action sheets** [AL][AS][W284]
- **Alert:**
  - For important, actionable problems only: title, optional message, up to three buttons.
  - Default button on the trailing side or at the top; Cancel leading or at the bottom.
  - Avoid "OK" unless the alert is purely informational. Avoid alerts at launch and for undoable actions.
- **Action sheet:**
  - For choices about an action the user deliberately started.
  - Destructive options at the top, Cancel at the bottom. Don't let it scroll.
  - In iOS 26, an action sheet springs from its source element. Inline action sheets have no Cancel button, because tapping outside cancels [W356][W284].

---

## 7. Iconography (SF Symbols) [SF][T][IC]
- **Weights:** nine, Ultralight to Black, each matching an SF font weight. Set the symbol weight equal to the adjacent text weight.
- **Scales:** small, medium (default), large, defined relative to the SF cap height. Change emphasis with scale, not weight.
- **Dynamic Type:** symbols scale with it automatically.
- **Rendering modes:** monochrome, hierarchical, palette, multicolor. SF Symbols 7 adds gradients and Draw On / Draw Off animation. Use variable color for changing values, not for depth.
- **Variants by context:**
  - Outline in toolbars, lists and next to text.
  - Fill in iOS tab bars, swipe actions and selection.
  - Enclosed variants for legibility at small sizes.
  - Toolbar symbols go without borders.
- **Animations:** appear, disappear, bounce, scale, pulse, variable color, replace and Magic Replace, wiggle, breathe, rotate, draw. Use them sparingly.
- **Standard symbols** (from the HIG Icons page) [IC]:

| Action | Symbol |
|---|---|
| Done | `checkmark` |
| Cancel / Close | `xmark` |
| Delete | `trash` |
| Copy | `document.on.document` |
| Add | `plus` |
| More | `ellipsis` |
| Compose | `square.and.pencil` |
| Share | `square.and.arrow.up` |

- **Custom icons:** vector (PDF or SVG), with an accessibility label, and stroke weight matched to text.
- **iOS 26 uses more symbols in menus:** use one symbol to introduce a group of related actions. Use a text label when a symbol is ambiguous, for example Select or Edit [W356].

---

## 8. Accessibility [A][T][W219]

| Text | Minimum contrast (Accessibility Inspector, WCAG AA as the HIG states it) |
|---|---|
| Up to 17 pt | 4.5:1 |
| 18 pt and up | 3:1 |
| Bold, any size | 3:1 |

- **Dynamic Type:**
  - Support at least 200% enlargement and test at AX5.
  - Avoid truncation; stack horizontal layouts at accessibility sizes (`isAccessibilityCategory`).
  - Scale meaningful icons with the text.
  - Keep the information hierarchy the same at every size [T][A].
- **Reduce Motion:**
  - Tighten springs (less bounce) and track gestures directly.
  - Avoid z-axis depth animation; replace x/y/z transitions with fades.
  - Don't animate into or out of blurs.
  - Liquid Glass automatically turns off its elastic properties [A][W219].
- **Reduce Transparency.** Liquid Glass automatically becomes "frostier". Test dark mode with Increase Contrast and Reduce Transparency, separately and together [W219][DM].
- **Increase Contrast.** Glass becomes mostly black or white with a contrasting border. Provide an IC variant for every custom color [W219][C].
- **Other:** don't rely on color alone, label every icon for VoiceOver, avoid UI that auto-dismisses on a timer, and offer a button alternative to every gesture [A].

---

## 9. iOS 27 (WWDC26) changes to factor in
- **Refined Liquid Glass.** Apps get the refined look without code changes, and it responds to a new system **"Liquid Glass slider"** that changes the glass tint [W26S]. Press coverage says default transparency is reduced and the slider runs from clear to tinted; that is secondary (Wikipedia, BGR) and **UNVERIFIED** against Apple docs. Design for both ends of the slider.
- **Toolbars.**
  - `toolbarMinimizeBehavior(.onScrollDown)` for the navigation bar.
  - The `ToolbarOverflowMenu` container lets you decide which items move into the overflow menu [W26S].
- **Tab bars** [W26U]:
  - iPhone apps can opt into a sidebar.
  - Any tab can be made the "prominent" tab (`prominentTabIdentifier`), which stays visible when the bar collapses.
- **Menus.** Images on menu items may be hidden in some contexts [W26U].
- **HIG pages are still current.** Typography, color and toolbars were last updated Dec 2025; tab bars Jun 8 2026. So the specs above are still the published ones.

## 10. Gaps (not verifiable from primary sources in this session)
- Point heights for bars, rows, buttons and text fields, and all corner radii. Measure these from the iOS 26 Apple Design Resources UI kit (Figma/Sketch), which I couldn't access.
- Blur radius and opacity for the materials.
- Shadow values.
- Fixed curve durations.
- Semantic color values for iOS 26 and 27. The ones in §2.3 are iOS 13-era values from Flutter.
- The SF font license terms.
- The Inter tracking formula.

