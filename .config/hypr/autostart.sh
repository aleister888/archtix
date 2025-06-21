#!/bin/bash
# shellcheck disable=SC1091

# Script Iniciador del entorno de escritorio
# por aleister888 <pacoe1000@gmail.com>

source "$HOME/.dotfiles/.profile"
# Leemos nuestro perfil de zsh
. "$XDG_CONFIG_HOME/zsh/.zprofile"

XDG_RUNTIME_DIR=/run/user/$(id -u)
export XDG_RUNTIME_DIR

# Mostramos el fondo de pantalla
hyprpaper

# Cerrar instancias previas del script
PROCESSLIST=/tmp/startScript_processes
MY_ID=$BASHPID

grep -v "^$MY_ID$" "$PROCESSLIST" | while read -r ID; do
	kill -9 "$ID" 2>/dev/null
done

echo $MY_ID | tee $PROCESSLIST >/dev/null

#############
# Funciones #
#############

virtualmic() {
	sleep 15 # Esperamos 15 segundos para que se carguen los sinks reales
	# Contador para evitar bucles infinitos
	local COUNTER=0
	# Salir si se encuentra el sink
	pactl list | grep '\(Name\|Monitor Source\): my-combined-sink' && exit

	# En caso contrario, intentar crear el sink cada 5 segundos durante un
	# máximo de 5 intentos
	while [ $COUNTER -lt 6 ]; do
		# Verificar si Wireplumber está en ejecución
		pgrep wireplumber && ~/.local/bin/pipewire-virtualmic &
		# Esperar 5 segundos antes del siguiente intento
		COUNTER=$((COUNTER + 1))
		sleep 5
	done
	exit
}

##########
# Script #
##########

# Leer la configuración Xresources
if [ -f "$XDG_CONFIG_HOME/Xresources" ]; then
	xrdb -merge "$XDG_CONFIG_HOME/Xresources"
fi

# Joycond para emuladores
if [ -x /usr/bin/joycond ] && ! pgrep -x joycond; then
	/usr/bin/joycond &
fi
if [ -x /usr/bin/joycond-cemuhook ] && ! pgrep -f joycond-cemuhook; then
	/usr/bin/joycond-cemuhook &
fi

# Esperar a que se incie wireplumber para activar el micrófono virtual
# (Para compartir el audio de las aplicaciones através del micrófono)
virtualmic &

# Corregir el nivel del micrófono en portátiles
if [ -e /sys/class/power_supply/BAT0 ]; then
	sleep 15 # Esperamos 15 segundos para que se carguen los sinks reales
	MIC=$(pactl list short sources |
		grep -E "alsa_input.pci-[0-9]*_[0-9]*_[0-9].\.[0-9].analog-stereo" |
		awk '{print $1}')
	pactl set-source-volume "$MIC" 25%
fi &

# Iniciar hydroxide si está instalado
# https://github.com/emersion/hydroxide?tab=readme-ov-file#usage
[ -x /usr/bin/hydroxide ] && hydroxide imap &

# Limpiar directorio $HOME
cleaner
