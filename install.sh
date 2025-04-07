#!/bin/bash

set -e

REPO_DIR="/tmp/artix-installer"

if [ ! -d /sys/firmware/efi ]; then
	printf "El sistema no es UEFI. Abortando..."
	exit 1
fi

# Configuramos el servidor de claves y actualizamos las claves
grep ubuntu /etc/pacman.d/gnupg/gpg.conf ||
	echo 'keyserver hkp://keyserver.ubuntu.com' |
	sudo tee -a /etc/pacman.d/gnupg/gpg.conf >/dev/null

sudo pacman -Sc --noconfirm
sudo pacman-key --populate && sudo pacman-key --refresh-keys

# Instalamos los paquetes necesarios:
# - whiptail: para la interfaz TUI
# - parted: para gestionar particiones
# - xkeyboard-config: para seleccionar el layout del teclado
# - bc: para calcular el DPI de la pantalla
# - git: para clonar el repositorio
# - lvm2: para gestionar volúmenes lógicos
sudo pacman -Sy --noconfirm --needed parted libnewt xkeyboard-config bc git lvm2

if [ ! -d ./installer ]; then
	# Clonamos el repositorio e iniciamos el instalador
	git clone --depth 1 https://github.com/aleister888/artix-installer.git \
		$REPO_DIR
	cd $REPO_DIR/installer || exit 1
else
	cd ./installer || exit 1
fi

sudo ./stage1.sh
