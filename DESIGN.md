---
name: Lofi Radio
description: A distraction-free synthwave-themed audio player for focus and relaxation.
colors:
  primary: "#E94560"
  secondary: "#533483"
  tertiary: "#0F3460"
  neutral-bg: "#0D0D1A"
  neutral-surface: "#1A1A2E"
  neutral-text: "#EAEAEA"
typography:
  display:
    fontFamily: "Outfit, sans-serif"
    fontSize: "32px"
    fontWeight: 700
    lineHeight: 1.2
  headline:
    fontFamily: "Outfit, sans-serif"
    fontSize: "24px"
    fontWeight: 600
    lineHeight: 1.3
  title:
    fontFamily: "Outfit, sans-serif"
    fontSize: "18px"
    fontWeight: 500
    lineHeight: 1.4
  body:
    fontFamily: "Outfit, sans-serif"
    fontSize: "14px"
    fontWeight: 400
    lineHeight: 1.5
  label:
    fontFamily: "Outfit, sans-serif"
    fontSize: "12px"
    fontWeight: 500
    letterSpacing: "0.05em"
rounded:
  sm: "4px"
  md: "8px"
  lg: "16px"
spacing:
  xs: "4px"
  sm: "8px"
  md: "12px"
  lg: "16px"
  xl: "24px"
  xxl: "32px"
components:
  channel-card:
    backgroundColor: "{colors.neutral-surface}"
    rounded: "{rounded.lg}"
    padding: "0px"
  mini-player:
    backgroundColor: "{colors.neutral-surface}"
    rounded: "{rounded.lg}"
    padding: "12px 12px 10px 12px"
---

# Design System: Lofi Radio

## 1. Overview

**Creative North Star: "Synthwave Sanctuary"**

Lofi Radio is designed as a digital sanctuary for users seeking focus, relaxation, or sleep. The visual language balances a nostalgic, low-fidelity analog feel with a sleek, modern cyberpunk aesthetic. The layout uses defined outlines, translucent panels, and neon-lit highlights floating on top of deep midnight spaces. The density of the interface is loose, spacious, and calming, reducing visual noise to a absolute minimum.

This system explicitly rejects bright light themes, stark white cards, and aggressive neon gradients that strain the eyes in dark environments. It favors quiet, glowing indicators over constant, flashing movements.

**Key Characteristics:**
- **Dimmed Stacking Context**: Immersive dark blue-black backgrounds layer with semi-transparent navy containers to establish a flat, low-contrast hierarchy.
- **Neon Accents**: Radiant Neon Red (#E94560) is used sparingly as the primary highlight color to denote interactive states and active playback.
- **Atmospheric Depth**: Subtle backdrop blurs and radial gradients create a sense of floating, neon-lit panels in space.

## 2. Colors

The color palette is characterized by "Neon Embers on Midnight Charcoal," utilizing rich, deep space tones accented by warm glowing embers.

### Primary
- **Radiant Neon Red** (#E94560): The primary accent color. Used for active selection borders, visualizer bars, and core play states.

### Secondary
- **Soft Deep Violet** (#533483): Used as background decorative gradients and subtle borders, adding a nostalgic, night-sky depth.

### Tertiary
- **Deep Teal** (#0F3460): Used as secondary dark accents and contrast backings.

### Neutral
- **Space Charcoal** (#0D0D1A): The scaffold background color, designed to occupy over 80% of the screen.
- **Tape Deck Navy** (#1A1A2E): The container and surface background color, reflecting a dense, dark plastic tape-deck texture.
- **Cloud Gray** (#EAEAEA): The primary text and icon color, comfortable for night reading without causing eye strain.

### Named Rules
**The Rarity Rule.** The primary accent (#E94560) must occupy ≤5% of any screen surface. It serves as an active spark, not a fill color.
**The No-White Rule.** True white (#FFFFFF) is prohibited for body text or large panels. All text must use Cloud Gray (#EAEAEA) or dimmed opacities (e.g., opacity 0.7) to preserve night-time comfort.

## 3. Typography

**Display Font:** Outfit (Google Fonts)
**Body Font:** Outfit (Google Fonts)
**Label/Mono Font:** Outfit (Google Fonts)

**Character:** The typography uses the single family "Outfit" in varying weights and tracking to convey a clean, geometric, yet humanistic and comforting feel. Wide tracking on labels adds a classic retro console layout vibe.

### Hierarchy
- **Display** (Bold, 32px, line-height 1.2): Used for prominent titles (e.g., active channel title in the full-screen player).
- **Headline** (SemiBold, 24px, line-height 1.3): Used for main section headers.
- **Title** (Medium, 18px, line-height 1.4): Used for channel names in list views.
- **Body** (Regular, 14px, line-height 1.5): Used for short descriptions, statuses, and fallback text.
- **Label** (Medium, 12px, letterSpacing 0.05em): Used for metadata, badges, and timestamps.

## 4. Elevation

The system relies on tonal layering and translucent panel backdrops rather than strong physical drop shadows. Depth is conveyed using background opacity, border outlines, and subtle glow effects.

### Shadow Vocabulary
- **Neon Glow** (box-shadow / Glow): A soft, 20px blur of the primary accent (#E94560) at 15% opacity, applied to the active playing channel card to represent a warm, backlit ember.
- **Ambient Shadow** (box-shadow): A soft, 12px blur of black (#000000) at 30% opacity, used on the floating Mini Player.

### Named Rules
**The Flat-By-Default Rule.** Containers do not have shadows at rest. Shadow and glow are state-driven responses to user interaction or playback status.

## 5. Components

Components are refined and ghostly, using thin lines, soft borders, and subtle opacity transitions to highlight interactivity.

### Buttons
- **Shape:** Softly curved corners (8px radius) or circular (for controls).
- **Primary Control:** Circular, using the primary accent (#E94560) for playback actions.
- **Secondary Control:** Translucent or transparent background with white/gray icon buttons.
- **States:** Hover/Tap feedback uses soft opacity transitions.

### Cards / Containers (Channel Card)
- **Corner Style:** Rounded corners (16px radius).
- **Background:** Tape Deck Navy (#1A1A2E) with an Aspect Ratio of 16/10.
- **Border:** At rest, no border. Active channel has a 1.5px border of Radiant Neon Red (#E94560) at 60% opacity.
- **Gradients:** Overlay gradient fades to Space Charcoal (#0D0D1A) at the bottom to secure text readability.

### Mini Player
- **Corner Style:** Rounded corners (16px radius) floating with a 12px margin.
- **Background:** Tape Deck Navy (#1A1A2E) at 95% opacity.
- **Border:** Thin 0.5px border of Soft Deep Violet (#533483) at 30% opacity.

### Audio Visualizer
- **Style:** Discrete vertical bars representing frequencies.
- **Color:** Solid Radiant Neon Red (#E94560).
- **States:** Animates smoothly when playing; collapses to static low lines when paused.

## 6. Do's and Don'ts

### Do:
- **Do** use translucent navy containers (#1A1A2E at 95% opacity) over the charcoal background to create visual depth.
- **Do** keep text sizes small and clean, relying on weight variation (Bold/Regular) rather than extreme size scaling.
- **Do** bound visualizer animation counts and frequencies to a calm, steady wave, matching a low-frequency state.

### Don't:
- **Don't** use bright light backgrounds or high-contrast primary colors that could disrupt a dark room.
- **Don't** use solid saturated neon blocks or neon text gradients. Accent color should only light up key outlines or states.
- **Don't** animate elements on hover/focus using sharp curves or bounce effects; use linear or ease-out curves to preserve tranquility.
