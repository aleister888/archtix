#!/bin/bash
# shellcheck disable=SC2154

# Auto-instalador para Artix OpenRC (Parte 2)
# por aleister888 <pacoe1000@gmail.com>
# Licencia: GNU GPLv3

source /etc/os-release

# Esta parte del script se ejecuta ya dentro de la instalación (chroot).

# - Pasa como variables los siguientes parámetros al siguiente script:
#   - DPI de la pantalla ($FINAL_DPI)
#   - Driver de video a usar ($GRAPHIC_DRIVER)
#   - Variables con el software opcional elegido
#     - $CHOSEN_AUDIO_PROD, $CHOSEN_LATEX, $CHOSEN_MUSIC, $CHOSEN_VIRT

pacinstall() {
	pacman -Sy --noconfirm --disable-download-timeout --needed "$@"
}

service_add() {
	if [ "$ID" = "artix" ]; then
		rc-update add "$1" default
	elif [ "$ID" = "arch" ]; then
		systemctl enable "$1"
	fi
}

# Instalamos GRUB
install_grub() {
	local -r SWAP_UUID=$(lsblk -nd -o UUID /dev/mapper/"$VG_NAME"-"swap")

	# Obtenemos el nombre del dispositivo donde se aloja la partición boot
	case "$ROOT_DISK" in
	*"nvme"*)
		BOOT_DRIVE="${ROOT_DISK%p[0-9]}"
		;;
	*)
		BOOT_DRIVE="${ROOT_DISK%[0-9]}"
		;;
	esac

	# Instalar GRUB
	grub-install --target=x86_64-efi --efi-directory=/boot \
		--recheck "$BOOT_DRIVE"

	grub-install --target=x86_64-efi --efi-directory=/boot \
		--removable --recheck "$BOOT_DRIVE"

	# Le indicamos a GRUB el UUID de la partición encriptada y desencriptada.
	local -r CRYPT_ID=$(lsblk -nd -o UUID /dev/"$ROOT_PART_NAME")
	local -r ROOT_UUID=$(lsblk -nd -o UUID /dev/mapper/"$VG_NAME"-"root")
	echo GRUB_ENABLE_CRYPTODISK=y >>/etc/default/grub
	sed -i "s/\(^GRUB_CMDLINE_LINUX_DEFAULT=\".*\)\"/\1 cryptdevice=UUID=$CRYPT_ID:cryptroot root=UUID=$ROOT_UUID resume=UUID=$SWAP_UUID net.ifnames=0\"/" /etc/default/grub

	# Crear el archivo de configuración
	grub-mkconfig -o /boot/grub/grub.cfg
}

# Definimos el nombre de nuestra máquina y creamos el archivo hosts
hostname_config() {
	echo "$HOSTNAME" >/etc/hostname

	# Este archivo hosts bloquea el acceso a sitios maliciosos
	ping gnu.org -c 1 && curl -o /etc/hosts \
		"https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"

	cat <<-EOF | tee -a /etc/hosts
		127.0.0.1 localhost
		127.0.0.1 $HOSTNAME.localdomain $HOSTNAME
		127.0.0.1 localhost.localdomain
		127.0.0.1 local
	EOF
}

# Configurar pacman
repos_conf() {
	if [ "$ID" = "artix" ]; then
		# Activar lib32
		sed -i '/#\[lib32\]/{s/^#//;n;s/^.//}' /etc/pacman.conf && pacman -Sy

		# Instalar paquetes necesarios
		pacinstall archlinux-mirrorlist archlinux-keyring artix-keyring \
			artix-archlinux-support lib32-artix-archlinux-support pacman-contrib \
			rsync lib32-elogind

		# Activar repositorios de Arch
		grep -q "^\[extra\]" /etc/pacman.conf ||
			cat <<-EOF >>/etc/pacman.conf
				[extra]
				Include = /etc/pacman.d/mirrorlist-arch

				[multilib]
				Include = /etc/pacman.d/mirrorlist-arch
			EOF

		pacman -Sy --noconfirm && pacman-key --populate archlinux
	elif [ "$ID" = "arch" ]; then
		# Activar multilib
		sed -i '/#\[multilib\]/{s/^#//;n;s/^.//}' /etc/pacman.conf
		pacman -Sy --noconfirm
	fi

	pacinstall reflector

	# Escoger mirrors más rápidos de los repositorios de Arch
	local MIRRORLIST_FILE
	if [ "$ID" = "artix" ]; then
		MIRRORLIST_FILE="mirrorlist-arch"
	elif [ "$ID" = "arch" ]; then
		MIRRORLIST_FILE="mirrorlist"
	fi
	reflector --verbose --fastest 10 --age 6 \
		--connection-timeout 1 --download-timeout 1 \
		--threads "$(nproc)" \
		--save /etc/pacman.d/$MIRRORLIST_FILE

	# Configurar cronie para actualizar automáticamente los mirrors de Arch
	cat <<-EOF >/etc/crontab
		SHELL=/bin/bash
		PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

		# Escoger los mejores repositorios para Arch Linux
		@hourly root ping gnu.org -c 1 && reflector --latest 10 --connection-timeout 1 --download-timeout 1 --sort rate --save /etc/pacman.d/$MIRRORLIST_FILE
	EOF
}

# Cambiar la codificación del sistema a español
genlocale() {
	sed -i -E 's/^#(en_US\.UTF-8 UTF-8)/\1/' /etc/locale.gen
	sed -i -E 's/^#(es_ES\.UTF-8 UTF-8)/\1/' /etc/locale.gen
	locale-gen
	echo "LANG=es_ES.UTF-8" >/etc/locale.conf
}

# Configurar la creación del initramfs
mkinitcpio_conf() {
	local -r MKINITCPIO_CONF="/etc/mkinitcpio.conf"
	local MODULES="vfat usb_storage btusb nvme"
	local HOOKS="base udev autodetect microcode modconf kms keyboard keymap consolefont block lvm2 encrypt"
	[ "$ID" = "artix" ] && HOOKS+=" resume"
	HOOKS+=" filesystems fsck"
	sed -i "s/^MODULES=.*/MODULES=($MODULES)/" "$MKINITCPIO_CONF"
	sed -i "s/^HOOKS=.*/HOOKS=($HOOKS)/" "$MKINITCPIO_CONF"
}

##########
# SCRIPT #
##########

# Establecer la zona horaria
ln -sf "$SYSTEM_TIMEZONE" /etc/localtime
# Sincronizar reloj del hardware con la zona horaria
hwclock --systohc

# Configurar el servidor de claves y limpiar la cache
grep ubuntu /etc/pacman.d/gnupg/gpg.conf ||
	echo 'keyserver hkp://keyserver.ubuntu.com' |
	tee -a /etc/pacman.d/gnupg/gpg.conf >/dev/null
pacman -Sc --noconfirm
pacman-key --populate && pacman-key --refresh-keys

# Configurar pacman
sed -i 's/^#Color/Color\nILoveCandy/' /etc/pacman.conf
sed -i 's/^#ParallelDownloads = 5/ParallelDownloads = 5/' /etc/pacman.conf

if echo "$(
	lspci
	lsusb
)" | grep -i bluetooth; then
	pacinstall bluez bluez-utils bluez-obex
	if [ "$ID" = "artix" ]; then
		pacinstall bluez-openrc
		service_add bluetoothd
	elif [ "$ID" = "arch" ]; then
		service_add bluetooth
	fi
fi

# Instalamos grub
install_grub

# Definimos el nombre de nuestra máquina y creamos el archivo hosts
hostname_config

# Configurar pacman
repos_conf

# Configurar la codificación del sistema
genlocale

# Agregamos los módulos y ganchos imprescindibles al initramfs
mkinitcpio_conf
# Regeneramos el initramfs
mkinitcpio -P
# Actualizamos la configuración de GRUB
grub-mkconfig -o /boot/grub/grub.cfg

# Activamos servicios
service_add NetworkManager
service_add cronie
service_add acpid
if [ "$ID" = "artix" ]; then
	service_add cupsd
	rc-update add device-mapper boot
	rc-update add lvm boot
	rc-update add dmcrypt boot
	rc-update add dmeventd boot
elif [ "$ID" = "arch" ]; then
	service_add cups
fi

# Hacemos que la swap se utilize despúes de montar todos los discos
[ "$ID" = "artix" ] && sed -i '/rc_need="localmount"/s/^#//g' /etc/conf.d/swap

ln -sf /usr/bin/nvim /usr/local/bin/vim
ln -sf /usr/bin/nvim /usr/local/bin/vi

# Configuramos sudo para stage3.sh
echo "root ALL=(ALL:ALL) ALL
%wheel ALL=(ALL) NOPASSWD: ALL" | tee /etc/sudoers

# Ejecutamos la siguiente parte del script pasandole las variables
# correspondientes
su "$USERNAME" -c "
	export \
	FINAL_DPI=$FINAL_DPI \
	GRAPHIC_DRIVER=$GRAPHIC_DRIVER \
	CHOSEN_AUDIO_PROD=$CHOSEN_AUDIO_PROD \
	CHOSEN_LATEX=$CHOSEN_LATEX \
	CHOSEN_MUSIC=$CHOSEN_MUSIC \
	CHOSEN_VIRT=$CHOSEN_VIRT \

	cd /home/$USERNAME/.dotfiles/installer && ./stage3.sh
"
