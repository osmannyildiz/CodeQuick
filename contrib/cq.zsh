# CodeQuick Zsh wrapper
# Add this to your .zshrc to enable 'cq cd' to change your shell's working directory:
# source $HOME/aa/code/shell/codequick/contrib/cq.zsh

cq() {
  if [[ "$1" == cd ]]; then
    shift
    local destination
    destination="$($HOME/aa/code/shell/codequick/bin/cq _cd "$@")"
    [[ -n "$destination" ]] && builtin cd "$destination"
    return
  fi
  
  # If not 'cd', just run the command as usual
  $HOME/aa/code/shell/codequick/bin/cq "$@"
}
