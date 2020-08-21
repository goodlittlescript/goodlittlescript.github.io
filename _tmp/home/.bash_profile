_Projectfile_completions() {
  COMPREPLY=($(compgen -o default -W "$(./Projectfile list 2>/dev/null)" "${COMP_WORDS[1]}"))
}
complete -F _Projectfile_completions Projectfile
