#!/bin/bash

# Alejandro Lugo Fumero
crear_usuario () {

        read -p "Introduzca los permisos en octal: " permisos
        ejecutivos=$1
        shift

	while [ "$1" != "" ]
                do
                useradd $1
                echo $1 | passwd --stdin $1
                chage -M 90 -W 1 -I 2 $1
                chown root:$1 /home/$1
                chmod $permisos /home/$1

                if [ "$ejecutivos" == "1" ] ; then
                        usermod -a -G ejecutivos $1
                else
                    	usermod -a -G comun $1
                fi
                shift 
        done
}



borrar_usuario () {

        echo "Estos son los usuarios disponibles: "
        usuario=$(ls /home | cut -d: -f1)

        for es_usuario in $usuario
        do
          	if [ "$es_usuario" != "aquota.group" ] && [ "$es_usuario" != "aquota.user" ] && [ "$es_usuario" != "quota.group" ] && 
                   [ "$es_usuario" != "quota.user" ] && [ "$es_usuario" != "lost+found" ] ; then
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
          	if [ "$es_usuario" != "aquota.group" ] && [ "$es_usuario" != "aquota.user" ] && [ "$es_usuario" != "quota.group" ] &&
                   [ "$es_usuario" != "quota.user" ] && [ "$es_usuario" != "lost+found" ] ; then
                        echo $es_usuario
                fi
        done
}



crear_grupo () {

        echo "Estos son los usuarios disponibles: "
        usuario=$(ls /home | cut -d: -f1)

        for es_usuario in $usuario
        do
          	if [ "$es_usuario" != "aquota.group" ] && [ "$es_usuario" != "aquota.user" ] && [ "$es_usuario" != "quota.group" ] && 
                   [ "$es_usuario" != "quota.user" ] && [ "$es_usuario" != "lost+found" ] ; then
                        echo $es_usuario
                fi
        done

        read -p "Introduzca el nombre de los usuarios: " usuario
        for es_usuario in $usuario
        do
                usermod -a -G $grupo $es_usuario
        done
}



crear_proyecto () {

        read -p "Introduzca el nombre del proyecto: " nombre
        mkdir /export/proyectos/$nombre
	chmod 770 /export/proyectos/$nombre

        grupo_usuario=""usu_""$nombre""
        groupadd $grupo_usuario

        grupo_ejecutivo=""eje_""$nombre""
	groupadd $grupo_ejecutivo

	echo "Estos son los usuarios disponibles: "
        usuario=$(ls /home | cut -d: -f1)

        for es_usuario in $usuario
        do
                if [ "$es_usuario" != "aquota.group" ] && [ "$es_usuario" != "aquota.user" ] && [ "$es_usuario" != "quota.group" ] && 
                   [ "$es_usuario" != "quota.user" ] && [ "$es_usuario" != "lost+found" ] ; then
                        echo $es_usuario
                fi
        done

	read -p "Introduzca el nombre de los usuarios: " usuario
        for es_usuario in $usuario
        do
          	usermod -a -G $grupo_usuario $es_usuario
        done

	read -p "Introduzca el nombre de los ejecutivos: " usuario
        for es_usuario in $usuario
        do
          	usermod -a -G $grupo_ejecutivo $es_usuario
        done

        setfacl -m g:$grupo_usuario:rwx /export/proyectos/$nombre
        setfacl -R -m g:$grupo_usuario:rwx /export/proyectos/$nombre

        setfacl -m g:$grupo_ejecutivo:rx /export/proyectos/$nombre
        setfacl -R -m g:$grupo_ejecutivo:rx /export/proyectos/$nombre

        cp /bin/ls /usr/local/bin/ls.$nombre
        chown root:$grupo_ejecutivo /usr/local/bin/ls.$nombre
        chmod 110 /usr/local/bin/ls.$nombre
        chmod g+s /usr/local/bin/ls.$nombre

        setfacl -m g:ejecutivos:x /usr/local/bin/ls.$nombre
        setfacl -R -m g:ejecutivos:x /usr/local/bin/ls.$nombre
}



borrar_proyecto () {

        read -p "Introduzca el nombre del proyecto: " nombre
        groupdel usu_$nombre
        groupdel eje_$nombre
        rm -r -f /export/proyectos/$nombre
        rm -r -f /usr/local/bin/ls.$nombre
}




echo "Introduzca un:"
echo "1 CREAR NUEVOS EMPLEADOS"
echo "2 CREAR NUEVOS EJECUTIVOS"
echo "3 BORRAR USUARIOS"
echo "4 CREAR NUEVOS GRUPOS"
echo "5 AÑADIR USUARIOS A UN GRUPO"
echo "6 CREAR UN NUEVO PROYECTO"
echo "7 BORRAR UN PROYECTO"
read -p "Su opcion es: " opcion

case $opcion in
    1 )
       	read -p "Introduzca a los empleados: " usuarios
        crear_usuario 0 $usuarios
        ;;
    2 )
       	read -p "Introduzca a los ejecutivos: " usuarios
        crear_usuario 1 $usuarios
        ;;
    3 )
       	borrar_usuario
        ;;
    4 )
       	read -p "Introduzca el nombre del grupo: " grupo
        groupadd $grupo

        crear_grupo
        ;;
    5 )
       	read -p "Introduzca el nombre del grupo: " grupo

        crear_grupo
        ;;
    6 )
       	crear_proyecto
        ;;
    7 )
       	borrar_proyecto
        ;;
esac
