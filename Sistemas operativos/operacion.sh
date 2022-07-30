#!/bin/bash

# sysinfo - Un script sobre la practica 4 de sistemas

##### Constantes
TITLE="PRACTICA 4 DE SISTEMAS OPERATIVOS POR $USER"
interactive=
usuario=$USER
RIGHT_NOW=$(date +"%x %r%Z")
TIME_STAMP="Actualizada el $RIGHT_NOW por $USER"
##### Estilos
TEXT_BOLD=$(tput bold)
TEXT_ULINE=$(tput sgr 0 1)
TEXT_GREEN=$(tput setaf 2)
TEXT_RESET=$(tput sgr0)

##### Funciones

system_info(){
    echo "${TEXT_ULINE}Versión del sistema${TEXT_RESET}"
    echo 
    uname -a
}

show_uptime(){
    echo "${TEXT_ULINE}Tiempo de encendido del sistema${TEXT_RESET}"
    echo 
    uptime
}

drive_space(){
    echo "${TEXT_ULINE}Espacio en el sistema de archivos${TEXT_RESET}"
    echo 
    df
}
home_space(){
    if [ "$USER" = "root" ] 
    then
       echo "${TEXT_ULINE}Espacio en home por usuario${TEXT_RESET}"
       echo
       echo "Bytes Directorio"
       du -s /home/* | sort -nr
   fi
}
funciones(){

##### Programa principal

cat << _EOF_

$TEXT_BOLD$TITLE$TEXT_RESET

$(system_info)

$(show_uptime)

$(drive_space)

$(home_space)

$TEXT_GREEN$TIME_STAMP$TEXT_RESET

_EOF_
}
if [ "$1" != "" ]
then
    usuario=$1
fi
ps -e -o user,pcpu,nice,state,cputime,args --sort pcpu | grep $usuario
echo
funciones