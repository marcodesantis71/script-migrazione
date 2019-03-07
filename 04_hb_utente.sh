#!/bin/bash

# script finali per la migrazione da Ubuntu 16 a Ubuntu 18
# Quarto script da eseguire
# Lo script effettua:
# 1) Check utente

## EXPORT VARIABILI ##
data="06_03_2019_1000"

## FUNZIONE INZIO SCRIPT ##
function inizio_script {
echo "Inizio Script: $(date "+%d%m%Y %H:%M:%S")" >> /home/thegod/04_hb_utente.log
}

## FUNZIONE CHECK UTENTE ##
function check_utente {
echo "Controllo l'utente $(date "+%d%m%Y %H:%M:%S")" >> /home/thegod/04_hb_utente.log

if [ "$(whoami)" != "thegod" ]; then
        echo "Lo script va lanciato con utente thegod"
        exit -1
fi
}

## FUNZIONE INSTALLAZIONE PLUGIN FOSCAM ##
function installa_foscam {
echo "Installo plugin Foscam $(date "+%d%m%Y %H:%M:%S")" >> /home/thegod/04_hb_utente.log
sudo npm install -g --unsafe-perm homebridge-foscamcamera
if [[ $? != 0 ]] ;
then
        echo "Foscam Plugin in errore. Riprovo" >> /home/thegod/04_hb_utente.log
        installa_foscam
else
        echo "Foscam Plugin Installato correttamente" >> /home/thegod/04_hb_utente.log
fi
}

## FUNZIONE INSTALLAZIONE PLUGIN WEBOS ##
function installa_webos {
echo "Installo plugin webos $(date "+%d%m%Y %H:%M:%S")" >> /home/thegod/04_hb_utente.log
sudo npm install -g --unsafe-perm homebridge-webos-tv
if [[ $? != 0 ]] ;
then
        echo "WebOS Plugin in errore. Riprovo" >> /home/thegod/04_hb_utente.log
        installa_webos
else
        echo "WebOS Plugin Installato correttamente" >> /home/thegod/04_hb_utente.log
fi
}

## FUNZIONE INSTALLAZIONE PLUGIN NETATMO ##
function installa_netatmo {
echo "Installo plugin netatmo $(date "+%d%m%Y %H:%M:%S")" >> /home/thegod/04_hb_utente.log
sudo npm install -g --unsafe-perm homebridge-eveatmo
if [[ $? != 0 ]] ;
then
        echo "Netatmo Plugin in errore. Riprovo" >> /home/thegod/04_hb_utente.log
        installa_netatmo
else
        echo "Netatmo Plugin Installato correttamente" >> /home/thegod/04_hb_utente.log
fi
}

## FUNZIONE INSTALLAZIONE PLUGIN BROADLINK ##
function installa_broadlink {
echo "Installo plugin broadlink $(date "+%d%m%Y %H:%M:%S")" >> /home/thegod/04_hb_utente.log
sudo npm install -g --unsafe-perm homebridge-broadlink-rm
if [[ $? != 0 ]] ;
then
        echo "Broadlink Plugin in errore. Riprovo" >> /home/thegod/04_hb_utente.log
        installa_broadlink 
else
        echo "Broadlink Plugin Installato correttamente" >> /home/thegod/04_hb_utente.log
fi
}

## FUNZIONE INSTALLAZIONE PLUGIN ALEXA ##
function installa_alexa {
echo "Installo plugin alexa $(date "+%d%m%Y %H:%M:%S")" >> /home/thegod/04_hb_utente.log
sudo npm install -g --unsafe-perm homebridge-alexa
if [[ $? != 0 ]] ;
then
        echo "Alexa Plugin in errore. Riprovo" >> /home/thegod/04_hb_utente.log
        installa_alexa
else
        echo "Alexa Plugin Installato correttamente" >> /home/thegod/04_hb_utente.log
fi
}

#inizio_script
#check_utente
#installa_foscam
#installa_webos
#installa_netatmo
#installa_broadlink
installa_alexa
