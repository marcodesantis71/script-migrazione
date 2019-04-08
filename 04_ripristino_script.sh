#!/bin/bash
# script finali per la migrazione da Ubuntu 16 a Ubuntu 18
# Quarto script da eseguire
# Lo script effettua:
# 1) Check utente
# 2) Installazione plugin (con retry in caso di errore)
# 3) Riavvio
#
# Script creato da Marco de Santis

## FUNZIONE INZIO SCRIPT ##
function inizio_script {
echo "Inizio Script: $(date "+%d%m%Y %H:%M:%S")" >> /home/thegod/04_ripristino_script.log
}

## FUNZIONE CHECK UTENTE ##
function check_utente {
echo "Controllo l'utente $(date "+%d%m%Y %H:%M:%S")" >> /home/thegod/04_ripristino_script.log

if [ "$(whoami)" != "root" ]; then
        echo "Lo script va lanciato con utente root"
        exit -1
fi
}

## FUNZIONE CREA CARTELLA ##
function crea_cartella {
echo "Creo la cartella $(date "+%d%m%Y %H:%M:%S")" >> /home/thegod/04_ripristino_script.log
mkdir /root/Script
mkdir /home/thegod/Script
}

## FUNZIONE RIPRISTINO SCRIPT ##
function recupero_script {
echo "Ripristino Script $(date "+%d%m%Y %H:%M:%S")" >> /home/thegod/04_ripristino_script.log
cp /home/thegod/bck_${data}.sh /root/Script/
cp /home/thegod/pulizia_${data}.sh /root/Script/
cp /home/thegod/clean_memory_${data}.sh /root/Script/
cp /home/thegod/rinnovo_certificati_${data}.sh /root/Script/
cp /home/thegod/rsync_${data}.sh /root/Script/
cp /home/thegod/Pulizia_VideoSorveglianza_${data}.sh /home/thegod/Script/
}

## FUNZIONE RIPRISTINO PERMESSI ##

function repair_perm {
echo "Riparo permessi $(date "+%d%m%Y %H:%M:%S")" >> /home/thegod/04_ripristino_script.log
chmod u+x /root/Script/bck.sh
chmod u+x /root/Script/rsync.sh
chmod u+x /root/Script/pulizia.sh
chmod u+x /root/Script/clean_memory.sh
chmod u+x /root/Script/rinnovo_certificati.sh
chown -R thegod:thegod /home/thegod/Script
chown thegod:crontab /var/spool/cron/crontabs/thegod
chmod u+x /home/thegod/Script/Pulizia_VideoSorveglianza.sh
chmod 600 /var/spool/cron/crontabs/thegod
chmod 600 /var/spool/cron/crontabs/root
}

## FUNZIONE RIPRISTINO CRONTAB ##
function ripristino_crontab {
echo "RIPRISTINO CRONTAB $(date "+%d%m%Y %H:%M:%S")" >> /home/thegod/04_ripristino_script.log
echo "00 01 * * * /home/thegod/Script/Pulizia_VideoSorveglianza.sh pulisci >/dev/null 2>&1" | tee -a /var/spool/cron/crontabs/thegod
echo "00 10 * * * /root/Script/bck.sh full > /dev/null 2>&1" | tee -a /var/spool/cron/crontabs/root
echo "00 05 * * * /root/Script/pulizia.sh > /dev/null 2>&1" | tee -a /var/spool/cron/crontabs/root
echo "00 * * * * /root/Script/clean_memory.sh > /dev/null 2>&1" | tee -a /var/spool/cron/crontabs/root
echo "30 10 * * * /root/Script/rinnovo_certificati.sh renew > /var/log/certbot.log" | tee -a /var/spool/cron/crontabs/root
}

## FUNZIONE FINE SCRIPT ##
function fine_script {
echo "Fine Script: $(date "+%d%m%Y %H:%M:%S")" >> /home/thegod/Migrazione/Logs/04_ripristino_script.log
}

inizio_script
crea_cartella
check_utente
recupero_script
ripristino_crontab
repair_perm
fine_script
