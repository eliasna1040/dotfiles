# Startup banner, shown when a new Alacritty window opens.
# Sourced from ~/.zshrc before the Powerlevel10k instant prompt.

() {
  local b=$'\e[1;34m' c=$'\e[36m' d=$'\e[90m' r=$'\e[0m'
  local os=${${(M)${(f)"$(</etc/os-release)"}:#PRETTY_NAME=*}#PRETTY_NAME=}
  local up=$(uptime -p 2>/dev/null)

  local -a art=(
    "${b}   ▄▀▀▀▀▀▀▀▀▄ ${r}"
    "${b}   █ ${c}>_${b}     █ ${r}"
    "${b}   █        █ ${r}"
    "${b}   ▀▄▄▄▄▄▄▄▄▀ ${r}"
  )
  local -a info=(
    "${b}Hello, ${USER}!${r}"
    "${d}${(Q)os} on ${HOST}${r}"
    "${d}${up}${r}"
    "${d}$(LC_ALL=C date '+%A %d %B, %H:%M')${r}"
  )

  print
  local i
  for i in {1..4}; print -r -- "${art[i]}  ${info[i]}"
  print
}
