# Plugins
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh
source "${XDG_CONFIG_HOME:-$HOME/.config}"/zsh/aliasrc
source /etc/os-release

bindkey -e

# Autocompletación con TAB
autoload -U compinit
zstyle ':completion:*' menu select
zmodload zsh/complist
compinit
_comp_options+=(globdots) # Incluir archivos ocultos

# Tipo de autocompletación
autoload -U select-word-style
select-word-style bash

# Cambiar directorios con lf (Ctrl+O)
lfcd () {
	tmp="$(mktemp)"
	lf -last-dir-path="$tmp" "$@"
	if [ -f "$tmp" ]; then
		dir="$(cat "$tmp")"
		rm -f "$tmp"
		[ -d "$dir" ] && [ "$dir" != "$(pwd)" ] && cd "$dir"
	fi
}
bindkey -s '^o' 'lfcd\n'

HISTSIZE=512
SAVEHIST=512

# Bindings de teclado
bindkey  "^[[3~" delete-char

bindkey '^[OA' history-substring-search-up
bindkey '^[OB' history-substring-search-down

bindkey "^[[1;5C" forward-word
bindkey "^[[1;5D" backward-word

# Funcion para imprimir la dirección IP local en el prompt
function get_local_ip {
	adress=$(ip addr show | grep inet | grep -v 127.0.0.1 | awk '{print $2}' | grep -oE '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' | head -1)
	if [ ! -z $adress ]; then
		echo $adress
	else
		echo "N/A"
	fi
}

function get_time {
	date +'%H:%M:%S'
}

function precmd {
PROMPT="%B%F{red}[%F{yellow}$(get_time)%F{green}/%F{blue}$(get_local_ip)%F{white}:%F{magenta}%~%F{red}]%F{white}$ %b"
}

setopt promptsubst

printf '\033[?1h\033=' >/dev/tty

if [ "$ID" = "artix" ]; then
	fastfetch -c screenfetch -l artix2_small
elif [ "$ID" = "arch" ]; then
	fastfetch -c screenfetch
fi

source "$HOME/.profile"
