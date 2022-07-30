#!/bin/bash

crear_usuario () {
    while [ "$1" != "" ]
        do
	useradd $1
        echo $1 | passwd --stdin $1
        chage -M 90 -W 1 -I 2 $1
        chown root:$1 /home/$1
        chmod $permisos /home/$1
        shift 
    done
}



borrar_usuario () {

        echo "Estos son los usuarios disponibles: "
        usuario=$(ls /home | cut -d: -f1)
        for es_usuario in $usuario
        do
          	if [ "$es_usuario" != "aquota.group" ] && [ "$es_usuario" != "aquota.user" ] && [ "$es_usuario" != "quota.group" ] && [ "$es_usuario" != "quota.user" ] && [ "$es_usuario" != "lost+found"$
                        echo $es_usuario
                fi
        done
	echo
	read -p "Introduzca el nombre de los usuarios que quiera eliminar: " usuario

        for es_usuario in $usuario
        do
          	userdel -r -f $es_usuario
        done

	echo "Esta es la nueva lista de usuarios: "
        usuario=$(ls /home | cut -d: -f1)
        for es_usuario in $usuario
        do
          	if [ "$es_usuario" != "aquota.group" ] && [ "$es_usuario" != "aquota.user" ] && [ "$es_usuario" != "quota.group" ] && [ "$es_usuario" != "quota.user" ] && [ "$es_usuario" != "lost+found"$
                        echo $es_usuario
                fi
        done
}



read -p "Introduzca un 1 para crear nuevos usuarios, un 2 para borrar un usuario: " opcion

case $opcion in
    1 )
        read -p "Introduzca los permisos en octal: " permisos
        read -p "Introduzca a los usuarios: " usuarios
        crear_usuario $usuarios
        ;;
    2 )  
	borrar_usuario
        ;;
esac

