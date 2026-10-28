# AGENT.md — Production AI Coding Guidelines, Zero-Fault Architecture & CMP UI System

> Place this file in the root of the Flutter project. Optionally copy it to `CLAUDE.md` or `.cursorrules` so other coding agents pick it up. Read the whole file before writing code. If a request conflicts with a rule here, say so and propose a compliant alternative instead of silently breaking the rule.

---

## 1\. Project Overview

**Project:** Zero-Fault Phone-Only Vehicle Speed Estimator (Single-Phone Edition) **Working app name:** CMP Speed Monitor / সিএমপি স্পিড মনিটর *(placeholder — final name to be confirmed with CMP)* **Client / users:** Chattogram Metropolitan Police (CMP), Bangladesh Police — traffic officers operating a phone on a tripod at the roadside. **Target environment:** High-density roadside traffic in Bangladesh: cars, buses, trucks, CNG auto-rickshaws, legunas, motorcycles.

**Core mechanism:**

1. **Calibration** — The officer measures the real-world distance `D` (20 m–50 m recommended) between two roadside landmarks using an in-app **zoomed satellite map pin-dropper** (Haversine geodesic distance), or the **camera height \+ tilt geometry** fallback. Live phone GPS is never used for short distances, and the officer never steps onto the live road.  
2. **Virtual gates** — The officer aligns **Gate A (start)** and **Gate B (end)** on the camera preview with the same two landmarks. The engine automatically generates an invisible-to-edit **Gate M (midpoint)** halfway between them.  
3. **Zero-mismatch tracking** — A persistent background Isolate runs YOLOv8n (TFLite) \+ 2-stage ByteTrack \+ Kalman/constant-velocity prediction \+ class lock \+ 8-bin RGB color histogram lock at 30–60 FPS.  
4. **Zero-fault speed verification** — A speed is accepted only if the same `trackId` passes Gate A → Gate M → Gate B (or B → M → A on two-way roads) and the speeds of the two halves pass the consistency check.  
5. **Officer-facing UI** — A modern, Bangla-first, CMP-themed interface designed for outdoor, one-handed, gloved use (Section 7–9).

**Out of scope (never build):** license-plate recognition, face recognition, any personal identification of drivers or passengers, raw video recording or upload.

---

## 2\. Tech Stack & Approved Packages

Agents MUST use only the packages below. Do not introduce heavy, deprecated, or unmaintained dependencies. Adding a package requires an explicit note explaining why none of the approved ones suffice.

### Runtime dependencies

| Concern | Package / Choice |
| :---- | :---- |
| Framework | Flutter (latest stable), Dart 3.x, strict null safety, Material 3 (`useMaterial3: true`) |
| State management | `flutter_riverpod` \+ `riverpod_annotation` — `Notifier` / `AsyncNotifier` ONLY. No `StateNotifier`, no `ChangeNotifier`. |
| Navigation | `go_router` (declarative routes \+ redirect guards) |
| Camera | `camera` — stream raw `CameraImage`: `ImageFormatGroup.yuv420` on Android, `bgra8888` on iOS, 30–60 FPS |
| On-device ML | `tflite_flutter` — INT8/FP16 quantized YOLOv8n `.tflite`, GPU/NNAPI delegates enabled |
| Satellite calibration | `google_maps_flutter` or `flutter_map` with a high-zoom satellite tile layer, plus `geolocator` (initial map centering ONLY) |
| Sensors | `sensors_plus` — gyroscope/accelerometer for shake detection and fallback tilt/height calibration |
| Local database | `drift` \+ `sqlite3_flutter_libs` (offline-first persistence of verified records and saved sites) |
| Networking | `dio` — strictly for syncing tiny JSON metadata payloads |
| Data models | `freezed` \+ `json_serializable` — all domain entities and state models are immutable |
| Localization | `flutter_localizations` (SDK) \+ `intl`, ARB files, `flutter gen-l10n` |
| Screen & permissions | `wakelock_plus` (keep screen on while monitoring), `permission_handler` |
| Export | `path_provider`, `share_plus`, `csv` (export verified logs as CSV/JSON) |

### Dev dependencies

`build_runner`, `riverpod_generator`, `freezed`, `json_serializable`, `drift_dev`, `flutter_lints`, `mocktail`, `flutter_test` (SDK).

### Fonts & assets (bundled — no runtime downloads)

Do NOT use `google_fonts` or any runtime font/asset fetching; the app must work fully offline in the field. Bundle fonts and models under `assets/` and declare them in `pubspec.yaml`.

---

## 3\. Folder Structure (Feature-First Clean Architecture)

All generated code MUST follow this structure:

assets/

├── branding/               \# cmp\_crest.png — supplied by CMP. Never redraw, recolor or alter.

├── fonts/                  \# NotoSansBengali (400/500/700), Inter (400/500/600/700)

└── models/                 \# yolov8n\_int8.tflite

lib/

├── app/

│   ├── app.dart            \# MaterialApp.router, theme, locale, text-scale clamp

│   └── router.dart         \# go\_router routes \+ guards (Section 8\)

├── l10n/                   \# app\_bn.arb (template), app\_en.arb, generated localizations

├── core/

│   ├── constants/          \# Vehicle classes, tracker thresholds, physics limits

│   ├── errors/             \# Sealed Failure classes & Result\<T, Failure\> pattern

│   ├── services/           \# Background Isolate worker, NTP clock sync, permissions

│   ├── theme/              \# cmp\_colors.dart, overlay\_colors.dart, cmp\_typography.dart,

│   │                       \# cmp\_spacing.dart, cmp\_theme.dart (ThemeExtension tokens)

│   ├── utils/              \# Haversine math, 2D line intersection, RGB histogram extractor

│   └── widgets/            \# Shared design-system widgets (Section 9\) — no feature logic

├── features/

│   ├── home/               \# Dashboard screen

│   ├── session\_setup/      \# Site name, speed limit, road direction, saved sites

│   ├── calibration/        \# Satellite pin-dropper \+ 3-gate (A, M, B) overlay editor

│   │   ├── data/

│   │   ├── domain/         \# Entities: VirtualGate, CalibrationConfig

│   │   └── presentation/   \# SatellitePinScreen, GateAlignmentScreen, CalibrationNotifier

│   ├── speed\_tracking/     \# Camera stream \+ YOLO \+ RobustVehicleTracker \+ 3-gate validator

│   │   ├── data/           \# TFLite interpreter wrapper, YUV420 converter, gyro monitor

│   │   ├── domain/         \# Entities: YoloDetection, TrackedVehicleState, VerifiedSpeedRecord

│   │   │                   \# Logic: RobustVehicleTracker, SpeedMathEngine

│   │   └── presentation/   \# LiveMonitorScreen, BoundingBoxPainter, GatePainter, HUD widgets

│   ├── telemetry\_sync/     \# Drift SQLite storage, Dio sync, logs screen, CSV/JSON export

│   │   ├── data/

│   │   ├── domain/

│   │   └── presentation/   \# VerifiedLogsScreen, LogDetailSheet

│   └── settings/           \# Language, theme, digits, diagnostics, about/legal

└── main.dart

---

## 4\. Core Constants

Define these once in `lib/core/constants/` and reference them everywhere. Never hardcode them inline.

| Constant | Value | Purpose |
| :---- | :---- | :---- |
| `minGateDistanceM` | `15.0` | Minimum recommended distance `D` between gates A and B |
| `recommendedGateDistanceMin/Max` | `20.0 / 50.0` | Ideal calibration range |
| `satelliteZoomTarget` | `≥ 20` | Map zoom level for pin-dropping |
| `highConfThreshold` | `0.50` | Stage-1 (high-confidence) detection matching |
| `lowConfThreshold` | `0.15` | Stage-2 (ByteTrack) lower bound; range is `0.15 ≤ conf < 0.50` |
| `colorHistBins` | `8` per channel | Normalized RGB histogram (24 values) |
| `colorHistCoreRatio` | `0.50` | Inner 50% of the bounding box is sampled |
| `colorSimilarityMin` | `0.65` | Minimum cosine similarity to accept a match |
| `maxCoastFrames` | `15` | Frames an unmatched track may coast |
| `consistencyTolerance` | `0.35` | Max allowed \` |
| `minSpeedKmh` | `5.0` | Lower physical bound |
| `maxSpeedKmh` | `220.0` | Upper physical bound |
| `maxGyroRadPerSec` | `0.15` | Max camera angular velocity during a track |
| `defaultMapCenter` | `22.3569, 91.7832` | Fallback map center (Chattogram) when location is unavailable |
| `hudMetricsMaxHz` | `4` | Max update rate of numeric HUD metrics (FPS, ms) |
| `speedChipHoldMs` | `2500` | How long an on-video verified speed chip stays visible |

**Vehicle classes** (`VehicleClass` enum): `car`, `bus`, `truck`, `cng`, `motorcycle`, `leguna`.

---

## 5\. Non-Negotiable Engine Rules

### Rule 1 — Strict Isolate Separation & Frame-Drop Gate

- NEVER run TFLite inference, YUV420 pixel extraction, RGB histogram calculation, or ByteTrack association on the Main UI Isolate.  
- All vision and tracking logic MUST run inside a **persistent** background Isolate (spawn once, reuse for the whole session).  
- Implement a `bool _isProcessingFrame` flag on the main-isolate side: set it to `true` when a frame is dispatched to the worker and reset it to `false` when the worker's result arrives. If a new camera frame arrives while the flag is `true`, **drop the new frame immediately**. This guarantees zero UI jank and prevents Out-Of-Memory crashes.  
- Send frame bytes to the worker with `TransferableTypedData` (zero-copy). Never send `CameraImage` objects across isolates.

### Rule 2 — No Live GPS for Short-Distance Gate Calibration

- NEVER compute the distance between Point A and Point B from two live phone GPS readings. Consumer GPS error is roughly ±3–5 m, which ruins a 20 m speed trap.  
- **Primary calibration:** an interactive satellite map pin-dropper (`MapType.satellite`, zoom ≥ 20). The officer drops Pin A and Pin B on two visible roadside landmarks (electric poles, footbridge pillars, road markings, etc.). Compute the geodesic distance `D` with the Haversine formula. Enforce a recommended minimum of `D ≥ 15.0 m`.  
- **Fallback calibration:** camera height \+ gyroscope pitch-angle ground-plane projection, for cases where landmarks are hidden by trees, imagery is outdated, or there is no internet for map tiles.

### Rule 3 — Monotonic Hardware Timestamps & Sub-Frame Interpolation

- NEVER use `DateTime.now()` for speed delta calculations.  
- Use a monotonic high-resolution clock (`Stopwatch().elapsedMicroseconds`, or the camera sensor hardware timestamp where available), captured the instant the frame callback fires — before any processing — and passed to the worker with the frame as `frameTimestampUs`.  
- At 30 FPS, frames are \~33.3 ms apart. Whenever a vehicle's ground-contact point (`bbox.center.dx`, `bbox.bottom`) crosses Gate A, Gate M, or Gate B, compute **linear sub-frame interpolation**:

t\_cross \= t\_prev \+ (t\_curr − t\_prev) × dist(P\_prev, GateIntersection) / dist(P\_prev, P\_curr)

where `P_prev` / `P_curr` are the ground-contact points in the previous and current frames, and `GateIntersection` is the 2D intersection of the segment `P_prev → P_curr` with the gate line.

### Rule 4 — Zero-Mismatch Multi-Object Tracking (4-Layer Defense)

Every frame processed in the background Isolate MUST pass all four defenses **before** any gate timestamp is updated:

1. **Strict class lock** — A track (`car`, `bus`, `truck`, `cng`, `motorcycle`, `leguna`) can ONLY associate with a detection of the exact same `vehicleClass`.  
2. **Kalman / constant-velocity kinematics** — Predict each active track's bounding box at `frameTimestampUs` using smoothed velocity `(vx, vy)` BEFORE computing IoU.  
3. **8-bin RGB color histogram lock (Stage 1\)** — Extract a fast normalized RGB histogram from the **inner 50% core** of the bounding box (to ignore road background). During high-confidence matching (`conf ≥ 0.50`), reject any candidate whose cosine similarity with the track's histogram is `< 0.65`. This prevents side-by-side or lane-changing vehicles from swapping IDs.  
4. **ByteTrack low-confidence recovery (Stage 2\)** — Match still-unmatched tracks against low-confidence detections (`0.15 ≤ conf < 0.50`) using predicted-box IoU, so vehicles partially occluded by buses keep their original `trackId`. Unmatched tracks may coast for up to `maxCoastFrames = 15` frames before being dropped.

### Rule 5 — Zero-Fault 3-Gate Consistency Validator

**Gate M generation.** When the officer sets Gate A and Gate B, compute Gate M by averaging the normalized endpoints:

GateM.p1 \= (GateA.p1 \+ GateB.p1) / 2

GateM.p2 \= (GateA.p2 \+ GateB.p2) / 2

> Note: an image-space midpoint is only an approximation of the real-world midpoint because of perspective foreshortening. If a ground-plane homography is available from calibration, prefer computing Gate M from it. Either way, keep `consistencyTolerance` configurable, not hardcoded.

**Validity.** A speed record is VALID if and only if ALL of the following hold:

1. The same `trackId` sequentially records `gateATimeUs`, `gateMTimeUs`, and `gateBTimeUs` (or `B → M → A` for the opposite direction).  
2. Half-speeds are consistent:

V1      \= (D / 2\) / (tM − tA)

V2      \= (D / 2\) / (tB − tM)

V\_total \= D / (tB − tA)

\|V1 − V2\| / V\_total ≤ 0.35

3. `V_total` is within physical bounds: `5.0 km/h ≤ V_total ≤ 220.0 km/h` (convert m/s → km/h by × 3.6).  
4. Camera gyroscope angular velocity stayed `< 0.15 rad/s` for the entire track duration (first gate crossing to last).

If any check fails, **discard the measurement silently** and increment the diagnostic `rejectedFaultCount` counter. Never surface a partial or unverified speed to the UI (no red boxes, no "failed" toasts) or the database. `rejectedFaultCount` is visible only in Diagnostics mode.

### Rule 6 — Privacy & Ultra-Low-Bandwidth Telemetry

- NEVER store or upload raw video or vehicle images.  
- Store and sync ONLY verified metadata, in this shape:

{

  "track\_id": 104,

  "vehicle\_class": "cng",

  "speed\_kmh": 42.65,

  "speed\_half1\_kmh": 43.10,

  "speed\_half2\_kmh": 42.21,

  "direction": "A\_TO\_B",

  "distance\_m": 30.0,

  "timestamp\_utc\_ms": 1761578340000

}

- `direction` is `"A_TO_B"` or `"B_TO_A"`.  
- `timestamp_utc_ms` is NTP-corrected wall-clock UTC for logging only — never for speed math.

---

## 6\. Flutter Engineering Rules

### 6.1 Static analysis

`analysis_options.yaml` MUST be exactly this (zero warnings and zero errors allowed in `flutter analyze`):

include: package:flutter\_lints/flutter.yaml

analyzer:

  language:

    strict-casts: true

    strict-inference: true

    strict-raw-types: true

  errors:

    invalid\_annotation\_target: ignore

  exclude:

    \- "\*\*/\*.g.dart"

    \- "\*\*/\*.freezed.dart"

    \- "lib/l10n/app\_localizations\*.dart"

linter:

  rules:

    \- always\_use\_package\_imports

    \- avoid\_dynamic\_calls

    \- avoid\_print

    \- directives\_ordering

    \- prefer\_const\_constructors

    \- prefer\_const\_declarations

    \- prefer\_final\_locals

    \- require\_trailing\_commas

    \- sort\_child\_properties\_last

    \- unawaited\_futures

    \- use\_super\_parameters

`l10n.yaml`:

arb-dir: lib/l10n

template-arb-file: app\_bn.arb

output-localization-file: app\_localizations.dart

output-dir: lib/l10n

### 6.2 Architecture & code quality

- **Layering:** `presentation → domain ← data`. Presentation never imports `data` directly; it goes through Riverpod providers. Domain has no Flutter imports.  
- **Pure-Dart engines:** `SpeedMathEngine`, `RobustVehicleTracker`, and `HaversineCalculator` have **zero Flutter/UI imports** so they are 100% unit-testable.  
- **File size:** maximum **250 lines per file** (generated `*.g.dart`, `*.freezed.dart` and localization files are exempt). Split large widgets into private sub-widgets or separate files.  
- **Immutability:** every entity and state class is a `freezed` class. No mutable public fields.  
- **Error handling:** use sealed `Failure` classes and `Result<T, Failure>` from `core/errors/`. No bare `catch (e)` that swallows errors, except the intentional silent-discard path in Rule 5\.  
- **Complete code only:** when generating or editing files, output the full file contents — no `// ...rest of code`, no truncation, no placeholder bodies.  
- **Imports:** package imports only (`always_use_package_imports`), ordered per `directives_ordering`.

### 6.3 Widget & state rules

- Prefer `StatelessWidget` / `ConsumerWidget`. Use `setState` only for purely ephemeral, widget-local UI state.  
- Mark everything possible `const`. Extract sub-widgets into **widget classes**, not helper methods that return widgets.  
- Watch narrowly: `ref.watch(provider.select((s) => s.field))`. Never watch a whole large state object in a screen root.  
- Dispose everything you create: `CameraController`, `StreamSubscription`, `ValueNotifier`, `AnimationController`, `Isolate`/`ReceivePort`, wakelock. Use `ref.onDispose` in providers.  
- Never call `ref.read` inside `build`; never perform side effects (navigation, I/O) inside `build`.  
- Never use `BuildContext` after an `await` without checking `context.mounted`.  
- Lists use `ListView.builder` (or slivers) with stable `ValueKey`s for records.

### 6.4 High-FPS rendering rules

- Wrap `CameraPreview` and each custom overlay painter (`GatePainter`, `BoundingBoxPainter`) in its **own** `RepaintBoundary`.  
- NEVER rebuild the widget tree per camera frame. Feed a `ValueNotifier<List<TrackedVehicleState>>` (or a dedicated Riverpod stream) directly into the `CustomPainter` through its `repaint:` argument.  
- `CustomPainter.shouldRepaint` must be correct and cheap. Allocate `Paint`, `TextPainter` and `Path` objects once and reuse them; do not allocate per frame.  
- NEVER place `BackdropFilter`, blur, `Opacity` widgets, `ShaderMask`, or `saveLayer`\-heavy effects over the live camera preview. Use solid translucent colors (`overlayScrim`) instead.  
- HUD numeric metrics (FPS, inference ms, stability) are throttled to `hudMetricsMaxHz`. The verified-feed list updates only when a record is verified.  
- No animations on the per-frame path. UI animations are ≤ 200 ms, use `Curves.easeOut`, and are disabled when `MediaQuery.disableAnimations` is true.

### 6.5 Platform behavior

- **Live Monitor** and **Gate Alignment** lock to landscape (`SystemChrome.setPreferredOrientations`) and use immersive system UI; restore portrait \+ edge-to-edge when leaving.  
- Enable `wakelock_plus` on Live Monitor and release it on exit/pause.  
- Request camera permission with a plain-language rationale screen (Bangla \+ English) before the first request. If permanently denied, show a recovery screen with a button that opens system settings.  
- Android is the primary target (minSdk 24 or higher so NNAPI is available); iOS is secondary.

---

## 7\. UI Design System — CMP Theme

### 7.1 Design intent

Modern, calm, high-authority "command console" look: deep navy surfaces (the classic police-uniform navy), with the **crest greens, reds and yellows** used sparingly as semantic accents. Large numerals, generous spacing, rounded cards, zero clutter. Dark theme is the default (best for tripod use and low light); a high-contrast Light theme is available for strong sunlight. Both ship in v1.

### 7.2 Brand & legal usage (Rule 7\)

- App name, CMP crest and official wording are used **only as supplied and approved by CMP**. Place the supplied crest at `assets/branding/cmp_crest.png`. Never redraw, recolor, distort or invent a crest.  
- Until the crest is supplied, show a neutral shield icon placeholder (`Icons.shield_outlined`) — never an imitation of a real emblem.  
- Official name strings: `চট্টগ্রাম মহানগর পুলিশ` / `Chattogram Metropolitan Police (CMP)`.  
- The crest accent colors below were approximated from public logo references. **Confirm exact brand values with CMP before release**; they live in one file (`cmp_colors.dart`), so changing them is a one-file edit.

### 7.3 Color tokens (`ThemeExtension<CmpColors>` in `core/theme/cmp_colors.dart`)

NEVER hardcode a `Color(0x…)`, `Colors.xxx` or hex value in any widget. Read tokens via `context.cmp` (a `BuildContext` extension returning `CmpColors`). Both themes must be defined with `copyWith` and `lerp`.

| Token | Dark | Light | Use |
| :---- | :---- | :---- | :---- |
| `background` | `#0A1020` | `#F3F6FA` | Scaffold background |
| `surface` | `#111A2E` | `#FFFFFF` | Cards, sheets, nav bar |
| `surfaceHigh` | `#18243D` | `#E8EDF5` | Raised cards, inputs, chips |
| `outline` | `#2B3A5C` | `#C5CEDD` | Borders, dividers |
| `textPrimary` | `#F3F6FB` | `#0A1020` | Main text |
| `textSecondary` | `#A3B0C8` | `#4A5873` | Secondary text, captions |
| `primary` | `#007A38` | `#007A38` | Primary buttons (crest green, darkened for AA contrast) |
| `onPrimary` | `#FFFFFF` | `#FFFFFF` | Text/icons on `primary` |
| `verified` | `#2FD27A` | `#007A38` | Verified speed, success states |
| `warningFill` | `#FFED00` | `#FFED00` | Warning banners (text on it: `#0A1020`) |
| `warningText` | `#FFED00` | `#8A6D00` | Warning text/icons on surface |
| `dangerFill` | `#E30613` | `#E30613` | Destructive buttons, over-limit chips (text on it: `#FFFFFF`) |
| `dangerText` | `#FF5A63` | `#C4050F` | Error/over-limit text/icons on surface |
| `brandGreen` | `#008D3F` | `#008D3F` | Decorative crest accent only |
| `brandRed` | `#E30613` | `#E30613` | Decorative crest accent only |
| `brandYellow` | `#FFED00` | `#FFED00` | Decorative crest accent only |

**Contrast contract:** every text-on-background pair must be ≥ 4.5:1 and every UI boundary/icon ≥ 3:1. This is enforced by a unit test (Section 11).

### 7.4 Camera overlay colors (`overlay_colors.dart`, theme-independent)

Overlays sit on arbitrary live video, so they do not change with the app theme. Every line or label gets a 1 px black outline/shadow underlay for legibility.

| Element | Color | Style |
| :---- | :---- | :---- |
| Gate A | `#FFED00` (crest yellow) | 3 dp solid line, round end handles |
| Gate M | `#FFFFFF` | 2 dp dashed line, no handles (auto-generated) |
| Gate B | `#2FD27A` | 3 dp solid line, round end handles |
| Tracked vehicle box | `#FFFFFF` @ 85% | 2 dp, 6 dp corner radius |
| Vehicle crossing a gate | that gate's color | box tint flashes for 200 ms |
| Verified vehicle box | `#2FD27A` | 3 dp |
| `overlayScrim` | `#000000` @ 70% | HUD bars/panels on top of video (solid — no blur) |

### 7.5 Typography (`cmp_typography.dart`)

- **Bangla:** Noto Sans Bengali. **Latin & numerals:** Inter. Declare Noto Sans Bengali as `fontFamilyFallback` so mixed Bangla/English strings render correctly.  
- Bangla needs more vertical room: use `height: 1.4` or more for all text styles; never clip descenders/matras (no fixed-height text containers).  
- Use `FontFeature.tabularFigures()` on every changing number (speed, FPS, counters) so layouts don't jitter.

| Style | Size / weight | Use |
| :---- | :---- | :---- |
| `speedDisplay` | 40 sp / 700 | On-screen verified speed, large result |
| `headline` | 24 sp / 700 | Screen titles |
| `title` | 18 sp / 600 | Card titles, list titles |
| `body` | 16 sp / 400 | Default text |
| `label` | 14 sp / 600 | Buttons (large), chips, pills |
| `caption` | 12 sp / 500 | Minimum size anywhere; never go below 12 sp |

### 7.6 Spacing, shape, elevation

- **Spacing scale (dp):** 4, 8, 12, 16, 24, 32\. No other values.  
- **Radius:** 12 (cards, inputs), 16 (bottom sheets, dialogs), 999 (pills/chips). Gate handles are circles.  
- **Elevation:** express depth with surface color (`surface` → `surfaceHigh`) and a 1 dp `outline` border — not drop shadows (they vanish on dark backgrounds and cost GPU time).  
- **Brand stripe:** an optional 3 dp `CmpBrandStripe` under the app bar (`brandGreen` 60% / `brandRed` 25% / `brandYellow` 15%). Used on Home only; subject to CMP approval.

### 7.7 Iconography

Material Symbols (rounded). Vehicle class icons (placeholders — replace with a custom SVG set if supplied):

| Class | Icon |
| :---- | :---- |
| `car` | `Icons.directions_car_rounded` |
| `bus` | `Icons.directions_bus_rounded` |
| `truck` | `Icons.local_shipping_rounded` |
| `motorcycle` | `Icons.two_wheeler_rounded` |
| `cng` | `Icons.electric_rickshaw_rounded` |
| `leguna` | `Icons.airport_shuttle_rounded` |

---

## 8\. Navigation & Screen Flow

Use `go_router`. Bottom `NavigationBar` has three destinations: **Home**, **Logs**, **Settings**. The monitoring flow is a full-screen sequence outside the tab bar.

Home ──▶ Session Setup ──▶ Satellite Pin-Dropper ──▶ Gate Alignment ──▶ Live Monitor

  │            (1)                  (2)                    (3)               (4)

  ├──▶ Logs ──▶ Log Detail (bottom sheet)

  └──▶ Settings

| Route | Screen | Orientation |
| :---- | :---- | :---- |
| `/` | Home dashboard | Portrait |
| `/session/setup` | Session Setup | Portrait |
| `/calibration/map` | Satellite Pin-Dropper | Portrait |
| `/calibration/gates` | Gate Alignment | Landscape |
| `/monitor` | Live Monitor | Landscape, immersive |
| `/logs` | Verified Logs | Portrait |
| `/settings` | Settings | Portrait |

**Guards (go\_router `redirect`):**

- `/calibration/gates` requires a `CalibrationConfig` with `D ≥ minGateDistanceM` (or a completed fallback calibration).  
- `/monitor` requires both a valid `CalibrationConfig` AND confirmed Gate A \+ Gate B.  
- Camera permission denied → redirect to the permission recovery screen.

---

## 9\. Screen Specifications & Wireframes

All user-visible text comes from ARB files (Rule 8). Wireframes show layout only; use design tokens from Section 7\.

### 9.1 Home (Dashboard)

- Header: crest (or placeholder) \+ app name (Bangla primary line, English secondary line), optional `CmpBrandStripe`.  
- Primary CTA: full-width `CmpButton.primary` — "নতুন সেশন শুরু করুন / Start New Session" (56 dp tall).  
- Two `MetricTile`s: verified today, last session time.  
- `SyncStatusCard`: pending/synced record count, tap to retry sync.  
- "Recent verified" list: last 5 `VerifiedFeedTile`s.

┌────────────────────────────────┐

│ \[crest\] CMP Speed Monitor      │

│         সিএমপি স্পিড মনিটর      │

│ ▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀ │

│ ┌────────────────────────────┐ │

│ │  ▶  Start New Session      │ │

│ └────────────────────────────┘ │

│ ┌─────────────┐ ┌────────────┐ │

│ │ Verified    │ │ Last       │ │

│ │ today  128  │ │ session    │ │

│ │             │ │ 2h ago     │ │

│ └─────────────┘ └────────────┘ │

│ ┌────────────────────────────┐ │

│ │ ⟳ 12 records pending sync  │ │

│ └────────────────────────────┘ │

│ Recent verified                │

│  \[CNG\]  42 km/h   A→B   14:02  │

│  \[Car\]  38 km/h   A→B   14:01  │

│  \[Bus\]  27 km/h   B→A   13:59  │

├────────────────────────────────┤

│  Home        Logs     Settings │

└────────────────────────────────┘

### 9.2 Session Setup (step 1 of 4\)

- `StepIndicator` (4 steps).  
- Fields: Site name (required), Speed limit in km/h (optional — enables over-limit highlighting), Road type (`One-way` / `Two-way` segmented control).  
- "Saved sites" list: choosing one pre-fills the site name and re-uses its **pins and distance `D` only**. Gate positions depend on camera pose and MUST be re-aligned every session.  
- Footer: `Continue` (disabled until site name is valid).

### 9.3 Satellite Pin-Dropper (step 2 of 4\)

- Full-bleed satellite map (zoom ≥ 20), center crosshair, mini-map scale bar.  
- Segmented control: **Pin A / Pin B**. Tap "Drop Pin" at the crosshair; pins are draggable for fine adjustment. Tap "Undo" to remove the last pin.  
- `DistanceBadge` floating at top: `D = 30.4 m` with status:  
  - `D ≥ 15 m` → green check, "Good".  
  - `D < 15 m` → yellow warning, "Too short — accuracy will suffer".  
  - `D > 50 m` → neutral info, "Long span — ensure both landmarks are visible in the camera".  
- Bottom sheet: Pin A / Pin B coordinates (6 decimals), "Can't see landmarks? Use camera-height method" link (fallback).  
- If map tiles can't load (offline), show a banner offering the fallback method.  
- Footer: `Continue` (disabled until both pins placed and `D ≥ minGateDistanceM`).

┌────────────────────────────────┐

│ ←  Calibrate distance   ●●○○   │

│ ┌────────────────────────────┐ │

│ │      ╭ D \= 30.4 m  ✓ ╮     │ │

│ │                            │ │

│ │     (satellite imagery)    │ │

│ │        A●─ ─ ─ ─ ─●B       │ │

│ │              ⊕             │ │

│ │                            │ │

│ └────────────────────────────┘ │

│  \[ Pin A \]  \[ Pin B \]  \[Undo\]  │

│ ┌────────────────────────────┐ │

│ │ A 22.356912, 91.783211     │ │

│ │ B 22.357180, 91.783342     │ │

│ │ Can't see landmarks? →     │ │

│ └────────────────────────────┘ │

│ ┌────────────────────────────┐ │

│ │          Continue          │ │

│ └────────────────────────────┘ │

└────────────────────────────────┘

### 9.4 Gate Alignment (step 3 of 4, landscape)

- Camera preview full screen. Gate A and Gate B are draggable lines with circular handles (min 48 dp touch target, visually 20 dp). Gate M is drawn dashed, auto-updates while A/B move, and is **not** draggable (labelled "M · auto").  
- Hint card (dismissible): "Align A and B with the same two landmarks you marked on the map."  
- `StabilityPill` (gyro): must show "Steady" before `Confirm gates` enables.  
- Buttons: `Back`, `Reset`, `Confirm gates` (primary).

┌──────────────────────────────────────────────────────────────┐

│ ← Back     Align gates          ◉ Steady          D \= 30.4 m │

│                                                              │

│      A                      M                      B         │

│      ◯                      ┊                      ◯         │

│      ┃                      ┊                      ┃         │

│      ┃        (camera       ┊                      ┃         │

│      ┃         preview)     ┊                      ┃         │

│      ◯                      ┊                      ◯         │

│                         M · auto                             │

│  \[ Reset \]                                \[ Confirm gates \]  │

└──────────────────────────────────────────────────────────────┘

### 9.5 Live Monitor (step 4 of 4, landscape, immersive)

Layers, bottom to top: `CameraPreview` → `GatePainter` → `BoundingBoxPainter` → HUD widgets.

- **Top bar** (`overlayScrim`, solid): Stop button · `StatusPill` ARMED/PAUSED · FPS · inference ms · `StabilityPill` · `D` value.  
- **Right panel** (≈ 220 dp, `overlayScrim`): "Latest verified" — the last 5 `VerifiedFeedTile`s, newest on top, with a subtle 150 ms slide-in.  
- **On-video `SpeedChip`:** appears next to the vehicle's box after it clears Gate B (or A for reverse direction), stays for `speedChipHoldMs`, then fades. Color: `verified` if within the limit or no limit set; `dangerFill` \+ warning icon if above the session speed limit.  
- **Bottom bar:** verified counter (left), big Pause/Resume button (center, 64 dp), nothing on the right (keeps the thumb zone free).  
- **Diagnostics overlay** (hidden unless Diagnostics mode is on): `rejectedFaultCount`, active track count, dropped-frame count.  
- A tripod-shake event (gyro ≥ `maxGyroRadPerSec`) shows a `CmpBanner.warning`: "Camera moved — hold steady." Measurements during shake are discarded per Rule 5; no other error UI.

┌──────────────────────────────────────────────────────────────────────────┐

│ \[■ Stop\]  ● ARMED   30 FPS   18 ms   ◉ Steady              D \= 30.4 m    │

│                                                        ┌────────────────┐│

│   A ┃                    M ┊                    B ┃    │ LATEST VERIFIED││

│     ┃    ┌───────┐         ┊                      ┃    │ \[CNG\] 42 km/h →││

│     ┃    │  CAR  │ \#104    ┊                      ┃    │ \[Car\] 38 km/h →││

│     ┃    └───────┘         ┊       ╭ 42 km/h ╮    ┃    │ \[Bus\] 27 km/h ←││

│     ┃                      ┊       ╰─────────╯    ┃    │ \[Mot\] 51 km/h →││

│                                                        └────────────────┘│

│ Verified 128                \[ ❚❚ Pause \]                                 │

└──────────────────────────────────────────────────────────────────────────┘

### 9.6 Verified Logs

- Date-grouped list of `VerifiedFeedTile`s (class icon, speed, direction arrow, time, sync-state icon).  
- Filter chips: vehicle class, direction, over-limit only, pending sync.  
- Tap a tile → `LogDetailSheet`: all metadata fields (track id, half-speeds, consistency %, distance, UTC time).  
- Top-right actions: Export CSV, Export JSON (via `share_plus`). Export header includes site name and session date.  
- Empty state: `EmptyState` illustration \+ "No verified records yet".

### 9.7 Settings

Language (বাংলা / English, default Bangla) · Theme (System / Dark / Light) · Bangla digits toggle · Diagnostics mode toggle · Sync server endpoint (admin) · About & legal (version, disclaimer, CMP credit).

---

## 10\. UI Rules (Rules 7–10)

### Rule 7 — Design system & theming

- All colors, text styles, spacing and radii come from the tokens in Section 7\. Zero hardcoded colors, font sizes, paddings or radii in feature widgets.  
- All shared components live in `core/widgets/` and are used everywhere; do not re-implement a button, pill or tile inside a feature.  
- Both themes must be implemented and verified on every screen. Test each screen in Dark and Light, Bangla and English.  
- Brand/crest usage follows Section 7.2.

### Rule 8 — Bangla-first localization

- Default locale is `bn`; `en` is the fallback. ARB template is `app_bn.arb`. Both files MUST contain identical keys (enforced by test).  
- No user-visible string literals in widgets — everything via `AppLocalizations.of(context)`.  
- Use `intl` for numbers and dates. Digits follow the "Bangla digits" setting (`০১২৩…` vs `0123…`). Speed values, counters and times all go through shared formatter helpers in `core/utils/`.  
- Layouts must survive Bangla's taller glyphs and longer strings: no fixed-height text boxes, no single-line truncation for critical values.

### Rule 9 — Field usability & accessibility

- Minimum touch target **48 × 48 dp** (56 dp for primary actions, 64 dp for Pause/Resume on Live Monitor) — operators may wear gloves or be in motion.  
- Never rely on color alone: pair every state color with an icon or label (e.g., over-limit \= red \+ warning icon \+ text).  
- Contrast: text ≥ 4.5:1, UI components ≥ 3:1, in both themes.  
- Every interactive element has `Semantics` (label, button/ toggle role). Decorative icons are excluded from semantics.  
- Clamp the text scaler to `1.0–1.3` on Live Monitor and Gate Alignment (HUD space is fixed); other screens respect system scale up to `2.0` without overflow.  
- Respect `MediaQuery.disableAnimations`.  
- Keep the screen awake and avoid modal dialogs during monitoring; use non-blocking banners instead.

### Rule 10 — Honest estimate labeling & scope

- The UI always labels results as **estimated** ("আনুমানিক গতি / Estimated speed"). Never present a figure as a certified or legally validated measurement.  
- Settings → About & legal includes a disclaimer: results are estimates from a phone camera and must not be used as legal evidence unless the competent authority has validated the system and its calibration procedure.  
- No license-plate recognition, no face recognition, no driver/passenger identification, no video/image storage (see Rule 6).

---

## 11\. Shared Component Catalog (`core/widgets/`)

| Component | Purpose | Key spec |
| :---- | :---- | :---- |
| `CmpAppBar` | Screen title bar | Title (`headline`), back button, optional `CmpBrandStripe` |
| `CmpButton` | Actions | Variants: `primary`, `secondary`, `destructive`, `ghost`; 56 dp tall; radius 12; disabled state at 40% opacity \+ no ripple |
| `StepIndicator` | Flow progress (1–4) | 4 dots/segments; current \= `primary`, done \= `verified`, upcoming \= `outline` |
| `StatusPill` | ARMED / PAUSED / SYNCING | Pill (radius 999), icon \+ label, color by state |
| `StabilityPill` | Gyro steadiness | "Steady" (`verified`) / "Moving" (`warningText`) with icon |
| `MetricTile` | Dashboard numbers | `surfaceHigh` card, `caption` label, `speedDisplay`\-scale number |
| `DistanceBadge` | Calibration distance \+ validity | `D = 30.4 m` \+ status icon and text (Section 9.3) |
| `VerifiedFeedTile` | One verified record | Class icon, speed (`title`, tabular), direction arrow, time, sync icon |
| `SpeedChip` | On-video / detail speed | Rounded, `speedDisplay` or `title`; `verified` or `dangerFill` \+ warning icon |
| `VehicleClassIcon` | Class glyph | Maps `VehicleClass` → icon (Section 7.7) with semantics label |
| `GateHandle` | Draggable gate endpoint | 20 dp visual, 48 dp hit area, gate color \+ black outline |
| `CmpBanner` | Non-blocking messages | Variants: `info`, `warning`, `error`; icon \+ text \+ optional action |
| `SyncStatusCard` | Pending/synced counts | Tap to retry; shows last sync time |
| `EmptyState` | No-data screens | Icon/illustration, title, hint, optional action |
| `CmpBrandStripe` | Decorative accent | 3 dp, three-segment (Section 7.6) |

Every component has a widget test (Section 12\) covering Dark/Light and Bangla/English.

---

## 12\. Mandatory Tests Checklist

Before marking ANY feature complete, create and pass these tests:

**Engine (pure Dart)**

- [ ] `test/core/utils/haversine_test.dart` — geodesic distance in meters between two known satellite coordinates.  
- [ ] `test/features/speed_tracking/speed_math_engine_test.dart` — 2D line intersection and sub-frame microsecond interpolation accuracy.  
- [ ] `test/features/speed_tracking/robust_vehicle_tracker_test.dart`:  
      - Two differently colored cars crossing side by side → **0 ID swaps**.  
      - A car occluded by a bus for 10 frames → ByteTrack coasting **preserves `trackId`**.  
      - A corrupted track with `V1 = 40 km/h` and `V2 = 110 km/h` → 3-gate validator **returns `null`** (fault rejected, `rejectedFaultCount` incremented).

**UI & design system**

- [ ] `test/core/theme/contrast_test.dart` — every text/background token pair in both themes ≥ 4.5:1, every UI boundary pair ≥ 3:1.  
- [ ] `test/l10n/arb_parity_test.dart` — `app_bn.arb` and `app_en.arb` contain identical keys; no empty values.  
- [ ] `test/core/widgets/*_test.dart` — widget tests for `SpeedChip` (within limit / over limit / no limit), `DistanceBadge` (\<15 m, ≥15 m, \>50 m), `StatusPill`, `VerifiedFeedTile`, rendered in Dark \+ Light and Bangla \+ English.  
- [ ] `test/features/speed_tracking/live_monitor_golden_test.dart` — golden tests of the Live Monitor HUD (Dark/Light, bn/en) with a fixed fake track list.  
- [ ] `test/app/router_guard_test.dart` — `/monitor` and `/calibration/gates` redirect when calibration is invalid.

---

## 13\. Agent Workflow & Definition of Done

**Before writing code**

1. Read this file fully; place new files in the correct folder per Section 3\.  
2. For UI work, reuse components from `core/widgets/` and tokens from Section 7 before creating anything new.

**While writing code** 3\. Keep the UI isolate free of vision work (Rule 1\) and the math engines free of Flutter imports. 4\. Reference constants from `core/constants/`; never inline magic numbers. 5\. Never hardcode colors, strings or spacing (Rules 7–8).

**A task is DONE only when:**

- [ ] `dart run build_runner build --delete-conflicting-outputs` succeeds (if models changed)  
- [ ] `flutter gen-l10n` succeeds (if strings changed)  
- [ ] `dart format --set-exit-if-changed .` passes  
- [ ] `flutter analyze` reports 0 warnings / 0 errors  
- [ ] `flutter test` passes, including all relevant tests from Section 12  
- [ ] No file exceeds 250 lines (excluding generated files)  
- [ ] No hardcoded color, string, font size or spacing in feature widgets  
- [ ] Screens checked in Dark \+ Light and Bangla \+ English  
- [ ] No raw video/images are stored or uploaded

**Useful commands**

flutter pub get

dart run build\_runner build \--delete-conflicting-outputs

flutter gen-l10n

dart format \--set-exit-if-changed .

flutter analyze

flutter test