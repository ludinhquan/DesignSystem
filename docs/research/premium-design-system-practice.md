# Building a premium, Apple-like mobile design system: architecture, references and practice

**How this was researched:** WebFetch was blocked by the network egress proxy for every primary domain I tried (linear.app, stripe.com, w3.org, styledictionary.com, m3.material.io, polaris-react.shopify.com). Everything below comes from WebSearch result summaries of the URLs cited. Primary-source claims (Apple WWDC, the W3C DTCG spec, Linear, Stripe, NN/g, Uber Base, Radix) are reliable. Numbers taken from third-party "design extraction" sites (Airbnb radii, Revolut type sizes) are marked low-confidence. Apple HIG specs are left to the other researcher. I only touch them where they affect system architecture.

---

## 1. Token architecture

### 1.1 The standard is now real; build on it
- **The W3C Design Tokens Community Group (DTCG) format reached its first stable version (2025.10) on 28 Oct 2025.** It has three modules:
  - **Format:** tokens, types, groups, and `{alias}` references.
  - **Color:** Display P3, OKLCH, and every CSS Color 4 color space.
  - **Resolver:** sets, modifiers and resolution order. This is how the spec handles light/dark, contrast and brand themes.
  - Backed by 40+ organizations, including Adobe, Figma, Google, Microsoft, Shopify and Salesforce.
  - Sources: [W3C announcement](https://www.w3.org/community/design-tokens/2025/10/28/design-tokens-specification-reaches-first-stable-version/), [Format 2025.10](https://w3c.github.io/cg-reports/design-tokens/CG-FINAL-format-20251028/), [Resolver 2025.10](https://w3c.github.io/cg-reports/design-tokens/CG-FINAL-resolver-20251028/)
- **Tooling status (Oct 2026):**
  - **Style Dictionary v5** reads DTCG 2025.10, including structured color objects and dimension objects. Full Resolver support is still marked work-in-progress. ([SD releases](https://github.com/style-dictionary/style-dictionary/releases), [SD DTCG](https://styledictionary.com/info/dtcg/))
  - **Terrazzo** (formerly Cobalt UI) claims the fullest DTCG support and has first-class Swift, CSS, JS and Tailwind plugins. Resolver support is slated for 2.0, and React Native output is still only a plugin request. ([Terrazzo](https://github.com/terrazzoapp/terrazzo), [RN plugin issue](https://github.com/terrazzoapp/terrazzo/issues/856))
  - **Figma Variables** export DTCG JSON natively, but most composite tokens (typography, shadow, gradient) are not exported yet. **Tokens Studio** fills that gap with sets, themes, math and composites. Many production teams use both: Variables for modes and component bindings, Tokens Studio for the JSON round-trip. ([Atomize guide](https://atomize.tools/blog/figma-design-tokens-guide/), [Figma forum on composite export](https://forum.figma.com/suggest-a-feature-11/dtcg-composite-token-export-support-51314), [Figma dark-mode setup](https://atomize.tools/blog/figma-variables-dark-mode/))

### 1.2 Three tiers, with strict rules
This is the industry consensus. Nathan Curtis's taxonomy splits a name into namespace, object, base and modifier. ([Smart Interface Design Patterns](https://smart-interface-design-patterns.com/articles/naming-design-tokens/), [Always Twisted](https://www.alwaystwisted.com/articles/design-token-naming-conventions))

| Tier | What it holds | Has modes? | Who consumes it |
|---|---|---|---|
| **Primitive** (base/global) | Raw values: `color.gray.7`, `scale.16`, `duration.250` | **No** | Only semantic tokens. Components never reference primitives. |
| **Semantic** (functional/alias) | Intent: `color.fg.secondary`, `color.bg.surface.raised`, `space.inset.md` | **Yes**: light/dark, high contrast | Components and product code (around 90% of usage) |
| **Component** | `button.primary.bg.pressed` | Inherits from semantic | One component. Add these only when a component must diverge. |

Reference implementations worth copying:
- **GitHub Primer** uses base → functional → component/pattern tiers. Its functional tokens use property prefixes `fgColor` / `bgColor` / `borderColor` with the modifiers `default`, `muted` and `emphasis`, for example `fgColor-muted` and `bgColor-accent-emphasis`. Component tokens look like `button-primary-bgColor-hover`. ([Primer token names](https://primer.style/product/primitives/token-names/))
- **Shopify Polaris** uses the formula `--p-color-[element]-[role]-[variant]-[state]`, where element is one of bg, text, border or icon. Defaults are omitted, so the default card background is simply `--p-color-bg`. ([Polaris v11 color](https://polaris-react.shopify.com/previous-releases/version-11-color))

### 1.3 Build color ramps in a perceptually uniform space
- **Stripe** rebuilt its palette in CIELAB so that any two colors at least 5 levels apart pass WCAG contrast for small text, and 4 levels apart for icons and large text. Contrast becomes a property of the scale, not a per-pair check. ([Stripe: accessible color systems](https://stripe.com/blog/accessible-color-systems))
- **Linear** generates whole themes in LCH from three inputs (base color, accent color, contrast) instead of hand-tuning about 98 variables. A single `contrast` input gives a high-contrast theme for free. ([Linear redesign pt. II](https://linear.app/now/how-we-redesigned-the-linear-ui))
- **Radix Colors** gives every step of a 12-step scale a job:
  - Steps 1–2: app and subtle backgrounds
  - Steps 3–5: component backgrounds (rest, hover, pressed)
  - Steps 6–8: borders (subtle, interactive, hover)
  - Steps 9–10: solid fills
  - Steps 11–12: low- and high-contrast text
  - This is the best ready-made mapping from primitive steps to semantic roles. ([Radix: understanding the scale](https://www.radix-ui.com/colors/docs/palette-composition/understanding-the-scale))
- **Opinion:** author primitives in **OKLCH**, which DTCG 2025.10 supports natively. Use a 12-step neutral ramp plus one accent ramp, and give each step a Radix-style role. Generate the dark ramp separately, not by inverting the light one.

### 1.4 Recommended naming scheme
**Grammar:** `{category}.{role}.{variant?}.{state?}`, written as dot paths in the DTCG source. Each platform transform rewrites the path into that platform's casing.

**Primitive tier (no modes):**
```
color.neutral.1 … color.neutral.12     color.accent.1 … color.accent.12
color.red.1…12  color.green.1…12  color.amber.1…12
scale.0 scale.2 scale.4 scale.8 scale.12 scale.16 scale.20 scale.24 scale.32 scale.40 scale.48 scale.64
radius.raw.6 radius.raw.10 radius.raw.14 radius.raw.20 radius.raw.28 radius.raw.full
font.family.sans  font.weight.regular|medium|semibold|bold
duration.100 duration.150 duration.250 duration.350
```

**Semantic tier (modes: `colorScheme` light|dark × `contrast` standard|high):**
```
color.bg.canvas            color.bg.surface          color.bg.surface.raised     color.bg.surface.sunken
color.bg.overlay           color.bg.fill.subtle      color.bg.fill.subtle.pressed
color.fg.primary           color.fg.secondary        color.fg.tertiary           color.fg.disabled
color.fg.on-accent         color.fg.link
color.border.subtle        color.border.default      color.border.strong         color.border.focus
color.accent.solid         color.accent.solid.pressed  color.accent.subtle       color.accent.fg
color.status.danger.fg     color.status.danger.bg    (same for success / warning / info)
space.inset.xs|sm|md|lg    space.stack.xs…xl         space.inline.xs…lg          space.screen.gutter
radius.control  radius.card  radius.sheet  radius.pill
type.display  type.title.1|2|3  type.headline  type.body  type.callout  type.subhead  type.footnote  type.caption
motion.spring.smooth|snappy|bouncy   motion.effect.fast|default|slow
elevation.raised  elevation.overlay
```

**Component tier (only when needed):**
```
button.primary.bg.default / .pressed / .disabled
listItem.leading.size   sheet.handle.color   tabBar.item.fg.selected
```

**Naming rules:**
- Use **`accent`** for the brand color and **`primary/secondary/tertiary`** for emphasis level, following Apple's `label` / `secondaryLabel` convention. Using "primary" for both meanings is the most common source of confusion.
- Never put hues in semantic names (`text-gray`). Never put modes in names (`bg-dark`): modes are values, not names.
- Keep variants to at most three levels of emphasis. Primer's three modifiers are a good ceiling.

**Platform output from the same path `color.fg.secondary`:**
- CSS: `--color-fg-secondary`
- Swift: `Color.DS.fgSecondary`, backed by an asset catalog color set with Any, Dark and High Contrast appearances
- Compose: `DsTheme.colors.fgSecondary`
- React Native: `theme.color.fg.secondary`

**Example: DTCG 2025.10 source, with modes handled by the Resolver (illustrative):**
```jsonc
// tokens/primitives/color.json
{ "color": { "$type": "color",
  "neutral": { "12": { "$value": { "colorSpace": "oklch", "components": [0.21, 0.006, 285], "hex": "#18181B" } } } } }

// tokens/semantic/color.light.json
{ "color": { "fg": { "primary":   { "$type": "color", "$value": "{color.neutral.12}" },
                     "secondary": { "$type": "color", "$value": "{color.neutral.11}" } } } }

// tokens/resolver.json  (sets + modifiers)
{ "sets": { "base": { "sources": [{ "$ref": "primitives/color.json" }] } },
  "modifiers": { "colorScheme": { "contexts": {
      "light": [{ "$ref": "semantic/color.light.json" }],
      "dark":  [{ "$ref": "semantic/color.dark.json" }] } } } }
```

**In Figma**, mirror the tiers as collections:
- Primitives (one mode, hidden from publishing)
- Semantic Color (Light / Dark / Light-HC / Dark-HC modes)
- Spacing & Radius
- Typography

This two-or-more-collection setup is the standard pattern. ([Atomize: Figma dark mode](https://atomize.tools/blog/figma-variables-dark-mode/))

**Motion tokens:** DTCG has no spring type yet. Store springs as a composite token whose parameters live under `$extensions`, for example `{duration: 0.3, bounce: 0.15}`. Apple's two-parameter model (duration + bounce) converts losslessly to stiffness and damping ([WWDC23 "Animate with springs"](https://developer.apple.com/videos/play/wwdc2023/10158/), [notes](https://wwdcnotes.com/documentation/wwdc23-10158-animate-with-springs/)), so one token can drive SwiftUI, Reanimated and Compose.

---

## 2. Reference systems: what to copy from each

| System | The one or two ideas worth copying |
|---|---|
| **Apple HIG (structural lessons only)** | **Fluid interfaces:** every gesture-driven animation is responsive, interruptible and redirectable, and carries the gesture's velocity into the animation ([WWDC18 "Designing Fluid Interfaces"](https://developer.apple.com/videos/play/wwdc2018/803/)). **Springs defined by duration + bounce**, with three presets: smooth (no bounce), snappy (small bounce) and bouncy ([WWDC23](https://developer.apple.com/videos/play/wwdc2023/10158/)). **iOS 26 / Liquid Glass makes concentricity a system rule:** inner corner radius is derived from the container's radius minus the inset, and SwiftUI ships `ConcentricRectangle` ([nilcoalescing](https://nilcoalescing.com/blog/ConcentricRectangleInSwiftUI/), [WWDC25 "Get to know the new design system"](https://developer.apple.com/videos/play/wwdc2025/356/)). |
| **Airbnb DLS (2016)** | Built by a small, dedicated, cross-functional team who cleared their calendars and worked in a separate studio. A design language is "an evolving ecosystem," not a set of static atoms ([Karri Saarinen DLS](https://karrisaarinen.com/dls/)). On the engineering side, the **Ghost Platform** delivers server-driven UI made of sections, screens and actions, from one shared GraphQL schema for web, iOS and Android. That only works because the component vocabulary is small and strict ([Airbnb Eng](https://medium.com/airbnb-engineering/a-deep-dive-into-airbnbs-server-driven-ui-system-842244c5f5)). |
| **Airbnb 2025 redesign** | **Restraint everywhere, with richness spent in one place.** The typeface (Cereal), the Rausch accent and soft radii were all kept. The new budget went into dimensional, animated 3D icons, delivered in a custom alpha-video format ("Lava") because Lottie could not carry the lighting and depth ([Airbnb newsroom](https://news.airbnb.com/airbnb-2025-summer-release), [It's Nice That](https://www.itsnicethat.com/articles/airbnb-app-redesign-140525), [Lava deep dive](https://medium.com/@waldobear002/airbnbs-new-lava-icon-format-a-technical-deep-dive-b2604626c7e0)). Depth comes from photography and whitespace, not heavy shadows. Third-party extractions report about 20px card radii and multi-layer soft shadows (low confidence: [superdesign](https://superdesign.dev/blog/airbnb-design-system)). |
| **Linear** | **Themes generated from three LCH inputs** (base, accent, contrast) instead of about 98 hand-tuned variables ([2024 redesign](https://linear.app/now/how-we-redesigned-the-linear-ui)). **Not everything gets equal weight:** in the March 2026 refresh the navigation sidebar was dimmed "a few notches" so the content area leads, and header actions were moved to predictable positions ([A calmer interface](https://linear.app/now/behind-the-latest-design-refresh)). |
| **Stripe** | **Perceptually uniform color ramps with built-in contrast guarantees** (see §1.3). **Organizational quality rituals:** "walk the store" reviews of the top ~15 user journeys by PMs, engineers and designers, plus friction logs ([Katie Dill interview](https://creatoreconomy.so/p/how-stripe-crafts-quality-products-katie-dill)). Stripe reports that upgrading typography, layout and imagery in one email raised conversion by 20% ([same](https://creatoreconomy.so/p/how-stripe-crafts-quality-products-katie-dill), [Stripe Sessions talk](https://stripe.com/sessions/2024/craft-and-beauty-the-business-value-of-form-in-function)). |
| **Revolut** | Public sources are thin, and these figures come from third-party extractions (low confidence). Product UI is almost entirely achromatic (white surfaces, near-black ink, hairline dividers). Character comes from a distinctive display face (Aeonik Pro, tight tracking) paired with a neutral UI face (Inter), and from imagery ([shadcn extraction](https://www.shadcn.io/design/revolut)). **Lesson:** two typefaces with clear jobs, and large, confident numerals for money. |
| **Arc / The Browser Company** | Treats delight as pacing, borrowed from game design: users get early "little wins" during onboarding. Arc Search was a 2024 Apple Design Award finalist ([Inverse interview](https://www.inverse.com/input/design/the-browser-company-arc-design-interview), [refine.dev history](https://refine.dev/blog/arc-browser/)). Copy the idea of choreographing first-run moments, not the visual style. |
| **Things 3** | Two Apple Design Awards (2009, 2017). It uses a **custom animation toolkit**, and "unfolding animations keep your place": motion serves spatial continuity, not decoration ([Cultured Code features](https://culturedcode.com/things/features/), [Wikipedia](https://en.wikipedia.org/wiki/Things_(software))). Its Magic Plus button is one signature interaction rather than many small ones. |
| **Shopify Polaris** | The most rigorous public **semantic color naming formula** (§1.2). The 2023 "Uplift" escaped a sterile feel by starting from an extreme of tactility and then **designing by subtraction**. The buttons were tuned to feel like "matte plastic, not glass," and "joy" was to come from completing tasks, not from decoration ([Uplifting Polaris](https://halfool.medium.com/uplifting-shopify-polaris-7c54fc6564d9)). |
| **Material 3 Expressive (for contrast)** | It rests on 46 studies with 18,000+ participants and replaces duration-and-easing motion with springs ([M3 blog](https://m3.material.io/blog/building-with-m3-expressive)). **Steal its motion taxonomy:** *spatial* springs (position, size, shape) may overshoot; *effects* springs (color, opacity) must not. Each comes in fast, default and slow, and there are two schemes: Expressive (low damping) and Standard (high damping) ([M3 motion](https://m3.material.io/blog/m3-expressive-motion-theming)). **For an Apple-like feel, use the Standard scheme**, not Expressive's shape morphing and heavy bounce. |

---

## 3. What makes an app feel premium: concrete practices

1. **Color restraint: a monochrome base plus one accent.** Stripe, Linear and Vercel are almost entirely black, white and gray, with a single color carrying the brand ([Mantlr analysis](https://mantlr.com/blog/stripe-linear-vercel-premium-ui)). Revolut's product UI is achromatic. In practice:
   - Reserve the accent for the primary action, selection and links.
   - Status colors appear only when they carry meaning.
   - Never color-code decoration.
2. **Hierarchy through dimming, not adding.** Linear made the sidebar dimmer instead of making the content louder ([Linear 2026](https://linear.app/now/behind-the-latest-design-refresh)). Give text three levels (`fg.primary`, `secondary`, `tertiary`) and get most of the hierarchy from those plus weight before reaching for size.
3. **A small typographic scale.** Use about 8–10 named text roles mapped to the platform's Dynamic Type styles. Avoid arbitrary sizes. Use **tabular figures** wherever numbers update or align in columns: balances, timers, lists of amounts ([floow fintech](https://www.floow.design/blog/how-to-design-a-fintech-app-screen)).
4. **Generous, systematic whitespace.** Use a 4pt base with mostly 8pt multiples, and a fixed screen gutter of 16 or 20pt. Premium apps tend to have *fewer* elements per screen with more air, not smaller spacing.
5. **Consistent, concentric radii.** Keep about four radius roles (control, card, sheet, pill). Nested shapes use `inner = outer − padding`, otherwise corners look uneven ([30secondsofcode](https://www.30secondsofcode.org/css/s/nested-border-radius/)). This is now enforced at system level on iOS 26 ([ConcentricRectangle](https://nilcoalescing.com/blog/ConcentricRectangleInSwiftUI/)). On iOS, use continuous corners (squircles), never circular-arc corners.
6. **Springs, not easing curves, and interruptible.** All gesture-driven motion should hand off velocity and be interruptible mid-flight ([WWDC18](https://developer.apple.com/videos/play/wwdc2018/803/)). Ship three spring tokens: smooth (no bounce) for most transitions, snappy (small bounce) for press and toggle feedback, bouncy only for rare celebratory moments. Opacity and color changes must never overshoot (M3's spatial-vs-effects split).
7. **Motion frequency budget.** Actions people repeat hundreds of times a day should have little or no animation. Use only `transform` and `opacity`. Review animations in slow motion, frame by frame ([Emil Kowalski skill / principles](https://github.com/emilkowalski/skills/blob/main/skills/emil-design-eng/SKILL.md)). "The best animations are the ones you don't notice."
8. **Reduce Motion is a design token, not an afterthought.** When Reduce Motion is on, slides become cross-fades and parallax and autoplay are removed. Meaningful state changes keep a non-motion cue: a dissolve, a highlight or a color shift ([Apple App Store reduced-motion criteria](https://developer.apple.com/help/app-store-connect/manage-app-accessibility/reduced-motion-evaluation-criteria)).
9. **Haptics: sparse, semantic, never the only signal.**
   - Use system patterns: selection, impact and notification success, warning or error.
   - Very frequent events (scroll, drag) get only very subtle haptics or none.
   - Plain button taps usually get none.
   - Users can disable haptics, so always pair them with a visual cue.
   - ([Android haptics principles](https://developer.android.com/develop/ui/views/haptics/haptics-principles), [PIE haptics pattern](https://pie.design/patterns/haptic-feedback/))
   - Put haptics in the system as named roles (`haptic.selection`, `haptic.success`, `haptic.warning`) attached to components, so product teams don't sprinkle them ad hoc.
10. **Loading states.**
    - Use skeletons for full-screen or region loads expected to take about 1–10 s.
    - Show nothing for loads under ~1 s, which avoids flashing.
    - Use progress bars for long or measurable work like uploads and conversions.
    - Skeletons must match the real layout's geometry ([NN/g Skeleton Screens 101](https://www.nngroup.com/articles/skeleton-screens/)).
    - Evidence that skeletons improve perceived speed is mixed ([ResearchGate study](https://www.researchgate.net/publication/326858669_The_effect_of_skeleton_screens_Users'_perception_of_speed_and_ease_of_navigation)). The bigger premium signal is no layout shift when content arrives, plus a quick cross-fade in.
11. **Empty states as onboarding.**
    - A one-line explanation, at most three lines of guidance, and one clear action.
    - Starter content where it helps.
    - Illustration only to set mood, not to decorate.
    - ([NN/g empty states](https://www.nngroup.com/articles/empty-state-interface-design/), [Material empty states](https://m2.material.io/design/communication/empty-states.html))
12. **Dark mode designed, not inverted.**
    - Elevation comes from *lighter surfaces*, not shadows.
    - Desaturate accents (roughly −20 saturation) so they stay comfortable and pass contrast.
    - Generate a separate dark ramp.
    - ([dark mode practices](https://atmos.style/blog/dark-mode-ui-best-practices), [Uxcel](https://uxcel.com/blog/12-principles-of-dark-mode-design-627))
    - Material recommends #121212 over pure black. Apple instead uses true black as the base with lighter "elevated" grays, which suits OLED. For an Apple-like app, follow Apple's model: black base, distinct elevated surfaces for sheets and modals.
13. **Invisible details**, which users never notice but always feel:
    - pressed states on every tappable item;
    - hit targets of at least 44pt even when the visual is smaller;
    - focus-ring tokens;
    - toast timers that pause when the app is backgrounded;
    - no layout jump when the keyboard appears;
    - text truncation rules decided per component.
    - ([Rauno Freiberg, "Invisible Details of Interaction Design"](https://rauno.me/craft/interaction-design), [Devouring Details](https://devouringdetails.com/))
14. **Spend your richness budget in one place.** Airbnb 2025 kept everything restrained and invested in dimensional icons. Polaris put "juice" into the button press. Pick one signature moment and keep the rest quiet.

---

## 4. Component library structure

### 4.1 Prioritized v1 component list (mobile)
Priority reflects usage frequency. At Uber, the **list item makes up more than 80% of the UI** ([Uber Base list item](https://base.uber.com/6d2425e9f/v/0/p/96ccc3-list-item/b/60a9b6)), so invest there first.

**P0: foundations, needed before any screen ships**
1. **Text**: role-based (`type.*`), Dynamic Type aware, tabular-figures option
2. **Icon**: one icon set, sizes tied to text roles, optical alignment
3. **Button**: primary, secondary, tertiary (plain), destructive; S/M/L sizes; loading state
4. **IconButton**
5. **ListItem / Cell**: leading slot (icon, avatar, image), up to 3 text lines, trailing slot (chevron, value, toggle, button)
6. **List Section / Grouped container**: inset-grouped style, header and footer text
7. **TextField**: plus secure and multiline variants, helper and error text, clear button
8. **Selection controls**: Toggle, Checkbox, Radio
9. **Navigation bar / Screen header**: large and inline titles, actions
10. **Tab bar**
11. **Sheet**: bottom sheet with detents. Also **Alert/Dialog**, preferably the native one.

**P1: needed in the first months**

12. **Segmented control**
13. **Toast / Banner** (inline message)
14. **Skeleton** plus Spinner / Progress
15. **Empty state**
16. **Avatar**, **Badge / Tag**, **Card**, **Divider**
17. Search field, Menu / Context menu, Date / Picker (mostly native wrappers)

**Rule:** on iOS, *wrap* native navigation chrome (nav bar, tab bar, sheets, menus, alerts) rather than rebuilding it, especially under Liquid Glass. Re-implemented system chrome is the fastest way to look cheap. ([WWDC25 SwiftUI new design](https://developer.apple.com/videos/play/wwdc2025/323/))

### 4.2 Component documentation template
EightShapes' approach is to automate **anatomy, props, and layout and spacing**. Its Specs plugin generates them in Figma and shows which variables are bound ([EightShapes Specs](https://nathanacurtis.substack.com/p/the-eightshapes-specs-figma-plugin-2892f21adc96)). Align props across design and code ([Crafting component API together](https://medium.com/eightshapes-llc/crafting-ui-component-api-together-81946d140371)).

Each component page should include:
1. **Summary**: what it is, when to use it, **when not to** (and what to use instead)
2. **Anatomy**: numbered parts, each tied to the tokens it uses
3. **Variants & props**: a table whose prop names *match the code API exactly*
4. **States**: default, pressed, focused, selected, disabled, loading, error, in light, dark and high-contrast
5. **Layout & spacing**: token references, never raw pixel values
6. **Behavior**: motion token, haptic role, gestures, keyboard
7. **Accessibility**: label rules, traits, Dynamic Type up to AX sizes, minimum hit target, Reduce Motion behavior
8. **Content guidelines**: label length, casing, truncation
9. **Do / Don't**: side-by-side real screenshots, each with a one-line reason
10. **Platform notes and status**: iOS, Android or web differences; code links (Code Connect); version; changelog

---

## 5. Process and governance (short)

- **Figma:**
  - Separate a **Foundations** library (variables, text styles, icons) from a **Components** library. Product files consume both.
  - Use slash naming (`Button/Primary/Large`) and prefix private building blocks with `_` or `.` so they aren't published.
  - Use branching for changes, with release notes on every publish.
  - Add an "Examples" page; Figma AI and agents now use it.
  - ([Figma best practices](https://www.figma.com/best-practices/components-styles-and-shared-libraries/), [Figma AI and design systems](https://help.figma.com/hc/en-us/articles/38978644498199-Best-practices-to-help-Figma-AI-understand-your-design-system))
- **Source of truth:**
  - Keep the token JSON in Git, reviewed in pull requests and built by CI into each platform's artifacts. Figma Variables sync from or to it.
  - Version tokens and components with **semver**. A library serving 1–2 apps should version as a single package ([Brad Frost on versioning](https://bradfrost.com/blog/post/design-system-versioning-single-library-or-individual-components/)).
- **Handoff:** use **Figma Code Connect** so Dev Mode shows *your* component code, not generic CSS. Pair it with the **Figma MCP server**, which gives AI coding agents exact variable names and component mappings ([Code Connect](https://help.figma.com/hc/en-us/articles/23920389749655-Code-Connect), [Figma MCP](https://www.figma.com/blog/introducing-figma-mcp-server/)).
- **Implementation patterns:**
  - **SwiftUI:** semantic colors become asset-catalog color sets (Any, Dark, High Contrast); typography maps to Dynamic Type styles; springs are `Animation` tokens.
  - **Compose:** a `CompositionLocal` theme object.
  - **Flutter:** `ThemeExtension` token classes; `lerp` gives animated theme switches for free ([Widgetbook](https://www.widgetbook.io/blog/custom-design-system)).
  - **React Native:** **Unistyles 3** (swaps theme natively without re-rendering) or **Tamagui** (compiler, web plus native). Use Reanimated for springs and expo-haptics for haptic roles ([LogRocket comparison](https://blog.logrocket.com/unistyles-vs-tamagui-cross-platform-react-native-styles/)).
- **Contribution model:**
  - Promote a component into the system only when about three teams need it.
  - Path: proposal → design review → build in the component workshop (Storybook, Widgetbook or Xcode Previews) → accessibility check → release notes.
  - ([Brad Frost governance process](https://bradfrost.com/blog/post/a-design-system-governance-process/), [Figma: scaling mistakes](https://www.figma.com/resource-library/design-system-scaling/))
  - Add Stripe-style "walk the store" reviews of the top journeys each quarter.

---

## 6. Common mistakes that make a system feel cheap or become unmaintainable

**Feels cheap:**
- **Too many colors.** Status colors used for decoration, a second brand accent, gradients everywhere. The premium apps above are almost monochrome.
- **Arbitrary radii and spacing.** Off-scale values, equal radii on nested shapes (bulging corners), circular rather than continuous corners on iOS.
- **Rebuilt native chrome.** Custom nav bars, sheets and pickers that miss system physics, swipe-back, Dynamic Type or Liquid Glass behavior.
- **Easing curves with fixed durations** on gesture-driven UI. They can't be interrupted, so the UI feels laggy.
- **Overshoot on opacity or color.** Bounce on everything.
- **Animation on high-frequency actions.**
- **Dark mode made by inverting the light palette.** Saturated accents on black, shadows used for elevation, untested contrast.
- **Spinners for every load, layout shift when content arrives, and blank "No data" empty states.**
- **Haptics on every tap.**

**Becomes unmaintainable:**
- **Components referencing primitives directly**, so dark mode and rebrands need code changes. Hue or mode names in semantic tokens (`text-gray-dark`).
- **Component-token explosion.** Every component gets its own tokens even when they only mirror semantic ones. Keep the component tier sparse.
- **Variant bloat.** "200+ components ignored." A component with dozens of boolean props becomes a framework. Prefer slots and composition ([Figma: scaling mistakes](https://www.figma.com/resource-library/design-system-scaling/), [Design systems should do less](https://joshcusick.substack.com/p/design-systems-should-do-less)).
- **Figma and code out of sync.** Different prop names, no Code Connect, tokens hand-copied instead of generated.
- **A museum system.** Beautiful docs that don't solve real product needs, so teams detach instances and build local components ([why systems fail](https://medium.com/design-bootcamp/why-your-design-system-is-failing-and-how-to-fix-it-c42d9d5d2b10)).
- **No versioning or changelog.** Breaking changes ship silently, and trust collapses.

---

## 7. Recommended starting setup

### Token tiers
1. **Primitives (no modes, never used directly):**
   - OKLCH 12-step ramps: `neutral` and `accent`, plus `red`, `green` and `amber` for status. Separate light and dark ramps.
   - `scale.*` on a 4pt base.
   - `radius.raw.*`, font families and weights, `duration.*`.
2. **Semantic (modes: light, dark, light-HC, dark-HC):**
   - Color: `color.bg.*`, `color.fg.primary|secondary|tertiary|disabled|on-accent`, `color.border.*`, `color.accent.*`, `color.status.*`
   - Spacing: `space.inset|stack|inline.*`, `space.screen.gutter`
   - Radius: `radius.control|card|sheet|pill` (concentric by rule)
   - Type: about 9 `type.*` roles mapped to Dynamic Type
   - Motion: `motion.spring.smooth|snappy|bouncy`, `motion.effect.fast|default|slow`
   - Elevation and haptics: `elevation.raised|overlay`, `haptic.selection|success|warning|error`
3. **Component:** only where a component must diverge, for example `button.primary.bg.pressed`.

Starting spring values to tune by eye:
- `smooth`: duration 0.35 s, bounce 0
- `snappy`: duration 0.3 s, bounce 0.15
- `bouncy`: duration 0.45 s, bounce 0.3, used rarely
- Effects: 150 / 250 / 350 ms, no overshoot

### First 15 components
1. Text
2. Icon
3. Button
4. IconButton
5. ListItem
6. List Section
7. TextField
8. Toggle / Checkbox / Radio
9. NavigationBar
10. TabBar
11. Sheet + Alert (native-wrapped)
12. SegmentedControl
13. Toast / Banner
14. Skeleton + Progress
15. EmptyState

Avatar, Badge, Card and Divider come right after.

### Tooling stack
- **Design:** Figma Variables with collections Primitives / Semantic Color (4 modes) / Spacing-Radius / Typography. Add Tokens Studio only if you need composite tokens round-tripped. Use the EightShapes Specs plugin for anatomy docs.
- **Source of truth:** DTCG 2025.10 JSON in Git, with modes expressed through the Resolver module (`colorScheme`, `contrast`).
- **Build:** Style Dictionary v5, the most mature multi-platform transform set (Swift, Compose, XML, TS, CSS). Evaluate Terrazzo if you need full Resolver support today. Run it in CI and publish semver packages with changesets.
- **Implementation:**
  - SwiftUI native: asset catalogs + Swift token enums + `Animation` spring tokens.
  - React Native: Unistyles 3 + Reanimated + Gesture Handler + expo-haptics, wrapping native sheets and navigation.
  - Flutter: `ThemeExtension`.
- **Handoff and QA:** Figma Code Connect + Figma MCP server; a component workshop (Storybook, Widgetbook or Xcode Previews) with visual regression across all four modes; a quarterly "walk the store" quality review of the top 10–15 journeys.
