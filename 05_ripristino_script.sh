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
echo "Inizio Script: $(date "+%d%m%Y %H:%M:%S")" >> /home/thegod/05_ripristino_script.log
}

## FUNZIONE CHECK UTENTE ##
function check_utente {
echo "Controllo l'utente $(date "+%d%m%Y %H:%M:%S")" >> /home/thegod/05_ripristino_script.log

if [ "$(whoami)" != "root" ]; then
        echo "Lo script va lanciato con utente root"
        exit -1
fi
}

## FUNZIONE CREA CARTELLA ##
function crea_cartella {
echo "Creo la cartella $(date "+%d%m%Y %H:%M:%S")" >> /home/thegod/05_ripristino_script.log
mkdir /root/Script
}

## FUNZIONE RINNOVO CERTIFICATI ##
function ripristino_rinnovo_certificati {
echo "Ripristino rinnovo certificati: $(date "+%d%m%Y %H:%M:%S")" >> /home/thegod/05_ripristino_script.log
echo "#!/bin/bash
#set -x
#
# Script per gestione rinnovo certificati
# Effettua restart di:
# Apache
# Dovecot
# Postfix

export DATA=\$(date \"+%d%m%Y\")
function inizio_attivita {
echo \"Inizio attività di rinnovo \$(date \"+%d%m%Y %H:%M:%S\")\"
} > /var/log/rinnovo_certificati.log
function rinnovo_certificati {
echo \"Eseguo rinnovo certificati \$(date \"+%d%m%Y %H:%M:%S\")\"
certbot renew
if [[ \$? != 0 ]] ;
then
echo \"Problemi durante il rinnovo dei certificati \"
else
echo \"Certificati rinnovati correttamente\"
fi
} >> /var/log/rinnovo_certificati.log

function restart_apache {
echo \"Eseguo riavvio di Apache \$(date \"+%d%m%Y %H:%M:%S\")\"
systemctl restart apache2
if [[ \$? != 0 ]] ;
then
echo \"Problemi durante il riavvio di Apache \"
else
echo \"Riavvio Apache eseguito correttamente\"
fi
} >> /var/log/rinnovo_certificati.log

function restart_postfix {
echo \"Eseguo riavvio di postfix \$(date \"+%d%m%Y %H:%M:%S\")\"
systemctl restart postfix
if [[ \$? != 0 ]] ;
then
echo \"Problemi durante il riavvio di Postfix \"
else
echo \"Riavvio Postfix eseguito correttamente\"
fi
} >> /var/log/rinnovo_certificati.log

function restart_dovecot {
echo \"Eseguo riavvio di Dovecot \$(date \"+%d%m%Y %H:%M:%S\")\"
systemctl restart dovecot
if [[ \$? != 0 ]] ;
then
echo \"Problemi durante il riavvio di Dovecot \"
else
echo \"Riavvio Dovecot eseguito correttamente\"
fi
} >> /var/log/rinnovo_certificati.log


function check_rinnovo {
if [[ `grep \"No renewals were attempted\" /var/log/rinnovo_certificati.log  |wc -l` -eq 1 ]];
then
echo \"Nessun Certificato Rinnovato\" >> /var/log/rinnovo_certificati.log
else
restart_apache
restart_postfix
restart_dovecot
fi
} >> /var/log/rinnovo_certificati.log

#cat rinnovo_certificati.log | grep \"Problemi durante il riavvio\" |awk -F \" \" '{print \$6}'
function InviaReportMail {
export TEST=\$(date +%H)

if [[ `cat /var/log/rinnovo_certificati.log | grep \"Problemi durante il riavvio\"  |wc -l` -ne 0 ]] ; then
cat /var/log/rinnovo_certificati.log | grep \"Problemi durante il riavvio\" |awk -F \" \" '{print \$6}' > /tmp/errori_restart.log
OGGETTO_MAIL=\"ATTENZIONE: Ci sono stati problemi nel riavvio dei servizi\"
echo -e \"Alcuni servizi non sono ripartiti correttamente.\" > /tmp/corpo_mail.txt
echo -e \"Verificare i seguenti servizi:\" >> /tmp/corpo_mail.txt
echo -e \"\"
cat /tmp/errori_restart.log >> /tmp/corpo_mail.txt
TMP_CORPO_MAIL=`cat /tmp/corpo_mail.txt`
else
OGGETTO_MAIL=\"Risultato del Backup del \${DATA}\"
TMP_CORPO_MAIL=\"L'attività ha avuto esito posistivo\"
fi

if [[ \${TEST} == 00 ]]; then

echo \${TMP_CORPO_MAIL} | mutt -s \"\${OGGETTO_MAIL}\" \"report@sistemiesistemi.it\" -e 'my_hdr From:report@sistemiesistemi.it'
else
echo \${TMP_CORPO_MAIL} | mutt -s \"\${OGGETTO_MAIL}\" \"report@sistemiesistemi.it\" -e 'my_hdr From:report@sistemiesistemi.it'
fi
#rm /tmp/lock
#rm /tmp/lock.\$\$
}



inizio_attivita
rinnovo_certificati
check_rinnovo
InviaReportMail
} > /root/Script/rinnovo_certificati.sh
}

## RIPRISTINO BCK ##
function ripristino_bck {
echo "Ripristino script bck: $(date "+%d%m%Y %H:%M:%S")" >> /home/thegod/05_ripristino_script.log
echo "#!/bin/bash
set -x

## VARIABILI ##
export OGGI=\$(date +%d_%m_%Y_%H%M)
export OGGI2=\$(date +%d_%b_%Y)
export TMP_WEB_RISULTATO=/tmp/risultato_web.txt
export TMP_DB_RISULTATO=/tmp/risultato_db.txt
export TMP_CERT_RISULTATO=/tmp/risultato_cert.txt
export TMP_LETS_RISULTATO=/tmp/risultato_lets.txt
export TMP_IMAP_RISULTATO=/tmp/risultato_imap.txt
export TMP_SERVIZI_RISULTATO=/tmp/risultato_servizi.txt
export TMP_HOMEBRIDGE_RISULTATO=/tmp/risultato_homebridge.txt
export TMP_HOMEBRIDGE_MULTI_RISULTATO=/tmp/risultato_homebridge_multimedia.txt
export TMP_HOMEBRIDGE_SECU_RISULTATO=/tmp/risultato_homebridge_security.txt
export GEN_BCK_DEST=/BCK
export DIR_MYSQL=\${GEN_BCK_DEST}/MYSQL
export DIR_CERT=\${GEN_BCK_DEST}/CERTIFICATI
export DIR_IMAP=\${GEN_BCK_DEST}/MAIL
export DIR_HOMEBRIDGE=\${GEN_BCK_DEST}/HOMEBRIDGE
export WEB_DIR=/var/www
export WEB_SITE_PATH=\${GEN_BCK_DEST}/SITES
export SERVICE_DIR=/BCK/SERVICE
export SERVIZI='bind dhcp postfix dovecot openvpn apache2 spamassassin'
export TMP_CORPO_MAIL=/tmp/corpo_mail.txt

function mount_bck {
mount -t nfs backup-server.sistemiesistemi.it:MASTER-BCK /BCK/
                }

function umount_bck {
umount /BCK
}

 function RemoveTMP {

         rm \${TMP_SERVIZI_RISULTATO}
         rm \${TMP_CORPO_MAIL}
         rm \${TMP_DB_RISULTATO}
         rm \${TMP_WEB_RISULTATO}
         rm \${TMP_CERT_RISULTATO}
         rm \${TMP_LETS_RISULTATO}
         rm \${TMP_IMAP_RISULTATO}
         rm \${TMP_HOMEBRIDGE_RISULTATO}
         rm \${TMP_HOMEBRIDGE_MULTI_RISULTATO}
         rm \${TMP_HOMEBRIDGE_SECU_RISULTATO}
 }

function homebridge_casina {

tar -cvf \${DIR_HOMEBRIDGE}/homebridge_\${OGGI}.tar /home/thegod/.homebridge
                                if [ \"\$?\" ==  0 ];
                                        then
                                                echo  \"Backup di homebridge casina  eseguito con esito positivo \" >> \${TMP_HOMEBRIDGE_RISULTATO}
                                        else
                                                echo  \"ATTENZIONE: Backup di homebridge casina eseguito con esito negativo \" >> \${TMP_HOMEBRIDGE_RISULTATO}
                                fi
}

function homebridge_multimedia {

tar -cvf \${DIR_HOMEBRIDGE}/homebridge_multimedia_\${OGGI}.tar /home/thegod/.homebridge_multimedia
                                if [ \"\$?\" ==  0 ];
                                        then
                                                echo  \"Backup di homebridge multimedia  eseguito con esito positivo \" >> \${TMP_HOMEBRIDGE_MULTI_RISULTATO}
                                        else
                                                echo  \"ATTENZIONE: Backup di homebridge multimedia eseguito con esito negativo \" >> \${TMP_HOMEBRIDGE_MULTI_RISULTATO}
                                fi
}

function homebridge_security {

tar -cvf \${DIR_HOMEBRIDGE}/homebridge_security_\${OGGI}.tar /home/thegod/.homebridge_security
                                if [ \"\$?\" ==  0 ];
                                        then
                                                echo  \"Backup di homebridge security  eseguito con esito positivo \" >> \${TMP_HOMEBRIDGE_SECU_RISULTATO}
                                        else
                                                echo  \"ATTENZIONE: Backup di security multimedia eseguito con esito negativo \" >> \${TMP_HOMEBRIDGE_SECU_RISULTATO}
                                fi
}

function certificati_ssl {

tar -cvf \${DIR_CERT}/sistemiesistemi_cert_\${OGGI}.tar /etc/ssl/sistemiesistemi/
                                if [ \"\$?\" ==  0 ];
                                        then
                                                echo  \"Backup dei certificati sistemiesistemi  eseguito con esito positivo \" >> \${TMP_CERT_RISULTATO}
                                        else
                                                echo  \"ATTENZIONE: Backup dei certificati sistemiesistemi eseguito con esito negativo \" >> \${TMP_CERT_RISULTATO}
                                fi
}

function imap_mail {

tar -cvf \${DIR_IMAP}/imap_mail_\${OGGI}.tar /var/mail/
                                if [ \"\$?\" ==  0 ];
                                        then
                                                echo  \"Backup delle mail  eseguite con esito positivo \" >> \${TMP_IMAP_RISULTATO}
                                        else
                                                echo  \"ATTENZIONE: Backup delle mail eseguite con esito negativo \" >> \${TMP_IMAP_RISULTATO}
                                fi
}

function certificati_lets {

tar -cvf \${DIR_CERT}/lets_cert_\${OGGI}.tar /etc/letsencrypt/
                                if [ \"\$?\" ==  0 ];
                                        then
                                                echo  \"Backup dei certificati letsencrypt  eseguito con esito positivo \" >> \${TMP_LETS_RISULTATO}
					echo \"\" >> \${TMP_LETS_RISULTATO}
                                        else
                                                echo  \"ATTENZIONE: Backup dei certificati letsencrypt eseguito con esito negativo \" >> \${TMP_LETS_RISULTATO}
						echo \"\" >> \${TMP_LETS_RISULTATO}
                                fi
}

function servizi {

for SERVIZIO in \${SERVIZI};
do
tar -cvf \${SERVICE_DIR}/\${SERVIZIO}/\${SERVIZIO}_\${OGGI}.tar /etc/\$SERVIZIO/
                                if [ \"\$?\" ==  0 ];
                                        then
                                                echo  \"Backup del servizio \${SERVIZIO} eseguito con esito positivo \" >> \${TMP_SERVIZI_RISULTATO}
                                        else
                                                echo  \"ATTENZIONE: Backup del servizio \${SERVIZIO} eseguito con esito negativo \" >> \${TMP_SERVIZI_RISULTATO}
                                fi
done;
}
function BackupDB {
for i in \$(mysql --login-path=root.db -S /var/run/mysqld/mysqld.sock -N -B -e \"show databases\" | egrep -v \"mysql|information|performance_schema|sys\") ; do
mysqldump -u root -p\\$M4cB00kR3t1n4\\$ \${i} > \${DIR_MYSQL}/\${i}_\${OGGI}.sql
if [ \"\$?\" ==  0 ];
then
echo \"DATABASE \${i}: Il backup \${i} ha avuto esito positivo\" >> \${TMP_DB_RISULTATO}
echo \"\" >> \${TMP_DB_RISULTATO}
else
echo \"ATTENZIONE: DATABASE \${i}: Il backup \${i} ha avuto esito negativo\" >> \${TMP_DB_RISULTATO}
echo \"\" >> \${TMP_DB_RISULTATO}
fi
done
              }

function BackupWEB {

for b in \$(ls /var/www/ | grep -v \"html\" ) ; do
tar --format=ustar -cvf  \${WEB_SITE_PATH}/WebServer_\${b}_\${OGGI}.tar \${WEB_DIR}/\${b}
gzip \${WEB_SITE_PATH}/WebServer_\${b}_\${OGGI}.tar
if [ \"\$?\" ==  0 ];
then
echo \"Il backup della componente WEB \${b} ha avuto esito positivo\" >> \${TMP_WEB_RISULTATO}
echo \"\" >> \${TMP_WEB_RISULTATO}
else
echo \"ATTENZIONE: Il backup della componente WEB \${b} ha avuto esito negativo\" >> \${TMP_WEB_RISULTATO}
echo \"\" >> \${TMP_WEB_RISULTATO}
fi
done
}



function CorpoMail {
        echo  \"Salve, \" > \${TMP_CORPO_MAIL}
        echo  \"questo il report del \${OGGI2} \" >> \${TMP_CORPO_MAIL}
#        cat \${TMP_SERVER_RISULTATO} >> \${TMP_CORPO_MAIL}
        cat \${TMP_SERVIZI_RISULTATO} >> \${TMP_CORPO_MAIL}
#        cat \${TMP_OD_RISULTATO} >> \${TMP_CORPO_MAIL}
        cat \${TMP_CERT_RISULTATO} >> \${TMP_CORPO_MAIL}
        cat \${TMP_HOMEBRIDGE_RISULTATO} >> \${TMP_CORPO_MAIL}
        cat \${TMP_HOMEBRIDGE_MULTI_RISULTATO} >> \${TMP_CORPO_MAIL}
        cat \${TMP_HOMEBRIDGE_SECU_RISULTATO} >> \${TMP_CORPO_MAIL}
        cat \${TMP_IMAP_RISULTATO} >> \${TMP_CORPO_MAIL}
        cat \${TMP_LETS_RISULTATO} >> \${TMP_CORPO_MAIL}
#        cat \${TMP_MAIL_RISULTATO} >> \${TMP_CORPO_MAIL}
#        cat \${TMP_CALCON_RISULTATO} >> \${TMP_CORPO_MAIL}
        cat \${TMP_DB_RISULTATO} >> \${TMP_CORPO_MAIL}
        cat \${TMP_WEB_RISULTATO} >> \${TMP_CORPO_MAIL}
#        cat \${TMP_SICUREZZA_RISULTATO} >> \${TMP_CORPO_MAIL}
#        cat \${TMP_SICUREZZA_QNAP_RISULTATO} >> \${TMP_CORPO_MAIL}
#        cat \${TMP_REMOVE_RISULTATO} >> \${TMP_CORPO_MAIL}
#        cat \${TMP_REMOVE_QNAP_RISULTATO} >> \${TMP_CORPO_MAIL}
        echo  \"Mail generata automaticamente. Si prega di non rispondere alla presente casella mail, in quanto non presidiata. \" >> \${TMP_CORPO_MAIL}
        echo  \"Grazie per la collaborazione. \" >> \${TMP_CORPO_MAIL}
        echo  \"Saluti. \" >> \${TMP_CORPO_MAIL}
}



function InviaReportMail {
export TEST=\$(date +%H)

if [[ `cat /tmp/*.txt |grep ATTENZIONE  |wc -l` -ne 0 ]] ; then
OGGETTO_MAIL=\"ATTENZIONE: il Backup del \${OGGI} ha avuto problemi\"
else
OGGETTO_MAIL=\"Risultato del Backup del \${OGGI}\"
 fi

if [[ \${TEST} == 00 ]]; then

cat \${TMP_CORPO_MAIL} | mutt -s \"\${OGGETTO_MAIL}\" \"report@sistemiesistemi.it\" -e 'my_hdr From:report@sistemiesistemi.it'
else
cat \${TMP_CORPO_MAIL} | mutt -s \"\${OGGETTO_MAIL}\" \"report@sistemiesistemi.it\" -e 'my_hdr From:report@sistemiesistemi.it'
fi
#rm /tmp/lock
#rm /tmp/lock.\$\$
}




case \"\${1}\" in
        full)
		mount_bck
		BackupWEB
                BackupDB
		servizi
		imap_mail
		homebridge_casina
		homebridge_multimedia
		homebridge_security
		certificati_ssl
		certificati_lets
                CorpoMail
                InviaReportMail
		umount_bck
		RemoveTMP
        ;;
*)
;;
esac
} > /root/Script/bck.sh
