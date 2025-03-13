#!/bin/bash -x
# shellcheck disable=SC2068

# Auto-instalador para Artix OpenRC (Parte 1)
# por aleister888 <pacoe1000@gmail.com>
# Licencia: GNU GPLv3

# - Pasa como variables los siguientes parámetros al siguiente script:
#   - Nombre del usuario regular ($username)
#   - DPI de la pantalla ($final_dpi)
#   - Zona horaria del sistema ($systemTimezone)
#   - Nombre del disco utilizado ($ROOT_DISK)
#   - Si se usa encriptación ($crypt_root)
#   - El tipo de partición de la instalación ($ROOT_FILESYSTEM)
#   - Nombre de la partición principal ($rootPartName)
#   - Nombre de la partición desencriptada abierta ($cryptName)
#   - Nombre del host ($hostName)
#   - Driver de vídeo a usar ($graphic_driver)
#   - Variables con el software opcional elegido
#     - $virt, $music, $noprivacy, $office, $latex, $audioProd

REPO_URL="https://github.com/aleister888/artix-installer"

whip_msg() {
	whiptail --backtitle "$REPO_URL" --title "$1" --msgbox "$2" 10 60
}

whip_yes() {
	whiptail --backtitle "$REPO_URL" --title "$1" --yesno "$2" 10 60
}

whip_menu() {
	local TITLE=$1
	local MENU=$2
	shift 2
	whiptail --backtitle "$REPO_URL" \
		--title "$TITLE" --menu "$MENU" 15 60 5 $@ 3>&1 1>&2 2>&3
}

whip_input() {
	local TITLE=$1
	local INPUTBOX=$2
	whiptail --backtitle "$REPO_URL" \
		--title "$TITLE" --inputbox "$INPUTBOX" \
		10 60 3>&1 1>&2 2>&3
}

echo_msg() {
	clear
	echo "$1"
	sleep 1
}

# Muestra como quedarían las particiones de nuestra instalación para # confirmar
# los cambios. También prepara las variables para formatear los discos
scheme_show() {
	local scheme   # Variable con el esquema de particiones completo
	local rootType # Tipo de partición/ (LUKS o normal)
	bootPart=      # Partición de arranque
	rootPart=      # Partición con el sistema

	# Definimos el nombre de las particiones de nuestro disco principal
	# (Los NVME tienen un sistema de nombrado distinto)
	case "$ROOT_DISK" in
	*"nvme"* | *"mmcblk"*)
		bootPart="$ROOT_DISK"p1
		rootPart="$ROOT_DISK"p2
		;;
	*)
		bootPart="$ROOT_DISK"1
		rootPart="$ROOT_DISK"2
		;;
	esac

	# Mostrar si la partición esta encriptada
	if [ "$crypt_root" == "true" ]; then
		rootType="LUKS"
	else
		rootType="/"
	fi

	# Creamos el esquema que whiptail nos mostrará
	scheme="/dev/$ROOT_DISK    $(lsblk -dn -o size /dev/"$ROOT_DISK")
	/dev/$bootPart  /boot
	/dev/$rootPart  $rootType
	"
	if [ "$crypt_root" == "true" ]; then
		scheme+="/dev/mapper/root  /"
	fi

	# Mostramos el esquema para confirmar los cambios
	if ! whiptail --backtitle "$REPO_URL" \
		--title "Confirmar particionado" \
		--yesno "$scheme" 15 60; then
		whip_yes "Salir" "¿Desea cancelar la instalación? En caso contrario, volverá a elegir su esquema de particiones" &&
			exit 1
	fi
}

# Función para elegir como se formatearán nuestros discos
scheme_setup() {
	while true; do
		while true; do
			ROOT_DISK=$(
				whip_menu "Discos disponibles" \
					"Selecciona un disco para la instalación:" \
					"$(lsblk -dn -o name,size | tr '\n' ' ')"
			) && break
		done

		if whip_yes "LUKS" "¿Desea encriptar el disco duro?"; then
			crypt_root=true
		else
			crypt_root=false
		fi

		# Confirmamos los cambios
		if scheme_show; then
			break # Salir del bucle si se confirman los cambios
		else
			whip_msg "ERROR" "Hubo un error al comprobar el esquema de particiones elegido, o el usuario cancelo la operación."
		fi
	done
}

# Encriptar el disco duro
part_encrypt() {
	local cryptPassword
	while true; do
		cryptPassword=$(
			get_password "Entrada de Contraseña" "Confirmación de contraseña" \
				"Introduce la contraseña de encriptación del disco $1:" \
				"Re-introduce la contraseña de encriptación del disco $1:"
		)
		yes "$cryptPassword" | cryptsetup luksFormat -q --verify-passphrase "/dev/$2" && break
		whip_msg "LUKS" "Hubo un error, deberá introducir la contraseña otra vez"
	done

	yes "$cryptPassword" | cryptsetup open "/dev/$2" "$3" && return
}

disk_setup() {
	# Elegimos el sistema de ficheros
	ROOT_FILESYSTEM=$(
		whip_menu "Sistema de archivos" \
			"Selecciona el sistema de archivos para /:" \
			"ext4" "Ext4" "btrfs" "Btrfs"
	)

	rootPartName=

	# Nombre aleatorio de la partición encriptada abierta
	cryptName=$(tr -dc 'a-zA-Z' </dev/urandom | fold -w 5 | head -n 1)

	# Borramos la firma del disco
	wipefs --all "/dev/$ROOT_DISK"

	# Creamos nuestra tabla de particionado y las dos particiones necesarias
	printf "label: gpt\n,550M,U\n,,\n" | sfdisk "/dev/$ROOT_DISK"

	# Formateamos la primera partición como EFI
	mkfs.fat -F32 "/dev/$bootPart"

	# Si se eligió usar LUKS, es el momento de encriptar la partición
	if [ "$crypt_root" == "true" ]; then
		part_encrypt "/" "$rootPart" "$cryptName" &&
			# Cambiamos el indicador del disco a la partición encriptada
			rootPartName="$rootPart"
		rootPart="mapper/$cryptName"
	fi

	# Formateamos y montamosnuestras particiones
	if [ "$ROOT_FILESYSTEM" == "ext4" ]; then

		mkfs.ext4 "/dev/$rootPart"

		# Creamos el archivo swap
		mount "/dev/$rootPart" /mnt
		mkdir /mnt/swap
		fallocate -l 8G /mnt/swap/swapfile
		chmod 0600 /mnt/swap/swapfile
		mkswap /mnt/swap/swapfile

	elif [ "$ROOT_FILESYSTEM" == "btrfs" ]; then

		mkfs.btrfs -f "/dev/$rootPart"

		mount "/dev/$rootPart" /mnt
		btrfs subvolume create /mnt/@
		# Creamos el subvolumen home
		btrfs subvolume create /mnt/@home
		# Creamos el subvolumen swap
		btrfs subvolume create /mnt/@swap
		# Creamos un subvolumen para las imágenes de las máquinas
		# virtuales, así, en caso de que el usuario instale libvirt,
		# estas no se incluirán en las snapshots
		btrfs subvolume create /mnt/@images
		umount -R /mnt

		mount -t btrfs \
			-o noatime,compress=zstd:1,autodefrag,subvol=@ \
			"/dev/$rootPart" /mnt

		mkdir /mnt/home
		mkdir /mnt/swap
		mkdir -p /mnt/var/lib/libvirt/images

		mount -t btrfs \
			-o noatime,compress=zstd:1,autodefrag,subvol=@home \
			"/dev/$rootPart" /mnt/home

		mount -t btrfs \
			-o noatime,autodefrag,subvol=@images \
			"/dev/$rootPart" /mnt/var/lib/libvirt/images

		mount -t btrfs \
			-o noatime,nodatacow,subvol=@swap \
			"/dev/$rootPart" /mnt/swap

		btrfs filesystem mkswapfile -s 8G /mnt/swap/swapfile

	fi

	swapon /mnt/swap/swapfile

	mkdir /mnt/boot
	mount "/dev/$bootPart" /mnt/boot
}

# Instalar paquetes con basestrap
# Ejecutamos basestrap en un bucle hasta que se ejecute correctamente
# porque el comando no tiene la opción --disable-download-timeout.
# Lo que podría hacer que la operación falle con conexiones muy lentas.
basestrap_install() {
	local basestrap_packages

	basestrap_packages="base elogind-openrc openrc linux linux-firmware"
	basestrap_packages+=" opendoas mkinitcpio wget libnewt btrfs-progs"
	basestrap_packages+=" neovim"

	# Instalamos los paquetes del grupo base-devel manualmente para luego
	# poder borrar sudo facilmente. (Si en su lugar instalamos el grupo,
	# luego será más complicado desinstalarlo)
	basestrap_packages+=" autoconf automake bison debugedit fakeroot flex"
	basestrap_packages+=" gc gcc groff guile libisl libmpc libtool m4 make"
	basestrap_packages+=" patch pkgconf texinfo which"

	basestrap_packages+=" linux-headers linux-lts linux-lts-headers"
	basestrap_packages+=" networkmanager networkmanager-openrc dosfstools"
	basestrap_packages+=" cronie cronie-openrc cups cups-openrc freetype2"
	basestrap_packages+=" libjpeg-turbo grub git wpa_supplicant usbutils"
	basestrap_packages+=" pciutils cryptsetup device-mapper-openrc dialog"
	basestrap_packages+=" cryptsetup-openrc acpid-openrc efibootmgr"

	# Instalamos pipewire para evitar conflictos (p.e. se isntala jack2 y no
	# pipewire-jack). Los paquetes para 32 bits se instalarán una vez
	# activados el repo multilib de Arch Linux (s3)
	basestrap_packages+=" pipewire-pulse wireplumber pipewire pipewire-alsa"
	basestrap_packages+=" pipewire-audio pipewire-jack"

	# Instalamos go y sudo para poder compilar yay más adelante (s3)
	basestrap_packages+=" go sudo"

	# Para procesar los .json con los paquetes a instalar
	basestrap_packages+=" jq"

	# Añadimos el paquete con el microcódigo de CPU correspodiente
	local manufacturer
	manufacturer=$(
		grep vendor_id /proc/cpuinfo | awk '{print $3}' | head -1
	)
	if [ "$manufacturer" == "GenuineIntel" ]; then
		basestrap_packages+=" intel-ucode"
	elif [ "$manufacturer" == "AuthenticAMD" ]; then
		basestrap_packages+=" amd-ucode"
	fi

	# Si el dispositivo tiene bluetooth, instalaremos blueman
	if echo "$(
		lspci
		lsusb
	)" | grep -i bluetooth; then
		basestrap_packages+=" blueman"
	fi

	# shellcheck disable=SC2086
	while true; do
		basestrap /mnt $basestrap_packages && break
	done
}

# Elegimos distribución de teclado
kb_layout_select() {
	key_layouts=$(
		find /usr/share/X11/xkb/symbols/ -mindepth 1 -type f \
			-printf "%f\n" | sort -u | grep -v '...'
	)

	# Array con las diferentes distribuciones de teclado posibles
	keyboard_array=()
	for key_layout in $key_layouts; do
		keyboard_array+=("$key_layout" "$key_layout")
	done

	# Elegimos nuestro layout
	final_layout=$(
		whip_menu "Teclado" \
			"Por favor, elige una distribucion de teclado:" \
			${keyboard_array[@]}
	)
}

kb_layout_conf() {
	sudo mkdir -p /mnt/etc/X11/xorg.conf.d/ # X11
	cat <<-EOF >/mnt/etc/X11/xorg.conf.d/00-keyboard.conf
		Section "InputClass"
		    Identifier "system-keyboard"
		    MatchIsKeyboard "on"
		    Option "XkbLayout" "$final_layout"
		    Option "XkbModel" "pc105"
		    Option "XkbOptions" "terminate:ctrl_alt_bksp"
		EndSection
	EOF
	# Si elegimos español, configurar el layout de la tty en español también
	[ "$final_layout" == "es" ] &&
		sudo sed -i 's|keymap="us"|keymap="es"|' /etc/conf.d/keymaps
}

# Calcular el DPI
calculate_dpi() {
	local resolution size width height fact displayDPI

	# Selección de resolución del monitor
	resolution=$(
		whip_menu "Resolucion del Monitor" \
			"Seleccione la resolucion de su monitor:" \
			"720p" "HD" "1080p" "Full-HD" "1440p" "QHD" "2160p" "4K"
	)

	# Selección del tamaño del monitor en pulgadas (diagonal)
	size=$(
		whip_menu "Tamaño del Monitor" \
			"Seleccione el tamaño de su monitor (en pulgadas):" \
			"14" "Portatil" \
			"15.6" "Portatil" \
			"17" "Portatil" \
			"24" "Escritorio" \
			"27" "Escritorio"
	)

	# Definimos la resolución elegida
	case $resolution in
	"720p")
		width=1280
		height=720
		fact="0.6"
		;;
	"1080p")
		width=1920
		height=1080
		fact="0.6"
		;;
	"1440p")
		width=2560
		height=1440
		fact="0.6"
		;;
	"2160p")
		width=3840
		height=2160
		fact="1.2"
		;;
	esac

	# Calculamos el DPI
	displayDPI=$(
		echo "scale=6; sqrt($width^2 + $height^2) / $size * $fact" | bc
	)

	# Redondeamos el DPI calculado al entero más cercano
	final_dpi=$(printf "%.0f" "$displayDPI")
}

get_password() {
	local password1 password2
	local title1=$1
	local title2=$2
	local box1=$3
	local box2=$4

	while true; do

		# Pedir la contraseña la primera vez
		password1=$(
			whiptail --backtitle "$REPO_URL" \
				--title "$title1" \
				--passwordbox "$box1" \
				10 60 3>&1 1>&2 2>&3
		)

		# Pedir la contraseña una segunda vez
		password2=$(
			whiptail --backtitle "$REPO_URL" \
				--title "$title2" \
				--passwordbox "$box2" \
				10 60 3>&1 1>&2 2>&3
		)

		# Si ambas contraseñas coinciden devolver el resultado
		if [ "$password1" == "$password2" ] && [ -n "$password1" ]; then
			echo "$password1" && break
		else
			# Mostrar un mensaje de error si las contraseñas no coinciden
			whiptail --backtitle "$REPO_URL" \
				--title "Error" \
				--msgbox "Las contraseñas no coinciden. Inténtalo de nuevo." \
				10 60 3>&1 1>&2 2>&3
		fi

	done
}

# Establecer zona horaria
timezone_set() {

	while true; do
		# Obtener la lista de regiones disponibles
		regions=$(
			find /usr/share/zoneinfo -mindepth 1 -type d \
				-printf "%f\n" | sort -u
		)

		# Crear un array con las regiones
		regions_array=()
		for region in $regions; do
			regions_array+=("$region" "$region")
		done

		# Elegir la región
		region=$(
			whip_menu "Selecciona una región" \
				"Por favor, elige una región" \
				${regions_array[@]}
		)

		# Obtener la lista de zonas horarias de la región seleccionada
		timezones=$(
			find "/usr/share/zoneinfo/$region" -mindepth 1 -type f \
				-printf "%f\n" | sort -u
		)

		# Crear un array con las distintas zonas horarias
		timezones_array=()
		for timezone in $timezones; do
			timezones_array+=("$timezone" "$timezone")
		done

		# Elegir la zona horaria dentro de la región seleccionada
		timezone=$(
			whip_menu "Selecciona una zona horaria en $region" \
				"Por favor, elige una zona horaria en $region:" \
				${timezones_array[@]}
		)

		# Verificar si la zona horaria seleccionada es válida
		if [ -f "/usr/share/zoneinfo/$region/$timezone" ] &&
			[ -n "$region" ] && [ -n "$timezone" ]; then
			break
		else
			whip_msg "Zona horaria no valida" \
				"Zona horaria no valida. Asegúrate de elegir una zona horaria valida."
		fi
	done

	echo "/usr/share/zoneinfo/$region/$timezone"
}

# Elegimos el driver de vídeo
driver_choose() {
	local driver_options

	# Opciones posibles
	driver_options=(
		"amd" "AMD" "nvidia" "NVIDIA" "intel" "Intel" "virtual" "VM"
	)

	# Elegimos nuestra tarjeta gráfica
	graphic_driver=$(
		whip_menu "Selecciona tu tarjeta grafica" "Elige una opcion:" \
			${driver_options[@]}
	)
}

packages_choose() {
	while true; do

		variables=(
			"audioProd"
			"latex"
			"music"
			"virt"
		)

		# Reiniciamos las variables si no confirmamos la selección
		for var in "${variables[@]}"; do eval "$var=false"; done

		whip_yes "Virtualizacion" \
			"¿Quieres instalar libvirt para ejecutar máquinas virtuales?" &&
			virt="true"

		whip_yes "Musica" \
			"¿Deseas instalar software para manejar tu coleccion de musica?" &&
			music="true"

		whip_yes "laTeX" \
			"¿Deseas instalar laTeX?" &&
			latex="true"

		whip_yes "DAW" \
			"¿Deseas instalar software de produccion de audio?" &&
			audioProd="true"

		# Confirmamos la selección de paquetes a instalar (o no)
		if packages_show; then
			break
		else
			whip_msg "Operacion cancelada" \
				"Se te volvera a preguntar que software desea instalar"
		fi
	done
}

# Elegimos que paquetes instalar
packages_show() {
	local scheme # Variable con la lista de paquetes a instalar
	scheme="Se instalaran:\n"
	[ "$virt" == "true" ] && scheme+="libvirt\n"
	[ "$music" == "true" ] && scheme+="Softw. Gestión de Música\n"
	[ "$latex" == "true" ] && scheme+="laTeX\n"
	[ "$audioProd" == "true" ] && scheme+="Softw. Prod. Musical\n"

	whiptail --backtitle "$REPO_URL" \
		--title "Confirmar paquetes" \
		--yesno "$scheme" 15 60
}

##########
# SCRIPT #
##########

# Elegimos como se formatearán nuestros discos
scheme_setup

# Formateamos, creamos la swap y montamos los discos
disk_setup

# Elegimos y establecemos la distribución de teclado
kb_layout_select
kb_layout_conf

# Calculamos el DPI
calculate_dpi

rootPassword=$(
	get_password "Entrada de Contraseña" "Confirmación de contraseña" \
		"Introduce la contraseña del superusuario:" \
		"Re-introduce la contraseña del superusuario:"
)

username="$(
	whiptail --backtitle "$REPO_URL" \
		--inputbox "Por favor, ingresa el nombre del usuario:" \
		10 60 3>&1 1>&2 2>&3
)"

userPassword=$(
	get_password "Entrada de Contraseña" "Confirmación de contraseña" \
		"Introduce la contraseña del usuario $username:" \
		"Re-introduce la contraseña del usuario $username:"
)

systemTimezone=$(timezone_set)

hostName=$(
	whip_input "Configuracion de Hostname" \
		"Por favor, introduce el nombre que deseas darle a tu ordenador:"
)

# Elegimos el driver de video y lo guardamos en la variable $graphic_driver
driver_choose

# Elegimos que software opcional instalar
packages_choose

# Avisamos al usuario de que ya puede relajarse y dejar que el haga su trabajo
whip_msg "Hora del cafe" \
	"El instalador ya tiene toda la información necesaria, puedes dejar el ordenador desatendido. La instalacion tomara 30-45min aproximadamente."

# Instalamos paquetes en la nueva instalación
basestrap_install

# Creamos el fstab
fstabgen -U /mnt >/mnt/etc/fstab

# Montamos los directorios necesarios para el chroot
for dir in dev proc sys run; do
	mount --rbind /$dir /mnt/$dir
	mount --make-rslave /mnt/$dir
done

artix-chroot /mnt sh -c "
	useradd -m -G wheel,lp $username
	yes $rootPassword | passwd
	yes $userPassword | passwd $username
"

# Copiamos el repositorio a la nueva instalación
cp -r "$(dirname "$0")/.." "/mnt/home/$username/.dotfiles"

# Corregimos el propietario del repositorio copiado y ejecutamos la siguiente
# parte del script pasandole las variables correspondientes.
artix-chroot /mnt sh -c "
	export \
	username=$username \
	final_dpi=$final_dpi \
	systemTimezone=$systemTimezone \
	ROOT_DISK=$ROOT_DISK \
	crypt_root=$crypt_root \
	ROOT_FILESYSTEM=$ROOT_FILESYSTEM \
	rootPartName=$rootPartName \
	cryptName=$cryptName \
	hostName=$hostName \
	graphic_driver=$graphic_driver \
	virt=$virt \
	music=$music \
	latex=$latex \
	audioProd=$audioProd

	chown $username:$username -R \
	   /home/$username/.dotfiles
	cd /home/$username/.dotfiles/installer

	./stage2.sh
"
