#!/bin/bash -x
# shellcheck disable=SC2154

# Auto-instalador para Artix OpenRC (Parte 2)
# por aleister888 <pacoe1000@gmail.com>
# Licencia: GNU GPLv3

# Esta parte del script se ejecuta ya dentro de la instalación (chroot).

# - Pasa como variables los siguientes parámetros al siguiente script:
#   - DPI de la pantalla ($final_dpi)
#   - Driver de video a usar ($graphic_driver)
#   - El tipo de partición de la instalación ($ROOT_FILESYSTEM)
#   - Variables con el software opcional elegido
#     - $virt, $music, $latex, $audioProd

pacinstall() {
	pacman -Sy --noconfirm --disable-download-timeout --needed "$@"
}

service_add() {
	rc-update add "$1" default
}

# Instalamos GRUB
install_grub() {
	local cryptid decryptid
	cryptid=$(lsblk -nd -o UUID /dev/"$rootPartName")
	decryptid=$(lsblk -n -o UUID /dev/mapper/"$cryptName")

	# Obtenemos el nombre del dispositivo donde se aloja la partición boot
	case "$ROOT_DISK" in
	*"nvme"*)
		bootDrive="${ROOT_DISK%p[0-9]}"
		;;
	*)
		bootDrive="${ROOT_DISK%[0-9]}"
		;;
	esac

	# Instalar GRUB
	grub-install --target=x86_64-efi --efi-directory=/boot \
		--recheck "$bootDrive"

	grub-install --target=x86_64-efi --efi-directory=/boot \
		--removable --recheck "$bootDrive"

	# Si se usa encriptación, le decimos a GRUB el UUID de la partición
	# encriptada y desencriptada.
	if [ "$crypt_root" = "true" ]; then
		echo GRUB_ENABLE_CRYPTODISK=y >>/etc/default/grub
		sed -i "s/\(^GRUB_CMDLINE_LINUX_DEFAULT=\".*\)\"/\1 cryptdevice=UUID=$cryptid:cryptroot root=UUID=$decryptid\"/" /etc/default/grub
	fi

	# Crear el archivo de configuración
	grub-mkconfig -o /boot/grub/grub.cfg
}

# Definimos el nombre de nuestra máquina y creamos el archivo hosts
hostname_config() {
	echo "$hostName" >/etc/hostname

	# Este archivo hosts bloquea el acceso a sitios maliciosos
	curl -o /etc/hosts \
		"https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"

	cat <<-EOF | tee -a /etc/hosts
		127.0.0.1 localhost
		127.0.0.1 $hostName.localdomain $hostName
		127.0.0.1 localhost.localdomain
		127.0.0.1 local
	EOF
}

# Activar repositorios de Arch Linux
arch_support() {
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

	# Actualizar cambios
	pacman -Sy --noconfirm &&
		pacman-key --populate archlinux
	pacinstall reflector

	# Escoger mirrors más rápidos de los repositorios de Arch
	reflector --verbose --fastest 10 --age 6 \
		--connection-timeout 1 --download-timeout 1 \
		--threads "$(nproc)" \
		--save /etc/pacman.d/mirrorlist-arch

	# Configurar cronie para actualizar automáticamente los mirrors de Arch
	cat <<-EOF >/etc/crontab
		SHELL=/bin/bash
		PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

		# Escoger los mejores repositorios para Arch Linux
		@hourly root ping gnu.org -c 1 && reflector --latest 10 --connection-timeout 1 --download-timeout 1 --sort rate --save /etc/pacman.d/mirrorlist-arch
	EOF
}

# Cambiar la codificación del sistema a español
genlocale() {
	sed -i -E 's/^#(en_US\.UTF-8 UTF-8)/\1/' /etc/locale.gen
	sed -i -E 's/^#(es_ES\.UTF-8 UTF-8)/\1/' /etc/locale.gen
	locale-gen
	echo "LANG=es_ES.UTF-8" >/etc/locale.conf
}

##########
# SCRIPT #
##########

# Establecer la zona horaria
ln -sf "$systemTimezone" /etc/localtime
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

# Si se utiliza encriptación, añadir el módulo encrypt a la imagen del kernel
if [ "$crypt_root" = "true" ]; then
	sed -i -e '/^HOOKS=/ s/block/& encrypt/' /etc/mkinitcpio.conf
fi

if echo "$(
	lspci
	lsusb
)" | grep -i bluetooth; then
	pacinstall bluez-openrc bluez-utils bluez-obex &&
		service_add bluetoothd
fi

# Instalamos grub
install_grub

# Creamos el archivo swap
swap_create

# Regeneramos el initramfs
mkinitcpio -P

# Definimos el nombre de nuestra máquina y creamos el archivo hosts
hostname_config

# Activar repositorios de Arch Linux
arch_support

# Configurar la codificación del sistema
genlocale

# Activamos servicios
service_add NetworkManager
service_add cupsd
service_add cronie
service_add acpid
rc-update add device-mapper boot
rc-update add dmcrypt boot
rc-update add dmeventd boot

# Hacemos que la swap se utilize despúes de montar todos los discos
sed -i '/rc_need="localmount"/s/^#//g' /etc/conf.d/swap

ln -s /usr/bin/nvim /usr/local/bin/vim
ln -s /usr/bin/nvim /usr/local/bin/vi

# Configuramos sudo para stage3.sh
echo "root ALL=(ALL:ALL) ALL
%wheel ALL=(ALL) NOPASSWD: ALL" | tee /etc/sudoers

# Ejecutamos la siguiente parte del script pasandole las variables
# correspondientes
su "$username" -c "
	export \
	final_dpi=$final_dpi \
	graphic_driver=$graphic_driver \
	ROOT_FILESYSTEM=$ROOT_FILESYSTEM \
	virt=$virt \
	music=$music \
	latex=$latex \
	audioProd=$audioProd

	cd /home/$username/.dotfiles/installer && ./stage3.sh
"
