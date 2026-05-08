# If not running interactively, don't do anything (leave this at the top of this file)
[[ $- != *i* ]] && return

# All the default Omarchy aliases and functions
# (don't mess with these directly, just overwrite them here!)
source ~/.local/share/omarchy/default/bash/rc

# Add your own exports, aliases, and functions here.
#
# Make an alias for invoking commands you use constantly
# alias p='python'

# fnm (Fast Node Manager) — replaces nvm, reads .nvmrc/.node-version automatically
eval "$(fnm env --use-on-cd --shell bash)"
alias nvm='fnm'
