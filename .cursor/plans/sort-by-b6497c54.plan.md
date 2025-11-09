<!-- b6497c54-5b56-4aca-8035-c001c507c454 380801be-899d-4387-9c75-ef80ff40322c -->
# Sort Projects by Last Access Time

## Overview

Add sorting by modification time (most recently accessed first) to project listings using filesystem timestamps. When a project is selected, touch its symlink to update the timestamp.

## Implementation Steps

### 1. Add Helper Functions

Add two new helper functions after the existing helper functions (around line 47, after `sanitize_name()`):

```zsh
get_sorted_links() {
  ls -t "$LINKS_DIR" 2>/dev/null | grep -v '^\.' || ls -1 "$LINKS_DIR" 2>/dev/null
}

record_access() {
  touch -h "$LINKS_DIR/$1" 2>/dev/null || true
}
```

- `get_sorted_links()`: Uses `ls -t` to sort by modification time (newest first), filters out dot-files, falls back to alphabetical if sorting fails
- `record_access()`: Touches the symlink (using `-h` to touch the link itself, not the target) to update its modification time

### 2. Update Interactive Commands

Update three commands to use sorted listing and record access:

**`cmd_ls()` (line 51-63):**

- Replace `ls -1 "$LINKS_DIR"` with `get_sorted_links`
- Add `record_access "$selected"` before the clipboard copy

**`cmd__cd()` (line 66-72):**

- Replace `ls -1 "$LINKS_DIR"` with `get_sorted_links`
- Add `record_access "$selected"` before the echo

**`cmd_open()` (line 74-80):**

- Replace `ls -1 "$LINKS_DIR"` with `get_sorted_links`
- Add `record_access "$selected"` before the cursor command

## Side Effects (Features)

- Renaming a project naturally bumps it to the top since `mv` updates modification time
- Creating a new project puts it at the top automatically
- Simple, no extra files or state to manage