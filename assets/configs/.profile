#!/bin/sh
# shellcheck disable=SC1091

# Abreviaciones
. "${XDG_CONFIG_HOME:-$HOME/.config}/zsh/aliasrc"

# Aquí puedes colocar alias sin que estos esten
# dentro de la estructura del repositorio
if [ -e "${XDG_CONFIG_HOME:-$HOME/.config}/useralias" ]; then
	. "${XDG_CONFIG_HOME:-$HOME/.config}/useralias"
fi

if [ -d "$HOME/.local/bin" ]; then
	PATH="$HOME/.local/bin:$PATH"
fi

# Añadir scripts de eww a $PATH
if [ -d "$HOME/.local/bin/eww" ]; then
	PATH="$HOME/.local/bin/eww:$PATH"
fi
# Añadir scripts de dwmblocks a $PATH
if [ -d "$HOME/.local/bin/sb" ]; then
	PATH="$HOME/.local/bin/sb:$PATH"
fi
# Añadir scripts a $PATH
if [ -d "$HOME/.local/bin/utils" ]; then
	PATH="$HOME/.local/bin/utils:$PATH"
fi

# Definir cursor usado por X11
export XCURSOR_PATH="/usr/share/icons:${XDG_DATA_HOME}/icons"
export XCURSOR_PATH=/usr/share/icons/
export XCURSOR_THEME=capitaine-cursors
export XCURSOR_SIZE=64

# Usar el filechooser del portal GTK
export GDK_SCALE=1
export GTK_USE_PORTAL=1
export GTK_THEME=Gruvbox-Dark

# Hacer que las aplicaciones QT sigan los ajustes de QT5CT
export QT_QPA_PLATFORMTHEME="qt5ct"

# XDG
export XDG_CURRENT_DESKTOP=X-Generic

# Apps
export OPENER="xdg-open"

# Arreglar aplicaciones de java
export _JAVA_AWT_WM_NONREPARENTING=1

# XDG
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_STATE_HOME="$HOME/.local/state"

# Apps
export EDITOR="nvim"
export SUDO_EDITOR="nvim"
export READER="zathura"
export TERMINAL="st"
export TERMTITLE="-t"
export TERMEXEC="-e"
export TERM="st-256color"
export BROWSER="firefox"
export VIDEO="mpv"
export PAGER="less"
export VIEWER="nsxiv"

# Limpiar el directorio ~/ de archivos de configuración
export PARALLEL_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"/parallel
export RUSTUP_HOME="$XDG_DATA_HOME"/rustup
export GOPATH="$XDG_DATA_HOME"/go
export TEXMFVAR="$XDG_CACHE_HOME"/texlive/texmf-var
export KODI_DATA="$XDG_DATA_HOME"/kodi
export DVDCSS_CACHE="$XDG_DATA_HOME"/dvdcss
export GNUPGHOME="${XDG_DATA_HOME:-$HOME/.local/share}/gnupg"
export CUDA_CACHE_PATH="${XDG_CACHE_HOME:-$HOME/.cache}/nv"
export GTK2_RC_FILES="${XDG_CONFIG_HOME:-$HOME/.config}/gtk-2.0/gtkrc:${XDG_CONFIG_HOME:-$HOME/.config}/gtk-2.0/gtkfilechooser.ini"
export WINEPREFIX="${XDG_CONFIG_HOME:-$HOME/.config}/wineprefixes"
export TERMINFO_DIRS="${XDG_CONFIG_HOME:-$HOME/.config}/terminfo:/usr/share/terminfo"
export HISTFILE="${XDG_DATA_HOME:-$HOME/.local/share}/history"
export LESSHISTFILE="$XDG_CACHE_HOME"/less/history
export CARGO_HOME="$XDG_DATA_HOME"/cargo
export NPM_CONFIG_USERCONFIG="${XDG_CONFIG_HOME:-$HOME/.config}"/npm/npmrc
