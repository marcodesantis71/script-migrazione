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

inizio_script
check_utente
