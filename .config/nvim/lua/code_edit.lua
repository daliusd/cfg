local log = require("codecompanion.utils.log")

local M = {
  name = "code_edit",
}

M.system_prompt = function()
  return [=[
## Code Editing Tool（`code_edit`） - Usages

### Purposes
Modify the content of a Neovim buffer by adding, updating, or deleting code when explicitly requested.

### When to Use:
- Only invoke the Code Editor Tool when the user specifically asks (e.g., "can you update the code?" or "update the buffer...").
- Use this tool solely for buffer edit operations. Other file tasks should be handled by the designated tools.

### How to use
- "Line" refers to a line of text in the buffer, delimited by a newline character, even if it does not form a single complete syntactic structure in the programming language code.
- Always return XML code wrapped in a Markdown code block. DO NOT forget the triple backticks.
- Use a <tool name="code_edit"> tag inside the <tools> tag to specify this tool.
- Group all operations of a single buffer in one <action> tag. Operations of different buffers should go in separate <action> tags.
- The following operations are supported:
  * <operation type="add">: Insert code before a specific line.
  * <operation type="append">: Add code at the end of the buffer.
  * <operation type="update">: Replace a block of code.
  * <operation type="delete">: Remove a block of code.
- Identify a buffer by its number. If the buffer number is not provided, stop execution and notify the user.
- Code text must be wrapped in a CDATA section to preserve special characters.
- Follow the coding style and conventions of the original buffer, including indentation, line breaks, and other formatting.
- Try to shrink the affected range of each operation. No need to include context lines that need not be modified.
- When locating a position to modify:
  * No two operations of the same buffer should overlap. Merge adjacent operations if possible.
  * Specify the line location using <before_line>, <first_line> and <last_line> (inclusive) tags.
  * Use the line numbers provided with the source buffer when possible, otherwise assume the first line of the buffer is line 1.
  * Index the line according to the original content of the buffer, even if multiple operations are performed on the same buffer.
  * Along with the line number, include the original text of the line in the <before_line>, <first_line> and <last_line> tags. This text must match exactly with the line number you specified, even if it contains only punctuations, whitespaces or even nothing.

### Example
#### Given the following source buffer
Buffer number: 42
Filetype: c
Content:
```c
1:#include <stdio.h>
2:
3:void to_add() {
4:  printf("Add code before this line");
5:}
6:
7:void to_update() {
8:  /* Update this function */
9:  printf("Original content");
10:}
11:
12:void to_delete() {
13:  /* Delete this function */
14:  printf("Delete this function");
15:}
16:
17:// Lines can also be added at the end of the buffer
```

#### When you need to modify this buffer:
Comments in the XML are for explanation only, do not include them in your response.
```xml
<tools>
  <tool name="code_edit">
    <!-- All operations to the buffer 42 are specified in one <action> -->
    <action buffer="42">
      <!-- Use <operation type="add"> with <before_line> to insert code before a specific line -->
      <operation type="add">
        <before_line line="4"><![CDATA[  printf("Add code before this line");]]></before_line>
        <code><![CDATA[  printf("New code line 1");
    printf("New code line 2");]]></code>
      </operation>
      <!-- Use <operation type="append"> to add code at the end of the buffer -->
      <operation type="append">
        <code><![CDATA[void appended() {
  printf("This function is appended");
}]]></code>
      </operation>
      <!-- Use <operation type="update"> with <first_line> and <last_line> to replace a block of code -->
      <operation type="update">
        <first_line line="7"><![CDATA[void to_update() {]]></first_line>
        <last_line line="10"><![CDATA[}]]></last_line>
        <code><![CDATA[void updated() {
  printf("This function is updated, with different number of lines");
}  // End of to_update()]]></code>
      </operation>
      <!-- Use <operation type="delete"> with <first_line> and <last_line> to remove a block of code -->
      <operation type="delete">
        <first_line line="12"><![CDATA[void to_delete() {]]></first_line>
        <last_line line="15"><![CDATA[}]]></last_line>
      </operation>
    </action>
  </tool>
</tools>
```
]=]
end

---Finds the actual line number that matches the given text content near the expected line
---@param original_lines table All lines of the original buffer
---@param line_tag table The parsed <*_line line="N"> tag
---@return number Actual matching line number
local function reposition_line(original_lines, line_tag)
  local MAX_ABS_OFFSET = 5
  local LTRIM_PATTERN = "^%s*(.*)$" -- Remove leading spaces

  local line_number = line_tag._attr and tonumber(line_tag._attr.line)
  assert(line_number, "Line number not provided")
  local text = line_tag[1]
  if not text then
    log:info("No reference text provided for line %d", line_number)
    return line_number
  end
  local trimmed_text = text:gsub(LTRIM_PATTERN, "%1")

  -- check at line_number, +1, -1, +2, -2, ...
  for offset = 0, MAX_ABS_OFFSET do
    local line = original_lines[line_number + offset]
    if line and line:gsub(LTRIM_PATTERN, "%1") == trimmed_text then
      log:info("Reposition line %d to %d: %s", line_number, line_number + offset, line)
      return line_number + offset
    end

    line = offset > 0 and original_lines[line_number - offset]
    if line and line:gsub(LTRIM_PATTERN, "%1") == trimmed_text then
      log:info("Reposition line %d to %d: %s", line_number, line_number - offset, line)
      return line_number - offset
    end
  end

  log:warn("Line not found around %d: %s", line_number, text)
  return line_number
end

---@class OpBase
---@field type string The operation type. Defined in subclasses
---@field code string? The new code, if applicable. Defined in subclasses
local OpBase = {}
function OpBase:extend()
  return setmetatable({}, { __index = self })
end

---Returns the range parameters for `nvim_buf_set_lines`
---@return number, number: The start and end line indices (0-based, exclusive)
function OpBase:range_for_set_lines()
  error("Should be implemented by subclasses")
end

function OpBase:apply(buffer)
  local set_lines_start, set_lines_end = self:range_for_set_lines()
  vim.api.nvim_buf_set_lines(
    buffer,
    set_lines_start,
    set_lines_end,
    false,
    self.code and vim.split(self.code, "\n") or {}
  )
end

local OpAdd = OpBase:extend()
function OpAdd:new(op, original_lines)
  return setmetatable({
    type = "add",
    before_line = reposition_line(original_lines, op.before_line),
    code = op.code[1] or op.code,
  }, { __index = self })
end

function OpAdd:range_for_set_lines()
  return self.before_line - 1, self.before_line - 1
end

local OpAppend = OpBase:extend()
function OpAppend:new(op)
  return setmetatable({
    type = "append",
    code = op.code[1] or op.code,
  }, { __index = self })
end

function OpAppend:range_for_set_lines()
  return -1, -1
end

local OpUpdate = OpBase:extend()
function OpUpdate:new(op, original_lines)
  return setmetatable({
    type = "update",
    first_line = reposition_line(original_lines, op.first_line),
    last_line = reposition_line(original_lines, op.last_line),
    code = op.code[1] or op.code,
  }, { __index = self })
end

function OpUpdate:range_for_set_lines()
  return self.first_line - 1, self.last_line
end

local OpDelete = OpBase:extend()
function OpDelete:new(op, original_lines)
  return setmetatable({
    type = "delete",
    first_line = reposition_line(original_lines, op.first_line),
    last_line = reposition_line(original_lines, op.last_line),
  }, { __index = self })
end

function OpDelete:range_for_set_lines()
  return self.first_line - 1, self.last_line
end

---Create an operation object based on the operation type
---@param op table The operation table
---@param original_lines string[] The original lines of the buffer
---@return OpBase
local function create_operation(op, original_lines)
  if op._attr.type == "add" then
    return OpAdd:new(op, original_lines)
  elseif op._attr.type == "append" then
    return OpAppend:new(op)
  elseif op._attr.type == "update" then
    return OpUpdate:new(op, original_lines)
  elseif op._attr.type == "delete" then
    return OpDelete:new(op, original_lines)
  else
    error("Unsupported operation type: " .. op._attr.type)
  end
end

local function init_buffer_diff(buffer, original_lines)
  local md = require("mini.diff")
  md.set_ref_text(buffer, original_lines)
end

---Perform the requested action
---@param tools CodeCompanion.Tools
---@param action table The action to perform
---@return { status: string, msg: string }
local function run(tools, action)
  local buffer = tonumber(action._attr.buffer)
  if not buffer then
    return { status = "error", msg = "Buffer number missing or invalid" }
  end
  if buffer <= 0 then
    return { status = "error", msg = "Buffer number must be positive" }
  end
  if not vim.api.nvim_buf_is_loaded(buffer) then
    return { status = "error", msg = "Buffer not loaded" }
  end

  local original_lines = vim.api.nvim_buf_get_lines(buffer, 0, -1, false)
  local op_seq = vim.tbl_map(function(op)
    return create_operation(op, original_lines)
  end, vim.islist(action.operation) and action.operation or { action.operation })
  -- Sort operations by line number, so that we can check & apply them in order
  table.sort(op_seq, function(a, b)
    local a_start, _ = a:range_for_set_lines()
    local b_start, _ = b:range_for_set_lines()
    return a_start < b_start
  end)
  -- Verify that no two operations overlap
  for i = 1, #op_seq - 1 do
    local _, a_end = op_seq[i]:range_for_set_lines()
    local b_start, _ = op_seq[i + 1]:range_for_set_lines()
    if a_end > b_start then
      log:error("Operations overlap: %s and %s", vim.inspect(op_seq[i]), vim.inspect(op_seq[i + 1]))
      return { status = "error", msg = "Operations overlap" }
    end
  end
  -- Apply operations BACKWARDS to avoid line number changes
  init_buffer_diff(buffer, original_lines)
  for i = #op_seq, 1, -1 do
    log:debug("Applying operation %d: %s", i, vim.inspect(op_seq[i]))
    op_seq[i]:apply(buffer)
  end
  return { status = "success", msg = "OK" }
end

M.cmds = { run }

return M
