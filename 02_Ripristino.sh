#!/bin/bash

# script finali per la migrazione da Ubuntu 16 a Ubuntu 18
# Primo script da eseguire
# Lo script effettua:
# 1) Check data
# 2) Recupero BCK
# 3) Resize del disco
# 4) Personalizzazione Profile
# 5) Modifica configurazione rete, file hosts e hostname
# 6) Update sistema
# 7) Rimozione Firewall
# 8) Sync orario
#
# Script creato da Marco de Santis

## EXPORT VARIABILI ##
data=""
ip_nas="192.168.123.8"
user_nas="admin"
path_nas="/share/CACHEDEV1_DATA/MASTER-BCK/"
path_servizi="${path_nas}/SERVICE/"
path_certificati="${path_nas}/CERTIFICATI/"
path_homebridge="${path_nas}/HOMEBRIDGE/"
path_mysql="${path_nas}/MYSQL"
path_contenuti="${path_nas}/SITES/"
path_mail="${path_nas}/MAIL"

## FUNZIONE INZIO SCRIPT ##
function inizio_script {
echo "Inizio Script: $(date "+%d%m%Y %H:%M:%S")" >> /home/thegod/02_Ripristino.log
}

## FUNZIONE CHECK UTENTE ##
function check_utente {
echo "Controllo l'utente $(date "+%d%m%Y %H:%M:%S")" >> /home/thegod/02_Ripristino.log

if [ "$(whoami)" != "root" ]; then
        echo "Lo script va lanciato con utente root"
        exit -1
fi
}

## FUNZIONE CHECK DATA ##
function check_data {
echo "Verifico data $(date "+%d%m%Y %H:%M:%S")" >> /home/thegod/02_Ripristino.log
if [[ -z ${data} ]];
then
echo "Non hai inserito la data."
exit
fi
}

## FUNZIONE RECUPERO BCK ##
function recupero_bck {
scp -r ${user_nas}@${ip_nas}:${path_servizi}/bind/bind_${data}.tar /home/thegod/
scp -r ${user_nas}@${ip_nas}:${path_mysql}/*_${data}.sql /home/thegod/
scp -r ${user_nas}@${ip_nas}:${path_certificati}/*_${data}.tar /home/thegod/
scp -r ${user_nas}@${ip_nas}:${path_servizi}/apache2/apache2_${data}.tar /home/thegod/
scp -r ${user_nas}@${ip_nas}:${path_contenuti}/WebServer_*_${data}.tar.gz /home/thegod/
scp -r ${user_nas}@${ip_nas}:${path_servizi}/dovecot/dovecot_${data}.tar /home/thegod/
scp -r ${user_nas}@${ip_nas}:${path_servizi}/spamassassin/spamassassin_${data}.tar /home/thegod/
scp -r ${user_nas}@${ip_nas}:${path_servizi}/postfix/postfix_${data}.tar /home/thegod/
scp -r ${user_nas}@${ip_nas}:${path_mail}/imap_mail_${data}.tar /home/thegod/
scp -r ${user_nas}@${ip_nas}:${path_homebridge}/homebridge*${data}.tar /home/thegod/ >> /home/thegod/03_homebridge.log
}


#inizio_script
#check_utente
#check_data
recupero_bck
