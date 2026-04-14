# Nothing Design System — Platform Mapping

> **ℹ️ Implementation Status:** Nothing Design System is already fully implemented in this Rails 8 + Tailwind CSS v4 project. Use the Tailwind classes below directly without any setup.

---

## 1. QUICK REFERENCE — USE THESE CLASSES

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

| Font Role | Tailwind Class |
|-----------|----------------|
| Body / UI | `font-sans` (Space Grotesk) |
| Data / Labels | `font-mono` (Space Mono) |
| Display | `font-display` (Doto) |

---

## 2. RAILS 8 + TAILWIND CSS v4

Tokens are pre-configured in `app/assets/stylesheets/application.css`. Use standard Tailwind classes directly.

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
  <span class="font-mono text-sm tracking-widest text-zinc-500 uppercase">
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
  <a href="#" class="font-mono text-sm tracking-widest uppercase text-white">
    [ HOME ]
  </a>
  <a href="#" class="font-mono text-sm tracking-widest uppercase text-zinc-600 hover:text-zinc-200 transition-colors">
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

