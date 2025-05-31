#!/bin/bash

set -e

export REPO_NAME="artix-installer"
export REPO_URL="https://github.com/aleister888/$REPO_NAME"
REPO_DIR="/tmp/artix-installer"

[ ! -d /sys/firmware/efi ] && exit 1

# Configuramos el servidor de claves y actualizamos las claves
grep ubuntu /etc/pacman.d/gnupg/gpg.conf ||
	echo 'keyserver hkp://keyserver.ubuntu.com' |
	sudo tee -a /etc/pacman.d/gnupg/gpg.conf >/dev/null

# Instalamos los paquetes necesarios:
# - whiptail: para la interfaz TUI
# - parted: para gestionar particiones
# - xkeyboard-config: para seleccionar el layout del teclado
# - bc: para calcular el DPI de la pantalla
# - git: para clonar el repositorio
# - lvm2: para gestionar volúmenes lógicos
sudo pacman -Sy
sudo pacman -Sc --noconfirm
#sudo pacman-key --populate && sudo pacman-key --refresh-keys
sudo pacman -S --noconfirm --needed parted libnewt xkeyboard-config bc git lvm2

# Clonamos el repositorio solo si es necesario
if [ -d ./installer ]; then
	cd ./installer || exit 1
else
	git clone --depth 1 "$REPO_URL.git" $REPO_DIR
	cd $REPO_DIR/installer || exit 1
fi

sudo ./stage1.sh
