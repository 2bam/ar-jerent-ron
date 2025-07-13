#!/bin/bash

if [ "$(uname)" == "Darwin" ]; then
    if ! which brew >/dev/null; then
        echo Necesitas instalar "brew"
        exit 1
    fi
    brew install fceux zenity coreutils
else
    sudo apt-get -y install fceux zenity
fi

mkdir -p ~/.fceux

echo '
Copiando configuracion base del emulador'

cp -i base-fceux.cfg ~/.fceux/fceux.cfg

echo '
Instalado!
Para configurar, ejecutar el emulador con el comando "fceux".
En el menu superior ir a Options, Gamepad Config.
Se puede ajustar la paleta y video tambien en Options.'
