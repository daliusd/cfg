# WDS Advanced Patterns

This reference covers component composition patterns, library integrations, and advanced usage patterns for Wix Design System.

## Component Composition Patterns

Many WDS components are designed to work together as composed units. Understanding these patterns helps you build consistent, maintainable UIs.

### Card Composition

Cards have built-in subcomponents for consistent structure:

```tsx
import { Card } from '@wix/design-system';

// Basic composition
<Card>
  <Card.Header title="Card Title" subtitle="Optional subtitle" />
  <Card.Divider />
  <Card.Content>
    Main content goes here
  </Card.Content>
</Card>

// With actions
<Card>
  <Card.Header 
    title="Settings" 
    suffix={<Button size="small">Edit</Button>}
  />
  <Card.Content>
    Content here
  </Card.Content>
</Card>

// Clickable card
<Card onClick={() => navigate('/details')}>
  <Card.Content>
    Entire card is clickable
  </Card.Content>
</Card>
```

**Key patterns:**
- Always use Card.Header for titles (not custom heading elements)
- Card.Divider provides consistent spacing
- Card.Content handles proper padding
- Use suffix/prefix in Card.Header for actions

### Page Composition

Page component structures full-page layouts:

```tsx
import { Page, Button } from '@wix/design-system';

<Page>
  <Page.Header 
    title="Page Title"
    subtitle="Page description"
    actionsBar={<Button>Primary Action</Button>}
  />
  <Page.Content>
    <Card>
      Main content
    </Card>
  </Page.Content>
  <Page.Tail>
    <Button>Cancel</Button>
    <Button priority="primary">Save</Button>
  </Page.Tail>
</Page>
```

**Key patterns:**
- Page.Header for consistent header styling
- actionsBar for primary page actions
- Page.Content is scrollable by default
- Page.Tail for sticky footer actions (forms, wizards)

### Modal Layouts

Modals require layout components for proper structure:

```tsx
import { Modal, CustomModalLayout, Button } from '@wix/design-system';

// Custom modal
<Modal isOpen={isOpen} onRequestClose={onClose}>
  <CustomModalLayout
    primaryButtonText="Save"
    primaryButtonOnClick={handleSave}
    secondaryButtonText="Cancel"
    secondaryButtonOnClick={onClose}
    title="Modal Title"
    subtitle="Optional subtitle"
  >
    Modal content goes here
  </CustomModalLayout>
</Modal>

// Message modal (simpler)
<Modal isOpen={isOpen} onRequestClose={onClose}>
  <MessageModalLayout
    primaryButtonText="Confirm"
    primaryButtonOnClick={handleConfirm}
    title="Are you sure?"
    illustration={<Image src="..." />}
  >
    Confirmation message
  </MessageModalLayout>
</Modal>
```

**Key patterns:**
- Always wrap Modal content with a layout component
- CustomModalLayout for forms and complex content
- MessageModalLayout for confirmations and alerts
- Layout handles buttons, title, and footer automatically

### Table Composition

Tables have specialized components for common patterns:

```tsx
import { Table, TableToolbar, TableActionCell, Badge } from '@wix/design-system';

const columns = [
  { title: 'Name', render: row => row.name },
  { title: 'Status', render: row => <Badge>{row.status}</Badge> },
  { 
    title: '', 
    render: row => (
      <TableActionCell
        primaryAction={{
          text: 'Edit',
          onClick: () => handleEdit(row)
        }}
        secondaryActions={[
          { text: 'Delete', onClick: () => handleDelete(row) }
        ]}
      />
    )
  }
];

<Table
  data={data}
  columns={columns}
>
  <TableToolbar>
    <TableToolbar.ItemGroup>
      <Button>Add New</Button>
    </TableToolbar.ItemGroup>
  </TableToolbar>
  <Table.Content />
</Table>
```

**Key patterns:**
- TableActionCell for row actions (consistent overflow menus)
- TableToolbar for table-level actions
- Use render functions for custom cell content
- Table.Content renders the actual table body

### FormField + Input Pattern

Form inputs should always be wrapped with FormField:

```tsx
import { FormField, Input } from '@wix/design-system';

// Basic pattern
<FormField label="Email Address" required>
  <Input 
    type="email"
    value={email}
    onChange={e => setEmail(e.target.value)}
  />
</FormField>

// With validation
<FormField 
  label="Password" 
  required
  status={error ? 'error' : undefined}
  statusMessage={error}
>
  <Input 
    type="password"
    value={password}
    onChange={e => setPassword(e.target.value)}
  />
</FormField>

// With help text
<FormField 
  label="Username"
  infoContent="Must be 3-20 characters"
>
  <Input value={username} onChange={e => setUsername(e.target.value)} />
</FormField>
```

**Key patterns:**
- FormField handles label, required indicator, and error states
- status prop: 'error', 'warning', or undefined
- infoContent for help text
- Works with Input, InputArea, Dropdown, etc.

## Layout Patterns

### Box for Flexbox/Grid

Box is the most flexible layout component:

```tsx
import { Box } from '@wix/design-system';

// Flex row with gap
<Box direction="horizontal" gap="SP2" align="center">
  <Button>First</Button>
  <Button>Second</Button>
</Box>

// Flex column
<Box direction="vertical" gap="SP3">
  <Card>Card 1</Card>
  <Card>Card 2</Card>
</Box>

// Grid layout
<Box 
  direction="horizontal" 
  gap="SP3"
  wrap="wrap"
>
  {items.map(item => (
    <Box key={item.id} width="200px">
      <Card>{item.name}</Card>
    </Box>
  ))}
</Box>

// With padding
<Box padding="SP4" backgroundColor="D10">
  Content with padding
</Box>
```

**Key patterns:**
- Use direction for flex-direction
- Use gap with SP tokens (not margin)
- align and verticalAlign for flex alignment
- wrap for responsive grids

### Layout + Cell for Grids

Layout provides responsive grid system:

```tsx
import { Layout, Cell } from '@wix/design-system';

// 2-column layout
<Layout cols={2} gap="SP3">
  <Cell>
    <Card>Left column</Card>
  </Cell>
  <Cell>
    <Card>Right column</Card>
  </Cell>
</Layout>

// Responsive layout
<Layout>
  <Cell span={8}>
    <Card>Main content (2/3 width)</Card>
  </Cell>
  <Cell span={4}>
    <Card>Sidebar (1/3 width)</Card>
  </Cell>
</Layout>

// Different mobile/desktop
<Layout cols={{ mobile: 1, tablet: 2, desktop: 3 }}>
  {items.map(item => (
    <Cell key={item.id}>
      <Card>{item.name}</Card>
    </Cell>
  ))}
</Layout>
```

**Key patterns:**
- 12-column grid system (span 1-12)
- cols prop sets number of columns
- Responsive breakpoints: mobile, tablet, desktop
- Use gap with SP tokens

## Integration Patterns

### React Hook Form Integration

WDS components work with React Hook Form for validation:

```tsx
import { useForm, Controller } from 'react-hook-form';
import { FormField, Input, Button } from '@wix/design-system';

function MyForm() {
  const { control, handleSubmit, formState: { errors } } = useForm();

  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      <Controller
        name="email"
        control={control}
        rules={{ required: 'Email is required' }}
        render={({ field }) => (
          <FormField 
            label="Email"
            required
            status={errors.email ? 'error' : undefined}
            statusMessage={errors.email?.message}
          >
            <Input {...field} type="email" />
          </FormField>
        )}
      />
      
      <Button type="submit">Submit</Button>
    </form>
  );
}
```

**Key patterns:**
- Use Controller for each WDS input
- Map errors to FormField status/statusMessage
- Spread field props to Input component
- FormField handles visual error states

### Table with React Query

Integrate Table with server-side data:

```tsx
import { useQuery } from '@tanstack/react-query';
import { Table, Loader } from '@wix/design-system';

function DataTable() {
  const { data, isLoading } = useQuery({
    queryKey: ['users'],
    queryFn: fetchUsers
  });

  if (isLoading) return <Loader />;

  const columns = [
    { title: 'Name', render: row => row.name },
    { title: 'Email', render: row => row.email }
  ];

  return <Table data={data} columns={columns} />;
}
```

**Key patterns:**
- Show Loader during loading states
- Map query data directly to Table data prop
- Use EmptyState for no data

### Modal with Form State

Manage modal open/close with form data:

```tsx
import { useState } from 'react';
import { Modal, CustomModalLayout, FormField, Input } from '@wix/design-system';

function EditModal({ item, onSave, onClose }) {
  const [formData, setFormData] = useState(item);

  const handleSave = () => {
    onSave(formData);
    onClose();
  };

  return (
    <Modal isOpen onRequestClose={onClose}>
      <CustomModalLayout
        title="Edit Item"
        primaryButtonText="Save"
        primaryButtonOnClick={handleSave}
        secondaryButtonText="Cancel"
        secondaryButtonOnClick={onClose}
      >
        <FormField label="Name">
          <Input 
            value={formData.name}
            onChange={e => setFormData({ ...formData, name: e.target.value })}
          />
        </FormField>
      </CustomModalLayout>
    </Modal>
  );
}
```

**Key patterns:**
- Initialize form state from props
- Handle save in modal, callback to parent
- onRequestClose for ESC/overlay click
- Reset state on close if needed

## Common Prop Patterns

### Size Variants

Most components support consistent size props:

```tsx
// Common values: 'tiny', 'small', 'medium', 'large'
<Button size="medium">Button</Button>
<Input size="medium" />
<Badge size="medium">Badge</Badge>
```

### Skin/Appearance

Components use `skin` for visual variants:

```tsx
// Button skins
<Button skin="standard">Standard</Button>
<Button skin="destructive">Delete</Button>
<Button skin="premium">Premium</Button>

// Box backgrounds
<Box backgroundColor="D10">Light background</Box>
<Box backgroundColor="D80">Dark background</Box>
```

### Priority

Buttons and similar components use priority:

```tsx
<Button priority="primary">Primary</Button>
<Button priority="secondary">Secondary</Button>
```

### dataHook for Testing

All components accept dataHook for test automation:

```tsx
<Button dataHook="submit-button">Submit</Button>
<Input dataHook="email-input" />

// In tests
const button = await findByDataHook('submit-button');
```

### as Prop (Polymorphic Components)

Some components can render as different elements:

```tsx
// Text as different elements
<Text as="h1">Heading</Text>
<Text as="p">Paragraph</Text>
<Text as="span">Inline text</Text>

// Box as different elements
<Box as="section">Section content</Box>
<Box as="article">Article content</Box>
```

## TypeScript Patterns

### Component Props Types

Import prop types for type-safe composition:

```tsx
import { ButtonProps, InputProps } from '@wix/design-system';

interface MyComponentProps {
  buttonProps?: Partial<ButtonProps>;
  inputProps?: Partial<InputProps>;
}

function MyComponent({ buttonProps, inputProps }: MyComponentProps) {
  return (
    <>
      <Input {...inputProps} />
      <Button {...buttonProps}>Submit</Button>
    </>
  );
}
```

### Generic Table Columns

Type-safe table columns:

```tsx
interface User {
  id: string;
  name: string;
  email: string;
}

const columns: TableColumn<User>[] = [
  { 
    title: 'Name', 
    render: (user) => user.name // user is typed as User
  },
  { 
    title: 'Email', 
    render: (user) => user.email
  }
];
```

### Event Handler Types

Use proper event types:

```tsx
import { ChangeEvent } from 'react';

const handleChange = (e: ChangeEvent<HTMLInputElement>) => {
  setValue(e.target.value);
};

<Input onChange={handleChange} />
```

## Performance Patterns

### Memoize Table Columns

Prevent unnecessary re-renders:

```tsx
import { useMemo } from 'react';

function MyTable({ data }) {
  const columns = useMemo(() => [
    { title: 'Name', render: row => row.name },
    { title: 'Email', render: row => row.email }
  ], []); // Only create once

  return <Table data={data} columns={columns} />;
}
```

### Virtualization for Long Lists

For very long lists, consider virtualization (not built into WDS Table):

```tsx
// Use external library like react-window with WDS styling
import { FixedSizeList } from 'react-window';
import { TableListItem } from '@wix/design-system';

// See code-research skill for full examples
```

## When to Use Code-Research

For these advanced patterns, consider using code-research skill to find production examples:

- Complex multi-step wizards with WDS
- Advanced table features (sorting, filtering, pagination)
- Real-world form validation patterns
- Complex modal workflows
- Performance optimization techniques
- Accessibility patterns
- Theme customization
- Integration with state management (Redux, Zustand, etc.)

Example code-research query:
```
Find production examples of multi-step forms using WDS CustomModalLayout 
and React Hook Form with validation
```
