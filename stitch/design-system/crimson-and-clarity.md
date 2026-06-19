---
name: Crimson & Clarity
colors:
  surface: '#faf9fe'
  surface-dim: '#dad9df'
  surface-bright: '#faf9fe'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f4f3f8'
  surface-container: '#eeedf3'
  surface-container-high: '#e9e7ed'
  surface-container-highest: '#e3e2e7'
  on-surface: '#1a1b1f'
  on-surface-variant: '#5d3f3b'
  inverse-surface: '#2f3034'
  inverse-on-surface: '#f1f0f5'
  outline: '#926f6a'
  outline-variant: '#e7bdb7'
  surface-tint: '#c0000a'
  primary: '#bc000a'
  on-primary: '#ffffff'
  primary-container: '#e2241f'
  on-primary-container: '#fffbff'
  inverse-primary: '#ffb4aa'
  secondary: '#5f5e60'
  on-secondary: '#ffffff'
  secondary-container: '#e2dfe1'
  on-secondary-container: '#636264'
  tertiary: '#5a5c60'
  on-tertiary: '#ffffff'
  tertiary-container: '#737479'
  on-tertiary-container: '#fdfcff'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#ffdad5'
  primary-fixed-dim: '#ffb4aa'
  on-primary-fixed: '#410001'
  on-primary-fixed-variant: '#930005'
  secondary-fixed: '#e4e2e4'
  secondary-fixed-dim: '#c8c6c8'
  on-secondary-fixed: '#1b1b1d'
  on-secondary-fixed-variant: '#474649'
  tertiary-fixed: '#e2e2e7'
  tertiary-fixed-dim: '#c6c6cb'
  on-tertiary-fixed: '#1a1c1f'
  on-tertiary-fixed-variant: '#45474b'
  background: '#faf9fe'
  on-background: '#1a1b1f'
  surface-variant: '#e3e2e7'
typography:
  display-lg:
    fontFamily: Inter
    fontSize: 48px
    fontWeight: '700'
    lineHeight: 56px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Inter
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
    letterSpacing: -0.01em
  headline-lg-mobile:
    fontFamily: Inter
    fontSize: 28px
    fontWeight: '700'
    lineHeight: 36px
  title-md:
    fontFamily: Inter
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
  body-lg:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-sm:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  label-md:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
    letterSpacing: 0.05em
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
  sm: 16px
  md: 24px
  lg: 40px
  xl: 64px
  gutter: 20px
  margin-mobile: 16px
  margin-desktop: 32px
---

## Brand & Style
The brand personality centers on the intersection of high-energy performance and approachable utility. By utilizing a "cute-professional" aesthetic, the design system avoids the cold, technical tropes of traditional productivity tools in favor of an inviting, lifestyle-oriented experience.

The design style leverages **Minimalism** with **Tactile** accents. It features expansive white space, high-contrast crimson focal points, and significant roundedness to soften the professional edge. The goal is to evoke a sense of clarity and urgency without inducing stress, making the interface feel like a premium physical stationary set or a well-designed modern studio.

## Colors
The palette is built on a foundation of "Recording Red," used sparingly but purposefully to draw attention to primary actions and active states. 

- **Primary (#FF3B30):** Reserved for high-priority triggers, active recording states, and critical notifications.
- **Surface (#FFFFFF):** The dominant background color to maintain a "paper-white" clarity.
- **Accents (#1C1C1E):** Used for primary text and iconography to ensure AAA accessibility against the white surface.
- **Secondary Neutral (#F2F2F7):** Used for subtle grouping containers and background fills for secondary UI elements.

## Typography
This design system utilizes **Inter** exclusively to maintain a functional, systematic feel. To achieve the "cute" and friendly requirement, the typography relies on heavier weights (SemiBold and Bold) for headers to create a "bubbly" visual weight, contrasted with generous line heights for body text.

All headings should use tighter letter-spacing to appear more compact and "logo-like," while labels use increased tracking for legibility in small-caps or utility contexts.

## Layout & Spacing
The layout follows a **Fluid Grid** philosophy with an 8px rhythmic scale. On desktop, the system uses a 12-column grid, while mobile scales down to a 4-column grid with increased external margins to emphasize the "contained" feel of the UI.

Spacing is intentionally generous. To maintain the "Clarity" aspect of the theme, avoid crowding elements. Use `lg` (40px) or `xl` (64px) padding for section containers to create a breathable, high-end editorial look.

## Elevation & Depth
Elevation is achieved through **Ambient Shadows** and **Tonal Layers** rather than harsh borders. 

- **Level 0 (Base):** White (#FFFFFF) background.
- **Level 1 (Cards/Inputs):** Soft Gray (#F2F2F7) background with no shadow, or a White background with a very diffused, low-opacity shadow (4% Alpha Black, 12px Blur).
- **Level 2 (Floating/Popovers):** White background with a more pronounced shadow (8% Alpha Black, 24px Blur).

The "tactile" feel comes from using the Primary Red as a subtle inner glow or a 2px bottom-heavy shadow on buttons to make them feel "pressable."

## Shapes
The shape language is the primary driver of the "cute" aesthetic. This design system uses a standardized **16px (1rem)** corner radius for all primary containers and buttons. Smaller components like tags or checkboxes should scale proportionally but remain noticeably rounded to avoid sharp geometric tension.

## Components
- **Buttons:** Primary buttons are Solid Crimson (#FF3B30) with white text. They should have 16px corner radii and a subtle 2px vertical offset on hover to feel tactile. Secondary buttons use a light gray fill (#F2F2F7) with black text.
- **Input Fields:** Soft gray backgrounds (#F2F2F7) with no border. On focus, the field transitions to a white background with a 2px Crimson outline.
- **Cards:** White surfaces with a 16px radius and a soft ambient shadow. Use "Chip" style tags within cards for categorization.
- **Chips/Tags:** Pill-shaped (fully rounded) with light gray backgrounds. Active tags should toggle to the Primary Red with white text.
- **Progress Bars:** Use a thick 8px height with fully rounded ends. The track is light gray, and the progress indicator is the vibrant Primary Red.
- **Lists:** Clean, borderless list items separated by 8px of vertical space rather than dividers, emphasizing the "Clarity" of the layout.
