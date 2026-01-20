# TRISH Dating App - Visual Design Guide

## 🎨 Design System Overview

This guide showcases the premium visual design system implemented in TRISH v2.0.

---

## 🌈 Color Palette

### Primary Colors
```
Pink:    #FF1744 ████████
Purple:  #9C27B0 ████████
Orange:  #FF6F00 ████████
Blue:    #00B0FF ████████
```

### Background Colors
```
Dark:    #0A0E27 ████████
Card:    #1A1F3A ████████
Surface: #252B48 ████████
```

### Text Colors
```
Primary:   #FFFFFF ████████
Secondary: #B0B3C1 ████████
Tertiary:  #6B7280 ████████
```

### Status Colors
```
Success: #10B981 ████████
Warning: #FBBF24 ████████
Error:   #EF4444 ████████
Info:    #3B82F6 ████████
```

---

## 🎨 Gradients

### Primary Gradient (Pink → Purple)
Most commonly used for buttons, headers, and highlights
```dart
LinearGradient(
  colors: [#FF1744, #9C27B0],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
)
```

### Accent Gradient (Orange → Pink)
Used for special features and CTAs
```dart
LinearGradient(
  colors: [#FF6F00, #FF1744],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
)
```

### Blue Gradient (Blue → Purple)
Used for secondary actions
```dart
LinearGradient(
  colors: [#00B0FF, #9C27B0],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
)
```

### Gold Gradient (Gold → Orange)
Used for premium features
```dart
LinearGradient(
  colors: [#FFD700, #FF8C00],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
)
```

---

## 📐 Spacing System

We use a consistent 4px base unit:

```
4px   - Tiny gaps
8px   - Small spacing
12px  - Medium-small spacing
16px  - Medium spacing
20px  - Medium-large spacing
24px  - Large spacing
32px  - Extra large spacing
40px  - Huge spacing
```

---

## 🔤 Typography

### Font Family
**Poppins** - Modern, clean, and professional

### Text Styles

```
Display Large:  32px, Bold
Display Medium: 28px, Bold
Display Small:  24px, Bold

Headline Large:  22px, SemiBold
Headline Medium: 20px, SemiBold
Headline Small:  18px, SemiBold

Title Large:  16px, SemiBold
Title Medium: 14px, Medium
Title Small:  12px, Medium

Body Large:  16px, Regular
Body Medium: 14px, Regular
Body Small:  12px, Regular

Label Large:  14px, SemiBold
Label Medium: 12px, Medium
Label Small:  10px, Medium
```

---

## 🎯 Border Radius

```
Small:       8px  - Badges, chips
Medium:      16px - Cards, buttons
Large:       24px - Profile cards
Extra Large: 32px - Dialogs, modals
```

---

## 💫 Shadows

### Card Shadow
```dart
BoxShadow(
  color: primaryPink.withOpacity(0.2),
  blurRadius: 20,
  offset: Offset(0, 10),
)
```

### Glow Shadow
```dart
BoxShadow(
  color: primaryPink.withOpacity(0.5),
  blurRadius: 30,
  spreadRadius: 5,
)
```

---

## 🎬 Animations

### Duration Guidelines
```
Fast:    100ms - Button press
Normal:  300ms - Transitions
Slow:    600ms - Page transitions
Smooth:  1000ms - Pulse effects
```

### Curves
```
easeInOut - Most animations
easeIn    - Fade in
easeOut   - Fade out
elasticOut - Bounce effects
```

---

## 🎨 Component Styles

### Buttons

#### Primary Button
- Background: Solid pink (#FF1744)
- Text: White
- Shadow: Pink glow
- Press: Scale to 0.95

#### Gradient Button
- Background: Pink-Purple gradient
- Text: White
- Shadow: Pink glow
- Press: Scale to 0.95

#### Outline Button
- Background: Transparent
- Border: 2px pink
- Text: White
- Press: Scale to 0.95

#### Glass Button
- Background: Translucent surface
- Border: 1px white (10% opacity)
- Text: White
- Blur: 10px

### Cards

#### Glass Card
- Background: Surface color (30% opacity)
- Border: 1px white (10% opacity)
- Blur: 10px
- Shadow: Subtle black

#### Gradient Card
- Background: Gradient
- Shadow: Colored glow
- Border Radius: 16px

#### Profile Card
- Background: Image with gradient overlay
- Overlay: Transparent → Black (80%)
- Border Radius: 24px
- Shadow: Deep shadow

### Chat Bubbles

#### Sent Message
- Background: Pink-Purple gradient
- Text: White
- Border Radius: 20px (bottom-right: 4px)
- Shadow: Pink glow

#### Received Message
- Background: Surface color
- Text: White
- Border Radius: 20px (bottom-left: 4px)
- Shadow: Subtle

---

## 🎨 Design Principles

### 1. Glassmorphism
Modern, translucent surfaces with blur effects
- Creates depth
- Professional appearance
- Trendy and attractive

### 2. Gradient Overlays
Smooth color transitions
- Better text readability
- Visual interest
- Premium feel

### 3. Micro-animations
Small, delightful interactions
- Button press feedback
- Swipe animations
- Loading states
- Improves perceived performance

### 4. Consistent Spacing
4px base unit system
- Visual rhythm
- Professional layout
- Easy to maintain

### 5. Color Harmony
Vibrant yet professional palette
- Pink-Purple primary
- Complementary accents
- High contrast for readability

### 6. Typography Hierarchy
Clear text levels
- Poppins font family
- Consistent sizing
- Proper weights

### 7. Shadows & Depth
Elevation system
- Card shadows
- Glow effects
- 3D appearance

---

## 📱 Screen Patterns

### Home Screen
```
┌─────────────────────────┐
│  [👤]  TRISH  [💬]      │ Header
├─────────────────────────┤
│ ┌─────┐ ┌─────┐         │ Stats
│ │ 12  │ │  3  │         │
│ │Likes│ │Match│         │
│ └─────┘ └─────┘         │
├─────────────────────────┤
│                         │
│   ┌───────────────┐     │
│   │               │     │
│   │  Profile Card │     │ Card Stack
│   │               │     │
│   └───────────────┘     │
│                         │
├─────────────────────────┤
│  [✕]  [⭐]  [♥]        │ Actions
└─────────────────────────┘
```

### Matches Screen
```
┌─────────────────────────┐
│      Your Matches       │ Header
├─────────────────────────┤
│ ┌───┐ ┌───┐ ┌───┐      │
│ │ 👤│ │ 👤│ │ 👤│      │
│ └───┘ └───┘ └───┘      │ Grid
│ ┌───┐ ┌───┐ ┌───┐      │
│ │ 👤│ │ 👤│ │ 👤│      │
│ └───┘ └───┘ └───┘      │
└─────────────────────────┘
```

### Chat Screen
```
┌─────────────────────────┐
│  ← Sarah, 24            │ Header
├─────────────────────────┤
│                         │
│     ┌──────────┐        │ Received
│     │ Hi there │        │
│     └──────────┘        │
│                         │
│        ┌──────────┐     │ Sent
│        │ Hey! 👋  │     │
│        └──────────┘     │
│                         │
├─────────────────────────┤
│ [Type a message...]  [→]│ Input
└─────────────────────────┘
```

---

## 🎯 Best Practices

### DO ✅
- Use theme colors consistently
- Add loading states
- Implement smooth animations
- Provide visual feedback
- Use glassmorphic effects
- Add proper shadows
- Maintain spacing system
- Use gradient overlays for readability

### DON'T ❌
- Use random colors
- Skip loading states
- Have instant transitions
- Ignore user actions
- Use flat designs
- Forget shadows
- Use random spacing
- Put text on images without overlay

---

## 🎨 Component Examples

### Premium Button
```
┌──────────────┐
│  Sign In  →  │  Primary
└──────────────┘

┌──────────────┐
│   Cancel     │  Outline
└──────────────┘

┌──────────────┐
│ Get Started  │  Gradient
└──────────────┘
```

### Cards
```
╔══════════════╗
║              ║
║  Glass Card  ║  Translucent
║              ║
╚══════════════╝

┌──────────────┐
│ ╔══════════╗ │
│ ║  Stat    ║ │  With Icon
│ ║   42     ║ │
│ ╚══════════╝ │
└──────────────┘
```

### Badges
```
┌─────────┐
│ ✓ Verified │  Success
└─────────┘

┌─────────┐
│ ⭐ Premium │  Gold
└─────────┘
```

---

## 🎨 Accessibility

### Contrast Ratios
- Text on dark background: 15:1 (AAA)
- Text on cards: 7:1 (AA)
- Interactive elements: 4.5:1 (AA)

### Touch Targets
- Minimum: 44x44 px
- Recommended: 48x48 px
- Buttons: 56x56 px

### Font Sizes
- Minimum: 12px
- Body text: 14-16px
- Headers: 20-32px

---

## 📊 Performance

### Animation Performance
- Target: 60 FPS
- Use hardware acceleration
- Avoid layout thrashing
- Optimize images

### Loading States
- Show shimmer immediately
- Fade in content
- Smooth transitions

---

## 🎉 Conclusion

This design system creates a **premium, cohesive, and delightful** user experience through:

- 🎨 Consistent color palette
- 💫 Smooth animations
- 🌟 Glassmorphic design
- 📐 Systematic spacing
- 🔤 Clear typography
- 💎 Professional polish

Use this guide to maintain design consistency across the TRISH dating app!

---

**Version**: 2.0.0  
**Last Updated**: 2026-01-13  
**Design System**: TRISH Premium
