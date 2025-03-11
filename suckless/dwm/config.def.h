// Consulta el archivo LICENSE para los detalles de derechos de autor y licencia.

#define DLINES "16" // Lineas para los comandos de dmenu
#define TERM   "st" // Terminal
#define TERMT  "-t" // Flag usada para establecer el título de la terminal
#define TERME  "-e" // Flag usada de ejecución de la terminal
#define TERMC  "st-256color" // Clase de ventana de la terminal
#define BROWSER "firefox" // Navegador Web

static const char *fonts[] = {
	"Symbols Nerd Font Mono:pixelsize=22:antialias=true:autohint=true",
	"Iosevka Fixed SS05:pixelsize=22:bold",
	"Noto Color Emoji:pixelsize=20:regular"
};

static const unsigned int borderpx     = 3;   // Borde de las ventanas
static const int user_bh               = 18;  // Altura añadida
static const unsigned int snap         = 0;   // Proximidad necesaria para pegarse al borde
static const int swallowfloating       = 0;   // 1 == Tragarse nuevas ventanas por defecto
static const int showbar               = 1;   // 0 == Barra desactivada
static const int topbar                = 1;   // 0 == Barra en la parte inferior
static const unsigned int stairpx      = 20;  // Stairs: Profundidad del layout
static const int stairdirection        = 1;   // Stairs: 0 == Alineación izquierda
static const int stairsamesize         = 0;   // Strairs 1 == Reducir las ventanas en escalera al mismo tamaño
static const float mfact               = 0.5; // Factor de escalado master [0.05..0.95]
static const int nmaster               = 1;   // Número de clientes en master
static const int resizehints           = 1;   // ¿Respetar pistas de dibujado?
static const int lockfullscreen        = 1;   // 1 == Fuerza el foco en las ventanas en pantalla completa
static const unsigned int colorfultag  = 1;   // 1 == Los indicadores de etiqueta coloridos
static const unsigned int ulinepad     = 0;   // Margen horizontal subrayado
static const unsigned int ulinevoffset = 0;   // Margen vertical subrayado
static const unsigned int ulinestroke  = 4;   // Grosor/Altura del subrayado
static const int ulineall              = 0;   // 1 == Subrayado en todos los espacios


static const char background[]     = "#282828";
static const char background_sel[] = "#3c3836";
static const char foreground[]     = "#EBDBB2";
static const char col_green[]      = "#B8BB26";
static const char col_aqua[]       = "#8EC07C";
static const char col_blue[]       = "#83A598";
static const char col_purple[]     = "#D3869B";

// Nombre de los espacios cuando están vacíos y cuando tienen ventanas:
static const char *tags[] = { "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "a", "b", "c", "d", "e", "f"};

static const char *colors[][3] = {
	// Colores:             Fuente      Fondo           Borde
	[SchemeNorm]        = { foreground, background,     background_sel }, // Color de las ventanas normales
	[SchemeSel]         = { foreground, background_sel, col_green      }, // Color de las ventanas seleccionadas
	[SchemeStickyNorm]  = { "#000000",  "#000000",      background_sel }, // Sticky (Normal)
	[SchemeStickySel]   = { "#000000",  "#000000",      col_purple     }, // Sticky (Seleccionada)
	[SchemeScratchNorm] = { "#000000",  "#000000",      background_sel }, // Scratchpad (Normal)
	[SchemeScratchSel]  = { "#000000",  "#000000",      col_aqua       }, // Scratchpad (Seleccionada)
	[SchemeTag1]        = { col_green,  background_sel, "#000000"      }, // Colores de los espacios
	[SchemeTag2]        = { col_aqua,   background_sel, "#000000"      },
	[SchemeTag3]        = { col_blue,   background_sel, "#000000"      },
	[SchemeTag4]        = { col_purple, background_sel, "#000000"      },
	[SchemeTag5]        = { col_green,  background_sel, "#000000"      },
	[SchemeTag6]        = { col_aqua,   background_sel, "#000000"      },
	[SchemeTag7]        = { col_blue,   background_sel, "#000000"      },
	[SchemeTag8]        = { col_purple, background_sel, "#000000"      },
	[SchemeTag9]        = { col_green,  background_sel, "#000000"      },
	[SchemeTag10]       = { col_aqua,   background_sel, "#000000"      },
	[SchemeTag11]       = { col_blue,   background_sel, "#000000"      },
	[SchemeTag12]       = { col_purple, background_sel, "#000000"      },
	[SchemeTag13]       = { col_green,  background_sel, "#000000"      },
	[SchemeTag14]       = { col_aqua,   background_sel, "#000000"      },
	[SchemeTag15]       = { col_blue,   background_sel, "#000000"      },
	[SchemeTag16]       = { col_purple, background_sel, "#000000"      },
	[SchemeTag17]       = { col_green,  background_sel, "#000000"      },
	[SchemeTag18]       = { col_aqua,   background_sel, "#000000"      },
};

static const int tagschemes[] = {
	SchemeTag1,  SchemeTag2,  SchemeTag3,  SchemeTag4, SchemeTag5,   SchemeTag6,
	SchemeTag7,  SchemeTag8,  SchemeTag9,  SchemeTag10, SchemeTag11, SchemeTag12,
	SchemeTag13, SchemeTag14, SchemeTag15, SchemeTag16, SchemeTag17, SchemeTag18
};

typedef struct {
	const char *name;
	const void *cmd;
} Sp;

static const Rule rules[] = {
	// Clase, Instancia y Título. Tag, ><>, Full, Term, Swallow, Mon, Scratch
	{ "Yad",                   NULL,  NULL,      0,  1,  0,  0,  0,  -1,    0 },
	{ "Arandr",                NULL,  NULL,      0,  1,  0,  0,  0,  -1,    0 },
	{ "Nl.hjdskes.gcolor3",    NULL,  NULL,      0,  1,  0,  0,  0,  -1,    0 },
	{ "Qalculate-gtk",         NULL,  NULL,      0,  1,  0,  0,  0,  -1,    0 },
	{ "tauonmb",               NULL,  NULL,   1<<0,  0,  0,  0,  0,  -1,    0 },
	{ "thunderbird",           NULL,  NULL,   1<<1,  0,  0,  0,  0,  -1,    0 },
	{ "xfreerdp",              NULL,  NULL,   1<<3,  0,  0,  0,  0,  -1,    0 },
	{ "Soffice",               NULL,  NULL,   1<<3,  0,  0,  0,  0,  -1,    0 },
	{ "discord",               NULL,  NULL,   1<<4,  0,  1,  0,  0,  -1,    0 },
	{ "TelegramDesktop",       NULL,  NULL,   1<<4,  0,  0,  0,  0,  -1,    0 },
	{ "Virt-manager",          NULL,  NULL,   1<<5,  0,  0,  0,  0,  -1,    0 },
	{ "looking-glass-client",  NULL,  NULL,   1<<5,  0,  0,  0,  0,  -1,    0 },
	{ "TuxGuitar",             NULL,  NULL,   1<<6,  0,  0,  0,  0,  -1,    0 },
	{ "Gmetronome",            NULL,  NULL,   1<<6,  1,  0,  0,  0,  -1,    0 },
	{ "REAPER",                NULL,  NULL,   1<<6,  0,  0,  0,  0,  -1,    0 },
	{ "qBittorrent",           NULL,  NULL,   1<<6,  0,  0,  0,  0,  -1,    0 },
	{ "Lrcget",                NULL,  NULL,   1<<6,  0,  0,  0,  0,  -1,    0 },
	{ "Easytag",               NULL,  NULL,   1<<6,  0,  0,  0,  0,  -1,    0 },
	{ "Picard",                NULL,  NULL,   1<<6,  0,  0,  0,  0,  -1,    0 },
	{ "krita",                 NULL,  NULL,   1<<7,  0,  0,  0,  0,  -1,    0 },
	{ "Fr.handbrake.ghb",      NULL,  NULL,   1<<7,  0,  0,  0,  0,  -1,    0 },
	{ "Gimp",                  NULL,  NULL,   1<<7,  0,  0,  0,  0,  -1,    0 },
	{ "Timeshift-gtk",         NULL,  NULL,   1<<7,  0,  0,  0,  0,  -1,    0 },
	{ "BleachBit",             NULL,  NULL,   1<<7,  0,  0,  0,  0,  -1,    0 },
	{ "Gnome-disks",           NULL,  NULL,   1<<7,  0,  0,  0,  0,  -1,    0 },
	{ "Nitrogen",              NULL,  NULL,   1<<7,  1,  0,  0,  0,  -1,    0 },
	{ "Blueman-manager",       NULL,  NULL,   1<<7,  0,  0,  0,  0,  -1,    0 },
	{ "Lxappearance",          NULL,  NULL,   1<<7,  0,  0,  0,  0,  -1,    0 },
	{ "qt5ct",                 NULL,  NULL,   1<<7,  0,  0,  0,  0,  -1,    0 },
	{ "baobab",                NULL,  NULL,   1<<7,  0,  0,  0,  0,  -1,    0 },
	{ "steam",                 NULL,  NULL,   1<<8,  0,  0,  0,  0,  -1,    0 },
	{ "Lutris",                NULL,  NULL,   1<<8,  0,  0,  0,  0,  -1,    0 },
	{ "ProtonUp-Qt",           NULL,  NULL,   1<<8,  0,  0,  0,  0,  -1,    0 },
	{ "heroic",                NULL,  NULL,   1<<8,  0,  0,  0,  0,  -1,    0 },
	{ "PrismLauncher",         NULL,  NULL,   1<<8,  1,  0,  0,  0,  -1,    0 },
	{ "Minecraft* 1.8.9",      NULL,  NULL,   1<<8,  0,  0,  0,  0,  -1,    0 },
	{ "Minecraft* 1.9.4",      NULL,  NULL,   1<<8,  0,  0,  0,  0,  -1,    0 },
	{ "Minecraft* 1.10.2",     NULL,  NULL,   1<<8,  0,  0,  0,  0,  -1,    0 },
	{ "Minecraft* 1.11.2",     NULL,  NULL,   1<<8,  0,  0,  0,  0,  -1,    0 },
	{ "Minecraft* 1.12.2",     NULL,  NULL,   1<<8,  0,  0,  0,  0,  -1,    0 },
	{ "Minecraft* 1.13.2",     NULL,  NULL,   1<<8,  0,  0,  0,  0,  -1,    0 },
	{ "Minecraft* 1.14.4",     NULL,  NULL,   1<<8,  0,  0,  0,  0,  -1,    0 },
	{ "Minecraft* 1.15.2",     NULL,  NULL,   1<<8,  0,  0,  0,  0,  -1,    0 },
	{ "Minecraft* 1.16.5",     NULL,  NULL,   1<<8,  0,  0,  0,  0,  -1,    0 },
	{ "Minecraft* 1.17.1",     NULL,  NULL,   1<<8,  0,  0,  0,  0,  -1,    0 },
	{ "Minecraft* 1.18.2",     NULL,  NULL,   1<<8,  0,  0,  0,  0,  -1,    0 },
	{ "Minecraft* 1.19.4",     NULL,  NULL,   1<<8,  0,  0,  0,  0,  -1,    0 },
	{ "Minecraft* 1.20.6",     NULL,  NULL,   1<<8,  0,  0,  0,  0,  -1,    0 },
	{ "Minecraft* 1.21.1",     NULL,  NULL,   1<<8,  0,  0,  0,  0,  -1,    0 },
	{ "Minecraft* 1.21.4",     NULL,  NULL,   1<<8,  0,  0,  0,  0,  -1,    0 },
	{ "Minecraft 1.21.4",      NULL,  NULL,   1<<8,  0,  0,  0,  0,  -1,    0 },
	{ "Java",                  NULL,  NULL,  1<<11,  1,  0,  0,  0,  -1,    0 },
	{ "Eclipse",               NULL,  NULL,  1<<11,  0,  0,  0,  0,  -1,    0 },
	{ "KeePassXC",             NULL,  NULL,  1<<12,  0,  0,  0,  0,  -1,    0 },
	{ "gnome-contacts",        NULL,  NULL,  1<<12,  0,  0,  0,  0,  -1,    0 },
	{ "Standard Notes",        NULL,  NULL,  1<<13,  0,  0,  0,  0,  -1,    0 },
	{ TERMC,                   NULL,  NULL,      0,  0,  0,  1,  0,  -1,    0 },
	{ BROWSER,                 NULL,  NULL,      0,  0,  0,  1,  0,  -1,    0 },
	{ NULL,  NULL,     "scratchpad",             0,  1,  0,  0,  0,  -1,  's' },
	{ NULL,  NULL,   "Media viewer",             0,  1,  0,  0,  0,  -1,    0 },
};

#include "layouts.c" // Código con los layouts

static const Layout layouts[] = {
	{ "[]=", tile },
	{ "[M]", monocle },
	{ "><>", NULL },
	{ "[S]", stairs },
	{ "[D]", deck },
	{ "|M|", centeredmaster },
	{ "|||", col },
};

#define MODKEY Mod1Mask // Alt como modificador
#define TAGKEYS(KEY,TAG) \
	{ MODKEY,                       KEY, view,       {.ui = 1 << TAG} }, \
	{ MODKEY|ControlMask,           KEY, toggleview, {.ui = 1 << TAG} }, \
	{ MODKEY|ShiftMask,             KEY, tag,        {.ui = 1 << TAG} }, \
	{ MODKEY|ControlMask|ShiftMask, KEY, toggletag,  {.ui = 1 << TAG} },

#define STACKKEYS(MOD,ACTION) \
/* Poner el foco/Mover a la posición anterior */         { MOD, XK_comma,      ACTION##stack, {.i = INC(-1) } }, \
/* Poner el foco/Mover a la posición posterior */        { MOD, XK_period,     ACTION##stack, {.i = INC(+1) } }, \
/* Poner el foco en la primera posición del stack */     { MOD, XK_ntilde,     ACTION##stack, {.i = 1 } }, \
/* Poner el foco en la segunda posición del stack */     { MOD, XK_dead_acute, ACTION##stack, {.i = 2 } }, \
/* Poner el foco en la tercera posición del stack */     { MOD, XK_ccedilla,   ACTION##stack, {.i = 3 } }, \
/* Poner el foco/Mover a la primera ventana principal */ { MOD, XK_minus,      ACTION##stack, {.i = 0 } },

// Invocador de comandos
#define SHCMD(cmd) { .v = (const char*[]){ "/usr/bin/zsh", "-c", cmd, NULL } }

// Comandos
static char dmenumon[2] = "0"; // Comando para ejecutar dmenu
static const char *dmenucmd[] = { "dmenu_run",
"-m",  dmenumon,   "-nb", background,
"-nf", foreground, "-sb", background_sel,
"-sf", foreground, "-c","-l", DLINES, NULL };
static const char *termcmd[]  = { TERM, NULL };      // Terminal
static const char *layoutmenu_cmd = "layoutmenu.sh"; // Script para cambiar el layout
static const char *scratchpadcmd[] = { "s", NULL };  // Tecla para los scratchpads
static const char *spawnscratchpadcmd[] = { TERM, TERMT, "scratchpad", NULL }; // Comando para invocar un scratchpad

static const char *statuscmd[] = { "/bin/sh", "-c", NULL, NULL };

static const StatusCmd statuscmds[] = {
	{ "music-control play-pause; pkill -RTMIN+5 dwmblocks", 1 },
	{ "sb-bat-info", 2 },
	{ "sb-disks-info; pkill -RTMIN+15 dwmblocks", 3 },
	{ "notify-send $(uname -r)", 4 },
	{ "pactl set-sink-mute @DEFAULT_SINK@ toggle; pkill -RTMIN+25 dwmblocks", 5 },
	{ "sb-ram-info; pkill -RTMIN+30 dwmblocks", 6 },
	{ "sb-cal-info", 7 },
	{ "sb-timer-manager", 8 },
	{ "blue-toggle", 11 },
};

#include <X11/XF86keysym.h> // Incluir teclas especiales

static const Key keys[] = {
	// Alternar entre los espacios recientes
	{ MODKEY,                       XK_Tab,    view,             {0} },

	// Abrir dmenu
	{ MODKEY|ControlMask,           XK_h,      spawn,            SHCMD("zathura ~/.dotfiles/assets/pdf/help.pdf") },
	{ MODKEY,                       XK_p,      spawn,            {.v = dmenucmd } },
	{ MODKEY|ShiftMask,             XK_p,      spawn,            SHCMD("j4-dmenu-desktop --dmenu 'dmenu -c -l 12'") },
	{ MODKEY|ControlMask,           XK_p,      spawn,            SHCMD("dmenu -C -l 1 | tr -d '\n' | xclip -selection clipboard") },
	{ 0,               XF86XK_Calculator,      spawn,            SHCMD("dmenu -C -l 1 | tr -d '\n' | xclip -selection clipboard") },
	{ MODKEY,                       XK_t,      spawn,            SHCMD("tray-toggle") },

	// Abrir terminal
	{ MODKEY|ShiftMask,             XK_Return, spawn,            {.v = termcmd } },

	// Bloquear pantalla
	{ Mod4Mask,                     XK_l,      spawn,            SHCMD("sleep 0.17; i3lock-fancy-rapid 4 4") },

	// Configurar pantallas
	{ MODKEY,                       XK_F1,     spawn,            SHCMD("arandr && nitrogen --restore") },
	{ Mod4Mask,                     XK_p,      spawn,            SHCMD("arandr && nitrogen --restore") },

	// Abrir aplicaciones más usadas
	{ MODKEY,                       XK_F2,     spawn,            {.v = (const char*[]){ BROWSER, NULL } } },
	{ MODKEY,                       XK_F3,     spawn,            {.v = (const char*[]){ TERM, TERME, "lf", NULL } } },
	{ MODKEY,                       XK_F4,     spawn,            SHCMD("tauon") },

	// Montar/Desmontar dispositivos android
	{ MODKEY,                       XK_F5,     spawn,            SHCMD("android-mount") },
	{ MODKEY|ShiftMask,             XK_F5,     spawn,            SHCMD("android-umount") },

	// Menu de apagado
	{ MODKEY,                       XK_F11,    spawn,            SHCMD("powermenu") },

	// Reiniciar dwm
	{ MODKEY|ShiftMask,             XK_F11,    spawn,            SHCMD("pkill dwm") },

	// Ajustes de audio
	{ MODKEY,                       XK_F12,    spawn,            {.v = (const char*[]){ TERM, TERMT, "scratchpad", TERME, "pulsemixer", NULL } } },
	{ MODKEY|ShiftMask,             XK_F12,    spawn,            SHCMD("pipewire-virtualmic-select") },

	// Controlar reproducción
	{ MODKEY,                       XK_z,      spawn,            SHCMD("music-control previous; pkill -RTMIN+5 dwmblocks") },
	{ 0,                XF86XK_AudioPrev,      spawn,            SHCMD("music-control previous; pkill -RTMIN+5 dwmblocks") },
	{ MODKEY,                       XK_x,      spawn,            SHCMD("music-control next; pkill -RTMIN+5 dwmblocks") },
	{ 0,                XF86XK_AudioNext,      spawn,            SHCMD("music-control next; pkill -RTMIN+5 dwmblocks") },
	{ MODKEY|ShiftMask,             XK_z,      spawn,            SHCMD("music-control play-pause; -RTMIN+5 dwmblocks") },
	{ MODKEY|ShiftMask,             XK_x,      spawn,            SHCMD("music-control play-pause; -RTMIN+5 dwmblocks") },
	{ 0,                XF86XK_AudioPlay,      spawn,            SHCMD("music-control play-pause; -RTMIN+5 dwmblocks") },

	// Cambiar volumen
	{ 0,         XF86XK_AudioLowerVolume,      spawn,            SHCMD("volinc -5; pkill -RTMIN+25 dwmblocks") },
	{ MODKEY,                       XK_n,      spawn,            SHCMD("volinc -10; pkill -RTMIN+25 dwmblocks") },
	{ 0,         XF86XK_AudioRaiseVolume,      spawn,            SHCMD("volinc 5; pkill -RTMIN+25 dwmblocks") },
	{ MODKEY,                       XK_m,      spawn,            SHCMD("volinc 10; pkill -RTMIN+25 dwmblocks") },
	{ 0,                XF86XK_AudioMute,      spawn,            SHCMD("pactl set-sink-mute @DEFAULT_SINK@ toggle; pkill -RTMIN+25 dwmblocks") },
	{ MODKEY|ControlMask,           XK_n,      spawn,            SHCMD("pactl set-sink-mute @DEFAULT_SINK@ toggle; pkill -RTMIN+25 dwmblocks") },
	{ MODKEY|ControlMask,           XK_m,      spawn,            SHCMD("pactl set-sink-mute @DEFAULT_SINK@ toggle; pkill -RTMIN+25 dwmblocks") },
	{ MODKEY|ShiftMask,             XK_n,      spawn,            SHCMD("pactl set-sink-volume @DEFAULT_SINK@ 32768; pkill -RTMIN+25 dwmblocks") },
	{ MODKEY|ShiftMask,             XK_m,      spawn,            SHCMD("pactl set-sink-volume @DEFAULT_SINK@ 65536; pkill -RTMIN+25 dwmblocks") },

	// Cambiar brillo (Portátiles)
	{ 0,        XF86XK_MonBrightnessDown,      spawn,            SHCMD("brightchange dec") },
	{ 0,          XF86XK_MonBrightnessUp,      spawn,            SHCMD("brightchange inc") },

	// Activar/Desactivar Micrófono (Portátiles)
	{ 0,             XF86XK_AudioMicMute,      spawn,            SHCMD("amixer sset Capture toggle") },

	// Forzar cerrar ventana
	{ MODKEY|ShiftMask,             XK_c,      spawn,            SHCMD("xkill") },
	{ 0,                    XK_Caps_Lock,      spawn,            SHCMD("sleep 0.2; pkill -RTMIN+2 dwmblocks")},
	{ 0,                     XK_Num_Lock,      spawn,            SHCMD("sleep 0.2; pkill -RTMIN+2 dwmblocks")},

	// Tomar capturas de pantalla
	{ 0,                            XK_Print,  spawn,            SHCMD("screenshot all_clip") },
	{ ShiftMask,                    XK_Print,  spawn,            SHCMD("screenshot selection_clip") },
	{ MODKEY,                       XK_o,      spawn,            SHCMD("screenshot all_clip") },
	{ MODKEY|ShiftMask,             XK_o,      spawn,            SHCMD("screenshot selection_clip") },
	{ MODKEY|ControlMask,           XK_o,      spawn,            SHCMD("screenshot all_save") },
	{ MODKEY|ShiftMask|ControlMask, XK_o,      spawn,            SHCMD("screenshot selection_save") },

	// Mostrar/Ocultar barra
	{ MODKEY,                       XK_b,      togglebar,        {0} },

	// Cambiar de espacio
	{ MODKEY,                       XK_q,      shiftviewclients, { .i = -1 } },
	{ MODKEY,                       XK_w,      shiftviewclients, { .i = +1 } },

	// Cambiar foco/Mover ventana
	STACKKEYS(MODKEY,                                            focus)
	STACKKEYS(MODKEY|ShiftMask,                                  push)

	// Incrementar/Decrementar el número de ventanas de la zona principal
	{ MODKEY,                       XK_j,      incnmaster,       {.i = +1 } },
	{ MODKEY,                       XK_k,      incnmaster,       {.i = -1 } },

	// Incrementar/Decrementar el tamaño de la zona principal y las ventanas
	{ MODKEY,                       XK_u,      setmfact,         {.f = -0.025} },
	{ MODKEY|ControlMask,           XK_u,      setmfact,         {.f = -0.075} },
	{ MODKEY,                       XK_i,      setmfact,         {.f = +0.025} },
	{ MODKEY|ControlMask,           XK_i,      setmfact,         {.f = +0.075} },
	{ MODKEY|ShiftMask,             XK_u,      setcfact,         {.f = -0.25} },
	{ MODKEY|ShiftMask,             XK_i,      setcfact,         {.f = +0.25} },

	// Cerrar aplicación
	{ MODKEY|ShiftMask,             XK_q,      killclient,       {0} },

	// Hacer/Deshacer ventana flotante
	{ MODKEY|ShiftMask,             XK_space,  togglefloating,   {0} },

	// Cambiar de monitor / Mover las ventanas entre monitores
	{ MODKEY,                       XK_g,      focusmon,     {.i = -1 } },
	{ MODKEY,                       XK_h,      focusmon,     {.i = +1 } },
	{ MODKEY|ShiftMask,             XK_g,      tagmon,       {.i = -1 } },
	{ MODKEY|ShiftMask,             XK_h,      tagmon,       {.i = +1 } },

	// Scratchpads
	{ MODKEY,                       XK_s,      togglescratch,    {.v = scratchpadcmd } },
	{ MODKEY|ShiftMask,             XK_s,      scratchtoggle,    {.v = scratchpadcmd } },
	{ MODKEY,                       XK_f,      spawn,            {.v = spawnscratchpadcmd } },

	// Hacer/Deshacer ventana-permanente
	{ MODKEY|ControlMask,           XK_s,      togglesticky,     {0} },

	// Cambiar la distribución de las ventanas
	{ MODKEY,                       XK_e,      setlayout,        {.v = &layouts[0]} }, // Por defecto
	{ MODKEY|ShiftMask,             XK_e,      setlayout,        {.v = &layouts[1]} }, // Una ventana
	{ MODKEY,                       XK_r,      setlayout,        {.v = &layouts[2]} }, // Ventanas flotantes
	{ MODKEY,                 XK_KP_Home,      setlayout,        {.v = &layouts[3]} }, // Stairs  (Teclado numérico)
	{ MODKEY|ShiftMask,       XK_KP_Home,      setlayout,        {.v = &layouts[4]} }, // Deck    (Thinkpad)
	{ MODKEY,                   XK_KP_Up,      setlayout,        {.v = &layouts[5]} }, // Cmaster (Teclado numérico)
	{ MODKEY|ShiftMask,         XK_KP_Up,      setlayout,        {.v = &layouts[6]} }, // Columns (Teclado numérico)
	{ MODKEY,                    XK_Home,      setlayout,        {.v = &layouts[3]} }, // Stairs  (Thinkpad)
	{ MODKEY|ShiftMask,          XK_Home,      setlayout,        {.v = &layouts[4]} }, // Deck    (Thinkpad)
	{ MODKEY,                     XK_End,      setlayout,        {.v = &layouts[5]} }, // Cmaster (Thinkpad)
	{ MODKEY|ShiftMask,           XK_End,      setlayout,        {.v = &layouts[6]} }, // Columns (Thinkpad)

	// Teclas para cada espacio
	TAGKEYS(                        XK_1,                        0)
	TAGKEYS(                        XK_2,                        1)
	TAGKEYS(                        XK_3,                        2)
	TAGKEYS(                        XK_4,                        3)
	TAGKEYS(                        XK_5,                        4)
	TAGKEYS(                        XK_6,                        5)
	TAGKEYS(                        XK_7,                        6)
	TAGKEYS(                        XK_8,                        7)
	TAGKEYS(                        XK_9,                        8)
	TAGKEYS(                        XK_0,                        9)
	TAGKEYS(                        XK_apostrophe,              10)
	TAGKEYS(                        XK_exclamdown,              11)
	// Thinkpad
	TAGKEYS(                        XK_Left,                    12)
	TAGKEYS(                        XK_Down,                    13)
	TAGKEYS(                        XK_Right,                   14)
	TAGKEYS(                        XK_Prior,                   15)
	TAGKEYS(                        XK_Up,                      16)
	TAGKEYS(                        XK_Next,                    17)
	// Teclado numérico
	TAGKEYS(                        XK_KP_End,                  12)
	TAGKEYS(                        XK_KP_Down,                 13)
	TAGKEYS(                        XK_KP_Page_Down,            14)
	TAGKEYS(                        XK_KP_Left,                 15)
	TAGKEYS(                        XK_KP_Begin,                16)
	TAGKEYS(                        XK_KP_Right,                17)
};

static const Button buttons[] = {
	// Click                Combinación     Botón           Función         Argumento
	{ ClkLtSymbol,          0,              Button1,        layoutmenu,     {0} },
	{ ClkLtSymbol,          0,              Button2,        layoutmenu,     {0} },
	{ ClkLtSymbol,          0,              Button3,        layoutmenu,     {0} },
	{ ClkStatusText,        0,              Button1,        spawn,          {.v = statuscmd } },
	{ ClkClientWin,         MODKEY|ControlMask,Button1,     movemouse,      {0} },
	{ ClkClientWin,         MODKEY|ControlMask,Button2,     togglefloating, {0} },
	{ ClkClientWin,         MODKEY|ControlMask,Button3,     resizemouse,    {0} },
	{ ClkTagBar,            0,              Button1,        view,           {0} },
	{ ClkTagBar,            0,              Button3,        toggleview,     {0} },
	{ ClkTagBar,            MODKEY,         Button1,        tag,            {0} },
	{ ClkTagBar,            MODKEY,         Button3,        toggletag,      {0} },
	{ ClkStatusText,        0,              Button4,        spawn,          SHCMD("volinc 5; pkill -RTMIN+25 dwmblocks") },
	{ ClkStatusText,        0,              Button5,        spawn,          SHCMD("pactl set-sink-volume @DEFAULT_SINK@ -5%; pkill -RTMIN+25 dwmblocks") },
};
