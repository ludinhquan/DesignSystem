# Mobile design system: research synthesis

Goal: a clean, premium, Apple-style design system for a mobile app.
This page is the senior-design read of two research reports. It turns them into decisions.

- [apple-hig-foundations.md](apple-hig-foundations.md): Apple HIG specs for iOS 26/27 (type, color, layout, Liquid Glass, motion, haptics, components, accessibility). Mostly verified against developer.apple.com.
- [premium-design-system-practice.md](premium-design-system-practice.md): token architecture, reference systems (Linear, Stripe, Airbnb, Polaris, Material 3), premium practices, component priorities, tooling.
- [v1-critique.md](v1-critique.md): critique of the first published system (rendered at phone size) and the "Ink" proposal.
- [art-directions.md](art-directions.md): case studies of distinctive finance and award-winning apps, money typography, depth, motion, and three art directions (Ledger, Instrument, Pebble).

Values marked **UNVERIFIED** in the reports are not published by Apple. Measure them from the iOS 26 UI kit at https://developer.apple.com/design/resources/ before locking them in.

---

## 1. Principles

1. **Content first, chrome quiet.** Navigation floats on Liquid Glass above content. Hierarchy comes from layout, grouping and dimming, not from borders, boxes and shadows.
2. **Monochrome base, one accent.** Neutrals carry 90% of the UI. The accent marks the primary action, selection and links, and nothing else. Status colors appear only when they mean something.
3. **Hierarchy by dimming.** Three text levels (primary, secondary, tertiary) plus weight do most of the work before size changes.
4. **Native where it counts.** Wrap the system nav bar, tab bar, sheets, menus and alerts instead of rebuilding them. Rebuilt chrome is the fastest way to look cheap.
5. **Motion is physics.** Springs, not easing curves. Every animation is interruptible and keeps gesture velocity. Frequent actions get little or no animation.
6. **One signature moment.** Spend the "richness budget" in one place (an onboarding moment, a hero interaction, a celebratory state). Keep everything else restrained.
7. **Accessible by construction.** Dynamic Type, Reduce Motion, Reduce Transparency and Increase Contrast are designed as modes, not patched later.

## 2. Decisions

| Area | Decision | Why |
|---|---|---|
| Token tiers | Primitive → Semantic → Component (component tier sparse) | Industry consensus; components never touch primitives, so dark mode and rebrands are data changes |
| Format | W3C DTCG 2025.10 JSON in Git, modes via the Resolver module | First stable standard, supported by Style Dictionary v5 and Figma |
| Modes | `colorScheme` light/dark × `contrast` standard/high = 4 modes | Apple requires Increased Contrast variants for custom colors |
| Color space | Author primitives in OKLCH, 12-step ramps (Radix-style step roles) | Perceptually uniform; contrast becomes a property of the scale (Stripe, Linear) |
| Dark mode | Separate dark ramp. True-black base, lighter *elevated* surfaces for sheets and modals | Apple's base vs elevated model; never invert the light palette |
| Accent | Brand accent must reach **≥ 4.5:1 on white** for text use | iOS 26 default blue `#0088FF` is only 3.52:1 on white |
| Typeface | iOS: system font via text styles. Android/web: **Inter** with the same size/leading tokens | SF is not licensed for other platforms (verify); Inter has optical sizing and tabular figures |
| Type scale | The 11 Dynamic Type roles, no arbitrary sizes. Tabular figures for any changing or aligned numbers | Free Dynamic Type and Bold Text support on iOS |
| Spacing | 4 pt base, mostly 8 pt multiples. Screen gutter 16 pt (20 pt on large phones) | Matches Apple's 8 pt default margins; 16/20 split is common practice |
| Hit target | 44 × 44 pt minimum, even when the visual is smaller | HIG |
| Shape | Capsule for buttons, chips, toggles. Concentric radius (`inner = outer − padding`) for anything nested. Continuous corners everywhere | iOS 26 shape system; bordered buttons are capsules by default |
| Depth | No shadows in the content layer. Depth from background levels and the glass layer | Glass draws its own adaptive shadows; Apple publishes no shadow tokens |
| Motion | Springs only; opacity and color never overshoot | Apple springs + Material's spatial vs effects split |
| Haptics | Named roles attached to components, never ad hoc; always paired with a visual cue | HIG playing-haptics |

## 3. Starter tokens

Naming grammar: `{category}.{role}.{variant?}.{state?}`. Use `accent` for the brand color and `primary/secondary/tertiary` only for emphasis level.

**Primitives** (no modes, never used by components):

```
color.neutral.1…12   color.accent.1…12   color.red|green|amber.1…12   (light and dark ramps)
scale.0 2 4 8 12 16 20 24 32 40 48 64
radius.raw.*   font.family.sans   font.weight.regular|medium|semibold|bold
```

**Semantic** (4 modes):

```
color.bg.canvas | surface | surface.raised | surface.sunken | overlay | fill.subtle
color.fg.primary | secondary | tertiary | disabled | on-accent | link
color.border.subtle | default | strong | focus
color.accent.solid | solid.pressed | subtle | fg
color.status.{danger|success|warning|info}.{fg|bg}
space.inset.xs…lg   space.stack.xs…xl   space.inline.xs…lg   space.screen.gutter
radius.control (capsule) | card | sheet (system) | pill
type.largeTitle | title1 | title2 | title3 | headline | body | callout | subhead | footnote | caption1 | caption2
motion.spring.smooth | snappy | bouncy     motion.effect.fast | default | slow
haptic.selection | success | warning | error
```

**Type roles** (iOS default "Large" size; Apple's values):

| Role | Size / leading (pt) | Weight | Tracking (pt) |
|---|---|---|---|
| largeTitle | 34 / 41 | Regular (Bold in nav bars) | +0.40 |
| title1 | 28 / 34 | Regular | +0.38 |
| title2 | 22 / 28 | Regular | −0.26 |
| title3 | 20 / 25 | Regular | −0.45 |
| headline | 17 / 22 | Semibold | −0.43 |
| body | 17 / 22 | Regular | −0.43 |
| callout | 16 / 21 | Regular | −0.31 |
| subhead | 15 / 20 | Regular | −0.23 |
| footnote | 13 / 18 | Regular | −0.08 |
| caption1 | 12 / 16 | Regular | 0 |
| caption2 | 11 / 13 | Regular | +0.06 |

**Motion** (starting values; tune by eye on device):

| Token | Duration | Bounce | Use |
|---|---|---|---|
| `spring.smooth` | 0.5 s | 0 | Default for transitions (Apple: "when unsure, bounce 0") |
| `spring.snappy` | 0.35 s | 0.15 | Press, toggle and selection feedback |
| `spring.bouncy` | 0.5 s | 0.3 | Rare celebratory moments only |
| `effect.fast / default / slow` | 150 / 250 / 350 ms | none | Opacity and color changes |

Conversion for Android and web (mass 1): stiffness `k = (2π / duration)²`, damping `c = 4π(1 − bounce) / duration`.

## 4. v1 components

Uber reports list items make up over 80% of its UI, so the list item gets the most care.

**P0, before any screen ships**
1. Text (role-based, tabular-figures option)
2. Icon (SF Symbols on iOS; weight matches adjacent text)
3. Button (prominent, tinted, plain, destructive; small, regular, large; loading state)
4. IconButton
5. ListItem (leading slot, up to 3 text lines, trailing slot)
6. List section, inset grouped
7. TextField (secure, multiline, helper and error text, clear button)
8. Toggle, Checkbox, Radio
9. Navigation bar (native-wrapped)
10. Tab bar (native-wrapped)
11. Sheet and Alert (native-wrapped)

**P1, first months**: segmented control, toast/banner, skeleton and progress, empty state, avatar, badge, card, divider, search field, menu, picker.

Every component page documents: when to use and when not to, anatomy tied to tokens, props named exactly as in code, all states in all 4 modes, motion and haptic role, accessibility (Dynamic Type up to AX5), content rules, do/don't with real screenshots.

## 5. Tooling

- **Figma**: Variables in collections Primitives (hidden) / Semantic Color (4 modes) / Spacing & Radius / Typography. Separate Foundations and Components libraries. Code Connect for handoff.
- **Source of truth**: DTCG JSON in this repo, reviewed in pull requests.
- **Build**: Style Dictionary v5 in CI, emitting Swift, Compose, TypeScript and CSS. Semver releases.
- **Implementation**: SwiftUI (asset catalogs with Any/Dark/High Contrast + Swift token enums) or React Native (Unistyles 3 + Reanimated + expo-haptics, wrapping native navigation and sheets).
- **QA**: component workshop (Storybook, Widgetbook or Xcode Previews) with visual regression across all 4 modes.

## 6. Avoid

- A second brand color, gradients everywhere, status colors used as decoration.
- Off-scale spacing and radii; equal radii on nested shapes; circular instead of continuous corners.
- Rebuilt nav bars, sheets and pickers.
- Fixed-duration easing on gesture-driven UI; bounce on everything; animation on high-frequency actions.
- Dark mode made by inverting light mode.
- Spinners for every load, layout shift when content arrives, blank "No data" empty states.
- Haptics on every tap.
- Components referencing primitives; hue or mode names in semantic tokens (`text-gray-dark`).
- Variant bloat; Figma and code with different prop names.

## 7. Open items

- Choose the product, the brand accent and the one signature moment.
- Pick the stack: native SwiftUI, React Native or Flutter.
- Measure bar heights, row heights, button heights and corner radii from Apple's iOS 26 UI kit.
- Verify iOS 26 semantic color values (the report's table is iOS 13-era, from Flutter).
- Check the SF Pro license before any non-Apple use.
