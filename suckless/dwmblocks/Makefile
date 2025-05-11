# Consulta el archivo LICENSE para los detalles de derechos de autor y licencia.

PREFIX  := /usr/local
CC      := cc # Compilador
CFLAGS  := -pedantic -Wall -Wno-deprecated-declarations -Os -Wno-incompatible-pointer-types
LDFLAGS := -lX11

# Descomenta esta línea para compilar en FreeBSD
#LDFLAGS += -L/usr/local/lib -I/usr/local/include
# Descomenta esta línea para compilar en OpenBSD
#LDFLAGS += -L/usr/X11R6/lib -I/usr/X11R6/include

all: options dwmblocks

options:
	@echo dwmblocks build options:
	@echo "CFLAGS  = ${CFLAGS}"
	@echo "LDFLAGS = ${LDFLAGS}"
	@echo "CC      = ${CC}"

dwmblocks: dwmblocks.c blocks.def.h blocks.h
	${CC} -o dwmblocks dwmblocks.c ${CFLAGS} ${LDFLAGS}

blocks.h:
	cp blocks.def.h $@

clean:
	rm -f *.o *.gch blocks.h dwmblocks

install: dwmblocks
	mkdir -p ${DESTDIR}${PREFIX}/bin
	install -Dm755 dwmblocks ${DESTDIR}${PREFIX}/bin

uninstall:
	rm -f ${DESTDIR}${PREFIX}/bin/dwmblocks

.PHONY: all options clean install uninstall
