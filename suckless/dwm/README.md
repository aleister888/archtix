# aleister888's build of dwm

> ¿Cuáles son los atajos de teclado?

Puedes consultar los atajos de teclado leyendo el código en `config.def.h` (`static const Key keys[]`).

## Modificaciones

- Al iniciar dwm se ejecuta un script que inicia el entorno de escritorio: [dwm-autostart-20210120-cb3f58a.diff](http://dwm.suckless.org/patches/autostart/dwm-autostart-20210120-cb3f58a.diff)
- Espacio entre las ventanas: [dwm-vanitygaps-6.2.diff](https://dwm.suckless.org/patches/vanitygaps/dwm-vanitygaps-6.2.diff)
- Las ventanas se mantienen en su espacio al reiniciar dwm: [dwm-preserveonrestart-6.3.diff](http://dwm.suckless.org/patches/preserveonrestart/dwm-preserveonrestart-6.3.diff)
- Los ajustes de ventana son para cada espacio en vez de globales [dwm-pertag-20200914-61bb8b2.diff](http://dwm.suckless.org/patches/pertag/dwm-pertag-20200914-61bb8b2.diff)
- Las ventanas se pueden re-dimensionar desde cualquiera de sus cuatro esquinas: [dwm-resizecorners-6.3.diff](https://github.com/bakkeby/patches/blob/master/dwm/dwm-resizecorners-6.3.diff)
- La posición y tamaño de las ventanas flotantes se guardan en memoria: [dwm-savefloats-20181212-b69c870.diff](http://dwm.suckless.org/patches/save_floats/dwm-savefloats-20181212-b69c870.diff)
- Arreglar la opacidad de los bordes de ventanas: [dwm-fixborders-6.2.diff](https://dwm.suckless.org/patches/alpha/dwm-fixborders-6.2.diff)
- Atajos de teclado para organizar el stack: [dwm-stacker-6.2.diff](https://dwm.suckless.org/patches/stacker/dwm-stacker-6.2.diff)
- Las aplicaciones abiertas por una terminal ocupan el espacio de dicha terminal: [dwm-swallow-6.3.diff](https://dwm.suckless.org/patches/swallow/dwm-swallow-6.3.diff)
- Atajo de teclado para cambiar entre espacios ocupados fácilmente: [dwm-shiftviewclients-6.2.diff](https://github.com/bakkeby/patches/blob/master/dwm/dwm-shiftviewclients-6.2.diff)
- Ventanas semi-visibles: [dwm-renamedscratchpads-6.3.diff](https://github.com/bakkeby/patches/blob/master/dwm/dwm-renamedscratchpads-6.3.diff)
- Ventanas persistentes: [dwm-sticky-6.4.diff](http://dwm.suckless.org/patches/sticky/dwm-sticky-6.4.diff)
- Layout deck: [dwm-deck-6.2.diff](http://dwm.suckless.org/patches/deck/dwm-deck-6.2.diff)
- Layout strairs: [dwm-stairs-fullgaps-20220430-8b48e30.diff](https://dwm.suckless.org/patches/stairs/dwm-stairs-fullgaps-20220430-8b48e30.diff)
- Pantalla completa falsa: [dwm-selectivefakefullscreen-20201130-97099e7.diff](https://dwm.suckless.org/patches/selectivefakefullscreen/dwm-selectivefakefullscreen-20201130-97099e7.diff)
- **Modificaciones a la barra de tareas:**
  - Solo se muestran los espacios ocupados: [dwm-hide_vacant_tags-6.2.diff](https://dwm.suckless.org/patches/hide_vacant_tags/dwm-hide_vacant_tags-6.2.diff)
  - El tamaño de la barra se puede configurar: [dwm-bar-height-spacing-6.3.diff](http://dwm.suckless.org/patches/bar_height/dwm-bar-height-spacing-6.3.diff)
  - Las ventanas flotantes nuevas aparecerán centradas: [dwm-alwayscenter-20200625-f04cac6.diff](http://dwm.suckless.org/patches/alwayscenter/dwm-alwayscenter-20200625-f04cac6.diff)
  - Las ventanas nuevas aparecerán al final del stack: [dwm-attachbottom-6.3.diff](http://dwm.suckless.org/patches/attachbottom/dwm-attachbottom-6.3.diff)
  - Se usa el caracter unicode "…" cuando el texto es demasiado largo para la barra de estado en vez de "..." [dwm-unicode_ellipsis-20222909-d3f93c7.diff](https://dwm.suckless.org/patches/unicode-ellipsis/dwm-unicode_ellipsis-20222909-d3f93c7.diff)
  - Se pueden usar colores en la barra de estado: [dwm-status2d-6.3.diff](https://dwm.suckless.org/patches/status2d/dwm-status2d-6.3.diff)
  - La etiqueta seleccionada tiene una barra debajo [dwm-underlinetags-6.2.diff](https://dwm.suckless.org/patches/underlinetags/dwm-underlinetags-6.2.diff)
  - La barra de estado se puede clicar para ejecutar comandos: [dwm-statuscmd-nosignal-status2d-20210402-60bb3df.diff](https://dwm.suckless.org/patches/statuscmd/dwm-statuscmd-nosignal-status2d-20210402-60bb3df.diff)
    - Se deben de añadir unas lineas para ignorar también los _^_

```c
@@ buttonpress(XEvent *e)
					if (x >= ev->x)
						break;
					statuscmdn = ch;
+				} else if (*s == '^') {
+					*s = '\0';
+					x += TEXTW(text) - lrpad;
+					*s = '^';
+					if (*(++s) == 'f')
+						x += atoi(++s);
+					while (*(s++) != '^');
+					text = s;
+					s--;
				}
			}
		}
```

- Función para marcar/desmarcar una ventana como scratchpad

```c
void
scratchtoggle(const Arg *arg)
{
	Client *c = selmon->sel;
	if (!c) {
		return;
	} else {
		if (c->scratchkey == 0) {
			XSetWindowBorder(dpy, c->win, scheme[SchemeScratchSel][ColBorder].pixel);
			c->scratchkey = ((char**)arg->v)[0][0];
		} else {
			XSetWindowBorder(dpy, c->win, scheme[SchemeSel][ColBorder].pixel);
			c->scratchkey = 0;
		}
	}
}
```

- Actualizar el borde de las ventanas sticky inmediatamente

```c
void
setsticky(Client *c, int sticky)
{

	if(sticky && !c->issticky) {
		XChangeProperty(dpy, c->win, netatom[NetWMState], XA_ATOM, 32,
			PropModeReplace, (unsigned char *) &netatom[NetWMSticky], 1);
		c->issticky = 1;
		XSetWindowBorder(dpy, c->win, scheme[SchemeStickySel][ColBorder].pixel);
	} else if(!sticky && c->issticky){
		XChangeProperty(dpy, c->win, netatom[NetWMState], XA_ATOM, 32,
			PropModeReplace, (unsigned char *)0, 0);
		c->issticky = 0;
		XSetWindowBorder(dpy, c->win, scheme[SchemeSel][ColBorder].pixel);
		arrange(c->mon);
	}
}
```

```c
@@ -1101,10 +1101,13 @@ focus(Client *c)
		detachstack(c);
		attachstack(c);
		grabbuttons(c, 1);
-		if (c->scratchkey != 0)
+		if (c->scratchkey != 0) {
			XSetWindowBorder(dpy, c->win, scheme[SchemeScratchSel][ColBorder].pixel);
-		else
+		} else if (c->issticky) {
+			XSetWindowBorder(dpy, c->win, scheme[SchemeStickySel][ColBorder].pixel);
+		} else {
			XSetWindowBorder(dpy, c->win, scheme[SchemeSel][ColBorder].pixel);
+		}
		setfocus(c);
	} else {
		XSetInputFocus(dpy, root, RevertToPointerRoot, CurrentTime);
```
