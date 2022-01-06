#!/bin/bash
# By Gaston Ibarra 
#pendientes: fix alternate , script multiglog, parchado, postcheck 


clear -x 
espacio="\n"
trap control_c INT

dfvar=$(df -h | awk '$NF=="/boot"{print "%" int($5)}')

#dfvar(){    df -h | awk '$NF=="/var"{print "%" int($5)}'}
#var=$(df -h | grep /var | awk 'NR==1{print $5}' | sed 's/.$//') #Detecta el % de uso en disco en /var

menu_fisicos(){
    read -r -p "$(echo -e " \n")--1-- Hacer Clean General $(echo -e " $espacio ")--2-- Registrar la RPM y el Oscheck $(echo -e " $espacio ")--3-- Arrancar el Alternate_boot $(echo -e " $espacio ")--4-- Salir $(echo -e " $espacio ") " eleccion 
}

menu_var(){     
    read -r -p "$(echo -e "$espacio")$(echo -e " $espacio ")--4-- Desea limpiar el /Var $(echo -e " $espacio ")--5-- Solo borrar old kernelss $(echo -e " $espacio ")--6-- Limpiar Var y Kernels $(echo -e " $espacio ") " eleccion2 
}

menu_final(){     
    read -r -p "$(echo -e "$espacio")$(echo -e " $espacio ")--7-- Desea volver al menu principal? $(echo -e " $espacio ")--8-- Desea salir? $(echo -e " $espacio ")--9-- Enviar emails y salir $(echo -e " $espacio ") " eleccion3 
}

ctrl_c(){
  echo ""
  echo -e "\n[!] Saliendo...\n\n"
  sleep 1
  exit 
}

oscheck(){
   checkout=$(find /root -name "*check*.sh")
   $checkout > /var/tmp/PrecheckOS."$user_input"
}


title(){
    echo "

  ______  ______   _   _ _   _ _____  __  _____ _____    _    __  __ 
 |  _ \ \/ / ___| | | | | \ | |_ _\ \/ / |_   _| ____|  / \  |  \/  |
 | | | \  / |     | | | |  \| || | \  /    | | |  _|   / _ \ | |\/| |
 | |_| /  \ |___  | |_| | |\  || | /  \    | | | |___ / ___ \| |  | |
 |____/_/\_\____|  \___/|_| \_|___/_/\_\   |_| |_____/_/   \_\_|  |_|                   

--Welcome to the bash app to patch physicals servers. (Only RedHat)--

"
}

caseloop(){
if [[ "$seleccion4" == "7" ]]; then
menu_fisicos
else
title
read -n 1 -s -r -p " press any key to exit $( echo -e "\n")"
fi  
}



########################################## programa  #####################################################
while true; do
title

menu_fisicos


case "$eleccion" in 
    [1])
    clear -x  
    echo -e "El Diskspace actual es de $dfvar"   
        menu_var
        case "$eleccion2" in 
            [4])
                echo "Limpiando logs"
                > /var/log/tallylog
                > /var/log/lastlog
                find /var/audit -type f -mtime +0 -exec rm -f {} \;
                logrotate -vf /etc/logrotate.d/syslog 
                
            ;;
            [5])
                echo "Limpiando Kernels"
                package-cleanup -y --oldkernels --count=2
            ;;    
            [6])
                echo "Limpiando logs"
                > /var/log/tallylog
                > /var/log/lastlog
                find /var/audit -type f -mtime +0 -exec rm -f {} \
                logrotate -vf /etc/logrotate.d/syslog 

                echo "Limpiando Kernels"
                package-cleanup -y --oldkernels --count=2

            ;;
        esac    
    ;;
    [2]) 
        echo  " Comenzando el Registro de la RPM y el Oscheck"
        read -p "ingresar Nº RFC:  " user_input
        echo " `rpm -qa` "
        rpm -qa > /var/tmp/rpmqa.$user_input
        oscheck
    ;;    
    [3])
    echo  " empezando alternate_boot"
    cd /root 
    nohup alternate_boot -v -c & sleep 1; tail -f nohup.out
    ls -l /var/log/alternate_boot.log
    tail /var/log/alternate_boot.log
    ;;
    [4])
    break
    ;;

    
esac

title

menu_final

case $seleccion3 in

    [7])
    seleccion4=7
    ;;

    [8])

    #echo "gracias por su visita"

    #read -p "gracias por su visita"

    break
    ;;

    [9])
    #echo "enviando los checks por email"
    #echo "gracias por su visita"
    break
    ;;

esac    

done



