#!/bin/sh

if [ ! -d /sys/firmware/efi ]; then
	printf "El sistema no es UEFI. Abortando..."
	exit 1
fi

REPO_DIR="/tmp/artix-installer"

# Configuramos el servidor de claves y actualizamos las claves
grep ubuntu /etc/pacman.d/gnupg/gpg.conf ||
	echo 'keyserver hkp://keyserver.ubuntu.com' |
	sudo tee -a /etc/pacman.d/gnupg/gpg.conf >/dev/null

sudo pacman -Sc --noconfirm
sudo pacman-key --populate && sudo pacman-key --refresh-keys

# Instalamos:
# - whiptail: para la interfaz TUI
# - parted: para formatear nuestros discos
# - xkeyboard-config: para elegir el layout de teclado
# - bc: para calcular el DPI de la pantalla
# - git: para clonar el repositorio
sudo pacman -Sy --noconfirm --needed parted libnewt xkeyboard-config bc git lvm2

# Clonamos el repositorio e iniciamos el instalador
git clone --depth 1 https://github.com/aleister888/artix-installer.git \
	$REPO_DIR

cd $REPO_DIR/installer || exit 1
sudo ./stage1.sh
