---
name: wds
description: Wix Design System component reference for building React UIs with @wix/design-system. Use when: (1) choosing WDS components for UI needs, (2) checking component props and TypeScript types, (3) finding code examples, (4) searching 400+ WDS icons, (5) building forms/tables/modals/layouts/pages. Optimized for efficient navigation of large local documentation files (some 900+ lines). Triggers on "WDS", "Wix Design System", "what component should I use", "how do I make [UI element]", "show me props for [component]", or specific component names like Button, Card, Modal, Box, Table, Input, FormField, Dropdown.
---

# WDS Documentation Navigator

**Docs path:** `node_modules/@wix/design-system/dist/docs/`

## CRITICAL: Never Read Entire Files

Documentation files are 200-900+ lines. BoxProps.md is 8000+ lines. Follow the staged discovery flow below to read only what you need.

---

## Staged Discovery Flow

### Stage 1: Find Component

**Goal:** Search for component by feature/keyword

```bash
Grep: "table" in node_modules/@wix/design-system/dist/docs/components.md
Grep: "form\|input\|validation" in node_modules/@wix/design-system/dist/docs/components.md
Grep: "modal\|dialog\|popup" in node_modules/@wix/design-system/dist/docs/components.md
```

**Output:** Component name + description + do/don'ts

**Next:** Go to Stage 2 with component name

---

### Stage 2: Get Props + Example List

**Goal:** Get props AND discover available examples

```bash
# 2a. Get props (small files OK to read, large files grep)
Read: node_modules/@wix/design-system/dist/docs/components/ButtonProps.md              # OK if <100 lines
Grep: "### disabled" in node_modules/@wix/design-system/dist/docs/components/BoxProps.md -A 3  # Box is huge

# 2b. List available examples (ALWAYS grep, never read)
Grep: "^### " in node_modules/@wix/design-system/dist/docs/components/ButtonExamples.md -n
```

**Output from 2b:**
```
5:### Size
17:### Skin
71:### Affix
123:### Disabled
183:### Loading state
```

**Next:** Pick example(s) from list, go to Stage 3

---

### Stage 3: Fetch Specific Example

**Goal:** Read only the example you need (~30-50 lines)

```bash
# Option A: Read with offset (line number from Stage 2)
Read: node_modules/@wix/design-system/dist/docs/components/ButtonExamples.md offset=183 limit=40

# Option B: Grep with context
Grep: "### Loading state" in node_modules/@wix/design-system/dist/docs/components/ButtonExamples.md -A 40
```

**Output:** JSX code example for that specific feature

---

### Stage 4: Icons (when needed)

```bash
Grep: "Add\|Edit\|Delete\|Search" in node_modules/@wix/design-system/dist/docs/icons.md
```

---

## Flow Summary

```
┌─────────────────────────────────────────────────────────┐
│ Stage 1: Grep components.md for keyword                 │
│          → finds: Button, Card, Table...                │
└────────────────────┬────────────────────────────────────┘
                     ↓
┌─────────────────────────────────────────────────────────┐
│ Stage 2a: Read/Grep {Component}Props.md                 │
│           → gets: props with types & descriptions       │
│                                                         │
│ Stage 2b: Grep "^### " in {Component}Examples.md        │
│           → gets: example names + line numbers          │
│           "5:### Size, 71:### Affix, 183:### Loading"   │
└────────────────────┬────────────────────────────────────┘
                     ↓
┌─────────────────────────────────────────────────────────┐
│ Stage 3: Read offset=183 limit=40                       │
│          → gets: specific example JSX code              │
└─────────────────────────────────────────────────────────┘
```

---

## Quick Component Reference

### Forms & Inputs
- **Input** - Single-line text input
- **InputArea** - Multi-line text input
- **Dropdown** - Select from list of options
- **AutoComplete** - Searchable dropdown
- **Checkbox** - Multiple selections
- **RadioGroup** - Single selection from options
- **DatePicker** - Date selection
- **NumberInput** - Numeric input with controls
- **FormField** - Label wrapper for form inputs
- **ToggleSwitch** - On/off toggle

### Buttons & Actions
- **Button** - Primary action buttons
- **IconButton** - Icon-only buttons
- **TextButton** - Low-emphasis text links
- **CloseButton** - Close/dismiss actions

### Layout & Structure
- **Page** - Main page structure for BM apps
- **Card** - Content containers
- **Box** - Flexible layout container
- **Layout** - Grid-based layout system
- **Modal** - Modal dialog overlays
- **SidePanel** - Side panel overlays
- **Tabs** - Content organization
- **Accordion** - Collapsible sections

### Data Display
- **Table** - Data tables with sorting/filtering
- **TableListItem** - Simple list rows
- **Badge** - Status indicators
- **Avatar** - User/org representations
- **Text** - Typography component
- **Heading** - Section headings
- **EmptyState** - No data states

### Feedback & States
- **Loader** - Loading indicators
- **CircularProgressBar** - Progress visualization
- **FloatingNotification** - Temporary notifications
- **StatusToast** - Status change notifications
- **SectionHelper** - Inline help/info messages

### Navigation
- **Breadcrumbs** - Navigation hierarchy
- **Pagination** - Page navigation
- **SidebarNext** - Main app navigation
- **PopoverMenu** - Contextual menus

---

## Quick Reference Table

| Stage | Command Pattern | Output |
|-------|----------------|--------|
| 1. Find | `Grep: "keyword" in components.md` | Component name + description |
| 2a. Props | `Read: {Name}Props.md` (if small) or `Grep: "### propname" -A 3` | Props with types |
| 2b. Examples | `Grep: "^### " in {Name}Examples.md -n` | Example names + line numbers |
| 3. Fetch | `Read: {Name}Examples.md offset=N limit=40` | Specific example code |
| 4. Icons | `Grep: "IconName" in icons.md` | Icon exists + import |

---

## Design Element → WDS Component Mapping

| Design Element | WDS Component | Notes |
|----------------|---------------|-------|
| Rectangle/container | `<Box>` | Layout wrapper with flex/grid |
| Text button | `<TextButton>` | Secondary actions |
| Input with label | `<FormField>` + `<Input>` | Always wrap inputs |
| Toggle | `<ToggleSwitch>` | On/off settings |
| Modal | `<Modal>` + `<CustomModalLayout>` | Use together |
| Grid | `<Layout>` + `<Cell>` | Responsive layout |

---

## Common Patterns

### Spacing Tokens (px → SP conversion)

When designer specifies pixels, convert to nearest SP token:

| Token | Classic | Studio |
|-------|---------|--------|
| `SP1` | 6px | 4px |
| `SP2` | 12px | 8px |
| `SP3` | 18px | 12px |
| `SP4` | 24px | 16px |
| `SP5` | 30px | 20px |
| `SP6` | 36px | 24px |

```tsx
<Box gap="SP2" padding="SP3">
```

Use SP tokens for `gap`, `padding`, `margin` - not for width/height.

### Imports

```tsx
// Components
import { Button, Card, Input, FormField } from '@wix/design-system';

// Icons (separate package!)
import { Add, Edit, Delete } from '@wix/wix-ui-icons-common';
```

### Component Composition

Some WDS components are designed to be composed:

```tsx
// Card composition
<Card>
  <Card.Header title="Title" />
  <Card.Divider />
  <Card.Content>Content here</Card.Content>
</Card>

// Page composition
<Page>
  <Page.Header title="Page Title" />
  <Page.Content>Main content</Page.Content>
</Page>
```

---

## Example Session: Building a Product Page

```bash
# Stage 1: Find components
Grep: "image\|card\|price" in node_modules/@wix/design-system/dist/docs/components.md
→ Found: Image, Card, Text

# Stage 2a: Get Card props
Read: node_modules/@wix/design-system/dist/docs/components/CardProps.md
→ Got: props list with types

# Stage 2b: List Card examples
Grep: "^### " in node_modules/@wix/design-system/dist/docs/components/CardExamples.md -n
→ 5:### Basic, 25:### With media, 60:### Clickable

# Stage 3: Fetch "With media" example
Read: node_modules/@wix/design-system/dist/docs/components/CardExamples.md offset=25 limit=35
→ Got: Card with Image example code

# Repeat Stage 2-3 for Text component
```

**Result:** Read ~80 lines instead of 1500+ lines

---

## Advanced Topics

### Component Composition Patterns
For detailed composition examples (Card subcomponents, Page layouts, Modal layouts, Table structures), read `references/advanced-patterns.md`.

### Integration Patterns
For integrating WDS with React Hook Form, React Query, or other libraries, read `references/advanced-patterns.md`.

### TypeScript Tips
For advanced type patterns and generic component typing, read `references/advanced-patterns.md`.

### Troubleshooting
If you encounter issues with component not found, type errors, icons not showing, or validation problems, read `references/troubleshooting.md`.

### File Structure Details
For detailed information about file formats and sizes in the WDS docs, read `references/file-structure.md`.

---

## When to Use Code-Research Skill

Switch to code-research skill when you need:

- **Real-world examples** - Production usage patterns not in docs
- **Complex integrations** - WDS with specific libraries/frameworks
- **Architectural patterns** - How large codebases structure WDS components
- **Edge cases** - Uncommon scenarios not covered in documentation

Example:
```
Use code-research skill to find examples of integrating WDS Modal 
with React Hook Form in production codebases
```

---

## File Path Summary

| What You Need | File Path |
|---------------|-----------|
| All components | `node_modules/@wix/design-system/dist/docs/components.md` |
| Component props | `node_modules/@wix/design-system/dist/docs/components/{ComponentName}Props.md` |
| Component examples | `node_modules/@wix/design-system/dist/docs/components/{ComponentName}Examples.md` |
| All icons | `node_modules/@wix/design-system/dist/docs/icons.md` |
| TypeScript types | `node_modules/@wix/design-system/dist/types/{ComponentName}/index.d.ts` |

---

## Summary

This skill gives you complete access to Wix Design System documentation with maximum efficiency:

1. **Grep `components.md`** to discover components (never read fully)
2. **Read/Grep `{Component}Props.md`** to learn props (read small files, grep large ones)
3. **Grep `^### ` in `{Component}Examples.md`** to list available examples
4. **Read with offset/limit** to fetch specific examples only
5. **Use references/** for advanced patterns and troubleshooting
6. **Use code-research** for real-world integration patterns

All documentation is local, fast, and matches your installed WDS version exactly.
