#!/bin/bash
#open_lies.sh - práctica de bash manejo de ficheros.

# Constantes (variables en mayúsculas)
AUTOR="Práctica de bash realizada por Alejandro Lugo Fumero"
USUARIO="Usuario"
SEPARADOR="////////////////////////////////////////////////////"
MOSTRAR_UID="UID"
MOSTRAR_PID="PID mas antiguo"
MOSTRAR_TIEMPO_PID="Tiempo PID"
FICHEROS="Cantidad ficheros"
COINCIDENCIA_CON_EXPRESION="La cantidad de ficheros que coinciden con la expresion"
COINCIDENCIA_CON_EXPRESION1="es de :"
ANADIR_EXPRESION_REGULAR="$"

# Variables
# Aquí guardamos todos los usuarios de "who".
guardar_todos_los_usuario=
# Aquí guardamos la cantidad de ficheros abiertos por el usuario.
guardar_ficheros_abiertos= 
# Aquí guardamos el UID del usuario.
guardar_uid= 
# Aquí guardamos el PID del proceso más antiguo del usuario.
guardar_pid_antiguo=
# Aquí guardamos el tiempo de ejecucion del PID mas antiguo.
guardar_tiempo_pid=
# Variable auxiliar que usaremos para ir cambiando entre todos los usuarios.
cada_usuario=
# Variable que usaremos para sumar la cantidad de archivos que cumplan nuestra
# expresion regular.
sumador=0
# Variable auxiliar que usaremos para recorrer las distintas columnas de lsof
columna=
# Variable que usaremos para guardar la expresion regular a analizar
expresion_regular=
# Variable que usaremos para guardar la expresion regular + '$'
adaptar_expresion=
# Variable que cuenta la cantidad de elementos que cumplen la expresion regular
# por columna, no el total final
contador=
# Variable donde vamos a guardar todos los usuarios, los que estan offline y los que no.
usuario_off_line=
# Luego de aplicar un filtro a "usuario_off_line" aqui guardaremos a los usuarios que esten realmete ofline.
filtro_usuarios_off_line=
# Auxiliar que uso dentro de un bucle for.
comparador1=
# Auxiliar que uso dentro de un bucle for.
comparador2=
# Auxiliar que uso para filtrar a los usuarios offline
repeticion=0
# Auxiliar que uso para contar que todos los usuarios usados en la opcion -u pertenezcan al sistema.
contador_usuarios_introducidos=0

# Estilos
TEXT_BOLD=$(tput bold)
TEXT_ULINE=$(tput sgr 0 1)
TEXT_GREEN=$(tput setaf 2)
TEXT_RESET=$(tput sgr0)

# Función que lee todos los usuarios del Who sin repetir ninguno, de forma ordenada y los guarda en
# $guardar_todos_los_usuario, luego usamos un for para ir cambiando entre usuario y mostramos toda
# la informacion.
funcionamiento_basico(){

    # Si no le hemos dado anteriormente un valor a $guardar_todos_los_usuario se lo damos, esto significaria
    # que estamos usando la funcion basica del script.
    if [ "$guardar_todos_los_usuario" = "" ] ; then
    guardar_todos_los_usuario=$(who | sort | uniq |cut -d " " -f 1)
    fi
    for cada_usuario in $guardar_todos_los_usuario
        do
        # Si le pasamos un $2 es porque nos encontramos en la funcion -u usuario1 -f 'expresion_regular' y entonces
        # la cantidad de ficheros a contar son los que cumplen la expresion regular.
        if [ "$1" = "" ] ; then
        guardar_ficheros_abiertos=$(lsof -u $cada_usuario | wc -l)
        else
        filtro $1 $cada_usuario
        fi
        guardar_uid=$(id -u $cada_usuario)
        guardar_pid_antiguo=$(ps -u $cada_usuario -o pid,time | awk 'NR==2' | cut -d " " -f 4)
        guardar_tiempo_pid=$(ps -u $cada_usuario -o pid,time | awk 'NR==2' | cut -d " " -f 5)
        echo "$cada_usuario  /  $guardar_uid  /  $guardar_ficheros_abiertos  /  $guardar_pid_antiguo  /  $guardar_tiempo_pid"
    done
}

# Función que imprime los titulos y luego muestra la informacion de cada usuario.
escribir_funcionamiento_basico(){
    echo "$USUARIO / $MOSTRAR_UID / $FICHEROS / $MOSTRAR_PID / $MOSTRAR_TIEMPO_PID"
    if [ "$1" = "-o" ] || [ "$1" = "--off_line" ] ; then
    filtro_off_line
    else
    funcionamiento_basico $1 $2
    fi
}

# Funcion que cuenta la cantidad de archivos que cumplen la expresion regular que usamos con -f.
filtro(){
    expresion_regular=$1
    adaptar_expresion=$expresion_regular$ANADIR_EXPRESION_REGULAR

    for columna in 9 10 11
        do
        if [ "$2" = "" ] ; then
            contador=$(lsof | awk '{print $'$columna'}' | grep -E ''$adaptar_expresion'' | wc -l)
            sumador=$(($sumador + $contador))
        else 
            contador=$(lsof -u $2 | awk '{print $'$columna'}' | grep -E ''$adaptar_expresion'' | wc -l)
            sumador=$(($sumador + $contador))
        fi
        done
        
    if [ "$2" = "" ] ; then
        escribir_f
    else 
        guardar_ficheros_abiertos=$sumador
    fi
}

# Funcion que muestra la expresion regular y la cantidad de archivos que la cumplen.
escribir_f(){
    echo "$COINCIDENCIA_CON_EXPRESION $expresion_regular $COINCIDENCIA_CON_EXPRESION1 $sumador"
}

# Funcion que elimina todos los usuarios que se encuentran online del total de usuarios de esta forma
# optenemos solo los offline
filtro_off_line(){
    guardar_todos_los_usuario=$(who | sort | uniq |cut -d " " -f 1)
    usuario_off_line=$(cut -d: -f1 /etc/passwd)
    for comparador1 in $usuario_off_line
        do
        repeticion=0
        for comparador2 in $guardar_todos_los_usuario
            do
            if [ "$comparador1" == "$comparador2" ] ; then
            repeticion=$(($repeticion + 1))
            fi
            done  
        if [ "$repeticion" = 0 ] ; then
        filtro_usuarios_off_line="$filtro_usuarios_off_line $comparador1"
        fi
        done

        guardar_todos_los_usuario=$filtro_usuarios_off_line
        funcionamiento_basico
}



#Tratamiento de errores.
# Función que comprueba "que lsof esté instalado y sino da error y muestra un mensaje.
instalacion_lsof(){
    if [ $(type -P lsof) ] ; then
        creador
    else
        echo "Ha ocurrido un error ya que no cuenta con el paquete \"lsof\" pruebe a instalarlo con \"apt-get install lsoft\""
        error_exit
    fi
}

# Función que basicamente sale del programa retornando $? = 1.
error_exit(){
    exit 1
}

# Función que muestra quien fue el creador.
creador(){
    echo $TEXT_BOLD$TEXT_GREEN$SEPARADOR
    echo $AUTOR$TEXT_RESET
    echo 
}

# Función que muestra lo que hace el script y la forma correcta de ejecutarlo en caso de escribir -h o --help.
ayuda(){
cat << _EOF_
Este script de bash realiza diferentes tareas:

Funcion basica
    La funcion mas basica muestra una lista ordenada y sin duplicados de todos los usuarios conectados en el sistema,
    cuenta el número de ficheros abiertos que tiene actualmente cada usuario, incluye el UID del usuario, y el PID 
    de su proceso más antiguo.

    La forma correcta de ejecutarla es "./open_files.sh".

-f
    Con la opcion -f seguido de una expresion regular nuestro script de bash contara la cantidad de ficheros que cumplen
    con la expresion regular pasada.

    La forma correcta de ejecutarla es "./open_files.sh -f 'expresion_regular'"
    Siendo expresion_regular su expresion regular."
    Por ejemplo: siendo la expresion regular .*sh, la manera correcta de usar el comando seria "./open_files.sh -f '.*sh'"

-o | --off_line
    Con la opcion -o | --off_line nuestro script de bash realizara la "Funcion basica" pero para usuarios que estan offline

    La forma correcta de ejecutarla es "./open_files.sh -o" | "./open_files.sh --off_line"

-u | --user
    Con la opcion -u | --user seguido de uno o varios usuarios vamos a realizar la "Funcion basica" pero unicamente para esos
    usuarios, en el caso que despues de los usuarios escribamos "-f" seguido de una expresion regular, lo que haremos sera
    realizar la "Funcion basica" pero solo contaremos los ficheros que cumplan esa expresion. (Para mas informacion sobre como
    usar la opcion "-f" consulte ese apartado).

    La forma correcta de ejecutarla es "./open_files.sh -u usuario1 usuario2" | "./open_files.sh -u usuario1 usuario2 -f 'expresion_regular'" 

Para cualquier duda o problema contacte con el administrador "alu0101329185@ull.edu.es".
_EOF_
}

# Función que muestra las opciones que soporta el script y retorna 1(error).
opcion_no_soportada(){
    echo "Ha ocurrido un error ya que ha introducido una opcion no soportada por el propio script."
    echo "Pruebe con: \"./open_files.sh -h | --help\" para obtener mas informacion"
    error_exit
}

# Funcion que sale del programa si despues de -f no escribimos ninguna expresion regular o si depues de introducir
# los usuarios no ponemos algo distinto de "-f"
error_f(){

    if [ "$1" != "-f" ] ; then
    echo "Ha introducido una funcion no aceptada despues del \"/open_files.sh -u usuario1 usuario2 ...\""
    echo
    echo "Para mas informacion pruebe con : \"./open_files.sh -h | --help\""
    error_exit
    fi

    if [ "$2" = "" ] ; then
    echo "La expresion regular esta vacia, pruebe con -f 'expresion_regular'"
    echo "Siendo expresion_regular su expresion regular."
    echo "Por ejemplo: siendo la expresion regular .*sh, la manera correcta de usar el comando seria \"-f '.*sh'\""
    echo
    echo "Para mas informacion pruebe con : \"./open_files.sh -h | --help\""
    error_exit
    fi

    if [ "$3" != "" ] ; then
    echo "Ha introducido demasidas expresiones regulares o ha introducido la expresion regular de forma erronea"
    echo
    echo "Para mas informacion pruebe con : \"./open_files.sh -h | --help\""
    error_exit
    fi
}

# Funcion que sale del programa si introducimos un usuario que no exista en el sistema o si no introducimos 
# ningun usuario.
error_usuario_registrado(){
    usuario_off_line=$(cut -d: -f1 /etc/passwd)
    repeticion=0

    if [ ${#guardar_todos_los_usuario} = 0 ] ; then
    echo "Ha ocurrido un error ya que no ha introducido ningun usuario"
    echo
    echo "Para mas informacion pruebe con : \"./open_files.sh -h | --help\""
    error_exit
    fi

    for comparador1 in $guardar_todos_los_usuario
        do
        contador_usuarios_introducidos=$(($contador_usuarios_introducidos + 1))
        for comparador2 in $usuario_off_line
            do
            if [ "$comparador1" == "$comparador2" ] ; then
            repeticion=$(($repeticion + 1))
            fi
            done  
        done
        if [ "$repeticion" != "$contador_usuarios_introducidos" ] ; then
        echo "Ha introducido uno o mas usuarios incorrectos, por favor vuelva revisarlo."
        echo
        echo "Para mas informacion pruebe con : \"./open_files.sh -h | --help\""
        error_exit
        fi
}

error_offline(){

    if [ "$1" != "" ] ; then 
    echo "Ha introducido mas parametros de los soportados"
    echo
    echo "Para mas informacion pruebe con : \"./open_files.sh -h | --help\""
    error_exit
    fi
}




instalacion_lsof
case $1 in 
    "" )
        escribir_funcionamiento_basico
        ;;
    -h | --help )
        ayuda
        ;;
    -f )
        error_f $1 $2 $3
        filtro $2
        ;;
    -o | --off_line )
        error_offline $2
        escribir_funcionamiento_basico $1
        ;;
    -u | --user )
        shift
        while [ "$1" != "" ] && [ "$1" != "-f" ]
            do
            guardar_todos_los_usuario="$guardar_todos_los_usuario $1"
            shift
            done
            error_usuario_registrado
            if [ "$1" = "" ] ; then
            escribir_funcionamiento_basico
            else
            error_f $1 $2 $3
            escribir_funcionamiento_basico $2
            fi
        ;;
    * )
        opcion_no_soportada
        ;;
esac