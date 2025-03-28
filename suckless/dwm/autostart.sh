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
nitrogen --restore

# Cerrar instancias previas del script
PROCESSLIST=/tmp/startScript_processes
MY_ID=$BASHPID

grep -v "^$MY_ID$" "$PROCESSLIST" | while read -r ID; do
	kill -9 "$ID" 2>/dev/null
done

echo $MY_ID | tee $PROCESSLIST >/dev/null

# Permite al usuario root conectarse al servidor X (Para usar el porta-papeles)
xhost +SI:localuser:root

#############
# Funciones #
#############

virtualmic() {
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

# Ocultar el cursor si no se está usando
pgrep unclutter || unclutter --start-hidden --timeout 2 &

# Iniciar el compositor (Solo en maquinas real.)
grep "Q35\|VMware" /sys/devices/virtual/dmi/id/product_name ||
	pgrep picom || picom &

# Servicios del sistema
pgrep polkit-gnome || /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &
pgrep gnome-keyring || gnome-keyring-daemon -r -d &
pgrep udiskie || udiskie -t -a & # Auto-montador de discos
pgrep dwmblocks || dwmblocks &   # Barra de estado
pgrep nm-applet || nm-applet &   # Applet de red

# Si se detecta una tarjeta bluetooth, iniciar blueman-applet
if echo "$(
	lspci
	lsusb
)" | grep -i bluetooth; then
	pgrep blueman-applet || blueman-applet &
fi

# Corregir el nivel del micrófono en portátiles
if [ -e /sys/class/power_supply/BAT0 ]; then
	MIC=$(pactl list short sources |
		grep -E "alsa_input.pci-[0-9]*_[0-9]*_[0-9].\.[0-9].analog-stereo" |
		awk '{print $1}')
	pactl set-source-volume "$MIC" 50%
fi

# Servicio de notificaciones
pgrep dunst || dunst &

# Esperar a que se incie wireplumber para activar el micrófono virtual
# (Para compartir el audio de las aplicaciones através del micrófono)
virtualmic &

# Servidor VNC Local (Solo para equipos que no lleven batería)
if [ ! -e /sys/class/power_supply/BAT0 ]; then
	pgrep x0vncserver || x0vncserver -localhost -SecurityTypes none &
fi

# Iniciar hydroxide si está instalado
# https://github.com/emersion/hydroxide?tab=readme-ov-file#usage
[ -x /usr/bin/hydroxide ] && hydroxide imap &

# Limpiar directorio $HOME
cleaner
