# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
setopt autocd
bindkey -e
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '/home/wasted/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall

setopt -o sharehistory
############ENVIRONMENT
if  [[ -z "${CONTAINER_ID}" ]] then
	export $(envsubst < '/home/wasted/.env')
fi
# export $(envsubst < '/home/wasted/.env')
export PATH=$PATH:~/go/bin:~/.local/bin
############Prompt
##################
# PROMPT='%F{#6a6a6a}%n@%F{#6a6a6a}%m%F{#1f7177} '$CONTAINER_ID' %f%B%~%b%F{#6a6a6a} > ' 
PROMPT='%F{#1f7177}'$CONTAINER_ID' %f%B%(2~|.../%1~|%~)%b%F{#6a6a6a} > ' 
RPROMPT='%(1j.%j job(s).)%f[%F{#1f7177}%?%f]'

###########Aliases
##################
alias ls='ls --color=auto --group-directories-first'
alias tree='tree -C'

###########Plugins
##################
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

#additional keybindings
#######################
typeset -g -A key

key[Home]="${terminfo[khome]}"
key[End]="${terminfo[kend]}"
key[Insert]="${terminfo[kich1]}"
key[PageUp]="${terminfo[kpp]}"
key[PageDown]="${terminfo[knp]}"
key[Delete]="${terminfo[kdch1]}"
key[Control-Left]="${terminfo[kLFT5]}"
key[Control-Right]="${terminfo[kRIT5]}"

[[ -n "${key[Home]}"      ]] && bindkey -- "${key[Home]}"       beginning-of-line
[[ -n "${key[End]}"       ]] && bindkey -- "${key[End]}"        end-of-line
[[ -n "${key[Insert]}"    ]] && bindkey -- "${key[Insert]}"     overwrite-mode
[[ -n "${key[PageUp]}"    ]] && bindkey -- "${key[PageUp]}"     beginning-of-buffer-or-history
[[ -n "${key[PageDown]}"  ]] && bindkey -- "${key[PageDown]}"   end-of-buffer-or-history
[[ -n "${key[Delete]}"    ]] && bindkey -- "${key[Delete]}"     delete-char
[[ -n "${key[Control-Left]}"  ]] && bindkey -- "${key[Control-Left]}"  backward-word
[[ -n "${key[Control-Right]}" ]] && bindkey -- "${key[Control-Right]}" forward-word

# Finally, make sure the terminal is in application mode, when zle is
# # active. Only then are the values from $terminfo valid.
if (( ${+terminfo[smkx]} && ${+terminfo[rmkx]} )); then
	autoload -Uz add-zle-hook-widget
	function zle_application_mode_start { echoti smkx }
	function zle_application_mode_stop { echoti rmkx }
	add-zle-hook-widget -Uz zle-line-init zle_application_mode_start
	add-zle-hook-widget -Uz zle-line-finish zle_application_mode_stop
fi


#######Set terminal-emulator Title###############
#################################################
#https://wiki.archlinux.org/title/Zsh#xterm_title

autoload -Uz add-zsh-hook

function xterm_title_precmd () {
	print -Pn -- '\e]2;%~\a'
	[[ "$TERM" == 'screen'* ]] && print -Pn -- '\e_\005{g}%n\005{-}@\005{m}%m\005{-} \005{B}%~\005{-}\e\\'
}

function xterm_title_preexec () {
	print -Pn -- '\e]2;%~ %# ' && print -n -- "${(q)1}\a"
	[[ "$TERM" == 'screen'* ]] && { print -Pn -- '\e_\005{g}%n\005{-}@\005{m}%m\005{-} \005{B}%~\005{-} %# ' && print -n -- "${(q)1}\e\\"; }
}

if [[ "$TERM" == (foot*|Eterm*|alacritty*|aterm*|gnome*|konsole*|kterm*|putty*|rxvt*|screen*|tmux*|xterm*) ]]; then
	add-zsh-hook -Uz precmd xterm_title_precmd
	add-zsh-hook -Uz preexec xterm_title_preexec
fi


#######use dirstack to remember and quickliy navigate recent dirs##############
###############################################################################
#https://man.archlinux.org/man/zshcontrib.1#REMEMBERING_RECENT_DIRECTORIES
autoload -Uz chpwd_recent_dirs cdr add-zsh-hook
add-zsh-hook chpwd chpwd_recent_dirs

zstyle ':completion:*:*:cdr:*:*' menu selection
zstyle ':completion:*' rehash true

eval "$(zoxide init zsh)"


# Begin: PlatformIO Core completion support
if  [[ -z "${CONTAINER_ID}" ]] then
	eval "$(_PIO_COMPLETE=zsh_source pio)"
fi
# End: PlatformIO Core completion support

