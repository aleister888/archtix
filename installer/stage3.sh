#!/bin/bash -x
# shellcheck disable=SC2068
# shellcheck disable=SC2154

# Auto-instalador para Artix OpenRC (Parte 3)
# por aleister888 <pacoe1000@gmail.com>
# Licencia: GNU GPLv3

# Esta parte del script se ejecuta como nuestro usuario creado, no como root.
# Una vez instalado yay, desinstalamos sudo y lo reemplazamos por opendoas.

# Importamos todos los componentes en los que se separa el script
PATH="$PATH:$(find ~/.dotfiles/modules -type d | paste -sd ':' -)"

yayinstall() { # Instalar paquetes con yay
	yay -Sy --noconfirm --needed "$@"
}

service_add() { # Activar servicio
	sudo rc-update add "$1" default
}

# Paquetes

# Guardamos nuestros paquetes en un array con mapfile desde los
# diferentes archivos
mapfile -t packages < <(
	cat "$HOME"/.dotfiles/assets/packages/* 2>/dev/null | grep -v "^#"
)

driver_add() {
	case $graphic_driver in

	amd)
		packages+=(
			"xf86-video-amdgpu"
			"mesa" "lib32-mesa"
			"vulkan-radeon" "lib32-vulkan-radeon"
		)
		;;

	nvidia)
		packages+=(
			"dkms" "nvidia-dkms" "nvidia-utils"
			"libva-vdpau-driver" "libva-mesa-driver"
			"nvidia-prime" "lib32-nvidia-utils"
			"nvidia-utils-openrc" "opencl-nvidia"
		)
		;;

	intel)
		packages+=(
			"xf86-video-intel"
			"libva-intel-driver" "lib32-libva-intel-driver"
			"vulkan-intel" "lib32-vulkan-intel"
		)
		;;

	virtual)
		packages+=(
			"xf86-video-vmware" "xf86-input-vmmouse"
			"vulkan-virtio" "lib32-vulkan-virtio"
		)
		;;

	esac
}

# Elegir el software a instalar
packages_add() {
	# Agregamos paquetes al array dependiendo de que se eligió
	if [ "$virt" == "true" ]; then
		while IFS= read -r package; do
			packages+=("$package")
		done <"$HOME/.dotfiles/assets/packages/opt/virt"
	fi
	if [ "$latex" == "true" ]; then
		while IFS= read -r package; do
			packages+=("$package")
		done <"$HOME/.dotfiles/assets/packages/opt/latex"
	fi
	if [ "$audioProd" == "true" ]; then
		while IFS= read -r package; do
			packages+=("$package")
		done <"$HOME/.dotfiles/assets/packages/opt/daw"
	fi

	[ "$music" == "true" ] &&
		packages+=(
			"easytag" "picard" "flacon"
			"cuetools" "lrcget-bin" "python-tqdm"
		)

	[ "$noprivacy" == "true" ] &&
		packages+=("discord" "telegram-desktop")

	[ "$office" == "true" ] &&
		packages+=("libreoffice" "libreoffice-fresh-es")
}

# Configurar Xresources
xresources_make() {
	mkdir -p "$HOME/.config"
	XRES_FILE="$HOME/.config/Xresources"
	cp "$HOME/.dotfiles/assets/configs/Xresources" "$XRES_FILE"
	# Añadimos nuestro DPI a el arcivo Xresources
	echo "Xft.dpi:$final_dpi" | tee -a "$XRES_FILE"
}

# Descargar los archivos de diccionario
vim_spell_download() {
	mkdir -p "$HOME/.local/share/nvim/site/spell/"
	wget "https://ftp.nluug.nl/pub/vim/runtime/spell/es.utf-8.spl" \
		-q -O "$HOME/.local/share/nvim/site/spell/es.utf-8.spl"
	wget "https://ftp.nluug.nl/pub/vim/runtime/spell/es.utf-8.sug" \
		-q -O "$HOME/.local/share/nvim/site/spell/es.utf-8.sug"
}

# Crear enlaces simbólicos a /usr/local/bin para ciertos scripts
scripts_link() {
	files=(
		"wakeat"
		"wakeme"
		"pipewire-start"
		"tray-toggle"
		"rdp-connect"
	)
	for file in "${files[@]}"; do
		sudo ln -sf "$HOME/.dotfiles/bin/$file" "/usr/local/bin/$file"
	done
}

# Crear el directorio /.Trash con permisos adecuados
trash_dir() {
	sudo mkdir --parent /.Trash
	sudo chmod a+rw /.Trash
	sudo chmod +t /.Trash
}

##########################
# Aquí empieza el script #
##########################

# Instalamos yay (https://aur.archlinux.org/packages/yay)
yay-install

# Reemplamos sudo por doas
sudo sudo2doas

# Crear directorios
for dir in Documentos Música Imágenes Público Vídeos; do
	mkdir -p "$HOME/$dir"
done
ln -s /tmp/ "$HOME/Descargas"

# Escogemos que drivers de vídeo instalar
driver_add

# Elegimos que paquetes instalar
packages_add

# Calcular el DPI de nuestra pantalla y configurar Xresources
xresources_make

# Antes de instalar los paquetes, configurar makepkg para
# usar todos los núcleos durante la compliación
sudo sed -i "s/-j2/-j$(nproc)/;/^#MAKEFLAGS/s/^#//" /etc/makepkg.conf

# Instalar grub-btrfs solo si / es una partición btrfs
if [ "$ROOT_FILESYSTEM" == "btrfs" ]; then
	packages+=("grub-btrfs")
fi

# Instalamos todos los paquetes a la vez
while true; do
	yayinstall "${packages[@]}" &&
		break
done

# Crear directorio para montar dispositivos android
sudo mkdir /mnt/ANDROID
sudo chown "$USER" /mnt/ANDROID

# Configuramos Tauon Music Box (Nuestro reproductor de música)
"$HOME/.dotfiles/bin/tauon-config"

# Establecemos la versión de java por defecto
sudo archlinux-java set java-21-openjdk

# Descargar los diccionarios para vim
vim_spell_download

# Instalar los archivos de configuración e instalar plugins de zsh
dotfiles-install

# Crear enlaces simbólicos a /usr/local/bin/ para ciertos scripts
scripts_link

# Crear el directorio /.Trash con permisos adecuados
trash_dir

# Configurar cronie para iniciar syncthing con el ordenador y asignar la swap
cat <<-EOF | sudo tee -a /etc/crontab >/dev/null
	@reboot $USER syncthing --no-browser --no-default-folder
	@reboot root sleep 5 && swapon /swap/swapfile
EOF

# Si estamos usando una máquina virtual, configuramos X11 para funcionar a 1080p
[ "$graphic_driver" == "virtual" ] &&
	sudo cp "$HOME/.dotfiles/assets/system/xorg/xorg.conf" /etc/X11/xorg.conf

# Activar servicios
service_add elogind
service_add earlyoom
service_add tlp
service_add xdm
service_add syslog-ng

# Activar WiFi y Bluetooth
sudo rfkill unblock wifi
{ lspci | grep -i bluetooth || lsusb | grep -i bluetooth; } >/dev/null &&
	sudo rfkill unblock bluetooth

# /etc/polkit-1/rules.d/99-artix.rules
sudo usermod -aG storage,input,users "$USER"

# Configurar el software de instalación opcional
[ "$virt" == "true" ] && sudo virt-conf
[ "$audioProd" == "true" ] && sudo audioProd-conf
[ "$music" == "true" ] && lrcput-install

# Configurar el audio de baja latencia
sudo audio-setup
# Configuramos el reloj según la zona horaria escogida
sudo set-clock

# Añadir entradas a /etc/environment
cat <<-'EOF' | sudo tee -a /etc/environment
	CARGO_HOME="~/.local/share/cargo"
	GNUPGHOME="~/.local/share/gnupg"
EOF

WINEPREFIX="$HOME/.config/wineprefixes" winetricks -q mfc42

# Borrar archivos innecesarios
rm "$HOME"/.bash* 2>/dev/null
rm "$HOME"/.wget-hsts 2>/dev/null

mkdir -p "$HOME"/.local/share/gnupg

############
# Arreglos #
############

pacman -Q poppler >/dev/null 2>&1 &&
	sudo ln -s /usr/lib/libpoppler-cpp.so.2.0.0 \
		/usr/lib/libpoppler-cpp.so.1 2>/dev/null
