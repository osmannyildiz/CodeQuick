<!-- 5a1c5b21-c2aa-454a-ae41-748cb43fcda6 25d147ff-ed26-46cb-9949-6590e51cafe1 -->
# Set Cursor Window Title to Project Name

## Implementation

### 1. Create helper function `set_window_title`

Add a new helper function after the existing helper functions (around line 40-55) in `bin/cq`:

```bash
set_window_title() {
  local real_path="$1"
  local link_name="$2"
  local settings_dir="$real_path/.vscode"
  local settings_file="$settings_dir/settings.json"
  
  mkdir -p "$settings_dir"
  
  if [[ -f "$settings_file" ]]; then
    # Merge with existing settings
    jq --arg title "$link_name" '. + {"window.title": $title}' "$settings_file" > "$settings_file.tmp" \
      && mv "$settings_file.tmp" "$settings_file"
  else
    # Create new settings file
    jq -n --arg title "$link_name" '{"window.title": $title}' > "$settings_file"
  fi
}
```

### 2. Update `cmd_mk`

After creating the symlink (line 116), add call to set window title:

```bash
ln -s "../reals/$real_id" "$LINKS_DIR/$link_name" || { print_err "Failed to create symlink"; exit 1; }
set_window_title "$real_path" "$link_name"
```

### 3. Update `cmd_cp`

After creating the new symlink (line 140), add call to set window title:

```bash
ln -s "../reals/$new_real_id" "$LINKS_DIR/$new_link_name" || { print_err "Failed to create symlink"; exit 1; }
set_window_title "$new_real_path" "$new_link_name"
```

### 4. Update `cmd_rename`

After renaming the link (line 156), add call to update window title:

```bash
mv "$LINKS_DIR/$old_link_name" "$LINKS_DIR/$new_link_name"
local real_path
real_path=$(get_real_path_from_link_name "$new_link_name") || { print_err "Failed to resolve real path"; return 1; }
set_window_title "$real_path" "$new_link_name"
```

## Result

After these changes, whenever a project is created, copied, or renamed, its `.vscode/settings.json` will be updated to show the user-friendly link name in the Cursor window title instead of the internal `cq-XXXXXXXX` directory name.