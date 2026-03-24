# AerChain Sales Bible v3.0 — Interactive Command Center
## COMPLETE CONTEXT TRANSFER DOCUMENT
### For parallel build in Claude Code / Claude Chat / Cowork

**Prepared by**: Claude (Cowork session, March 24, 2026)
**Prepared for**: Gaurav Krishna Guha, Head of Sales, Aerchain
**Purpose**: Full-fidelity context transfer to spin up parallel build sessions with zero information loss
**Rule**: Do NOT build until Gaurav says "Geronimo"

---

# TABLE OF CONTENTS

1. [PROJECT OVERVIEW & OBJECTIVES](#1-project-overview--objectives)
2. [DESIGN SYSTEM — DARK THEME (Zero Hour Style)](#2-design-system--dark-theme)
3. [DESIGN SYSTEM — LIGHT THEME (Master App Style)](#3-design-system--light-theme)
4. [THEME SWITCHING ARCHITECTURE](#4-theme-switching-architecture)
5. [TYPOGRAPHY & FONTS](#5-typography--fonts)
6. [AERCHAIN LOGO (Base64 SVG)](#6-aerchain-logo)
7. [LAYOUT & COMPONENT ARCHITECTURE](#7-layout--component-architecture)
8. [SALES BIBLE CONTENT — ALL 9 STAGES](#8-sales-bible-content--all-9-stages)
9. [COLLATERAL TRACKER — 38 ITEMS WITH OWNERS](#9-collateral-tracker--38-items)
10. [V5 PRINCIPLES ALIGNMENT](#10-v5-principles-alignment)
11. [COMPETITIVE INTELLIGENCE / BATTLECARDS](#11-competitive-intelligence)
12. [PRICING FRAMEWORK](#12-pricing-framework)
13. [10 COMMANDMENTS & P0/P1/P2 GUARDRAILS](#13-commandments--guardrails)
14. [SALESOS INTEGRATION](#14-salesos-integration)
15. [EXISTING ARTIFACTS GALLERY](#15-existing-artifacts-gallery)
16. [ARCHITECTURAL DECISIONS LOG](#16-architectural-decisions)
17. [KEY PERSONNEL & OWNERSHIP](#17-key-personnel)
18. [CONTENT SOURCES & DRIFT NOTES](#18-content-sources)
19. [BUILD SPECIFICATION](#19-build-specification)

---

# 1. PROJECT OVERVIEW & OBJECTIVES

## What This Is
A single, self-contained HTML file (~3000-5000 lines) that serves as the **AerChain Sales Bible v3.0 — Interactive Command Center**. It unifies all sales playbook content, collateral tracking, competitive intelligence, and SalesOS module previews into one stunning interactive artifact.

## Who It's For
- **Primary audience**: Harsha Kadimisetty (CEO, Aerchain) — this must blow away his baseline (PDF flowchart + HTML v2 + Notion markdown)
- **Secondary audience**: Aerchain sales team, pre-sales, implementation
- **Builder**: Gaurav Krishna Guha (Head of Sales)

## The Baseline to Beat
Harsha created:
1. `Sales Bible_V2.pdf` — Visual flowchart of entire pipeline Stage 0→8 with decision diamonds
2. `aerchain_sales_bible_v2.html` (3998 lines) — Interactive HTML with accordions, pipeline viz, all 9 stages
3. `AerChain-Sales-Bible-Notion-Package.zip` (14 markdown files) — Notion export with full stage content

Gaurav's v3.0 must dramatically surpass all three in ambition, design, interactivity, and completeness.

## What It Must Include
1. **Hero + Dashboard** with pipeline visualization (Stage 0→8 visual flow)
2. **Stage-by-Stage Playbook** (all content from Notion + HTML v2, updated for V5 principles)
3. **Collateral Tracker** (38 items from Dubai Excel with real statuses/ownership/links)
4. **Live Artifact Gallery** (links/previews of existing HTML artifacts Gaurav has built)
5. **Competitive Intelligence Hub** (battlecard content — SAP Ariba complete, 6 competitors stubbed)
6. **Pricing Framework** (V5-aligned, modules + user roles + workflow credits)
7. **V5 Principles Summary** (the philosophical shift that changes everything)
8. **10 Commandments + P0/P1/P2 Guardrails** (sell/mention/don't sell classification)
9. **SalesOS Module Previews** (Pricing Calculator, Proposal Generator — links or embedded previews)
10. **Ownership & Accountability Dashboard** (who owns what, progress tracking)

---

# 2. DESIGN SYSTEM — DARK THEME (Zero Hour Keynote Style)

The dark theme uses the Aerchain Zero Hour Keynote (`Aerchain_Zero_Hour_-_Keynote_Presentation (1).html`) as its exact reference. This includes a **purple-glass default** canvas plus **7 alternate dark color palettes** selectable via a color dot bar.

## 2.1 Default Dark Theme (Purple-Glass) — CSS `:root`

```css
:root {
  /* Canvas — purple-glass default */
  --canvas-a: hsl(262 55% 18%);
  --canvas-b: hsl(270 45% 12%);
  --canvas-c: hsl(255 40% 10%);
  --canvas-d: hsl(245 35% 8%);
  --nav-bg: linear-gradient(180deg, hsl(262 55% 16% / .96), hsl(262 55% 16% / .88));

  /* Brand */
  --aerchain: #DC5F40;
  --gp: linear-gradient(135deg, hsl(262 80% 55%), hsl(275 85% 58%));
  --active-glow: hsl(262 80% 55% / .25);

  /* Semantic colours */
  --col-purple: hsl(262 80% 55%);
  --col-blue:   hsl(217 88% 58%);
  --col-green:  hsl(152 68% 42%);
  --col-amber:  hsl(38 92% 50%);
  --col-red:    hsl(0 68% 48%);
  --col-orange: hsl(18 90% 55%);

  /* Glass surfaces */
  --glass-1: rgba(255,255,255,.03);
  --glass-2: rgba(255,255,255,.06);
  --glass-3: rgba(255,255,255,.10);
  --glass-border:   rgba(255,255,255,.06);
  --glass-border-h: rgba(255,255,255,.14);

  /* Foreground */
  --fg:  rgba(255,255,255,.94);
  --fg2: rgba(255,255,255,.72);
  --fg3: rgba(255,255,255,.42);

  /* Shared radii */
  --r:  16px;
  --rm: 12px;

  /* Dot-grid pattern */
  --dot: radial-gradient(rgba(255,255,255,.045) 1px, transparent 1px);
}

/* Body application */
body {
  font-family: 'Montserrat', system-ui, sans-serif;
  background: linear-gradient(145deg, var(--canvas-a), var(--canvas-b) 35%, var(--canvas-c) 70%, var(--canvas-d));
  background-attachment: fixed;
  color: var(--fg);
  font-size: 15px;
  line-height: 1.5;
}
```

## 2.2 Alternate Dark Palettes — `[data-theme]` Selectors

These swap the canvas gradient and accent colors while keeping all glass/fg tokens the same.

```css
[data-theme="deep-ocean"] {
  --canvas-a: hsl(200 55% 16%); --canvas-b: hsl(210 50% 11%);
  --canvas-c: hsl(215 45% 9%);  --canvas-d: hsl(220 40% 7%);
  --gp: linear-gradient(135deg, hsl(195 85% 45%), hsl(175 80% 42%));
  --active-glow: hsl(195 85% 45% / .25);
  --nav-bg: linear-gradient(180deg, hsl(200 55% 16% / .96), hsl(210 50% 11% / .88));
}

[data-theme="rose-quartz"] {
  --canvas-a: hsl(330 38% 15%); --canvas-b: hsl(335 32% 11%);
  --canvas-c: hsl(340 28% 9%);  --canvas-d: hsl(345 22% 7%);
  --gp: linear-gradient(135deg, hsl(330 72% 58%), hsl(290 70% 55%));
  --active-glow: hsl(330 72% 58% / .25);
  --nav-bg: linear-gradient(180deg, hsl(330 38% 15% / .96), hsl(335 32% 11% / .88));
}

[data-theme="midnight-emerald"] {
  --canvas-a: hsl(155 40% 14%); --canvas-b: hsl(160 35% 10%);
  --canvas-c: hsl(165 30% 8%);  --canvas-d: hsl(170 25% 6%);
  --gp: linear-gradient(135deg, hsl(152 68% 42%), hsl(165 75% 38%));
  --active-glow: hsl(152 68% 42% / .25);
  --nav-bg: linear-gradient(180deg, hsl(155 40% 14% / .96), hsl(160 35% 10% / .88));
}

[data-theme="arctic"] {
  --canvas-a: hsl(225 45% 16%); --canvas-b: hsl(230 40% 12%);
  --canvas-c: hsl(235 35% 9%);  --canvas-d: hsl(240 30% 7%);
  --gp: linear-gradient(135deg, hsl(217 88% 58%), hsl(200 90% 55%));
  --active-glow: hsl(217 88% 58% / .25);
  --nav-bg: linear-gradient(180deg, hsl(225 45% 16% / .96), hsl(230 40% 12% / .88));
}

[data-theme="topaz"] {
  --canvas-a: hsl(192 40% 14%); --canvas-b: hsl(196 36% 10%);
  --canvas-c: hsl(200 32% 8%);  --canvas-d: hsl(205 28% 6%);
  --gp: linear-gradient(135deg, hsl(188 80% 48%), hsl(42 88% 52%));
  --active-glow: hsl(188 80% 48% / .25);
  --nav-bg: linear-gradient(180deg, hsl(192 40% 14% / .96), hsl(196 36% 10% / .88));
}

[data-theme="citrine"] {
  --canvas-a: hsl(48 55% 12%); --canvas-b: hsl(45 50% 9%);
  --canvas-c: hsl(42 45% 7%);  --canvas-d: hsl(38 40% 5%);
  --gp: linear-gradient(135deg, hsl(48 95% 52%), hsl(38 90% 44%));
  --active-glow: hsl(48 95% 52% / .30);
  --nav-bg: linear-gradient(180deg, hsl(48 55% 12% / .96), hsl(45 50% 9% / .88));
}

[data-theme="slate"] {
  --canvas-a: hsl(215 22% 15%); --canvas-b: hsl(218 20% 11%);
  --canvas-c: hsl(220 18% 9%);  --canvas-d: hsl(222 16% 7%);
  --gp: linear-gradient(135deg, hsl(213 72% 52%), hsl(232 68% 58%));
  --active-glow: hsl(213 72% 52% / .25);
  --nav-bg: linear-gradient(180deg, hsl(215 22% 15% / .96), hsl(218 20% 11% / .88));
}
```

## 2.3 Color Dot Indicator CSS (for the dark palette switcher dots)

```css
.td[data-t="purple-glass"]     { background: linear-gradient(135deg, hsl(262 80% 55%), hsl(275 85% 58%)); }
.td[data-t="deep-ocean"]       { background: linear-gradient(135deg, hsl(195 85% 45%), hsl(175 80% 42%)); }
.td[data-t="rose-quartz"]      { background: linear-gradient(135deg, hsl(330 72% 58%), hsl(290 70% 55%)); }
.td[data-t="midnight-emerald"] { background: linear-gradient(135deg, hsl(152 68% 42%), hsl(165 75% 38%)); }
.td[data-t="arctic"]           { background: linear-gradient(135deg, hsl(217 88% 58%), hsl(200 90% 55%)); }
.td[data-t="topaz"]            { background: linear-gradient(135deg, hsl(188 80% 48%), hsl(42 88% 52%)); }
.td[data-t="citrine"]          { background: linear-gradient(135deg, hsl(48 95% 52%), hsl(38 90% 44%)); }
.td[data-t="slate"]            { background: linear-gradient(135deg, hsl(213 72% 52%), hsl(232 68% 58%)); }
```

---

# 3. DESIGN SYSTEM — LIGHT THEME (Master App Style)

The light theme comes from `GKG-Master-App-Unified-2026-03-24.html` — specifically the `html.light` class. This is the ONLY light variant. No color sub-palettes for light mode.

## 3.1 Light Theme Root Tokens

```css
html.light {
  --primary: hsl(262 80% 55%);
  --accent: hsl(275 85% 58%);
  --green: hsl(152 68% 38%);
  --amber: hsl(38 92% 50%);
  --red: hsl(0 78% 58%);
  --blue: hsl(217 80% 55%);
  --teal: hsl(175 55% 42%);
  --canvas: linear-gradient(160deg, hsl(262 35% 94%) 0%, hsl(268 28% 91%) 40%, hsl(258 22% 88%) 100%);
  --glass-1: rgba(255,255,255,0.55);
  --glass-2: rgba(255,255,255,0.65);
  --glass-3: rgba(255,255,255,0.78);
  --glass-border: hsl(262 20% 86%);
  --glass-border-h: hsl(262 80% 55% / 0.30);
  --fg: hsl(220 15% 13%);
  --fg2: hsl(220 9% 46%);
  --fg3: hsl(220 9% 62%);
  --gp: linear-gradient(135deg, hsl(262 80% 55%), hsl(275 85% 58%));
  --s-glass: 0 4px 20px rgba(124,58,237,0.08), 0 1px 3px rgba(124,58,237,0.04);
  --s-elevated: 0 16px 40px -8px rgba(124,58,237,0.16), 0 4px 12px rgba(124,58,237,0.06);
  --s-glow: 0 0 24px hsl(262 80% 55% / 0.22);
  --s-premium: 0 16px 48px -12px rgba(124,58,237,0.30);
}
```

## 3.2 Light Theme Component Overrides (KEY ONES — 149 total rules in Master App)

These are the critical overrides that make light mode work. In the Sales Bible v3.0, adapt these class names to match whatever components you build.

### Topbar (inverted — purple gradient on light)
```css
.light .tb {
  background: linear-gradient(135deg, hsl(262 75% 52%), hsl(275 80% 56%));
  backdrop-filter: blur(20px) saturate(1.3);
  border-bottom-color: hsl(262 60% 45%);
}
/* Topbar elements stay white on the purple gradient */
.light .tb::before { background: linear-gradient(90deg, rgba(255,255,255,0.25), rgba(255,255,255,0.08)); opacity: 1; }
.light .tl-logo { filter: brightness(100) drop-shadow(0 0 10px rgba(255,255,255,0.20)); }
.light .tl-sep { background: rgba(255,255,255,0.18); }
```

### Sidebar (lavender frosted glass)
```css
.light .sb {
  background: linear-gradient(180deg, rgba(248,244,255,0.78), rgba(255,255,255,0.70));
  backdrop-filter: blur(24px) saturate(1.4);
}
.light .si { color: hsl(220 9% 52%); }
.light .si:hover { background: hsl(262 80% 55%/.08); color: hsl(262 60% 30%); }
.light .si.act { background: hsl(262 80% 55%/.12); color: hsl(262 70% 38%); box-shadow: inset 3px 0 0 var(--primary); }
```

### Cards (white frosted glass with purple shadows)
```css
.light .mc, .light .cd {
  background: linear-gradient(160deg, rgba(255,255,255,0.85), rgba(245,240,255,0.70));
  backdrop-filter: blur(20px) saturate(1.3);
}
.light .mc:hover, .light .cd:hover {
  background: rgba(255,255,255,0.92);
  box-shadow: var(--s-elevated);
}
```

### Right panel
```css
.light .rp {
  background: linear-gradient(180deg, rgba(255,255,255,0.72), rgba(245,240,255,0.68));
  backdrop-filter: blur(24px) saturate(1.4);
}
```

### Tables
```css
.light th { color: hsl(262 30% 45%); border-bottom-color: hsl(262 18% 88%); background: hsl(262 25% 95%); }
.light td { border-bottom-color: hsl(262 15% 93%); color: hsl(220 15% 20%); }
.light tbody tr:nth-child(even) td { background: hsl(262 20% 96%); }
.light tr:hover td { background: hsl(262 55% 94%); }
```

### Scrollbar
```css
.light ::-webkit-scrollbar-thumb { background: hsl(262 30% 80%); }
.light ::-webkit-scrollbar-thumb:hover { background: hsl(262 40% 70%); }
```

### Badges / status chips
```css
.light .b-p { background: hsl(262 80% 55%/.14); color: hsl(262 75% 38%); }
.light .b-g { background: hsl(152 68% 38%/.10); color: hsl(152 55% 30%); }
.light .b-w { background: hsl(38 92% 50%/.10); color: hsl(38 72% 33%); }
.light .b-r { background: hsl(0 78% 58%/.10); color: hsl(0 60% 40%); }
.light .b-i { background: hsl(217 80% 55%/.10); color: hsl(217 65% 38%); }
```

### Collapsible sections
```css
.light .collapsible { border-color: hsl(262 18% 88%); }
.light .coll-hd { background: hsl(262 22% 95%); color: hsl(220 15% 13%); }
.light .coll-hd:hover { background: hsl(262 45% 93%); }
.light .coll-content { color: hsl(220 9% 32%); }
```

### Battlecards
```css
.light .battle { background: rgba(255,255,255,0.80); border-color: hsl(262 18% 90%); }
.light .battle-claim { color: hsl(0 60% 42%); }
.light .battle-counter { color: hsl(220 15% 18%); }
.light .battle-proof { color: hsl(152 55% 32%); }
```

### Progress bars & tabs
```css
.light .pbar { background: hsl(262 22% 90%); }
.light .mtabs { background: hsl(262 22% 92%); }
.light .mtab { color: hsl(220 9% 52%); }
.light .mtab.act { background: rgba(255,255,255,0.90); color: var(--primary); box-shadow: 0 1px 4px rgba(124,58,237,0.10); }
```

### Theme toggle (stays white text on purple topbar in light mode)
```css
.light .theme-toggle {
  background: rgba(255,255,255,0.12);
  border-color: rgba(255,255,255,0.18);
  color: rgba(255,255,255,0.65);
}
.light .theme-toggle:hover {
  background: rgba(255,255,255,0.22);
  color: white;
  border-color: rgba(255,255,255,0.30);
}
.light .theme-toggle svg { transform: rotate(240deg); }
```

---

# 4. THEME SWITCHING ARCHITECTURE

## 4.1 Two-Level Toggle System

**Level 1 — Mode Toggle**: Dark ↔ Light
- Toggles `html.light` class on `<html>` element
- When switching to Light: hide the color palette bar (dark palettes don't apply)
- When switching to Dark: show the color palette bar

**Level 2 — Dark Palette Selector** (only visible in Dark mode)
- Uses `data-theme` attribute on `<body>` element
- 8 options: purple-glass (default), deep-ocean, rose-quartz, midnight-emerald, arctic, topaz, citrine, slate
- Visual: row of colored dots in the nav bar

## 4.2 Zero Hour Theme Bar HTML

```html
<div class="theme-bar">
  <span class="theme-bar-label">Theme</span>
  <div class="td active" data-t="purple-glass"     onclick="setTheme(this)" title="Purple Glass"></div>
  <div class="td"        data-t="deep-ocean"       onclick="setTheme(this)" title="Deep Ocean"></div>
  <div class="td"        data-t="rose-quartz"      onclick="setTheme(this)" title="Rose Quartz"></div>
  <div class="td"        data-t="midnight-emerald"  onclick="setTheme(this)" title="Midnight Emerald"></div>
  <div class="td"        data-t="arctic"           onclick="setTheme(this)" title="Arctic"></div>
  <div class="td"        data-t="topaz"            onclick="setTheme(this)" title="Topaz"></div>
  <div class="td"        data-t="citrine"          onclick="setTheme(this)" title="Citrine"></div>
  <div class="td"        data-t="slate"            onclick="setTheme(this)" title="Slate"></div>
</div>
```

## 4.3 Theme Bar CSS

```css
.theme-bar {
  display: flex; align-items: center; gap: 7px;
  padding: 5px 11px 5px 9px; margin-left: 10px;
  background: var(--glass-2); backdrop-filter: blur(20px); -webkit-backdrop-filter: blur(20px);
  border: 1px solid var(--glass-border); border-radius: 40px;
  flex-shrink: 0;
}
.theme-bar-label {
  font-family: 'JetBrains Mono', monospace; font-size: 8px; font-weight: 600;
  letter-spacing: .10em; text-transform: uppercase; color: var(--fg3); margin-right: 2px;
}
.td {
  width: 14px; height: 14px; border-radius: 50%; border: 2px solid transparent;
  cursor: pointer; transition: all .25s; flex-shrink: 0;
}
.td:hover { transform: scale(1.3); }
.td.active { border-color: rgba(255,255,255,.75); box-shadow: 0 0 8px var(--active-glow); }
```

## 4.4 JavaScript — Dark Palette Switcher

```javascript
function setTheme(el) {
  document.body.setAttribute('data-theme', el.dataset.t);
  document.querySelectorAll('.td').forEach(d => d.classList.remove('active'));
  el.classList.add('active');
}
```

## 4.5 JavaScript — Dark/Light Mode Toggle (to be built)

```javascript
// PROPOSED IMPLEMENTATION for Sales Bible v3.0
const MODES = ['dark', 'light'];

function toggleMode() {
  const html = document.documentElement;
  const isLight = html.classList.contains('light');

  if (isLight) {
    // Switch to dark
    html.classList.remove('light');
    document.querySelector('.theme-bar').style.display = 'flex';
    localStorage.setItem('sb-mode', 'dark');
  } else {
    // Switch to light
    html.classList.add('light');
    document.querySelector('.theme-bar').style.display = 'none';
    localStorage.setItem('sb-mode', 'light');
  }
}

// Persist on load
document.addEventListener('DOMContentLoaded', () => {
  const saved = localStorage.getItem('sb-mode');
  if (saved === 'light') {
    document.documentElement.classList.add('light');
    document.querySelector('.theme-bar').style.display = 'none';
  }
  const savedTheme = localStorage.getItem('sb-dark-palette');
  if (savedTheme) {
    document.body.setAttribute('data-theme', savedTheme);
  }
});
```

---

# 5. TYPOGRAPHY & FONTS

## Font Import
```html
<link href="https://fonts.googleapis.com/css2?family=Montserrat:wght@300;400;500;600&family=JetBrains+Mono:wght@400;500;600&display=swap" rel="stylesheet">
```

## Usage Rules
- **Montserrat 300/400/500/600** — All body text, headings, paragraphs. Weight ceiling: 600 (no 700/800/900)
- **JetBrains Mono 400/500/600** — All data values, financial figures, stage numbers, status badges, timestamps, code, labels, eyebrows
- **Heading pattern**: h1 = font-weight 300, with `<b>` spans at weight 550 using the gradient text effect
- **Gradient text effect** (for emphasis words in headings):
```css
b, .gradient-text {
  font-weight: 550;
  background: linear-gradient(90deg, hsl(262 80% 55%) 0%, hsl(275 85% 80%) 35%, hsl(262 80% 55%) 55%, hsl(275 85% 80%) 100%);
  background-size: 200% auto;
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
  animation: shine 15s ease-in-out infinite;
}

@keyframes shine {
  0%   { background-position: 200% center; }
  100% { background-position: -200% center; }
}
```

## Eyebrow Label Pattern
```css
.eyebrow {
  font-family: 'JetBrains Mono', monospace;
  font-size: 13px; font-weight: 700;
  letter-spacing: .14em; text-transform: uppercase;
  display: flex; align-items: center; gap: 8px;
}
.eyebrow::before {
  content: ''; width: 16px; height: 1.5px; border-radius: 1px;
  background: var(--gp); flex-shrink: 0;
}
```

---

# 6. AERCHAIN LOGO (Base64 SVG)

The actual Aerchain logo as a base64 SVG data URI. This is the WHITE version for dark themes. For light theme, apply `filter: brightness(0) saturate(100%)` or use a separate dark version.

**CRITICAL**: Use this exact string. Do not recreate the logo.

The full base64 string is 11,010 characters. It is saved in the file `aerchain-logo-base64.txt` in the working directory. The string starts with:

```
data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMTY4IiBoZWlnaHQ9IjMyIiB2aWV3Qm94PSIwIDAgMTY4IDMyIiBmaWxsPS...
```

**Usage in HTML**:
```html
<img src="[FULL_BASE64_STRING]" alt="Aerchain" class="nav-logo" style="height: 22px; width: auto; opacity: .9;">
```

**Light theme logo handling** (from Master App):
```css
.light .tl-logo { filter: brightness(100) drop-shadow(0 0 10px rgba(255,255,255,0.20)); }
```

NOTE: Since the light theme topbar is a purple gradient, the WHITE logo still works in light mode — it sits on the purple topbar, so no inversion needed.

---

# 7. LAYOUT & COMPONENT ARCHITECTURE

## 7.1 Proposed Layout Structure

The Sales Bible is a **scrollable single-page application** (like the Zero Hour Keynote) with a **fixed navigation bar** at the top. Unlike the Master App's 3-column grid layout, this should be a full-width content flow with section-based navigation.

### Fixed Top Navigation
```css
.nav {
  position: fixed; top: 0; left: 0; right: 0; z-index: 100;
  display: flex; align-items: center; gap: 16px;
  padding: 10px 32px;
  background: var(--nav-bg);
  backdrop-filter: blur(24px);
  border-bottom: 1px solid var(--glass-border);
}
```

### Content Container
```css
.page {
  max-width: 1280px;
  margin: 0 auto;
  padding: 96px 48px 80px; /* 96px top for nav clearance */
}
```

### Glass Card System
```css
.card {
  background: var(--glass-2);
  backdrop-filter: blur(40px) saturate(1.4);
  -webkit-backdrop-filter: blur(40px) saturate(1.4);
  border: 1px solid var(--glass-border);
  border-radius: var(--r); /* 16px */
  padding: 24px;
  transition: all 0.3s ease;
}
.card:hover {
  background: var(--glass-3);
  border-color: var(--glass-border-h);
}
```

## 7.2 Key Animation Keyframes (from Zero Hour)

```css
@keyframes flowDash     { to { stroke-dashoffset: -24; } }
@keyframes orbGlow      {
  0%,100% { box-shadow: 0 0 40px var(--active-glow), 0 0 80px var(--active-glow); }
  50%     { box-shadow: 0 0 60px var(--active-glow), 0 0 120px var(--active-glow); }
}
@keyframes metaPulse    {
  0%,100% { box-shadow: 0 0 6px var(--col-green / .4); }
  50%     { box-shadow: 0 0 14px var(--col-green / .7); }
}
@keyframes badgeGlow    {
  0%,100% { box-shadow: 0 0 10px var(--active-glow); }
  50%     { box-shadow: 0 0 20px var(--active-glow), 0 0 36px var(--active-glow); }
}
@keyframes countUp {
  from { opacity: 0; transform: translateY(8px); }
  to   { opacity: 1; transform: translateY(0); }
}
```

## 7.3 Section Spacing Pattern

```css
.section { margin-bottom: 245px; }
.section-header { margin-bottom: 29px; margin-top: 189px; }
.section-header h2 { font-size: 48px; font-weight: 300; letter-spacing: -.025em; }
```

## 7.4 Chip/Badge Component

```css
.chip {
  font-family: 'JetBrains Mono', monospace; font-size: 11px; font-weight: 600;
  padding: 4px 12px; border-radius: 14px;
  display: inline-flex; align-items: center; gap: 5px;
}
.chip::before { content: ''; width: 4px; height: 4px; border-radius: 50%; }
.chip.up  { background: hsl(152 68% 38% / .14); color: hsl(152 68% 52%); }
.chip.hot { background: hsl(38 92% 50% / .12);  color: hsl(38 92% 58%); }
```

## 7.5 Quote Banner Component

```css
.quote-banner {
  background: linear-gradient(135deg, hsl(262 20% 13% / .85), hsl(255 14% 10% / .72));
  backdrop-filter: blur(20px);
  border: 1px solid hsl(262 36% 44% / .13);
  border-radius: var(--r);
  padding: 24px 32px;
  display: flex; align-items: flex-start; gap: 14px;
  position: relative; overflow: hidden;
}
.quote-banner::before {
  content: ''; position: absolute; top: 0; left: 0; right: 0; height: 1.5px;
  background: var(--gp); opacity: .4;
}
```

---

# 8. SALES BIBLE CONTENT — ALL 9 STAGES

## Content Sources
- **Notion markdown files** (`AerChain-Sales-Bible-Notion-Package.zip`) — cleaner Stage 1-3 structure
- **HTML v2** (`aerchain_sales_bible_v2.html`) — richer Stage 4 and Stage 7 content
- **IMPORTANT**: Merge the best of both. HTML v2 has more detail in Stage 4 (9 savings levers, dual ROI profile, RACI matrix) and Stage 7 (7A-7F sub-stages). Notion has better Stage 1-3 flow.

## Stage Pipeline (9 stages with half-stages)

### Stage 0 — Lead Generation & Foundational Collaterals
- Industry vertical targeting (Manufacturing, FMCG, Retail, Pharma, Infra)
- ICP definition: $500M+ revenue, 5000+ SKUs, 500+ vendors, multi-site ops
- Channel strategy: Inbound (content, SEO, events), Outbound (targeted campaigns), Partnerships
- Lead scoring criteria

### Stage 0.5 — Pre-Discovery Call
- Share discovery call agenda (1-pager) in meeting invite
- Generate L1 Business Case (industry-specific) as pre-read
- Research: company 10-K, procurement org chart, tech stack, recent news

### Stage 1 — Discovery Call + L1 Business Case
- Business Case Presentation + Sales Deck + Demo Highlights
- L1 Discovery Questions + Navigation Help for Discovery Workshop
- Origin story script (3-min repeatable, two registers: CPO-level, VP-level)
- Platform overview deck (5 pillars + 5 agents + 9 pathways)
- Exit gate: Identified pain points, budget authority, timeline, next-step commitment

### Stage 1.5 — Post-Discovery
- Competitive positioning 1-pager (vs. Ariba, Coupa, point solutions)
- Security/tech/compliance fact sheet (SOC2 Type II, ISO27001, GDPR)
- AI guardrails documentation, network/tech infra map

### Stage 2 — Deep Dive Demo
- Industry-specific demo flow with Demo Builder + standard demo deck
- 10-15 step "wow plus plus" experience
- Recap + Next steps alignment — dictate/influence timeline, climb decision tree

### Stage 2.5 — Post-Demo
- Demo video recordings (async sharing) + demo deck
- Avoma mandate + mail template
- Workshop agenda (1/2 day plan with timings)
- Prepare deck & questionnaire aligned to customer-specific use cases

### Stage 3 — Discovery Workshop
- Conduct Discovery Workshop (onsite/virtual)
- Current state process maps (swimlane diagrams, bottleneck analysis)
- Value stream map (current vs. AerChain future state)
- 3 measurable outcomes document (SIGNED by both parties)

### Stage 3.5 — Post-Workshop
- Custom demo flow checklist (industry-specific scenarios)
- Collect & upload spend data into L3 business case builder
- Data quality report (auto-generated)
- L2/L3 business case (30-40 pages: financial model, ROI, sensitivities)

### Stage 4 — Customized Live Demo / POC
- Conduct customized demo on specific use cases
- Guided/Self POC based on client needs (only if required)
- 9 savings levers (from HTML v2): Price benchmarking, demand consolidation, supplier rationalization, contract compliance, process automation, maverick spend reduction, early payment optimization, tail spend management, category strategy optimization
- Dual ROI profile: Conservative (12-18 months payback) and Aggressive (8-12 months)
- RACI matrix for demo/POC delivery

### Stage 5 — Technical Validation (implied, between 4 and 6)
- Integration validation with client tech stack
- Security review deep dive
- Performance benchmarking

### Stage 6 — Post-Demo Closing Motion (LARGEST STAGE — 10 collateral items)
- Pricing overview (1-pager, high-level) + Credit Model
- Champion enablement kit (internal business case deck + talking points)
- ROI summary one-pager (for CFO)
- Technical architecture brief one-pager (for CIO)
- Executive brief (for CEO/board)
- 'Why Now' arguments document (FOMO)
- Internal objection handler (top 10)
- Multi-stakeholder positioning matrix (Current Problems + Aerchain Solutions + Value for Persona + Future State)
- Security questionnaire responses (pre-filled)
- Reference call scripts and prep materials

### Stage 7 — Proposal, Negotiation & Contract
- 7A: Commercial proposal (15-25 pages)
- 7B: Governance charter + RACI Matrix
- 7C: Scope lock document (signed) — inclusions, exclusions, client responsibilities
- 7D: Wave-based rollout plan (Wave 1/2/3 timeline, categories, dependencies)
- 7E: Implementation plan overview (16-week, 4-phase, resources, milestones)
- 7F: Change management plan
- Legal documents: MSA, DPA, SLA, SOW, Pricing schedule, Change request order form template

### Stage 8 — Implementation Handover
- Handover package containing:
  1. Business Case (L2/L3)
  2. Proposal with Sections
  3. Client Stakeholder Map (Relationship Handover)
  4. Upsell opportunities
  5. Risk register & Mitigation Plans
- Joint kickoff deck

## 4 Value Pillars (from Notion Home page)
1. **Spend Intelligence** — AI-powered spend analytics, classification, benchmarking
2. **Process Automation** — End-to-end P2P workflow automation
3. **Supplier Excellence** — Supplier lifecycle management, performance, risk
4. **Strategic Sourcing** — Category management, negotiations, contracts

---

# 9. COLLATERAL TRACKER — 38 ITEMS WITH OWNERS

Parsed from `Sales Bible Aerchain Collateral Tracker.xlsx` — the Dubai session consolidation. Original 85+ items reduced to this list.

## Ownership Summary
| Owner | Items | Percentage |
|---|---|---|
| Gaurav Guha | 17 | 44.7% |
| Harsha Kadimisetty | 7 | 18.4% |
| Abhishek Kumar | 4 | 10.5% |
| Animesh Bajpai | 3 | 7.9% |
| Himavanth Jasti | 1 | 2.6% |
| Gaurav Guha + Abhishek Kumar (shared) | 1 | 2.6% |
| Ashish Patil Balu | 1 | 2.6% |
| Unassigned | 4 | 10.5% |
| **TOTAL** | **38** | **100%** |

## Full Tracker Data

### Stage 0 — Foundational Collaterals (6 items, no numbering)

| # | Step | Owner | Remarks |
|---|---|---|---|
| — | 'Spend Operating System' whitepaper | Animesh Bajpai | — |
| — | Co-branded partner solution briefs | Animesh Bajpai | — |
| — | Q&A repository (20+ common questions) | Gaurav Guha | BattleCards + Common Q&A Repo from all meetings — standard FAQs and standard Objection Handling — discovery, demo, pricing, segments etc. |
| — | Printed Brochures | Animesh Bajpai | — |
| — | Customer case studies (Cars24, WeWork, ABInBev, Danone) | Himavanth Jasti | — |
| — | Integration Overview Doc (validated) | Harsha Kadimisetty | — |

### Stage 0.5 — Pre-Discovery Call (2 items)

| # | Step | Owner | Remarks |
|---|---|---|---|
| 1 | Share Discovery call agenda (1-pager) in the meeting Invite | Gaurav Guha | — |
| 2 | Generate L1 Business Case (industry-specific) & send as pre-read to the client | Abhishek Kumar | Print Friendly Version |

### Stage 1 — Discovery Call + L1 Business Case (1 item)

| # | Step | Owner | Remarks |
|---|---|---|---|
| 3 | Business Case Presentation, Sales Deck & Demo Highlights & L1 Discovery Questions & Navigation Help for Discovery Workshop | Gaurav Guha | Origin story script (3-min repeatable, two registers); Business Case Presentation; Platform overview deck (5 pillars + 5 agents + 9 pathways); Next-step proposal (workshop date template); (presentation version vs sharing version) |

### Stage 1.5 — Discovery Call + L1 Business Case (2 items)

| # | Step | Owner | Remarks |
|---|---|---|---|
| 4 | Sharing Competitive positioning 1-pager (vs. Ariba, Coupa, point solutions) | Gaurav Guha | — |
| 5 | Sharing Security/tech/compliance fact sheet (SOC2 Type II, ISO27001, GDPR) | Gaurav Guha | AI guardrails, network/tech infra map, SOC, etc. |

### Stage 2 — Deep Dive Demo (2 items)

| # | Step | Owner | Remarks |
|---|---|---|---|
| 6 | Present Industry-specific demo flow with demo builder + standard demo deck (wow plus plus — 10-15 steps) | Gaurav Guha | Standard demo with Demo Builder |
| 7 | Recap + Next steps alignment — Dictate/Influence timeline, do not leave it to customers + climb decision tree | Unassigned | — |

### Stage 2.5 — Deep Dive Demo / Workshop + L2/L3 Business Case (3 items)

| # | Step | Owner | Remarks |
|---|---|---|---|
| 8 | Share Demo video recordings (async sharing) along with the demo deck | Gaurav Guha | Avoma Mandate + Mail Template |
| 9 | Share the Workshop agenda (1/2 day plan with timings) | Harsha Kadimisetty | — |
| 10 | Prepare for the Discovery workshop, by aligning the deck & the questionnaire to the customer specific use cases | Unassigned | — |

### Stage 3 — Workshop + L2/L3 Business Case (1 item)

| # | Step | Owner | Remarks |
|---|---|---|---|
| 11 | Conduct a Discovery Workshop Onsite / Virtual | Harsha Kadimisetty | — |

### Stage 3.5 — Workshop + L2/L3 Business Case (5 items)

| # | Step | Owner | Remarks |
|---|---|---|---|
| 12 | Current state process maps (swimlane diagrams, bottleneck analysis) + Value stream map (current vs. AerChain future state) + 3 measurable outcomes document (SIGNED by both parties) | Harsha Kadimisetty | — |
| 13 | Prepare the demo instructions of Categories, Flows etc. (industry-specific scenarios) to be included in the Customised Live Demo / POC | Harsha Kadimisetty | Custom Demo Flow Checklist |
| 14 | Collect & Upload the Spend data into the L3 business case builder | Abhishek Kumar | — |
| 15 | Data quality report (auto-generated) | Abhishek Kumar | — |
| 16 | Use-case specific business case (draft L2/L3) — 30-40 pages, financial model, ROI, sensitivities + Business Case Pitch | Gaurav Guha + Abhishek Kumar | — |

### Stage 4 — Customized Live Demo / POC (2 items)

| # | Step | Owner | Remarks |
|---|---|---|---|
| 17 | Conduct a Customized demo on the Use Cases | Unassigned | — |
| 18 | Conduct a Guided / Self POC based on the client needs (only if required) | Unassigned | — |

### Stage 6 — Post-Demo Closing Motion (10 items)

| # | Step | Owner | Remarks |
|---|---|---|---|
| 19 | Pricing overview (1-pager, high-level) + Credit Model | Harsha Kadimisetty | Pricing Calculator |
| 20 | Champion enablement kit (internal business case deck + talking points) | Gaurav Guha | — |
| 21 | ROI summary one-pager (for CFO) | Gaurav Guha | Budget justification template (for client's internal use) |
| 22 | Technical architecture brief one-pager (for CIO) | Gaurav Guha | — |
| 23 | Executive brief (for CEO/board) | Gaurav Guha | — |
| 24 | 'Why Now' arguments document | Gaurav Guha | FOMO |
| 25 | Internal objection handler (top 10) | Gaurav Guha | — |
| 26 | Multi-stakeholder positioning matrix | Gaurav Guha | Current Problems + Aerchain Solutions + Value for Persona + Future State |
| 27 | Security questionnaire responses (pre-filled) | Abhishek Kumar | — |
| 28 | Reference call scripts and prep materials | Harsha Kadimisetty | — |

### Stage 7 — Proposal, Negotiation & Contract (2 items)

| # | Step | Owner | Remarks |
|---|---|---|---|
| 29 | Commercial proposal (15-25 pages), Governance charter, RACI Matrix, Scope lock document (signed) — inclusions, exclusions, client responsibilities | Gaurav Guha | Wave-based rollout plan (Wave 1/2/3 timeline, categories, dependencies); Implementation plan overview (16-week, 4-phase, resources, milestones); Change management plan |
| 30 | Master service agreement (MSA) | Gaurav Guha | DPA, SLA, SOW, Pricing schedule, Change request order form template |

### Stage 8 — Implementation Handover (2 items)

| # | Step | Owner | Remarks |
|---|---|---|---|
| 31 | Handover package (complete documentation bundle) | Gaurav Guha | 1. Business Case (L2/L3), 2. Proposal with Sections, 3. Client Stakeholder Map (Relationship Handover), 4. Upsell opportunities, 5. Risk register & Mitigation Plans |
| 32 | Joint kickoff deck | Ashish Patil Balu | — |

## Status Assignment (to be built into the tracker UI)
Status must be determined per-item. Use three states:
- 🟢 **Built** — Artifact exists and is linked
- 🟡 **In Progress** — Being actively worked on
- 🔴 **Not Started** — No artifact exists yet

Known "Built" items (based on existing artifacts):
- Q&A repository / Battlecards → `aerchain-battlecard-hub.html` (SAP Ariba complete)
- Security/tech compliance fact sheet → `Aerchain_IronMountain_TechSecurity_v4.html` (template exists)
- Technical architecture brief → `jnj_s2c_architecture_v2.html` (template exists)
- Demo deck → `jnj_demo_presentation.html` (template exists)
- P2P value stream visualization → `aerchain_p2p_final.html` (exists)

---

# 10. V5 PRINCIPLES ALIGNMENT

Source: `Aerchain_V5_Principles_280226.docx` (written by CEO Harsha, February 2026)

## The V5 Transformation Story

### V1-V4 History (what went wrong)
- V1-V4 were "platform" architecture — infinitely configurable
- This caused: 50% of all bugs from configuration errors, 16-week implementation cycles, customer confusion about what they were buying, sales team selling "anything is possible" instead of specific value
- Cascading consequences: long onboarding, high support costs, customer churn from unmet expectations

### V5 Core Principles (what changed)

1. **Product-First, Not Platform** — Aerchain is a product with predefined workflows, not a configurable platform. Customers buy modules that work out of the box.

2. **Predefined Everything** — Field dictionary, workflow sequences, approval matrices, report templates — all predefined. No "configure from scratch."

3. **Day-One Value** — Replaces the 16-week implementation cycle. Customers see value on day one through pre-configured industry templates and AI-driven setup.

4. **Microservices Architecture** — Each module is an independent microservice. Buy what you need. Scale independently.

5. **TDD (Test-Driven Development)** — Every feature starts with tests. Zero tolerance for regression.

6. **AI-First Development** — AI is not a feature — it's the foundation. Every workflow has AI augmentation.

7. **Value Engineering Pods** — Replaces siloed handoffs between sales → pre-sales → implementation. Cross-functional pods own the entire customer journey.

8. **Agentic Future of Procurement** — Section 8 of V5 describes the vision: AI agents that autonomously handle procurement tasks (PO creation, supplier communication, spend analysis, contract review).

### What This Means for the Sales Bible
- **Language shift**: Don't say "platform" → say "product suite" or "modules"
- **Don't sell configurability** → sell "works out of the box with industry best practices"
- **Value engineering workshops** replace generic demos
- **Day-one value** is the key differentiator vs. SAP Ariba's 6-12 month implementations
- **Sales Bible Section 6.3 and Section 11** explicitly called out in V5 doc as follow-up deliverables
- **Prescriptive, not configurable** — this changes the entire demo narrative

---

# 11. COMPETITIVE INTELLIGENCE / BATTLECARDS

Source: `aerchain-battlecard-hub.html` (620+ lines)

## SAP Ariba Battlecard (COMPLETE)

### AI Reality Check (Side-by-Side)
| Dimension | SAP Ariba Claims | Aerchain Reality |
|---|---|---|
| AI Engine | "AI-powered recommendations" | Purpose-built procurement AI with real-time spend intelligence |
| Implementation | 6-12 months typical | Day-one value, 4-week full deployment |
| Customization | Requires extensive consulting | Pre-configured industry templates |
| Integration | Complex middleware required | Native API-first architecture |

### SAP Ariba Strengths (acknowledge honestly)
- Massive install base (5M+ organizations in network)
- Deep SAP ERP integration
- Extensive supplier network effects
- Brand recognition with C-suite

### SAP Ariba Weaknesses (exploit)
- Painfully slow implementation (6-12 months minimum)
- Requires expensive SI partners for configuration
- Legacy architecture — AI bolted on, not native
- Poor UX — users need extensive training
- Rigid workflow engine — hard to customize post-implementation
- Pricing opacity — costs escalate unpredictably

### FUD Seeding Toolkit (6 Discovery Questions)
1. "How long did your SAP Ariba implementation take, and what was the actual vs. planned timeline?"
2. "What percentage of your procurement workflows are actually automated end-to-end in Ariba?"
3. "How many SI consultants are currently engaged for ongoing Ariba configuration?"
4. "When was the last time Ariba proactively identified a savings opportunity you weren't already tracking?"
5. "How does your team feel about the Ariba user experience — what's adoption looking like?"
6. "What's your total cost of ownership including licenses, SI fees, and internal team time?"

### Objection Handling (4 Expandable)
1. **"We already have Ariba"** → "That's exactly why the conversation is relevant. Most of our best customers came FROM Ariba..."
2. **"Ariba has a bigger network"** → "Network size ≠ network value. Our AI identifies savings in YOUR specific spend..."
3. **"Our IT standardized on SAP"** → "Aerchain's API-first architecture means we complement your SAP investment..."
4. **"Switching costs are too high"** → "What's the cost of NOT switching? Let's calculate your Ariba TCO vs. Aerchain..."

### Win Stories
- **NSE (National Stock Exchange)**: $147K ARR — Replaced manual procurement, 60% process time reduction
- **ABInBev**: $203K ARR — Spend visibility across 40+ categories, 12% direct material savings
- **Diageo**: $102K ARR — Supplier consolidation, 23% reduction in supplier base
- **Arvind Ltd**: $35K ARR — Tail spend management, 18% savings on indirect
- **Relaxo**: $27K ARR — First P2P automation, 45% cycle time reduction

### Persona Targeting
- **CPO/VP Procurement**: Lead with strategic value — "From cost center to value center"
- **CIO/CTO**: Lead with architecture — "API-first, AI-native, no middleware"
- **CFO**: Lead with ROI — "Measurable savings within 90 days"
- **CEO**: Lead with transformation — "Day-one value, not 16-week projects"

## Stubbed Competitors (6 — badges show "Soon")
1. **Coupa** — Coming soon
2. **Zycus** — Coming soon
3. **GEP SMART** — Coming soon
4. **Jaggaer** — Coming soon
5. **Procol** — Coming soon
6. **Ivalua** — Coming soon

---

# 12. PRICING FRAMEWORK

Source: Notion page `Aerchain Proposed Pricing Structure` (page 30201f61)

## Pricing Philosophy
- **Module-based**: Customers buy specific modules (Sourcing, Contracts, P2P, Spend Analytics, etc.)
- **User Role Tiers**: Power Users, Lite Users, Admin Users — different price points
- **Workflow Credits**: Consumption-based model for AI-driven workflows (spend analysis runs, supplier assessments, contract reviews)
- **No platform fee**: You pay for what you use

## Commercial Framework Examples
- **India Mid-Market**: ₹60-75L Year 1 (approximately $70-90K)
- **US/EU Enterprise**: $350-420K Year 1

## Pricing Structure Components
1. Module licenses (annual)
2. User license tiers (Power/Lite/Admin)
3. Workflow credit packs (consumption-based, AI operations)
4. Implementation services (but V5 = day-one value, so this is minimal)
5. Optional: Managed services / Value Engineering Pod engagement

## Key Pricing Collateral
- Pricing overview 1-pager (high-level) — Stage 6 deliverable
- Pricing Calculator (SalesOS module — to be built)
- Credit consumption model documentation

---

# 13. 10 COMMANDMENTS & P0/P1/P2 GUARDRAILS

Source: Notion files `The-10-Commandments.md` and `P0-P1-P2-Guardrails.md`

## The 10 Commandments of Aerchain Sales
1. **Thou shalt not sell the platform** — Sell specific modules that solve specific problems
2. **Thou shalt lead with value, not features** — Always start with the business outcome
3. **Thou shalt own the timeline** — Dictate next steps; never leave scheduling to the prospect
4. **Thou shalt multi-thread** — Always have 3+ contacts in every deal; never single-threaded
5. **Thou shalt quantify everything** — Every claim must have a number behind it
6. **Thou shalt never demo without discovery** — Discovery first, always
7. **Thou shalt create urgency** — Every deal needs a "Why Now" argument
8. **Thou shalt document obsessively** — Every meeting, every commitment, every risk — in writing
9. **Thou shalt know the competition** — Cold, hard, factual competitive intelligence
10. **Thou shalt protect pricing integrity** — Never discount without getting something in return

## P0/P1/P2 Guardrails

### 🟢 P0 — GREEN (Sell with confidence)
Modules and capabilities that are production-ready, well-tested, and have proven customer success stories. Lead with these.

### 🟡 P1 — YELLOW (Mention, but manage expectations)
Features that exist but may need customization, or are in advanced development. OK to reference in demos and proposals, but set clear timeline expectations.

### 🔴 P2 — RED (Do NOT sell)
Capabilities that are on the roadmap but not yet built. Features that require significant development. Anything that would create implementation risk. **Never promise what doesn't exist.**

---

# 14. SALESOS INTEGRATION

Source: `aerchain-salesos-context.md`

## Tech Stack
- **Frontend**: React 18.3.1 + Vite 6.0.5
- **Backend**: Supabase (PostgreSQL + pgvector for RAG)
- **AI**: Anthropic API (Claude)
- **Hosting**: GitHub Pages
- **Design System**: Dark Canvas v13 (FROZEN) — same tokens as Master App dark theme

## Current Modules (dummy UI exists)
1. **Pricing Calculator** — UI shell built, needs real pricing logic
2. **Proposal Generator** — UI shell built, needs AI integration

## Future Modules (11 total planned)
1. Pricing Calculator
2. Proposal Generator
3. Deal Analyzer
4. Competitor Battlecard Engine
5. ROI Calculator
6. Discovery Question Bank
7. Stakeholder Mapper
8. Win/Loss Analyzer
9. Territory Planner
10. Training & Certification Hub
11. **Sales Bible** (Module #11 — the v3.0 itself, or an embedded version)

## Supabase Schema
- `modules` — Module registry
- `module_data` — Module-specific data storage
- `documents` — Document store
- `doc_chunks` — Vector chunks for RAG
- `sync_log` — Sync audit trail
- `notion_backups` — Notion page backup snapshots

## Integration Points for Sales Bible v3.0
- The Sales Bible can link out to SalesOS modules (Pricing Calculator, Proposal Generator) via GitHub Pages URLs
- Alternatively, embed lightweight previews/mockups of these modules within the Sales Bible HTML
- The Sales Bible itself could become Module #11 in SalesOS

---

# 15. EXISTING ARTIFACTS GALLERY

These are real, built HTML artifacts that should be showcased/linked in the Sales Bible's Artifact Gallery section.

| Artifact | File | Lines | Maps To | Theme |
|---|---|---|---|---|
| Competitive Battlecard Hub | `aerchain-battlecard-hub.html` | 620+ | Stage 1.5 competitive positioning | Light (Inter font, purple gradient) |
| Iron Mountain IT/Security Brief | `Aerchain_IronMountain_TechSecurity_v4.html` | 795 | Stage 6C IT/Security collateral | Dark |
| J&J S2C Architecture | `jnj_s2c_architecture_v2.html` | 424 | Stage 5/6 CIO architecture doc | Dark |
| J&J Demo Presentation | `jnj_demo_presentation.html` | 891 | Stage 2 demo deck | Dark |
| P2P Flow Visualization | `aerchain_p2p_final.html` | 490 | Stage 3 value stream | Dark |
| Architecture Diagram (Light) | `arch_light_v3.html` | 684 | General architecture reference | Light |
| GKG Master App (Command Center) | `GKG-Master-App-Unified-2026-03-24.html` | 2624 | Design system reference | Dark/Purple/Light |
| Zero Hour Keynote | `Aerchain_Zero_Hour_-_Keynote_Presentation (1).html` | 3074 | Internal innovation day deck | Dark + 8 color palettes |
| Sales Bible v2 (Harsha's) | `aerchain_sales_bible_v2.html` | 3998 | The baseline to beat | Custom dark |
| GKG Aerchain Brain | `GKG Aerchain Brain.html` | — | Company intelligence reference | — |

---

# 16. ARCHITECTURAL DECISIONS LOG

These decisions were made explicitly in conversation and are LOCKED.

| Decision | Choice | Rationale | Date |
|---|---|---|---|
| Output format | Single self-contained HTML file | Matches all of Gaurav's existing artifact pattern; portable; no build tools needed | Mar 24, 2026 |
| Dark theme reference | Zero Hour Keynote HTML | Has the color palette toggle system Gaurav wants; richer dark canvas | Mar 24, 2026 |
| Light theme reference | Master App `html.light` class | Clean lavender frosted glass aesthetic; already proven | Mar 24, 2026 |
| Theme system | 2 modes (Dark + Light), NOT 3 | Explicitly dropped Purple Marble middle theme per Gaurav's instruction | Mar 24, 2026 |
| Dark mode color sub-palettes | Yes — 8 options via data-theme dots | From Zero Hour: purple-glass, deep-ocean, rose-quartz, midnight-emerald, arctic, topaz, citrine, slate | Mar 24, 2026 |
| Light mode sub-palettes | None — single light variant | Gaurav's explicit instruction | Mar 24, 2026 |
| Logo | Actual Aerchain base64 SVG — no placeholders | Extracted from Master App line 830 (11,010 chars) | Mar 24, 2026 |
| Typography | Montserrat + JetBrains Mono, weight ceiling 600 | From Master App frozen design system | Mar 24, 2026 |
| Layout | Full-width scrollable (like Zero Hour), NOT 3-column grid | Sales Bible is content-rich; needs reading flow, not dashboard layout | Mar 24, 2026 |
| Collateral tracker source | Dubai Excel (38 items, consolidated from 85+) | Harsha and Gaurav jointly decided in Dubai | Mar 24, 2026 |
| Content merge strategy | Best of Notion (Stage 1-3) + best of HTML v2 (Stage 4, 7) | Content drift identified between sources | Mar 24, 2026 |
| V5 language alignment | Required — update all V4-era language | "Product" not "platform"; "day-one value" not "16-week implementation" | Mar 24, 2026 |
| `#DC5F40` Aerchain orange | Reserved for icon mark ONLY — never for text or backgrounds | Design system rule from Master App | Mar 24, 2026 |
| Build trigger | Must wait for "Geronimo" | Gaurav's explicit rule — no code generation until go-word | Mar 24, 2026 |

---

# 17. KEY PERSONNEL & OWNERSHIP

## Aerchain Team (relevant to Sales Bible)

| Person | Role | Sales Bible Responsibility | Items Owned |
|---|---|---|---|
| **Gaurav Krishna Guha** | Head of Sales | Builder, primary owner, v3.0 architect | 17 collateral items (44.7%) |
| **Harsha Kadimisetty** | CEO | Created v2 baseline (PDF + HTML + Notion), co-architect | 7 collateral items (18.4%) |
| **Abhishek Kumar** | Pre-Sales / Solutions | Business case builder, data analysis | 4 collateral items (10.5%) |
| **Animesh Bajpai** | Marketing | Whitepapers, brochures, partner briefs | 3 collateral items (7.9%) |
| **Himavanth Jasti** | Customer Success | Case studies | 1 collateral item (2.6%) |
| **Ashish Patil Balu** | Implementation | Joint kickoff deck | 1 collateral item (2.6%) |

---

# 18. CONTENT SOURCES & DRIFT NOTES

## Source Priority (when content conflicts)
1. **V5 Principles** (`Aerchain_V5_Principles_280226.docx`) — HIGHEST priority, overrides everything for language/philosophy
2. **Dubai Excel Tracker** (`Sales Bible Aerchain Collateral Tracker.xlsx`) — Definitive list of what to build
3. **Notion Markdown** (`AerChain-Sales-Bible-Notion-Package.zip`) — Best Stage 1-3 content structure
4. **HTML v2** (`aerchain_sales_bible_v2.html`) — Best Stage 4 and Stage 7 detailed content
5. **Battlecard Hub** (`aerchain-battlecard-hub.html`) — Competitive intelligence content as-is
6. **Notion MCP pages** — Pricing structure, marketing collateral list

## Known Content Drift
- **HTML v2 Stage 4** has 9 detailed savings levers that Notion doesn't have → USE HTML v2 VERSION
- **HTML v2 Stage 7** has 7A-7F sub-stages with granular detail → USE HTML v2 VERSION
- **Notion Stage 1-3** has cleaner structure with explicit exit gates → USE NOTION VERSION
- **V5 language conflicts**: Any mention of "platform", "configurable", "customizable" in old content must be updated to V5 language ("product", "predefined", "prescriptive", "day-one value")

## Files NOT Yet Fully Read (may contain additional context)
- `Aerchain_Zero_Hour_-_Keynote_Presentation (1).html` — Read structure/CSS but not all body content. Contains 4 chapters: SalesOS, AerOps, Product Consulting, Engineering. May have reusable content or framing for the Sales Bible.
- `GKG Aerchain Brain.html` — Notion export with Company Profile, Product & Tech, V5 Evolution, AI Architecture, Security, Customer Portfolio, Pipeline, Competitive Intelligence, GTM Strategy, Team & Org, Events, Awards. Rich reference but dense.

---

# 19. BUILD SPECIFICATION

## File: `AerChain-Sales-Bible-v3.html`

### Structure (proposed section order)

```
1. HERO SECTION
   - Aerchain logo
   - "AerChain Sales Bible v3.0"
   - "Interactive Command Center"
   - Pipeline visualization (Stage 0→8 horizontal flow, inspired by Harsha's PDF flowchart)
   - Key stats: X stages, Y collateral items, Z% built

2. NAVIGATION
   - Fixed top bar with section links
   - Dark/Light toggle (sun/moon icon)
   - Color palette bar (dark mode only, 8 dots)
   - Aerchain logo left-aligned

3. DASHBOARD
   - Ownership pie chart or breakdown
   - Build status summary (built/in-progress/not-started counts)
   - Stage progression overview

4. STAGE-BY-STAGE PLAYBOOK
   - Accordion or tabbed interface for each stage (0, 0.5, 1, 1.5, 2, 2.5, 3, 3.5, 4, 6, 7, 8)
   - Each stage shows: objectives, activities, deliverables, exit gates, collateral items
   - V5-aligned language throughout

5. COLLATERAL TRACKER
   - Filterable table/grid of all 38 items
   - Columns: #, Stage, Item, Owner, Status (🟢🟡🔴), Remarks, Link
   - Filter by: stage, owner, status
   - Summary stats at top

6. COMPETITIVE INTELLIGENCE HUB
   - SAP Ariba battlecard (full, from battlecard hub)
   - 6 competitor stubs with "Coming Soon" badges
   - FUD toolkit, objection handling, win stories

7. PRICING FRAMEWORK
   - Module-based pricing overview
   - User role tiers explanation
   - Workflow credits model
   - Example deal math (India mid-market, US/EU enterprise)

8. V5 PRINCIPLES
   - The transformation story (V1-V4 → V5)
   - 8 core principles with visual cards
   - What this means for sales messaging

9. 10 COMMANDMENTS
   - Visual list with icons
   - Each commandment expandable with context

10. P0/P1/P2 GUARDRAILS
    - Traffic light classification
    - Module-by-module classification

11. ARTIFACT GALLERY
    - Grid of existing HTML artifacts with preview thumbnails/descriptions
    - Links to open them
    - Build status indicators

12. SALESOS MODULES
    - Pricing Calculator preview/link
    - Proposal Generator preview/link
    - Future modules roadmap

13. OWNERSHIP DASHBOARD
    - Per-person breakdown
    - Items assigned vs. completed
    - Stage coverage visualization
```

### Technical Requirements
- Single HTML file, all CSS/JS inline
- No external dependencies except Google Fonts CDN
- Must work in any modern browser
- Responsive down to tablet (1024px minimum)
- localStorage for theme persistence
- Smooth scroll between sections
- Print-friendly mode (optional, nice-to-have)

### Performance Targets
- File size: aim for under 500KB (excluding base64 logo)
- First paint: instant (no framework, no build step)
- Smooth 60fps scrolling
- All animations via CSS (no JS animation loops)

---

# APPENDIX A: ZERO HOUR KEYNOTE SECTIONS (for content inspiration)

The Zero Hour Keynote (`Aerchain_Zero_Hour_-_Keynote_Presentation (1).html`) is an internal innovation day deck with 4 chapters:

1. **SalesOS — AI-First Sales Operating System**
   - System Architecture
   - Before and After
   - SalesOS in Action
   - Contains design system reference material

2. **AerOps — Governance from Reactive to Proactive**
   - The System
   - Turning Governance & Info-Access from Reactive to Proactive
   - Value unlock from AI-first Delivery

3. **AI-first Product Consulting Engine**
   - Product Consulting Engine: AI Architecture
   - Value unlock from AI-first Consulting
   - 30+ AI use cases across 5 themes

4. **How I Adapted AI — A Playbook for the Team**
   - The Mindset Shift
   - The 5 Practices That Made It Work
   - What Changed for Me
   - What Every Team Member Can Start Today
   - Where We're Headed

This deck uses `data-theme` color switching with 8 palettes — same system we're adopting for the Sales Bible dark mode.

---

# APPENDIX B: NOTION MARKETING COLLATERAL LIST

From Notion page "🎯 List of Marketing Collaterals Required" (page 2b101f61):
- 6 priority tiers of marketing collateral
- Covers: website assets, case studies, whitepapers, videos, social proof, event materials
- This is the broader marketing universe; the Sales Bible tracker (38 items) is the sales-specific subset

---

# APPENDIX C: FILE REFERENCE

All uploaded files in this session:

| File | Type | Lines/Size | Status |
|---|---|---|---|
| `GKG-Master-App-Unified-2026-03-24.html` | HTML | 2624 | Fully parsed — light theme source |
| `Aerchain_Zero_Hour_-_Keynote_Presentation (1).html` | HTML | 3074 | Parsed CSS/structure — dark theme source |
| `aerchain_sales_bible_v2.html` | HTML | 3998 | Read — baseline to beat |
| `Sales Bible_V2.pdf` | PDF | — | Read — Harsha's flowchart |
| `AerChain-Sales-Bible-Notion-Package.zip` | ZIP | 14 .md files | Extracted and read |
| `aerchain-battlecard-hub.html` | HTML | 620+ | Read — competitive intelligence |
| `aerchain-salesos-context.md` | Markdown | — | Read — SalesOS tech context |
| `Claude SalesOS Coding History copy.md` | Markdown | — | Read — dev history |
| `GKG-Master-App-Unified-v2.1-RFPBrain (2).html` | HTML | 2343 | Read — earlier Master App version |
| `GKG-Master-App-Unified-2026-03-1233.html` | HTML | 2624 | Read — earlier Master App version |
| `Aerchain_IronMountain_TechSecurity_v4.html` | HTML | 795 | Read — Stage 6C template |
| `jnj_s2c_architecture_v2 (3).html` | HTML | 424 | Read — CIO architecture doc |
| `jnj_demo_presentation (3).html` | HTML | 891 | Read — demo deck template |
| `aerchain_p2p_final.html` | HTML | 490 | Read — P2P flow viz |
| `arch_light_v3.html` | HTML | 684 | Read — light theme architecture |
| `Aerchain_V5_Principles_280226.docx` | DOCX | — | Extracted via python-docx — V5 principles |
| `GKG Aerchain Brain.html` | HTML | — | Referenced — company intelligence |
| `Sales Bible Aerchain Collateral Tracker.xlsx` | XLSX | 38 rows | Fully parsed with pandas |

---

# END OF CONTEXT TRANSFER DOCUMENT

**This document contains everything needed to build AerChain Sales Bible v3.0 in any Claude session — Claude Code, Claude Chat, or Cowork — with full fidelity.**

**The logo base64 string (11,010 chars) is in a separate file: `aerchain-logo-base64.txt`**

**Awaiting "Geronimo" to begin build.**
