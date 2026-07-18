---
target: Home Screen
total_score: 28
p0_count: 0
p1_count: 1
timestamp: 2026-07-18T22-36-11Z
slug: lib-screens-home-screen-dart
---
# Design Critique: Home Screen

## Design Health Score

| # | Heuristic | Score | Key Issue |
|---|-----------|-------|-----------|
| 1 | Visibility of System Status | 3/4 | Loading state uses shimmer and cards pulse when playing, but list empty/connection state could be clearer. |
| 2 | Match System / Real World | 4/4 | Simple grid system with card elements matches standard mobile media layouts. |
| 3 | User Control and Freedom | 3/4 | Users can refresh and select channels easily, but search or categorization is absent. |
| 4 | Consistency and Standards | 2/4 | Hardcoded hex colors are still present in _buildHeader and _buildShimmerGrid, diverging from AppColors tokens. |
| 5 | Error Prevention | 3/4 | Handles network loss with a clean error view, but lacks automatic retry on connection recovery. |
| 6 | Recognition Rather Than Recall | 4/4 | Clean thumbnails, title text, and play state badges make card states highly recognizable. |
| 7 | Flexibility and Efficiency | 2/4 | Lacks accelerators like swipe actions or channel tagging/filtering. |
| 8 | Aesthetic and Minimalist Design | 3/4 | Solid layout rhythm, but the header layout is slightly stock/plain compared to the player screen. |
| 9 | Error Recovery | 3/4 | Simple retry button on network error screen works well. |
| 10 | Help and Documentation | 1/4 | No search, settings, or instructions (acceptable for the size of the app). |
| **Total** | | **28/40** | **Good** |

## Anti-Patterns Verdict

- **LLM Assessment**: Mostly clean, but the header looks slightly generic. The design system uses raw color hex values in the header icon container gradient and shimmer boxes, which constitutes design slop and breaks token consistency.
- **Deterministic Scan**: The automated scan returned 0 findings (exit code 0). It missed the local hex values in widgets/screens since it only searches for obvious global slop patterns.
- **Visual Overlays**: N/A (native desktop/mobile app, browser mutation injection skipped).

## Overall Impression
The Home Screen provides a solid, clean container for the channels, with proper bottom padding to prevent collisions with the mini-player. However, it suffers from minor token leakage (hardcoded colors) and a slightly plain header that misses the synthwave personality present on the player screen.

## What's Working
1. **Grid Layout Resilience**: Cards scale appropriately and provide clear grid spacing.
2. **Mini-Player Separation**: Reserving bottom padding dynamically when the mini-player is active is a great detail that prevents layout overlapping.

## Priority Issues

### [P1] Hardcoded Colors (Token Leakage)
- **Why it matters**: Breaks theme consistency and makes future palette updates error-prone.
- **Fix**: Replace all raw hex colors in `_buildHeader` and `_buildShimmerGrid` with their centralized counterparts from `AppColors`.
- **Suggested command**: `/impeccable polish`

### [P2] Plain Header Aesthetic
- **Why it matters**: The header looks like a standard Material 3 template and does not convey the nostalgic, vintage synthwave brand identity of the app.
- **Fix**: Style the header logo/headphones container with subtle scanline overlays, neon borders, or dynamic glowing effects matching the cassette player style.
- **Suggested command**: `/impeccable bolder`

### [P3] Lack of Filtering / Organization
- **Why it matters**: As the playlist grows, finding specific live channels (e.g., Chillhop vs Synthwave vs Cozy Piano) will become tedious for Casey (mobile user).
- **Fix**: Introduce simple pill tags at the top of the grid to filter channel categories (e.g., "All", "Cozy", "Chillhop", "Synthwave").
- **Suggested command**: `/impeccable layout`

## Persona Red Flags

- **Alex (Impatient Power User)**:
  - Red flag: Alex cannot search or filter channels, meaning Alex must scroll through all channels to find their favorite live stream.
- **Casey (Distracted Mobile User)**:
  - Red flag: Casey holding the phone on the go has to stretch their thumb to the top-right to tap the "Tải lại" (Refresh) icon. It should be easily reachable or triggered by a standard pull-to-refresh gesture.
