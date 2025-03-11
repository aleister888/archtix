#!/bin/bash

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
processlist=/tmp/startScript_processes
my_id=$BASHPID
instancias="$(pgrep -c -x "$(basename "$0")")"
echo $my_id | tee -a $processlist >/dev/null

for _ in $(seq $((instancias - 1))); do
	pkill -o "$(basename "$0")"
done

for id in $(grep -v "^$my_id$" "$processlist"); do
	kill -9 "$id" 2>/dev/null
done

# Cerramos eww
pkill eww

# Permite al usuario root conectarse al servidor X (p.e. Para compartir el porta-papeles)
xhost +SI:localuser:root

#############
# Funciones #
#############

# Función para ajustar el tamaño del widget de eww en función de la resolución
# y abrirlo solo si hay un único monitor y ninguna ventana abierta
ewwspawn() {
	while true; do
		local monitors
		local resolution
		# Contamos el numero de monitores activos
		monitors=$(xrandr | awk '/ connected/ { print $1 }' | wc -l)
		# Definir el archivo al que apunta el enlace simbólico actual
		current_link=$(readlink -f "$XDG_CONFIG_HOME/eww/dashboard.scss")

		# Definir los archivos de los que se crearán los enlaces simbólicos
		file_1080="$HOME/.dotfiles/.config/eww/dashboard/dashboard1080p.scss"
		file_2160="$HOME/.dotfiles/.config/eww/dashboard/dashboard2160p.scss"

		# Ejecutar xrandr y obtener la resolución vertical del monitor primario
		resolution=$(
			xrandr |
				grep -E ' connected (primary )?[0-9]+x[0-9]+' |
				awk -F '[x+]' '{print $2}'
		)

		# Verificar y crear enlaces simbólicos según los rangos de resolución
		if [[ $resolution -ge 2160 ]]; then
			[[ "$current_link" != "$file_2160" ]] &&
				ln -sf "$file_2160" "$XDG_CONFIG_HOME/eww/dashboard.scss"
		else
			[[ "$current_link" != "$file_1080" ]] &&
				ln -sf "$file_1080" "$XDG_CONFIG_HOME/eww/dashboard.scss"
		fi

		# Cerrar el widget si hay mas de un monitor en uso o alguna
		# ventana activa
		if
			[ "$monitors" -gt 1 ] ||
				xdotool getactivewindow &>/dev/null ||
				pgrep i3lock &>/dev/null
		then
			pkill eww

		# Invocar nuestro widget si hay un solo monitor activo y eww no esta
		# ya en ejecución
		elif [ "$monitors" -lt 2 ] && ! pgrep eww >/dev/null; then
			eww open dashboard &
		fi

		# Esperar antes de ejecutar el bucle otra vez
		sleep 0.2

	done
}

virtualmic() {
	# Contador para evitar bucles infinitos
	local counter=0
	# Salir si se encuentra el sink
	pactl list | grep '\(Name\|Monitor Source\): my-combined-sink' && exit

	# En caso contrario, intentar crear el sink cada 5 segundos durante un
	# máximo de 5 intentos
	while [ $counter -lt 6 ]; do
		# Verificar si Wireplumber está en ejecución
		pgrep wireplumber && ~/.local/bin/pipewire-virtualmic &
		# Esperar 5 segundos antes del siguiente intento
		counter=$((counter + 1))
		sleep 5
	done
	exit
}

##########
# Script #
##########

# Desactivar el atenuado de la pantalla
xset -dpms && xset s off &

# Leer la configuración Xresources
if [ -f "$XDG_CONFIG_HOME/Xresources" ]; then
	xrdb -merge "$XDG_CONFIG_HOME/Xresources"
fi

# Ocultar el cursor si no se está usando
pgrep unclutter || unclutter --start-hidden --timeout 2 &

# Pipewire
pgrep pipewire || pipewire-start &

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
	mic=$(pactl list short sources |
		grep -E "alsa_input.pci-[0-9]*_[0-9]*_[0-9].\.[0-9].analog-stereo" |
		awk '{print $1}')
	pactl set-source-volume "$mic" 25%
fi

# Servicio de notificaciones
pgrep dunst || dunst &

# Esperar a que se incie wireplumber para activar el micrófono virtual
# (Para compartir el audio de las aplicaciones através del micrófono)
virtualmic &
ewwspawn &

# Salvapantallas
xautolock -time 5 -locker screensaver &

while true; do
	resultado=0 # Reinicamos la variable antes de hacer las comprobaciones

	# Si alguno de estos procesos esta activo, no mostrar el salvapantallas
	processes=("i3lock")
	for process in "${processes[@]}"; do
		! pgrep "$process" >/dev/null
		resultado=$((resultado + $?))
	done

	activewindow="$(xdotool getwindowclassname "$(xdotool getactivewindow)")"

	# Si alguna de estas aplicaciones esta enfocada y reproduciendo
	# vídeo/audio, no mostrar el salvapantallas
	players=("vlc" "firefox" "mpv")
	for player in "${players[@]}"; do
		if [ "$(playerctl --player "$player" status)" == "Playing" ] &&
			[ "$activewindow" = "$player" ]; then
			resultado=1
			break
		fi
	done

	# Si alguna de estas apps esta enfocada, no mostrar el salvapantallas
	apps="looking-glass\|TuxGuitar"
	echo "$activewindow" | grep "$apps" && resultado=1

	# Reinciar xautolock en función de los resultados
	if [ "$resultado" -ne 0 ]; then
		xautolock -enable
		pkill dvdbounce
	fi

	sleep 0.5 # Esperar 0.5s antes de hacer la siguiente comprobación
done &

# Servidor VNC Local (Solo para equipos que no lleven batería)
if [ ! -e /sys/class/power_supply/BAT0 ]; then
	pgrep x0vncserver || x0vncserver -localhost -SecurityTypes none &
fi

# Iniciar hydroxide si está instalado
# https://github.com/emersion/hydroxide?tab=readme-ov-file#usage
[ -f /usr/bin/hydroxide ] && hydroxide imap &

# Limpiar directorio $HOME
cleaner
