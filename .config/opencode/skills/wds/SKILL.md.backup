---
name: wds
description: Build React UIs using Wix Design System with local documentation
compatibility: opencode
license: MIT
metadata:
  audience: developers
  workflow: ui-development
  requires: "@wix/design-system installed in node_modules"
---

## What I Do

I help you work with Wix Design System (WDS) by leveraging comprehensive documentation already available in your local `node_modules`. I provide instant access to:

- **150+ React components** with full documentation
- **Component props and TypeScript types**
- **Code examples** for every component
- **400+ icons** from the Wix icon library
- **Usage guidelines** (dos and don'ts)

No external dependencies, MCP servers, or web fetching needed - everything is local and fast!

## When to Use Me

Use this skill when you need to:

- Choose the right WDS component for your UI needs
- Understand component props and their types
- See working code examples
- Find available icons
- Build forms, tables, modals, or other UI patterns
- Validate your WDS component usage

## Prerequisites

This skill requires `@wix/design-system` to be installed in your project:

```bash
npm install @wix/design-system
```

## Core Workflows

### 1. Discover Components

**Browse all available components to find what you need:**

1. Read the component catalog:
   ```bash
   read node_modules/@wix/design-system/dist/docs/components.md
   ```

2. The file contains all components with:
   - **Description** - What the component does
   - **Do** - When to use it
   - **Don'ts** - When NOT to use it

3. Example entry format:
   ```markdown
   ### Button
   - description: <p>Buttons let users initiate actions, like saving changes...</p>
   - do: Use it to communicate primary and secondary actions users can take.
   - donts: No donts
   ```

4. Search for specific functionality:
   ```bash
   grep -i "form\|input" node_modules/@wix/design-system/dist/docs/components.md
   ```

### 2. Get Component Props

**Get detailed information about component props:**

1. Read the props file for your component:
   ```bash
   read node_modules/@wix/design-system/dist/docs/components/ButtonProps.md
   ```

2. Each prop includes:
   - **Type** - TypeScript type signature
   - **Description** - What the prop does
   - Whether it's required or optional
   - Default values (when available)

3. Example props format:
   ```markdown
   ### size
   - type: ButtonSize
   - description: Controls the size of a button.
   
   ### priority
   - type: ButtonPriority
   - description: Specifies the priority of a button.
   ```

4. For complex types, check the TypeScript definitions:
   ```bash
   read node_modules/@wix/design-system/dist/types/ComponentName/index.d.ts
   ```

### 3. Find Usage Examples

**See real working code examples:**

1. Read the examples file:
   ```bash
   read node_modules/@wix/design-system/dist/docs/components/ButtonExamples.md
   ```

2. Contains feature-specific examples:
   - Size variants
   - Skin/appearance options
   - State examples (disabled, loading, etc.)
   - Common patterns and compositions

3. Example format:
   ```markdown
   ### Size
   - description: Control button size with `size` prop...
   - example:
   ```jsx
   <Button size="large">Large</Button>
   <Button size="medium">Medium</Button>
   <Button size="small">Small</Button>
   ```
   ```

### 4. Access Icons

**Browse and use WDS icons:**

1. Read the complete icons catalog:
   ```bash
   read node_modules/@wix/design-system/dist/docs/icons.md
   ```

2. The file includes:
   - List of all 400+ available icons
   - Import instructions
   - Usage examples

3. Search for specific icons:
   ```bash
   grep -i "arrow\|chevron" node_modules/@wix/design-system/dist/docs/icons.md
   ```

4. Import and use icons:
   ```tsx
   import { Add, Delete, Edit } from '@wix/wix-ui-icons-common';
   
   <Button prefixIcon={<Add />}>Add Item</Button>
   ```

5. Note: Each icon has two size variants:
   - `IconName` - Default size (24x24)
   - `IconNameSmall` - Small variant (18x18)

### 5. Validate Generated Code

**Ensure type safety before applying changes:**

1. After generating component code, create a test file or validate inline:
   ```bash
   npx tsc --noEmit path/to/component-file.tsx
   ```

2. Fix any TypeScript errors reported

3. Common issues:
   - Missing required props
   - Incorrect prop types
   - Missing imports

4. If errors persist, re-read the Props.md file to verify correct usage

### 6. Use Code-Research for Advanced Patterns

**For complex scenarios not covered in local docs:**

When you need:
- Complex integration patterns (e.g., WDS with React Hook Form)
- Real-world architectural examples
- Advanced composition patterns
- Integration with specific libraries
- Uncommon use cases

Use the code-research skill:
```
Use the code-research skill to find examples of integrating WDS Modal 
with React Hook Form in production codebases
```

## Quick Reference: Documentation Paths

| What You Need | File Path |
|---------------|-----------|
| All components overview | `node_modules/@wix/design-system/dist/docs/components.md` |
| Specific component props | `node_modules/@wix/design-system/dist/docs/components/{ComponentName}Props.md` |
| Component code examples | `node_modules/@wix/design-system/dist/docs/components/{ComponentName}Examples.md` |
| All available icons | `node_modules/@wix/design-system/dist/docs/icons.md` |
| TypeScript type exports | `node_modules/@wix/design-system/dist/types/index.d.ts` |
| Specific component types | `node_modules/@wix/design-system/dist/types/{ComponentName}/index.d.ts` |

## Common Components Quick Reference

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
- **IconButton** - Icon-only buttons for compact layouts
- **TextButton** - Low-emphasis text links
- **CloseButton** - Close/dismiss actions

### Layout & Structure
- **Page** - Main page structure for BM apps
- **Card** - Content containers
- **Box** - Flexible layout container
- **Layout** - Grid-based layout system
- **SidePanel** - Side panel overlays
- **Modal** - Modal dialog overlays
- **Tabs** - Content organization tabs
- **Accordion** - Collapsible content sections

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

### Advanced Components
- **Calendar** - Full calendar view
- **ColorPicker** - Color selection
- **ImageViewer** - Image display with actions
- **RichTextInputArea** - Rich text editor
- **SelectorList** - Searchable selection lists

## Best Practices

1. **Always browse components.md first** - Understand what's available before choosing
2. **Read Props.md carefully** - Know all available options before implementing
3. **Study Examples.md** - Learn from real usage patterns
4. **Validate with TypeScript** - Run `tsc` before committing
5. **Use semantic props** - WDS uses consistent naming (skin, priority, size, etc.)
6. **Follow component guidelines** - Respect the dos/don'ts from documentation
7. **Import correctly**:
   - Components: `import { Button } from '@wix/design-system'`
   - Icons: `import { IconName } from '@wix/wix-ui-icons-common'`
8. **Compose carefully** - Some components are meant to be used together (Card.Header, Card.Content)

## Complete Workflow Example

**Task: Create a form with a submit button**

1. **Discover components** needed:
   ```bash
   grep -E "### (Input|FormField|Button)" node_modules/@wix/design-system/dist/docs/components.md
   ```

2. **Read FormField props**:
   ```bash
   read node_modules/@wix/design-system/dist/docs/components/FormFieldProps.md
   ```

3. **Read Input props**:
   ```bash
   read node_modules/@wix/design-system/dist/docs/components/InputProps.md
   ```

4. **Check examples**:
   ```bash
   read node_modules/@wix/design-system/dist/docs/components/FormFieldExamples.md
   read node_modules/@wix/design-system/dist/docs/components/InputExamples.md
   ```

5. **Generate code**:
   ```tsx
   import { FormField, Input, Button } from '@wix/design-system';
   
   function MyForm() {
     return (
       <form>
         <FormField label="Email Address" required>
           <Input 
             type="email"
             placeholder="Enter your email"
           />
         </FormField>
         
         <Button type="submit">Submit</Button>
       </form>
     );
   }
   ```

6. **Validate**:
   ```bash
   npx tsc --noEmit src/components/MyForm.tsx
   ```

## Troubleshooting

### Component Not Found?
- Verify spelling in `components.md`
- Check if component exists in `dist/docs/components/`
- Some components may be deprecated or renamed

### Type Errors?
- Read the `{Component}Props.md` file carefully
- Verify all required props are provided
- Check import statements are correct
- Ensure prop types match documentation

### Need More Examples?
- Check if component has subcomponents (e.g., Card.Header, Card.Content)
- Look for related components that might have similar patterns
- Use code-research skill for real-world usage

### Icons Not Showing?
- Verify icon name from `icons.md`
- Check import from `@wix/wix-ui-icons-common` (NOT @wix/design-system)
- Try the Small variant if size issues occur

## Limitations & Workarounds

**No Built-in Verify Tool**
- Workaround: Use `npx tsc --noEmit` for type checking

**Documentation Matches Installed Version**
- Workaround: Update `@wix/design-system` to get latest docs

**Some Components Lack Examples**
- Workaround: Use code-research skill to find real-world usage

**Complex Patterns Not Documented**
- Workaround: Use code-research skill for architectural patterns

## When to Use Code-Research Skill

Switch to code-research when you need:

- **Integration patterns**: "How to use WDS Table with React Query"
- **Real-world examples**: "Find production examples of WDS Modal forms"
- **Advanced composition**: "Complex multi-step form patterns with WDS"
- **Library integration**: "Integrate WDS with React Hook Form validation"
- **Architectural patterns**: "How do large codebases structure WDS components"
- **Edge cases**: Uncommon scenarios not in documentation

## Additional Resources

### Component Composition Patterns

Some WDS components are designed to be composed together:

- **Card**: `Card`, `Card.Header`, `Card.Divider`, `Card.Content`
- **Page**: `Page`, `Page.Header`, `Page.Content`, `Page.Tail`
- **Modal**: Use with `CustomModalLayout`, `MessageModalLayout`
- **Table**: `Table`, `Table.Content`, `Table.ActionCell`

Check component Examples.md files to see composition patterns.

### Common Prop Patterns

WDS uses consistent prop naming:

- **size**: `tiny`, `small`, `medium`, `large`
- **skin**: `standard`, `light`, `destructive`, `premium`, etc.
- **priority**: `primary`, `secondary`
- **dataHook**: For testing automation
- **as**: Render as different element/component

### TypeScript Tips

All WDS components are fully typed. To get better autocomplete:

```tsx
import { ButtonProps } from '@wix/design-system';

const myButtonProps: ButtonProps = {
  size: 'medium',
  priority: 'primary',
  // TypeScript will autocomplete available props
};
```

## Summary

This skill gives you complete access to Wix Design System without any external dependencies. Simply:

1. **Read `components.md`** to discover components
2. **Read `{Component}Props.md`** to learn props
3. **Read `{Component}Examples.md`** to see usage
4. **Validate with `tsc`** before applying
5. **Use code-research** for advanced patterns

All documentation is local, fast, and matches your installed WDS version exactly.
