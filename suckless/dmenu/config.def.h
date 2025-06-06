/* See LICENSE file for copyright and license details. */
/* Default settings; can be overriden by command line. */

static int topbar = 1;
static int centered = 0;
static int min_width = 500;

static const char *fonts[] = {
	"Iosevka Term SS05:pixelsize=26",
	"Symbols Nerd Font Mono:pixelsize=22:antialias=true:autohint=true",
	"Noto Color Emoji:pixelsize=26:regular"
};

static const char *prompt = NULL;
static const char *colors[SchemeLast][2] = {
	[SchemeNorm] = { "#EBDBB2", "#282828" },
	[SchemeSel]  = { "#EBDBB2", "#3c3836" },
	[SchemeOut]  = { "#000000", "#00ffff" },
};

static unsigned int lines = 6;
static const char worddelimiters[] = " ";
