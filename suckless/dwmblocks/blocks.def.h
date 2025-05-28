// Consulta el archivo LICENSE para los detalles de derechos de autor y licencia.

static char delim[] ="";
static unsigned int delimLen = 0;

static const Block blocks[] = {
	// Título                  Comando Tiempo de actualización Señal de actualización
	// ¿Que canción esta sonando?
	{"\x01^d^"                     ,"music-metadata -d",                       1,  5},
	// Estado de la batería (Si la hay)
	{"\x02^d^"                     ,"sb-bat",                                  1, 10},
	// Espacio libre
	{" \x03^c#D79921^ ^c#FABD2F^" ,"df -h /home | awk '/[0-9]/ {print $4}'", 60, 15},
	// Version del kernel
	{" \x04^c#458588^ ^c#83A598^" ,"uname -r | cut -d '-' -f 1",              0,  0},
	// Icono para el volumen
	{" \x05^c#B16286^"             ,"sb-vol-icon",                             1, 25},
	// Nivel de volumen
	{" ^c#D3869B^"                 ,"echo $(pamixer --get-volume)%",           1, 25},
	// Ram usada
	{" \x06^c#98971a^ ^c#b8bb26^" ,"free -h | awk '/^Mem:/ {print $3}'",     10, 30},
	// Fecha
	{" \x07^c#D65D0E^ ^c#FE8019^" ,"date +'%d/%m'",                          60,  0},
	// Hora
	{" \x08^c#CC241D^ ^c#FB4934^" ,"date +'%I:%M:%S'",                        1,  0},
	// Actualizaciones disponibles
	{" \x0a^c#427b58^󰏔 ^c#689d6a^"  ,"echo $(checkupdates | wc -l )&",        60,  0},
	{" "                           ,"true",                                    0,  0},
	// Indicador Bloq Mayus
	{"\x09^c#504945^"              ,"sb-bloq",                                 5,  2},
	// Filtro de luz azul
	{"\x0b"                        ,"sb-nighttime",                           60,  1},
	// Contador Pomodoro
	{"\x08^d^"                     ,"sb-timer",                                1,  0},
};
