---
name: Obsidian Flux
colors:
  surface: '#131315'
  surface-dim: '#131315'
  surface-bright: '#39393b'
  surface-container-lowest: '#0e0e10'
  surface-container-low: '#1b1b1d'
  surface-container: '#1f1f21'
  surface-container-high: '#2a2a2c'
  surface-container-highest: '#353437'
  on-surface: '#e4e2e4'
  on-surface-variant: '#cbc3d7'
  inverse-surface: '#e4e2e4'
  inverse-on-surface: '#303032'
  outline: '#958ea0'
  outline-variant: '#494454'
  surface-tint: '#d0bcff'
  primary: '#d0bcff'
  on-primary: '#3c0091'
  primary-container: '#a078ff'
  on-primary-container: '#340080'
  inverse-primary: '#6d3bd7'
  secondary: '#4cd7f6'
  on-secondary: '#003640'
  secondary-container: '#03b5d3'
  on-secondary-container: '#00424e'
  tertiary: '#ffb3ad'
  on-tertiary: '#68000a'
  tertiary-container: '#ff5451'
  on-tertiary-container: '#5c0008'
  error: '#ffb4ab'
  on-error: '#690005'
  error-container: '#93000a'
  on-error-container: '#ffdad6'
  primary-fixed: '#e9ddff'
  primary-fixed-dim: '#d0bcff'
  on-primary-fixed: '#23005c'
  on-primary-fixed-variant: '#5516be'
  secondary-fixed: '#acedff'
  secondary-fixed-dim: '#4cd7f6'
  on-secondary-fixed: '#001f26'
  on-secondary-fixed-variant: '#004e5c'
  tertiary-fixed: '#ffdad7'
  tertiary-fixed-dim: '#ffb3ad'
  on-tertiary-fixed: '#410004'
  on-tertiary-fixed-variant: '#930013'
  background: '#131315'
  on-background: '#e4e2e4'
  surface-variant: '#353437'
typography:
  headline-lg:
    fontFamily: Inter
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
    letterSpacing: -0.02em
  headline-lg-mobile:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '700'
    lineHeight: 32px
    letterSpacing: -0.02em
  headline-md:
    fontFamily: Inter
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
  body-lg:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  label-sm:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
    letterSpacing: 0.05em
  mono-label:
    fontFamily: Inter
    fontSize: 13px
    fontWeight: '500'
    lineHeight: 16px
    letterSpacing: 0.01em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  base: 4px
  xs: 8px
  sm: 12px
  md: 16px
  lg: 24px
  xl: 32px
  container-margin: 20px
  gutter: 12px
---

## Brand & Style

The design system is engineered for a high-performance mobile screen recording environment. It balances a professional technical aesthetic with a vibrant, energetic pulse suited for creators, gamers, and developers. The brand personality is "Precision in Motion"—it feels advanced and powerful, yet remains unobtrusive during the recording process.

The visual style is a fusion of **Modern Minimalism** and **Glassmorphism**. By utilizing a deep, near-black backdrop, the interface recedes to let the user's content take center stage, while high-contrast accents provide immediate clarity for status and interaction. Surfaces use subtle transparency and backdrop blurs to maintain a sense of physical layering without cluttering the viewport.

## Colors

The palette is optimized for OLED displays and high-performance focus.

- **Primary (Electric Purple):** Used for primary actions, active toggle states, and brand highlights.
- **Secondary (Cyan):** Used for secondary interactions, success states, and progress indicators.
- **Recording Red:** Reserved exclusively for live recording indicators and "Stop" actions to ensure high visibility and urgency.
- **Surface & Background:** The "Obsidian" base (#0A0A0B) provides the deepest black, while the Surface (#161618) creates subtle elevation for cards and modals.

## Typography

This design system uses **Inter** for its systematic, neutral, and highly legible characteristics. The hierarchy relies on substantial weight shifts (from Regular 400 to Bold 700) to create a structured information architecture. 

For technical data, such as frame rates, bitrates, or timestamps, use the `mono-label` style to maintain alignment and a "dashboard" feel. Large headlines should use negative letter spacing to feel tighter and more modern.

## Layout & Spacing

The layout follows a **Fluid Grid** model designed for mobile-first constraints. 

- **Margins:** A standard 20px safe area is maintained on the left and right edges of the screen.
- **Rhythm:** An 8pt spacing system governs all vertical and horizontal gaps.
- **Density:** Controls in the recording HUD (Heads-Up Display) use "Compact" spacing (8px), while settings and library views use "Comfortable" spacing (16px+) to improve scanability.
- **Adaptation:** On tablet devices, content containers should be capped at 720px width and centered to prevent line lengths from becoming unreadable.

## Elevation & Depth

Visual hierarchy is established through **Glassmorphism** and **Tonal Layering** rather than traditional heavy shadows.

- **Level 0 (Background):** Solid #0A0A0B.
- **Level 1 (Surface):** Solid #161618 with a 1px subtle border (#FFFFFF10).
- **Level 2 (Floating/Modals):** Background blur (20px) with a semi-transparent fill (#16161880). This level represents interactive overlays that sit above the recording preview.
- **Overlays:** A very soft, diffused purple or cyan ambient glow may be used behind primary buttons to suggest high energy, but shadow offsets should remain at 0 to maintain a flat, modern look.

## Shapes

The shape language is friendly yet structured. 

- **Standard Containers:** Use a 16px radius (`rounded-lg`) for cards and settings groups.
- **Primary Buttons:** Use a 12px radius to feel substantial.
- **Indicators:** Recording status bubbles and small tags should use "Pill" shapes (full radius) to distinguish them from structural UI elements.

## Components

### Buttons
- **Primary:** Solid Electric Purple with white text. High-performance actions.
- **Secondary:** Transparent with a 1px Cyan border and Cyan text.
- **Floating Action Button (FAB):** Large circular button with a blurred backdrop and Primary background for "Start Recording."

### Input Fields
- **Fields:** Dark #161618 background with a 1px border that glows Cyan on focus.
- **Sliders:** Used for volume and quality settings. The track is neutral; the thumb and active fill are Electric Purple.

### Cards & Lists
- **Media Cards:** Feature a large thumbnail with 16px rounded corners. Metadata is placed below in `body-md`.
- **List Items:** Separated by subtle 1px dividers or grouped within 16px rounded containers.

### Recording HUD
- **Status Indicator:** A pulsing "Recording Red" dot paired with a mono-space timer.
- **Controls:** Glassmorphic buttons with backdrop blur to ensure visibility over any background content.

### Chips & Tags
- Used for video resolution (e.g., "4K", "60FPS"). High-contrast neutral backgrounds with `label-sm` typography.
