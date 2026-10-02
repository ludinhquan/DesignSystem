# Switching design systems cheaply

_October 2026 · packages/ds after the Pebble work · Flutter 3.47 / Dart 3.13_

The question: once the app is built in one design system (Pebble), how much
work is it to move it to another one, and what makes that work small? This
note looks at where the cost of a switch comes from, what this repository
now does about each part, and what is left.

---

## 1. Where the cost of a switch comes from

| Cost | Why it hurts | Typical size without a plan |
|---|---|---|
| **Values in widgets** | Every hard-coded colour, size or font in a screen has to be found and changed by hand | Unbounded: grep and pray |
| **Vocabulary mismatch** | System A says `primary`/`onSurfaceVariant`, system B says `accent`/`text-2`. Components written against A's names do not read B | A rewrite of every component |
| **Component APIs that leak one look** | `Button(color: Colors.blue, elevation: 4)` encodes A's look in the call site | Every call site |
| **Behaviour, not only values** | Corner geometry, press feel, springs, haptics, icon family, type faces with variable axes | Usually forgotten, then patched per screen |
| **Re-keying the source** | Design tools export tokens in their own format; typing them into Dart by hand drifts | Hours per sync, plus silent mistakes |
| **Not knowing what broke** | Without visual baselines and accessibility checks, a switch ships regressions | Found by users |

Values are the easy part. Most of the cost is in the vocabulary, the
component APIs and the behaviour.

## 2. What this repository does about it

### 2.1 One semantic contract, read by every component

`packages/ds/lib/src/foundation/` defines **what any design system must
provide**, named by role, not by look:

- `DsColors`: 24 semantic colours (`canvas`, `surface…surface3`, `text1–3`,
  `accent`, `onAccent`, `accentText`, `positive`, `negative`, soft
  variants, `glass`, `scrim`, `focusRing`…) plus **six object fields**
  named by hue slot (`yellow, red, blue, green, purple, graphite`), each
  with face, gradient end, ink, secondary ink, tint and shadow.
- `DsTypeScale`: 20 roles in three voices (display / interface / rounded).
- `DsSpacing`, `DsRadii`, `DsSizes`, `DsOpacities`, `DsShadows` (CSS-style
  layers, inset included).
- `DsMotion`: springs as duration + bounce, press-in curve and scales.
- `DsIconSet`: 33 glyphs **by meaning** (`home`, `send`, `contactless`,
  `coffee`…), each in regular / bold / fill / duotone.
- `DsCorners`: superellipse or circular.

Components (`DsButton`, `DsAccountCard`, `DsTabBar`, …) read **only** this
contract through `context.ds`. No component knows which system it is in.

### 2.2 A design system is data, plus one small file

```
packages/ds/systems/pebble/tokens.json   ← exported from the design tool (verbatim)
packages/ds/systems/pebble/system.json   ← which of its colour names fills each hue slot
packages/ds/lib/src/systems/pebble/pebble_tokens.g.dart   ← generated
packages/ds/lib/src/systems/pebble/pebble.dart            ← faces, motion, icons, corners (hand-written)
```

`tokens.json` is the claude.ai **Design System** artifact format, so a
system made there drops in unchanged. `tool/gen_tokens.dart` (pure Dart, no
build_runner) turns it into a `DsTokenSet`, resolving aliases per theme and
parsing CSS shadows, and **refuses to generate** if any contract token is
missing, listing every gap at once. CI runs it with `--check`.

The hand-written part holds what tokens cannot say: which font files and
variable axes the voices use, springs, the icon family, corner geometry,
whether haptics are on. For Pebble that is about 40 lines of decisions
plus a 33-entry icon map (about 270 lines once formatted).

### 2.3 The app picks a system with one value

```dart
// app/lib/config/brands/brand_b.dart
const brandB = Brand(id: 'brand_b', appName: 'Acme', ds: classic);
```

`DsTheme.light/dark(brand.ds)` builds the material_ui `ThemeData` (so plain
Material widgets follow) and attaches the contract. Brand A runs Pebble,
brand B runs Classic: **the same screens, no `if (pebble)` anywhere**.
`flutter run -d chrome --dart-define-from-file=config/brand_b.dev.json`
shows it.

### 2.4 Component APIs carry intent, not looks

`DsButton(variant: prominent)` not `color: yellow`; `DsIconTile.glyph(field:
DsField.red, icon: ds.icons.send)` not a Phosphor constant;
`DsMoney(-65000, sign: true)` not a formatted string. App code never names a
colour value, a font, an icon font or a radius.

### 2.5 Every system is checked automatically

- **Golden matrix**: 7 component groups × every registered system × light
  and dark (`test/showcase_golden_test.dart`). Adding a system to the
  `systems` map gives it 14 baselines with no new test code.
- **Contract test** (`test/contract_test.dart`): WCAG floors for every text
  and mark pair in every system and theme: text 4.5:1 on all grounds,
  `text-3` and focus 3:1, ink on both gradient stops of every object field,
  `on-accent` on accent. It caught a 3.7:1 colour in the hand-written
  Classic system on its first run.
- **Generator `--check`** in CI keeps generated Dart in step with the JSON.

## 3. What a switch costs now

| Task | Before | Now |
|---|---|---|
| Re-skin to another system made in the Design System tool | Rewrite components and screens | Drop `tokens.json`, write `system.json` (6 lines) and `<name>.dart` (faces, motion, the 33-glyph icon map), run the generator, add one line to `Brand`. Goldens and contrast checks run for free |
| Sync a token change from design | Find and edit Dart constants | Replace `tokens.json`, run the generator, review the golden diff |
| Give one brand a different system | Fork screens | Change `Brand.ds` |
| Try a system in a branch of the UI | Not possible | `Theme(data: DsTheme.light(classic), child: …)` around any subtree |

The measured switch in this repo: brand B moved from Pebble to Classic by
changing one constructor argument. The app's screens, routes and tests did
not change (`test/smoke_test.dart` runs the login and home flow in both).

## 4. Limits and what is left

- **The contract is Pebble-shaped.** It was derived from Pebble's vocabulary
  (objects with fields, a glass tab bar). A system with genuinely different
  concepts (say, no objects, a side rail instead of a tab bar) needs the
  contract to grow, and every system to fill the new tokens. Keep additions
  semantic and give each a sensible derivation, so older systems do not
  break.
- **Components with a strong personality** (Tap to pay, the card stack)
  read only tokens, but their *structure* is Pebble's. Another system may
  want a different component, not a re-skin. Allow that with a per-system
  builder override only when a real second system needs it.
- **Inset shadows, grain and specular** are drawn by our painters, not by
  `BoxShadow`. A system that wants blur-based materials beyond that needs
  painter support first.
- **OKLab mixing** for the monthly face shift is done in RGB today
  (`Color.lerp`). Close at 35%; exact needs a small OKLab helper.
- **Not built (needs packages the architecture keeps out for now)**: card
  tilt from the gyroscope (`sensors_plus`), spring heroes (`heroine`), the
  presenting screen scaling behind a sheet, the per-digit rise in the
  AmountField. The static specular at the top left is the Reduce Motion
  look and is what ships.
- **Runtime switching** (a user picks a theme) works today, since the system
  is just a `ThemeData`, but there is no UI for it, and switching mid-
  animation snaps non-colour tokens at the halfway point by design.

## 5. Rules that keep switches cheap

1. Screens never name a colour, size, font, icon font or radius: only
   `context.ds.*` and Ds* components.
2. New design needs → a semantic token in the contract first, then every
   system fills it (the generator enforces it).
3. Component parameters describe intent (`variant`, `field`, `size`), never
   appearance.
4. A system's `tokens.json` is vendored verbatim from its source; edits go
   back to the source, then re-export.
5. Every system is in the golden matrix and the contrast test.
