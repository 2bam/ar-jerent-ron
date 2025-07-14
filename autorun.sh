#!/bin/bash

cd $(dirname "$0")

# Verificar si hay algun archivo corrupto y mostrar un mensaje de aviso.

if ! OUTPUT=$(sha256sum -c --quiet sha256sums 2>/dev/null); then
    # Uses Pango markup https://docs.gtk.org/Pango/pango_markup.html
    # CUIDADO AL USAR ACENTOS QUE FALLA EN LINUX!!!
    BODY="<span bgcolor='red' color='black' size='200%'><b>Instalacion rota</b></span><span size='150%'>
    
Algunos archivos cambiaron:

$OUTPUT
</span>"
    LC_ALL=C zenity \
        --warning \
        --no-wrap \
        --text "$BODY" \
        --ok-label "OK (cierra en 60 seg.)" \
        --timeout=60 \
        2>/dev/null
fi

LC_ALL=C zenity \
    --info \
    --no-wrap \
    --text "El emulador de nes iniciara automaticamente en 10 segundos y se escondera el escritorio.\n\n
Para en cambio configurar el sistema apretar el boton." \
    --ok-label="No iniciar y configurar sistema" \
    --timeout=10 \
    2>/dev/null

# Zenity exitcode 5 significa timeout. Cualquier otro input frena el autorun.
if [[ $? != 5 ]]; then
    exit 1
fi

# Especifico a Raspberry Pi OS: Desactivar barra de tareas del escritorio para,
# a su vez, tambien desactivar notificaciones y pop-ups.
pkill -f wf-panel-pi

# Extraer el juego inicial del script, ya que fceux lo requiere como parametro.
INITIAL=$(sed -nE 's/local current = "(.*)"/\1/p' jere.lua)

LC_ALL=C DISPLAY=:0 fceux --fullscreen 1 --loadlua jere.lua "$INITIAL.nes"
