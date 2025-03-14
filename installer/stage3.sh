#!/bin/bash -x
# shellcheck disable=SC2068
# shellcheck disable=SC2154

# Auto-instalador para Artix OpenRC (Parte 3)
# por aleister888 <pacoe1000@gmail.com>
# Licencia: GNU GPLv3

# Importamos todos los componentes en los que se separa el script
PATH="$PATH:$(find ~/.dotfiles/installer/modules -type d | paste -sd ':' -)"

yayinstall() { # Instalar paquetes con yay
	yay -Sy --noconfirm --needed "$@"
}

# Guardamos nuestros paquetes a instalar en un array
mapfile -t PACKAGES < <(
	jq -r '.[] | .[]' "$HOME"/.dotfiles/assets/packages/*.json
)

driver_add() {
	case $GRAPHIC_DRIVER in

	amd)
		PACKAGES+=(
			"xf86-video-amdgpu"
			"mesa" "lib32-mesa"
			"vulkan-radeon" "lib32-vulkan-radeon"
		)
		;;

	nvidia)
		PACKAGES+=(
			"dkms" "nvidia-dkms" "nvidia-utils"
			"libva-vdpau-driver" "libva-mesa-driver"
			"nvidia-prime" "lib32-nvidia-utils"
			"nvidia-utils-openrc" "opencl-nvidia"
		)
		;;

	intel)
		PACKAGES+=(
			"xf86-video-intel"
			"libva-intel-driver" "lib32-libva-intel-driver"
			"vulkan-intel" "lib32-vulkan-intel"
		)
		;;

	vm)
		PACKAGES+=(
			"xf86-video-vmware" "xf86-input-vmmouse"
			"vulkan-virtio" "lib32-vulkan-virtio"
		)
		;;

	esac
}

# Configurar Xresources
xresources_make() {
	mkdir -p "$HOME/.config"
	XRES_FILE="$HOME/.config/Xresources"
	cp "$HOME/.dotfiles/assets/configs/Xresources" "$XRES_FILE"
	# Añadimos nuestro DPI a el arcivo Xresources
	echo "Xft.dpi:$FINAL_DPI" | tee -a "$XRES_FILE"
}

# Descargar los archivos de diccionario
vim_spell_download() {
	mkdir -p "$HOME/.local/share/nvim/site/spell/"
	wget "https://ftp.nluug.nl/pub/vim/runtime/spell/es.utf-8.spl" \
		-q -O "$HOME/.local/share/nvim/site/spell/es.utf-8.spl"
	wget "https://ftp.nluug.nl/pub/vim/runtime/spell/es.utf-8.sug" \
		-q -O "$HOME/.local/share/nvim/site/spell/es.utf-8.sug"
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
for DIR in Documentos Música Imágenes Público Vídeos; do
	mkdir -p "$HOME/$DIR"
done
ln -s /tmp/ "$HOME/Descargas"

# Escogemos que drivers de vídeo instalar
driver_add

# Calcular el DPI de nuestra pantalla y configurar Xresources
xresources_make

# Antes de instalar los paquetes, configurar makepkg para
# usar todos los núcleos durante la compliación
sudo sed -i "s/-j2/-j$(nproc)/;/^#MAKEFLAGS/s/^#//" /etc/makepkg.conf

# Instalar grub-btrfs solo si / es una partición btrfs
if [ "$ROOT_FILESYSTEM" == "btrfs" ]; then
	PACKAGES+=("grub-btrfs")
fi

# Instalamos todos los paquetes a la vez
while true; do
	yayinstall "${PACKAGES[@]}" &&
		break
done

# Crear directorio para montar dispositivos android
sudo mkdir /mnt/ANDROID
sudo chown "$USER" /mnt/ANDROID

# Configuramos Tauon Music Box (Nuestro reproductor de música)
tauon-config
# Configuramos firefox
firefox-config

# Establecemos la versión de java por defecto
sudo archlinux-java set java-21-openjdk

# Descargar los diccionarios para vim
vim_spell_download

# Instalar los archivos de configuración e instalar plugins de zsh
dotfiles-install

# Crear el directorio /.Trash con permisos adecuados
trash_dir

# Configurar cronie para iniciar syncthing con el ordenador y asignar la swap
cat <<-EOF | sudo tee -a /etc/crontab >/dev/null
	@reboot $USER syncthing --no-browser --no-default-folder
	@reboot root sleep 5 && swapon /swap/swapfile
EOF

# Si estamos usando una máquina virtual, configuramos X11 para funcionar a 1080p
[ "$GRAPHIC_DRIVER" == "vm" ] &&
	sudo cp "$HOME/.dotfiles/assets/system/xorg/xorg.conf" /etc/X11/xorg.conf

# Activar WiFi y Bluetooth
sudo rfkill unblock wifi
{ lspci | grep -i bluetooth || lsusb | grep -i bluetooth; } >/dev/null &&
	sudo rfkill unblock bluetooth

# Añadimos al usuario a los grupos correspondientes
sudo usermod -aG storage,input,users,video,optical,uucp "$USER"

# Configurar el software opcional
[ "$CHOSEN_AUDIO_PROD" == "true" ] && opt_audio_prod
[ "$CHOSEN_LATEX" == "true" ] && opt_latex
[ "$CHOSEN_MUSIC" == "true" ] && opt_music
[ "$CHOSEN_VIRT" == "true" ] && opt_virt

# Configurar el audio de baja latencia
audio-setup
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
