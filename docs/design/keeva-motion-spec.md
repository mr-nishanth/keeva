# Keeva Motion & Haptic Feedback Specification

**Product:** Keeva (WhatsApp Status Saver → Premium Independent Identity)  
**Document Status:** Production Motion & Haptics Specification  
**Phase:** Phase 2E-A (UI/UX Design System Discovery & Specification)  
**Platform Target:** Android-First (Primary), iOS-Compatible (Secondary)  
**Date:** September 2026  

---

## 1. Motion Philosophy: "Respectful Precision"

In Keeva, animation is an architectural affordance, never decoration. Every movement must communicate:
1. **Spatial Continuity:** The user must intuitively understand where an object came from and where it returned (e.g. media expanding from a grid cell and snapping back).
2. **Immediate Feedback:** Interactive controls acknowledge touch within 100ms.
3. **Weightless Restraint:** No bouncy cartoon physics, no confetti explosions, and no gratuitous particles.

---

## 2. Motion Easing Curves & Timing Tokens

### 2.1 Easing Curves

```dart
/// Keeva Canonical Motion Curves
class KeevaCurves {
  /// Entrances: elements entering the viewport decelerate naturally into resting position.
  static const Curve emphasizedDecelerate = Cubic(0.05, 0.70, 0.10, 1.00);

  /// Exits: elements leaving the screen accelerate rapidly out of view.
  static const Curve emphasizedAccelerate = Cubic(0.30, 0.00, 0.80, 0.15);

  /// Morphing, selection changes, and color transitions.
  static const Curve standardEasing = Cubic(0.20, 0.00, 0.00, 1.00);

  /// Micro-spring for signature "Keep" button release.
  static const Curve buttonSpring = Cubic(0.175, 0.885, 0.32, 1.15);
}
```

### 2.2 Duration Tokens

| Token | Duration | Target Transitions |
| :--- | :--- | :--- |
| `motionDurationInstant` | 50ms | Rapid touch state changes (ripple start) |
| `motionDurationMicro` | 100ms | Button press scale-down, checkbox check |
| `motionDurationFast` | 180ms | Filter chip selection, tooltip popover |
| `motionDurationNormal` | 240ms | Staggered grid card entry, tab pill indicator morph |
| `motionDurationMedium` | 320ms | Bottom sheet slide-up, dialog entrance |
| `motionDurationHero` | 300ms | Thumbnail-to-fullscreen viewer zoom transition |
| `motionDurationToast` | 2500ms | Snackbar visibility duration |

---

## 3. The Signature "Keep" Interaction

"Keep" is the emotional centerpiece of Keeva. It transforms temporary ephemeral media into permanent, safely stored memories.

```
STATE CHOREOGRAPHY:
[Idle] ───────► [Pressed] ───────► [Saving] ───────► [Success]
(Mint Bookmark) (Scale 0.94)       (16dp Spinner)    (Aura Pulse + Check)
 48dp target     Haptic: Light      240ms loop        Haptic: Selection Click
```

### 3.1 Step-by-Step Interaction Flow
1. **Idle State:**
   * Icon: `bookmark_add` in Aurora Mint (`#10B981`) inside a 32dp dark glass disc (`rgba(0,0,0,0.50)`).
   * Semantics: *"Keep this moment. Button."*
2. **Pressed State (Touch Down):**
   * Button scales down from `1.0` to `0.94` over 80ms using `KeevaCurves.standardEasing`.
   * Haptic: Trigger `HapticFeedback.lightImpact()` immediately on pointer down.
3. **Saving State (Async In-Flight):**
   * If save takes > 150ms, bookmark icon fades out over 60ms and a 16dp circular progress indicator in Aurora Mint fades in.
   * Button remains responsive; double-taps are debounced.
4. **Success State (Saved to MediaStore):**
   * Spinner cross-fades into `check_circle` over 120ms with `KeevaCurves.buttonSpring`.
   * **Aura Wave:** A subtle concentric emerald ring (`#10B981` at 25% opacity) expands outward from the button from 32dp to 48dp diameter and fades to 0% opacity over 260ms.
   * Card top-left badge updates from hidden to `[✓ Kept]` pill over 160ms with vertical slide (4dp).
   * Haptic: Trigger `HapticFeedback.selectionClick()`.
5. **Already Kept State:**
   * If user taps an already kept card, button performs an informative 6dp horizontal nudge (shake) over 180ms with `HapticFeedback.selectionClick()` and surfaces options modal ("View in Kept Vault" or "Save Copy").
6. **Failure State:**
   * Button briefly flashes amber outline with a 2-step horizontal shake (8dp) over 200ms.
   * Haptic: Trigger `HapticFeedback.mediumImpact()`.
   * Transient toast appears: *"Unable to keep moment. Check device storage."*

---

## 4. Screen & Component Choreographies

### 4.1 Moments Grid Staggered Entrance
* When `StatusListState.success` is received, grid cards enter with a staggered fade and vertical translate:
  * Initial state: `opacity: 0.0`, `transform: translateY(12dp)`.
  * Target state: `opacity: 1.0`, `transform: translateY(0dp)`.
  * Duration: 220ms per card using `KeevaCurves.emphasizedDecelerate`.
  * Stagger offset: 25ms per row (capped at maximum 4 rows / 8 cards).
  * Cards beyond the first 4 rows render directly without stagger to avoid GPU queue delays during scroll.

### 4.2 Media Viewer Transition (Hero Zoom & Swipe-to-Dismiss)
1. **Open Viewer:**
   * Card thumbnail expands into full screen over 300ms using a shared-element hero transition with `KeevaCurves.emphasizedDecelerate`.
   * Background canvas fades from transparent to `#000000` concurrently.
   * Top and bottom floating chrome controls slide in vertically (translate 16dp) over 240ms with a 60ms delay.
2. **Interactive Swipe-to-Dismiss:**
   * Vertical drag gestures translate the media 1:1 with user finger position (`dy`).
   * Media scales down slightly as dragged: `scale = 1.0 - (dy.abs() / 1200dp).clamp(0.0, 0.25)`.
   * Scrim opacity decreases: `opacity = 1.0 - (dy.abs() / 300dp).clamp(0.0, 0.8)`.
   * If user releases past **120dp threshold** or drag velocity exceeds **800dp/s**:
     * Media smoothly shrinks and translates back to originating grid card over 220ms with `KeevaCurves.emphasizedAccelerate`.
   * If released below threshold:
     * Media snaps back to centered fullscreen over 180ms with spring physics (`SpringSimulation`).

### 4.3 Modal Bottom Sheet Transition
* Enters from screen bottom over 320ms with `KeevaCurves.emphasizedDecelerate`.
* Scrim backdrop fades in from `0.0` to `0.72` alpha over 240ms.
* Swiping down on drag handle translates sheet 1:1; releasing past 80dp or fast downward fling closes sheet.

---

## 5. Haptic Feedback Hierarchy

Haptics must feel deliberate and tactile, not noisy. Keeva strictly limits haptics to the following 5 semantic events:

| Interaction Event | Platform Haptic Method | Perceptual Weight |
| :--- | :--- | :--- |
| **Keep Signature Success** | `HapticFeedback.selectionClick()` | Crisp, satisfying micro-click |
| **Button Touch Down** | `HapticFeedback.lightImpact()` | Subdued confirmation of physical touch |
| **Bottom Tab Change** | `HapticFeedback.selectionClick()` | Mechanical gear tick sensation |
| **SAF Folder Grant Received** | `HapticFeedback.mediumImpact()` | Solid positive achievement feedback |
| **Action Error / Revocation** | `HapticFeedback.heavyImpact()` | Distinct alert notifying attention required |

* **Zero-Haptic Areas:** Fling scrolling the grid, tapping on empty background areas, or typing in filter search bars never triggers haptics.

---

## 6. Accessibility: Reduced Motion Compliance

Keeva fully respects user system accessibility settings:
* **System Setting Check:** `MediaQuery.disableAnimationsOf(context)` or `prefers-reduced-motion`.
* **When Reduced Motion is Enabled:**
  * Staggered grid entrance animations are **completely disabled**; items appear instantly.
  * Hero transitions from grid to viewer are replaced with a fast 100ms fade-in (`CrossFade`).
  * "Keep" button aura wave expansion is removed; button instantly toggles between bookmark and checkmark.
  * Swipe-to-dismiss in media viewer remains interactive for finger-tracking, but release snaps instantly without bounce.
