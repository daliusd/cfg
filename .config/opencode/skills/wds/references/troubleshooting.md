# WDS Troubleshooting Guide

This reference covers common issues when working with Wix Design System components and how to resolve them.

## Component Not Found

### Problem: Import fails or component doesn't exist

**Symptoms:**
```tsx
import { MyComponent } from '@wix/design-system';
// Error: Module '"@wix/design-system"' has no exported member 'MyComponent'
```

**Solutions:**

1. **Verify component name in components.md**
   ```bash
   Grep: "ComponentName" in node_modules/@wix/design-system/dist/docs/components.md
   ```
   Component names are case-sensitive and must match exactly.

2. **Check for deprecated components**
   Some components have been renamed or removed. Common changes:
   - `TextLabel` → `Text`
   - `Notification` → `FloatingNotification`
   - Check release notes for your WDS version

3. **Verify package installation**
   ```bash
   Read: node_modules/@wix/design-system/package.json
   ```
   Ensure @wix/design-system is installed and version is recent.

4. **Check component availability**
   Some components may be in different packages:
   ```tsx
   // Most components
   import { Button } from '@wix/design-system';
   
   // Icons are separate!
   import { Add } from '@wix/wix-ui-icons-common';
   ```

## Type Errors

### Problem: TypeScript errors about props

**Symptoms:**
```tsx
<Button color="blue">Click me</Button>
// Error: Type '"blue"' is not assignable to type 'ButtonProps["color"]'
```

**Solutions:**

1. **Check prop names and types in Props.md**
   ```bash
   Read: node_modules/@wix/design-system/dist/docs/components/ButtonProps.md
   ```
   Common mistakes:
   - `color` doesn't exist, use `skin` instead
   - `variant` doesn't exist, use `priority` instead
   - `disabled` is a boolean, not a string

2. **Verify required props**
   ```bash
   Grep: "required" in node_modules/@wix/design-system/dist/docs/components/ComponentProps.md
   ```
   Some components have required props that must be provided.

3. **Check prop value constraints**
   ```tsx
   // Wrong: arbitrary string
   <Button size="big">Click</Button>
   
   // Right: specific values
   <Button size="large">Click</Button>  // 'tiny' | 'small' | 'medium' | 'large'
   ```

4. **Common prop type mismatches:**

   | Wrong | Correct | Component |
   |-------|---------|-----------|
   | `color="primary"` | `skin="standard"` | Button |
   | `variant="filled"` | `priority="primary"` | Button |
   | `label="Name"` | Wrap in `<FormField label="Name">` | Input |
   | `placeholder={null}` | `placeholder=""` or omit | Input |
   | `disabled="true"` | `disabled={true}` | Most components |

### Problem: Missing required props

**Symptoms:**
```tsx
<Dropdown />
// Error: Property 'options' is missing
```

**Solutions:**

1. **Read Props.md to find required props**
   ```bash
   Read: node_modules/@wix/design-system/dist/docs/components/DropdownProps.md
   ```

2. **Common required props by component:**
   - `Dropdown`: requires `options` array
   - `Table`: requires `data` and `columns`
   - `Modal`: requires `isOpen` and `onRequestClose`
   - `RadioGroup`: requires `value` and `onChange`

## Import Errors

### Problem: Component imports fail

**Symptoms:**
```tsx
import { Button } from '@wix/design-system/Button';
// Error: Module not found
```

**Solutions:**

1. **Use barrel imports (correct pattern):**
   ```tsx
   // ✅ Correct
   import { Button, Input, Card } from '@wix/design-system';
   
   // ❌ Wrong
   import { Button } from '@wix/design-system/Button';
   import Button from '@wix/design-system/Button';
   ```

2. **Icons are in separate package:**
   ```tsx
   // ✅ Correct
   import { Add, Edit, Delete } from '@wix/wix-ui-icons-common';
   
   // ❌ Wrong
   import { Add } from '@wix/design-system';
   ```

3. **Check package.json dependencies:**
   ```json
   {
     "dependencies": {
       "@wix/design-system": "^11.0.0",
       "@wix/wix-ui-icons-common": "^3.0.0"
     }
   }
   ```

## Icons Not Showing

### Problem: Icons don't render or import fails

**Symptoms:**
```tsx
import { AddIcon } from '@wix/design-system';
// Error: Module has no exported member 'AddIcon'
```

**Solutions:**

1. **Verify icon name and import source:**
   ```bash
   Grep: "Add" in node_modules/@wix/design-system/dist/docs/icons.md
   ```
   
2. **Use correct import:**
   ```tsx
   // ✅ Correct
   import { Add } from '@wix/wix-ui-icons-common';
   
   // ❌ Wrong
   import { AddIcon } from '@wix/design-system';
   import { Add } from '@wix/design-system';
   ```

3. **Icon naming patterns:**
   ```tsx
   // Standard icon (24x24)
   import { Add } from '@wix/wix-ui-icons-common';
   
   // Small variant (18x18)
   import { AddSmall } from '@wix/wix-ui-icons-common';
   ```

4. **Common icon name variations:**
   - Not `Plus`, it's `Add`
   - Not `Trash`, it's `Delete`
   - Not `Pencil`, it's `Edit`
   - Not `Gear`, it's `Settings`
   
   Search icons.md to find exact names:
   ```bash
   Grep: -i "plus\|add" in node_modules/@wix/design-system/dist/docs/icons.md
   ```

5. **Icon not rendering (blank space):**
   - Ensure icon package is installed: `npm install @wix/wix-ui-icons-common`
   - Check icon is used as JSX: `<Add />` not `Add`
   - Icons in Button need prefixIcon/suffixIcon:
     ```tsx
     <Button prefixIcon={<Add />}>Add Item</Button>
     ```

## Validation Errors

### Problem: Code runs but doesn't work as expected

**Symptoms:**
- Component renders but props don't apply
- TypeScript doesn't show errors but runtime fails
- Events don't fire

**Solutions:**

1. **Validate with TypeScript:**
   ```bash
   npx tsc --noEmit path/to/component.tsx
   ```
   This catches type errors before runtime.

2. **Check prop value types:**
   ```tsx
   // ❌ Wrong: string instead of number
   <Input maxLength="50" />
   
   // ✅ Correct
   <Input maxLength={50} />
   ```

3. **Event handler signatures:**
   ```tsx
   // ✅ Correct
   const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
     setValue(e.target.value);
   };
   <Input onChange={handleChange} />
   
   // ❌ Wrong: wrong event type
   const handleChange = (value: string) => setValue(value);
   <Input onChange={handleChange} />
   ```

4. **Controlled vs uncontrolled components:**
   ```tsx
   // ✅ Controlled (recommended)
   <Input value={value} onChange={e => setValue(e.target.value)} />
   
   // ⚠️ Uncontrolled (use defaultValue, not value without onChange)
   <Input defaultValue="initial" />
   
   // ❌ Wrong: value without onChange
   <Input value="fixed" />  // Won't update!
   ```

## Examples Not Working

### Problem: Example code doesn't work when copied

**Solutions:**

1. **Add missing imports:**
   Examples assume common imports. Add:
   ```tsx
   import React, { useState } from 'react';
   import { ComponentName } from '@wix/design-system';
   ```

2. **Add missing state:**
   Examples show JSX but may need state:
   ```tsx
   // Example shows:
   <Input value={value} onChange={handleChange} />
   
   // You need to add:
   const [value, setValue] = useState('');
   const handleChange = (e) => setValue(e.target.value);
   ```

3. **Check for missing props:**
   Examples may omit required props for brevity. Check Props.md for requirements.

4. **Verify examples are complete:**
   ```bash
   # Get full example context
   Read: node_modules/@wix/design-system/dist/docs/components/ComponentExamples.md offset=N limit=50
   ```

## Component Not Rendering

### Problem: Component doesn't appear or looks broken

**Solutions:**

1. **Check for missing layout components:**
   ```tsx
   // ❌ Modal without layout
   <Modal isOpen={true}>
     <div>Content</div>
   </Modal>
   
   // ✅ Modal with layout
   <Modal isOpen={true}>
     <CustomModalLayout title="Title">
       Content
     </CustomModalLayout>
   </Modal>
   ```

2. **Verify parent container:**
   Some components need specific parents:
   - `Card.Header` must be inside `<Card>`
   - `Page.Content` must be inside `<Page>`
   - `Cell` must be inside `<Layout>`

3. **Check z-index issues:**
   Modals and tooltips use high z-index. Ensure parent containers don't have conflicting z-index or overflow: hidden.

4. **Verify visibility:**
   ```tsx
   // Check these props
   <Component 
     hidden={false}  // Not hidden
     disabled={false}  // Not disabled (may affect visibility)
   />
   ```

## Styling Issues

### Problem: Custom styles don't apply

**Solutions:**

1. **Use className, not style (when possible):**
   ```tsx
   // ✅ Preferred
   <Button className="my-button">Click</Button>
   
   // ⚠️ Works but not recommended
   <Button style={{ marginTop: '10px' }}>Click</Button>
   ```

2. **Use WDS spacing tokens:**
   ```tsx
   // ✅ Use Box for spacing
   <Box marginTop="SP3">
     <Button>Click</Button>
   </Box>
   
   // ❌ Don't fight WDS styles
   <Button style={{ margin: '15px' }}>Click</Button>
   ```

3. **Override with CSS specificity:**
   ```css
   /* If you must override */
   .my-component .wds-button {
     /* Your styles */
   }
   ```

## Form Integration Issues

### Problem: Form validation or state management fails

**Solutions:**

1. **Use FormField for error states:**
   ```tsx
   <FormField 
     label="Email"
     status={error ? 'error' : undefined}
     statusMessage={error}
   >
     <Input type="email" value={email} onChange={handleChange} />
   </FormField>
   ```

2. **With React Hook Form:**
   ```tsx
   <Controller
     name="email"
     control={control}
     rules={{ required: true }}
     render={({ field, fieldState }) => (
       <FormField 
         label="Email"
         status={fieldState.error ? 'error' : undefined}
         statusMessage={fieldState.error?.message}
       >
         <Input {...field} />
       </FormField>
     )}
   />
   ```

3. **Ensure controlled inputs:**
   All form inputs should have value + onChange (controlled) or defaultValue (uncontrolled), not both.

## Performance Issues

### Problem: Slow rendering or lag

**Solutions:**

1. **Memoize table columns:**
   ```tsx
   const columns = useMemo(() => [...], []);
   ```

2. **Virtualize long lists:**
   For 100+ items, consider virtualization libraries with WDS styling.

3. **Avoid re-creating objects in render:**
   ```tsx
   // ❌ Creates new object every render
   <Button style={{ marginTop: 10 }}>Click</Button>
   
   // ✅ Use Box or CSS class
   <Box marginTop="SP2">
     <Button>Click</Button>
   </Box>
   ```

## Getting More Help

### When local documentation isn't enough:

1. **Use code-research skill for production examples:**
   ```
   Use code-research skill to find how other projects handle [specific issue]
   ```

2. **Check WDS Storybook** (if accessible):
   Browse interactive examples at wix-design-system storybook

3. **Search for component issues:**
   ```
   Use code-research skill to search GitHub issues for "@wix/design-system [ComponentName] [issue]"
   ```

4. **Verify WDS version compatibility:**
   ```bash
   Read: node_modules/@wix/design-system/CHANGELOG.md
   ```

## Common Error Messages Decoded

| Error Message | Likely Cause | Solution |
|---------------|--------------|----------|
| "has no exported member" | Wrong import path or component name | Check components.md for exact name |
| "Property 'X' does not exist" | Prop doesn't exist or typo | Read ComponentProps.md |
| "Type 'X' is not assignable" | Wrong prop value type | Check prop type in Props.md |
| "Missing required prop" | Component needs additional props | Read Props.md for required props |
| "Cannot read property of undefined" | Missing state or props | Ensure all data is initialized |
| "React Hook useEffect has missing dependency" | Effect deps incomplete | Add dependencies or use useCallback |

## Debug Checklist

When something doesn't work:

- [ ] Verified component name spelling in components.md
- [ ] Checked Props.md for required props
- [ ] Reviewed Examples.md for usage patterns
- [ ] Validated imports are from correct package
- [ ] Ran `npx tsc --noEmit` to check types
- [ ] Checked browser console for runtime errors
- [ ] Verified component has necessary parent/wrapper
- [ ] Ensured all state is properly initialized
- [ ] Checked that icons are from @wix/wix-ui-icons-common
- [ ] Reviewed FormField wrapping for form inputs
