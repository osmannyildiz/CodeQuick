<!-- c7e12bb9-8e90-4e14-9573-a70c8a8398ac 8dfe8709-cf5c-4be7-898b-422eac8b88c3 -->
# CodeQuick MVP Plan

### Scope

Implement a single Zsh script `bin/cq` that manages projects under `/Users/osman/aa/code/_cq` with commands: `ls`, `cd`, `mk`, `cp`, `rm`, `rename`, `path`. Provide a small `.zshrc` wrapper so `cq cd` changes the parent shell.

### Key Behaviors

- Real dirs live in `reals/`, symlinks in `links/`.
- Link names are sanitized to kebab-case; duplicates are rejected (including after sanitization).
- Copy uses `cp -a -c` and includes dotfiles and `.git`.
- Unique real dir names created with `mktemp -d reals/cq-XXXXXXXX`.
- `cq ls` uses `fzf`; Enter copies the selected link name to clipboard via `pbcopy`.
- `cq cd` resolves the selected link to its absolute path and emits it; the wrapper runs `builtin cd`.
- `cq rm` moves both the resolved real dir and the symlink to Trash using macOS `trash`.
- `cq path` prints absolute real dir path.

### Files

- `bin/cq` (zsh script)
- Optional: `contrib/cq.zsh` (wrapper the user can paste into `.zshrc`)

### Essential Snippets

- `.zshrc` wrapper (concept):
```sh
cq() {
  if [[ "$1" == cd ]]; then shift; local d; d="$(/absolute/path/to/bin/cq __cd "$@")"; [[ -n "$d" ]] && builtin cd "$d"; return
  fi
  /absolute/path/to/bin/cq "$@"
}
```


### Command Details

- `cq mk <LINK_NAME>`: sanitize; ensure `links/<name>` absent; create `reals/cq-XXXXXXXX`; create symlink `links/<name>` -> `../reals/<id>` (relative is fine); error if exists.
- `cq cp <LINK_NAME> <NEW_LINK_SUFFIX>`: resolve `links/<name>` -> real; mktemp dest; `cp -a -c src/ dest/`; create `links/<name>__<suffix>`; error if link exists.
- `cq rename <LINK_NAME> <NEW_LINK_NAME>`: sanitize new; ensure not exists; `mv links/old links/new`.
- `cq ls`: list `links/*` basenames piped to `fzf`; on Enter, `pbcopy` selected name; optionally echo selection.
- `cq cd`: same selection as `ls` but emit absolute path of selected link target (for wrapper).
- `cq path <LINK_NAME>`: print absolute path of target real dir.
- `cq rm <LINK_NAME>`: resolve; `trash reals/<id>`; `trash links/<name>`; error clearly if either side missing or mismatch.

### Error Handling

- Fail early on missing args.
- Non-zero exit codes on errors; concise messages.
- Assume `fzf`, `trash`, `pbcopy`, and `cp` with `-a -c` exist (MVP requirement).

### To-dos

- [ ] Create zsh script bin/cq with command parsing
- [ ] Implement kebab-case sanitization and collision checks
- [ ] Implement cq mk using mktemp and symlink creation
- [ ] Implement cq cp with cp -a -c and new symlink
- [ ] Implement cq rename with sanitization checks
- [ ] Implement cq ls and __cd with fzf and pbcopy
- [ ] Implement cq path to print absolute real path
- [ ] Implement cq rm using trash for link and real
- [ ] Provide .zshrc wrapper to make cq cd change PWD