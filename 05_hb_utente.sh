#!/bin/bash
# script finali per la migrazione da Ubuntu 16 a Ubuntu 18
# Quarto script da eseguire
# Lo script effettua:
# 1) Check utente
# 2) Installazione plugin (con retry in caso di errore)
# 3) Riavvio
#
# Script creato da Marco de Santis

## EXPORT VARIABILI ##
data="06_03_2019_1000"

## FUNZIONE INZIO SCRIPT ##
function inizio_script {
echo "Inizio Script: $(date "+%d%m%Y %H:%M:%S")" >> /home/thegod/05_hb_utente.log
}

## FUNZIONE CHECK UTENTE ##
function check_utente {
echo "Controllo l'utente $(date "+%d%m%Y %H:%M:%S")" >> /home/thegod/05_hb_utente.log

if [ "$(whoami)" != "thegod" ]; then
        echo "Lo script va lanciato con utente thegod"
        exit -1
fi
}

## FUNZIONE INSTALLAZIONE PLUGIN FOSCAM ##
function installa_foscam {
echo "Installo plugin Foscam $(date "+%d%m%Y %H:%M:%S")" >> /home/thegod/05_hb_utente.log
sudo npm install -g --unsafe-perm homebridge-foscamcamera
if [[ $? != 0 ]] ;
then
        echo "Foscam Plugin in errore. Riprovo" >> /home/thegod/05_hb_utente.log
        installa_foscam
else
        echo "Foscam Plugin Installato correttamente" >> /home/thegod/05_hb_utente.log
fi
}

## FUNZIONE INSTALLAZIONE PLUGIN WEBOS ##
function installa_webos {
echo "Installo plugin webos $(date "+%d%m%Y %H:%M:%S")" >> /home/thegod/05_hb_utente.log
sudo npm install -g --unsafe-perm homebridge-webos-tv
if [[ $? != 0 ]] ;
then
        echo "WebOS Plugin in errore. Riprovo" >> /home/thegod/05_hb_utente.log
        installa_webos
else
        echo "WebOS Plugin Installato correttamente" >> /home/thegod/05_hb_utente.log
fi
}

## FUNZIONE INSTALLAZIONE PLUGIN NETATMO ##
function installa_netatmo {
echo "Installo plugin netatmo $(date "+%d%m%Y %H:%M:%S")" >> /home/thegod/05_hb_utente.log
sudo npm install -g --unsafe-perm homebridge-eveatmo
if [[ $? != 0 ]] ;
then
        echo "Netatmo Plugin in errore. Riprovo" >> /home/thegod/05_hb_utente.log
        installa_netatmo
else
        echo "Netatmo Plugin Installato correttamente" >> /home/thegod/05_hb_utente.log
fi
}

## FUNZIONE INSTALLAZIONE PLUGIN BROADLINK ##
function installa_broadlink {
echo "Installo plugin broadlink $(date "+%d%m%Y %H:%M:%S")" >> /home/thegod/05_hb_utente.log
sudo npm install -g --unsafe-perm homebridge-broadlink-rm
if [[ $? != 0 ]] ;
then
        echo "Broadlink Plugin in errore. Riprovo" >> /home/thegod/05_hb_utente.log
        installa_broadlink 
else
        echo "Broadlink Plugin Installato correttamente" >> /home/thegod/05_hb_utente.log
fi
}

## FUNZIONE INSTALLAZIONE PLUGIN ALEXA ##
function installa_alexa {
echo "Installo plugin alexa $(date "+%d%m%Y %H:%M:%S")" >> /home/thegod/05_hb_utente.log
sudo npm install -g --unsafe-perm homebridge-alexa
if [[ $? != 0 ]] ;
then
        echo "Alexa Plugin in errore. Riprovo" >> /home/thegod/05_hb_utente.log
        installa_alexa
else
        echo "Alexa Plugin Installato correttamente" >> /home/thegod/05_hb_utente.log
fi
}

## FUNZIONE INSTALLAZIONE PLUGIN IFTTT ##
function installa_ifttt {
echo "Installo plugin ifttt $(date "+%d%m%Y %H:%M:%S")" >> /home/thegod/05_hb_utente.log
sudo npm install -g --unsafe-perm homebridge-ifttt
if [[ $? != 0 ]] ;
then
        echo "IFTTT Plugin in errore. Riprovo" >> /home/thegod/05_hb_utente.log
        installa_ifttt
else
        echo "IFTTT Plugin Installato correttamente" >> /home/thegod/05_hb_utente.log
fi
}

## FUNZIONE INSTALLAZIONE PLUGIN HARMONY ##
function installa_harmony {
echo "Installo plugin harmony $(date "+%d%m%Y %H:%M:%S")" >> /home/thegod/05_hb_utente.log
sudo npm install -g --unsafe-perm homebridge-harmony
if [[ $? != 0 ]] ;
then
        echo "Harmony Plugin in errore. Riprovo" >> /home/thegod/05_hb_utente.log
        installa_harmony
else
        echo "Harmony Plugin Installato correttamente" >> /home/thegod/05_hb_utente.log
fi
}

## FUNZIONE REPAIR PERMESSI ##
function check_permessi {
echo "Sistemo i permessi $(date "+%d%m%Y %H:%M:%S")" >> /home/thegod/05_hb_utente.log
sudo chown -R thegod:thegod /home/thegod/.config
}

## FUNZIONE RIAVVIO SERVIZI ##
function riavvio_servizi {
echo "Riavvio i servizi e li abilito al boot $(date "+%d%m%Y %H:%M:%S")" >> /home/thegod/05_hb_utente.log
sudo systemctl restart rsyslog
sudo systemctl restart homebridge_casina
sudo systemctl restart homebridge_lgtv
sudo systemctl restart homebridge_security
sudo systemctl restart homebridge_harmony
sudo systemctl enable homebridge_casina
sudo systemctl enable homebridge_lgtv
sudo systemctl enable homebridge_security
sudo systemctl enable homebridge_harmony
}

## FUNZIONE RIMOZIONE BCK ##
function rimuovi_bck {
echo "Rimuovo i file di backup $(date "+%d%m%Y %H:%M:%S")" >> /home/thegod/05_hb_utente.log
sudo  rm -rf *.tar
sudo rm -rf *.sql
sudo rm -rf home var etc
}

## FUNZIONE ARCHIVIAZIONE ##
function archivia {
echo "Archivio tutto $(date "+%d%m%Y %H:%M:%S")" >> /home/thegod/05_hb_utente.log
mkdir Migrazione
mkdir Migrazione/Logs
mkdir Migrazione/Script
sudo mv *.log Migrazione/Logs/
sudo mv *.sh Migrazione/Script/
sudo chown -R thegod:thegod Migrazione
}

## FUNZIONE FINE SCRIPT ##
function fine_script {
echo "Fine Script: $(date "+%d%m%Y %H:%M:%S")" >> /home/thegod/Migrazione/Logs/05_hb_utente.log
}

inizio_script
check_utente
installa_foscam
installa_webos
installa_netatmo
installa_broadlink
installa_alexa
installa_ifttt
installa_harmony
check_permessi
riavvio_servizi
rimuovi_bck
archivia
fine_script
