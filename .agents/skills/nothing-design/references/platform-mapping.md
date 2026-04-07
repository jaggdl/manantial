# Nothing Design System — Platform Mapping

## 1. HTML / CSS / WEB

Load fonts via Google Fonts `<link>` or `@import`. Use CSS custom properties, `rem` for type, `px` for spacing/borders. Dark/light via `prefers-color-scheme` or class toggle.

```css
:root {
  --black: #000000;
  --surface: #111111;
  --surface-raised: #1A1A1A;
  --border: #222222;
  --border-visible: #333333;
  --text-disabled: #666666;
  --text-secondary: #999999;
  --text-primary: #E8E8E8;
  --text-display: #FFFFFF;
  --accent: #D71921;
  --accent-subtle: rgba(215,25,33,0.15);
  --success: #4A9E5C;
  --warning: #D4A843;
  --interactive: #5B9BF6;
  --space-xs: 4px;
  --space-sm: 8px;
  --space-md: 16px;
  --space-lg: 24px;
  --space-xl: 32px;
  --space-2xl: 48px;
  --space-3xl: 64px;
  --space-4xl: 96px;
}
```

---

## 2. RAILS 8 + TAILWIND CSS v4

Override Tailwind's default tokens with Nothing's values. This lets you use standard classes (`bg-black`, `text-white`, `border-zinc-800`) that render with Nothing's exact palette.

### Setup

**1. Load Fonts in `app/views/layouts/application.html.erb`:**

```erb
<head>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Doto:wght@400..700&family=Space+Grotesk:wght@300..700&family=Space+Mono:wght@400;700&display=swap" rel="stylesheet">
  <%= stylesheet_link_tag "application", "data-turbo-track": "reload" %>
</head>
```

**2. Configure in `app/assets/stylesheets/application.css`:**

```css
@import "tailwindcss";

@theme {
  /* Fonts — override Tailwind defaults with Nothing typefaces */
  --font-sans: "Space Grotesk", system-ui, sans-serif;
  --font-mono: "Space Mono", "JetBrains Mono", monospace;
  --font-display: "Doto", monospace;

  /* Colors — override Tailwind defaults with Nothing values */
  /* Dark mode palette (default) */
  --color-black: #000000;      /* Page background */
  --color-zinc-950: #111111;   /* Card surfaces */
  --color-zinc-900: #1A1A1A;   /* Raised surfaces */
  --color-zinc-800: #222222;   /* Borders */
  --color-zinc-700: #333333;   /* Visible borders */
  --color-zinc-600: #666666;   /* Disabled/muted */
  --color-zinc-500: #999999;   /* Secondary text */
  --color-zinc-200: #E8E8E8;   /* Primary text */
  --color-white: #FFFFFF;      /* Display text, inverted buttons */

  /* Semantic colors */
  --color-red-600: #D71921;    /* Accent, errors */
  --color-green-600: #4A9E5C;  /* Success */
  --color-amber-500: #D4A843;  /* Warning */
  --color-blue-500: #5B9BF6;   /* Interactive (dark) */
}

/* Dark mode (default) */
:root {
  color-scheme: dark;
}

/* Light mode — toggle via .light class */
.light {
  color-scheme: light;
  --color-black: #F5F5F5;
  --color-zinc-950: #FFFFFF;
  --color-zinc-900: #F0F0F0;
  --color-zinc-800: #E8E8E8;
  --color-zinc-700: #CCCCCC;
  --color-zinc-600: #999999;
  --color-zinc-500: #666666;
  --color-zinc-200: #1A1A1A;
  --color-white: #000000;
  --color-blue-500: #007AFF;
}
```

### Font Classes

| Nothing Font | Tailwind Class | Use Case |
|--------------|----------------|----------|
| Space Grotesk | `font-sans` | Body text, headings, UI |
| Space Mono | `font-mono` | Data, labels, code |
| Doto | `font-display` | Hero numbers, dot-matrix |

### Color Classes

| Nothing Concept | Tailwind Classes |
|-----------------|------------------|
| Page background | `bg-black` |
| Card surfaces | `bg-zinc-950` |
| Raised/hover | `bg-zinc-900` |
| Subtle borders | `border-zinc-800` |
| Visible borders | `border-zinc-700` |
| Disabled text | `text-zinc-600` |
| Secondary text | `text-zinc-500` |
| Primary text | `text-zinc-200` |
| Display/hero text | `text-white` |
| Accent/errors | `text-red-600`, `bg-red-600`, `border-red-600` |
| Success | `text-green-600`, `bg-green-600` |
| Warning | `text-amber-500`, `bg-amber-500` |
| Links/interactive | `text-blue-500` |

### Rails View Examples

**Card Component:**

```erb
<div class="bg-zinc-950 border border-zinc-800 rounded-xl p-4 md:p-6">
  <span class="font-mono text-[11px] tracking-widest text-zinc-500 uppercase">
    System Status
  </span>
  <h2 class="font-sans text-4xl tracking-tight text-white mt-2">
    98.4%
  </h2>
  <p class="text-base text-zinc-500 mt-1">
    Uptime this month
  </p>
</div>
```

**Button:**

```erb
<%# Primary — pill style %>
<button class="bg-white text-black font-sans text-sm uppercase tracking-wider px-6 py-3 rounded-full min-h-11">
  Submit
</button>

<%# Secondary — ghost with border %>
<button class="border border-zinc-700 text-zinc-200 font-sans text-sm uppercase tracking-wider px-6 py-3 rounded-full min-h-11 hover:border-zinc-500 transition-colors">
  Cancel
</button>

<%# Destructive %>
<button class="border border-red-600 text-red-600 font-sans text-sm uppercase tracking-wider px-6 py-3 rounded-full min-h-11">
  Delete
</button>
```

**Data Row:**

```erb
<div class="flex justify-between items-center py-3 border-b border-zinc-800">
  <span class="font-mono text-xs tracking-wide text-zinc-500 uppercase">
    CPU Usage
  </span>
  <span class="font-mono text-base text-zinc-200">
    42%
  </span>
</div>
```

**Navigation:**

```erb
<nav class="flex items-center gap-6">
  <a href="#" class="font-mono text-[11px] tracking-widest uppercase text-white">
    [ HOME ]
  </a>
  <a href="#" class="font-mono text-[11px] tracking-widest uppercase text-zinc-600 hover:text-zinc-200 transition-colors">
    GALLERY
  </a>
</nav>
```

**Progress Bar:**

```erb
<div class="w-full bg-zinc-800 h-2">
  <div class="bg-white h-2" style="width: 75%"></div>
</div>
<%# Over limit: use bg-red-600 %>
```

**Status Tags:**

```erb
<span class="border border-green-600 text-green-600 font-sans text-xs uppercase px-3 py-1 rounded-full">
  Active
</span>
<span class="border border-amber-500 text-amber-500 font-sans text-xs uppercase px-3 py-1 rounded-full">
  Pending
</span>
<span class="border border-red-600 text-red-600 font-sans text-xs uppercase px-3 py-1 rounded-full">
  Failed
</span>
```

### Development Commands

```bash
bin/dev                          # Rails dev server with Tailwind
bin/rails tailwindcss:watch      # Watch mode only
bin/rails tailwindcss:build      # Production build
```

