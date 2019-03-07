#!/bin/bash

# script finali per la migrazione da Ubuntu 16 a Ubuntu 18
# Secondo script da eseguire
# Lo script effettua:
# 1) Check data
# 2) Recupero BCK
# 3) Installazione e Ripristino DHCP Server
# 4) Installazione e Ripristino DNS Server
# 5) Installazione Apache
# 6) Installazione MySQL e Ripristino DB
# 7) Installazione LetsEncrypt e Ripristino Certificati
# 8) Ripristino Apache2
# 9) Ripristino Contenuti Statici
# 10) Installazione Mail e Ripristino da Backup
# 11) Riavvio Servizi
#
# Script creato da Marco de Santis

## EXPORT VARIABILI ##
data="06_03_2019_1000"
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
echo "RECUPERO BCK $(date "+%d%m%Y %H:%M:%S")" >> /home/thegod/02_Ripristino.log
scp -r -o StrictHostKeyChecking=no ${user_nas}@${ip_nas}:${path_servizi}/dhcp/dhcp_${data}.tar /home/thegod/
scp -r -o StrictHostKeyChecking=no ${user_nas}@${ip_nas}:${path_servizi}/bind/bind_${data}.tar /home/thegod/
scp -r -o StrictHostKeyChecking=no ${user_nas}@${ip_nas}:${path_mysql}/*_${data}.sql /home/thegod/
scp -r -o StrictHostKeyChecking=no ${user_nas}@${ip_nas}:${path_certificati}/*_${data}.tar /home/thegod/
scp -r -o StrictHostKeyChecking=no ${user_nas}@${ip_nas}:${path_servizi}/apache2/apache2_${data}.tar /home/thegod/
scp -r -o StrictHostKeyChecking=no ${user_nas}@${ip_nas}:${path_contenuti}/WebServer_*_${data}.tar.gz /home/thegod/
scp -r -o StrictHostKeyChecking=no ${user_nas}@${ip_nas}:${path_servizi}/dovecot/dovecot_${data}.tar /home/thegod/
scp -r -o StrictHostKeyChecking=no ${user_nas}@${ip_nas}:${path_servizi}/spamassassin/spamassassin_${data}.tar /home/thegod/
scp -r -o StrictHostKeyChecking=no ${user_nas}@${ip_nas}:${path_servizi}/postfix/postfix_${data}.tar /home/thegod/
scp -r -o StrictHostKeyChecking=no ${user_nas}@${ip_nas}:${path_mail}/imap_mail_${data}.tar /home/thegod/
scp -r -o StrictHostKeyChecking=no ${user_nas}@${ip_nas}:${path_homebridge}/homebridge*${data}.tar /home/thegod/
}

## FUNZIONE INSTALLAZIONE DHCP ##

function install_dhcp {
echo "INSTALLO DHCP $(date "+%d%m%Y %H:%M:%S")" >> /home/thegod/02_Ripristino.log
apt-get install isc-dhcp-server -y
}

## FUNZIONE GESTIONE FILE DI LOG DHCP ##
function dhcp_log {
echo "CREAZIONE LOG DHCP $(date "+%d%m%Y %H:%M:%S")" >> /home/thegod/02_Ripristino.log
mkdir /var/log/dhcpd/
chown -R syslog:adm /var/log/dhcpd
echo "local7.debug    /var/log/dhcpd/dhcpd.log" >> /etc/rsyslog.d/10-fixed_ip.conf
sed -i "s/INTERFACESv4=\"\"/INTERFACESv4=\"eth0\"/g" /etc/default/isc-dhcp-server
}

## FUNZIONE RIPRISTINO BCK DHCP ##
function ripristino_dhcp {
echo "RIPRISTINO DHCP $(date "+%d%m%Y %H:%M:%S")" >> /home/thegod/02_Ripristino.log
tar -xvf dhcp_${data}.tar
cp /home/thegod/etc/dhcp/dhcpd.conf /etc/dhcp/
cp /home/thegod/etc/dhcp/fixed_ip.conf /etc/dhcp/
}

## FUNZIONE RESTART SERVIZI DHCP ##
function restart_dhcp {
echo "RIAVVIO DHCP $(date "+%d%m%Y %H:%M:%S")" >> /home/thegod/02_Ripristino.log
systemctl restart rsyslog
systemctl restart isc-dhcp-server
}

## FUNZIONE INSTALLAZIONE DNS ##
function install_dns {
echo "INSTALLO DNS $(date "+%d%m%Y %H:%M:%S")" >> /home/thegod/02_Ripristino.log
apt-get install bind9 bind9utils bind9-doc -y
}

## FUNZIONE RIPRISTINO BCK DNS ##
function ripristino_dns {
echo "RIPRISTINO DNS $(date "+%d%m%Y %H:%M:%S")" >> /home/thegod/02_Ripristino.log
tar -xvf bind_${data}.tar
cp /home/thegod/etc/bind/* /etc/bind
}

## FUNZIONE MODIFICA RETE ##
function modifica_dns {
echo "MODIFICA DNS $(date "+%d%m%Y %H:%M:%S")" >> /home/thegod/02_Ripristino.log
sed -i 's/8.8.8.8/127.0.0.1/g' /etc/netplan/50-cloud-init.yaml
netplan apply
}

## FUNZIONE RIAVVIO SERVIZI DNS ##
function restart_dns {
echo "RIAVVIO DNS $(date "+%d%m%Y %H:%M:%S")" >> /home/thegod/02_Ripristino.log
netplan apply
systemctl restart bind9
}

## FUNZIONE INSTALLAZIONE APACHE2 ##
function install_apache2 {
echo "INSTALLO APACHE $(date "+%d%m%Y %H:%M:%S")" >> /home/thegod/02_Ripristino.log
apt-get install apache2 php libapache2-mod-php php-mysql -y
}

## FUNZIONE ABILITAZIONE MODULI ##
function abilita_moduli {
echo "ABILITO MODULI $(date "+%d%m%Y %H:%M:%S")" >> /home/thegod/02_Ripristino.log
a2enmod rewrite
a2enmod ssl
a2enmod proxy
}

## FUNZIONE RIAVVIO APACHE2 ##
function restart_apache2 {
echo "RIAVVIO APACHE2 $(date "+%d%m%Y %H:%M:%S")" >> /home/thegod/02_Ripristino.log
systemctl restart apache2
}

## FUNZIONE INSTALLAZIONE MYSQL ##
function install_mysql {
echo "INSTALLO DB $(date "+%d%m%Y %H:%M:%S")" >> /home/thegod/02_Ripristino.log
apt-get install mysql-server -y
apt-get install php-curl php-gd php-mbstring php-xml php-xmlrpc php-soap php-intl php-zip -y
}

## FUNZIONE MESSA IN SICUREZZA MYSQL ##
function security_mysql {
echo "Metto in sicurezza il DB $(date "+%d%m%Y %H:%M:%S")" >> /home/thegod/02_Ripristino.log
mysql --user=root <<_EOF_
SET PASSWORD FOR 'root'@'localhost' = PASSWORD("\$M4cB00kR3t1n4\$");
DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
FLUSH PRIVILEGES;
_EOF_
}

## FUNZIONE FILE LOGIN DB ##
function crea_cnf {
echo "Preparo file per login di backup  $(date "+%d%m%Y %H:%M:%S")" >> /home/thegod/02_Ripristino.log
echo "
[client]
user = root
password = \$M4cB00kR3t1n4\$" >> /root/.mylogin.cnf
chmod 600 /root/.mylogin.cnf
}

## FUNZIONE CREAZIONE DB ##
function crea_db {
echo "CREO DB $(date "+%d%m%Y %H:%M:%S")" >> /home/thegod/02_Ripristino.log
mysql -uroot -p$M4cB00kR3t1n4$ -e "CREATE DATABASE sistemiesistemi /*\!40100 DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci */;"
mysql -uroot -p$M4cB00kR3t1n4$ -e "GRANT ALL ON sistemiesistemi.* TO 'user_sistemi'@'localhost' IDENTIFIED BY 'M4rc03S4r4!';"
mysql -uroot -p$M4cB00kR3t1n4$ -e "CREATE DATABASE svapolandia /*\!40100 DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci */;"
mysql -uroot -p$M4cB00kR3t1n4$ -e "GRANT ALL ON svapolandia.* TO 'user_svapo'@'localhost' IDENTIFIED BY 'Us3r_Sv4p0_L4nd14';"
mysql -uroot -p$M4cB00kR3t1n4$ -e "CREATE DATABASE webmail_ss /*\!40100 DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci */;"
mysql -uroot -p$M4cB00kR3t1n4$ -e "GRANT ALL ON webmail_ss.* TO 'roundcube'@'localhost' IDENTIFIED BY 'M4rc03S4r4';"
mysql -uroot -p$M4cB00kR3t1n4$ -e "CREATE DATABASE webmail_linux /*\!40100 DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci */;"
mysql -uroot -p$M4cB00kR3t1n4$ -e "GRANT ALL ON webmail_linux.* TO 'roundcube'@'localhost' IDENTIFIED BY 'M4rc03S4r4';"
mysql -uroot -p$M4cB00kR3t1n4$ -e "CREATE DATABASE dituttoedipiu /*\!40100 DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci */;"
mysql -uroot -p$M4cB00kR3t1n4$ -e "GRANT ALL ON dituttoedipiu.* TO 'user_ditutto'@'localhost' IDENTIFIED BY 'M4rc03S4r4!';"
mysql -uroot -p$M4cB00kR3t1n4$ -e "CREATE DATABASE linuxguide /*\!40100 DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci */;"
mysql -uroot -p$M4cB00kR3t1n4$ -e "GRANT ALL ON linuxguide.* TO 'user_linux'@'localhost' IDENTIFIED BY 'M4rc03S4r4!';"
mysql -uroot -p$M4cB00kR3t1n4$ -e "CREATE DATABASE notizarionews /*\!40100 DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci */;"
mysql -uroot -p$M4cB00kR3t1n4$ -e "GRANT ALL ON notizarionews.* TO 'user_notizario'@'localhost' IDENTIFIED BY 'Us3r_N0t1z14R10N3ws';"
mysql -uroot -p$M4cB00kR3t1n4$ -e "CREATE DATABASE servermail /*\!40100 DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci */;"
mysql -uroot -p$M4cB00kR3t1n4$ -e "GRANT ALL ON servermail.* TO 'usermail'@'localhost' IDENTIFIED BY 'M4rc03S4r4!';"
}

## FUNZIONE RIPRISTINO DB ##
function ripristino_db {
echo "IMPORTO DB $(date "+%d%m%Y %H:%M:%S")" >> /home/thegod/02_Ripristino.log
mysql -u user_sistemi -pM4rc03S4r4! sistemiesistemi < sistemiesistemi_${data}.sql
mysql -u user_svapo -pUs3r_Sv4p0_L4nd14 svapolandia < svapolandia_${data}.sql
mysql -u roundcube -pM4rc03S4r4 webmail_ss < webmail_ss_${data}.sql
mysql -u roundcube -pM4rc03S4r4 webmail_linux < webmail_linux_${data}.sql
mysql -u user_ditutto -pM4rc03S4r4! dituttoedipiu < dituttoedipiu_${data}.sql
mysql -u user_linux -pM4rc03S4r4! linuxguide < linuxguide_${data}.sql
mysql -u user_notizario -pUs3r_N0t1z14R10N3ws notizarionews < notizarionews_${data}.sql
mysql -u usermail -pM4rc03S4r4! servermail < servermail_${data}.sql
}

## FUNZIONE INSTALLAZIONE LETSENCRYPT ##
function installo_certbot {
echo "Install LETSENCRYPT $(date "+%d%m%Y %H:%M:%S")" >> /home/thegod/02_Ripristino.log
add-apt-repository ppa:certbot/certbot -y
apt-get install certbot python-certbot-apache -y
}

## FUNZIONE RIPRISTINO CERTIFICATI ##
function ripristino_certificati {
echo "Sostituisco i certificato $(date "+%d%m%Y %H:%M:%S")" >> /home/thegod/02_Ripristino.log
tar -xvf /home/thegod/sistemiesistemi_cert_${data}.tar
tar -xvf /home/thegod/lets_cert_${data}.tar
mv /home/thegod/etc/ssl/sistemiesistemi/ /etc/ssl/
cp -R /home/thegod/etc/letsencrypt/* /etc/letsencrypt
}

## FUNZIONE RIPRISTINO CONFIGURAZIONE APACHE2 ##
function ripristino_apache2 {
echo "Ripristino apache $(date "+%d%m%Y %H:%M:%S")" >> /home/thegod/02_Ripristino.log
tar -xvf apache2_${data}.tar
cp -R etc/apache2/* /etc/apache2/
}

## FUNZIONE DISATTIVAZIONE MODULI APACHE2 ##
function disattiva_moduli {
echo "Sistemo i moduli di apache $(date "+%d%m%Y %H:%M:%S")" >> /home/thegod/02_Ripristino.log
sed -i 's/^/#/' /etc/apache2/mods-enabled/php7.0.load
sed -i 's/^/#/' /etc/apache2/mods-enabled/fcgid.load
}

## FUNZIONE CARTELLE LOG APACHE2 ##
function log_apache {
echo "Creo le dir dei log di apache $(date "+%d%m%Y %H:%M:%S")" >> /home/thegod/02_Ripristino.log
mkdir /var/log/apache2/default/
mkdir /var/log/apache2/www.sistemiesistemi.it/
mkdir /var/log/apache2/imap.sistemiesistemi.it/
mkdir /var/log/apache2/vpn.sistemiesistemi.it/
mkdir /var/log/apache2/webmail.sistemiesistemi.it/
mkdir /var/log/apache2/cam-server.sistemiesistemi.it/
mkdir /var/log/apache2/bck-server.sistemiesistemi.it/
mkdir /var/log/apache2/www.linux-guide.it/
mkdir /var/log/apache2/webmail.linux-guide.it/
mkdir /var/log/apache2/www.ilsistemistafolle.it/
mkdir /var/log/apache2/www.dituttoedipiu.eu/
mkdir /var/log/apache2/www.svapolandia.it/
mkdir /var/log/apache2/www.svapovendita.it/
mkdir /var/log/apache2/www.svapovendita.com/
mkdir /var/log/apache2/www.venditasvapo.it/
mkdir /var/log/apache2/www.venditasvapo.com/
mkdir /var/log/apache2/www.notiziarionews.it/
mkdir /var/log/apache2/www.grafana.it/
}

## FUNZIONE RIPRISTINO CONTENUTI STATICI ##
function ripristino_contenuti_statici {
echo "Ripristino i contenuti statici di apache $(date "+%d%m%Y %H:%M:%S")" >> /home/thegod/02_Ripristino.log
gzip -d WebServer_*_${data}.tar.gz
for i in $(ls WebServer_*_${data}*.tar); do tar -xvf $i; done
mv var/www/* /var/www/
}

## FUNZIONE RESTART APACHE2 ##
function restart_apache_conf {
echo "Riavvio apache $(date "+%d%m%Y %H:%M:%S")" >> /home/thegod/02_Ripristino.log
systemctl restart apache2
}

## FUNZIONE INSTALLAZIONE CORE MAIL ##
function installa_mail {
echo "Installo le componenti mail $(date "+%d%m%Y %H:%M:%S")" >> /home/thegod/02_Ripristino.log
echo "postfix postfix/mailname string imap.sistemiesistemi.it" | debconf-set-selections
echo "postfix postfix/main_mailer_type string 'Internet Site'" | debconf-set-selections
apt install postfix postfix-mysql dovecot-core dovecot-imapd dovecot-lmtpd dovecot-mysql spamassassin spamc -y
}

## FUNZIONE CREAZIONE UTENTE spamd ##
function crea_spamd {
echo "Creo Utente spamd $(date "+%d%m%Y %H:%M:%S")" >> /home/thegod/02_Ripristino.log
useradd -m spamd
groupadd -g 5000 vmail
useradd -g vmail -u 5000 vmail -d /var/mail
}

## FUNZIONE RIPRISTINO PERMESSI UTENTE spamd ##
function permessi_spamd {
echo "Sistemo i permessi vmail $(date "+%d%m%Y %H:%M:%S")" >> /home/thegod/02_Ripristino.log
chown -R vmail:vmail /var/mail
chown -R vmail:dovecot /etc/dovecot
chmod -R o-rwx /etc/dovecot
}

## FUNZIONE RIPRISTINO CONFIGURAZIONE POSTA ##
function ripristino_conf_posta {
echo "Ripristino la configurazione della posta $(date "+%d%m%Y %H:%M:%S")" >> /home/thegod/02_Ripristino.log
tar -xvf /home/thegod/dovecot_${data}.tar
tar -xvf /home/thegod/spamassassin_${data}.tar
tar -xvf /home/thegod/postfix_${data}.tar
cp -R /home/thegod/etc/dovecot/* /etc/dovecot/
cp -R /home/thegod/etc/postfix/* /etc/postfix/
cp -R /home/thegod/etc/spamassassin/* /etc/spamassassin/
}

## FUNZIONE PREPARAZIONE CARTELLE MAIL ##
function prepara_dir {
echo "Preparo le dir per le mail $(date "+%d%m%Y %H:%M:%S")" >> /home/thegod/02_Ripristino.log
mkdir /var/mail/vhosts
chown -R vmail:vmail /var/mail/vhosts
}

## FUNZIONE RIPRISTINO MAIL ##
function ripristino_mail {
echo "Ripristino le mail $(date "+%d%m%Y %H:%M:%S")" >> /home/thegod/02_Ripristino.log
tar -xvf /home/thegod/imap_mail_${data}.tar
cp -R /home/thegod/var/mail/vhosts/* /var/mail/vhosts/
chown -R vmail:vmail /var/mail/vhosts
}

## FUNZIONE CREAZIONE DH ##
function crea_dh {
echo "Creo il file dh.pem $(date "+%d%m%Y %H:%M:%S")" >> /home/thegod/02_Ripristino.log
openssl dhparam -out /etc/letsencrypt/live/imap.sistemiesistemi.it/dhparam.pem 4096
}

## FUNZIONE ABILITAZIONE DH ##
function abilita_dh {
echo "Abilito dh.pem $(date "+%d%m%Y %H:%M:%S")" >> /home/thegod/02_Ripristino.log
echo "ssl_dh = </etc/letsencrypt/live/imap.sistemiesistemi.it/dhparam.pem" >> /etc/dovecot/conf.d/10-ssl.conf
}

## FUNZIONE INSTALLAZIONE MUTT ##
function installa_mutt {
echo "Install mutt $(date "+%d%m%Y %H:%M:%S")" >> /home/thegod/02_Ripristino.log
apt-get install mutt -y
}

## FUNZIONE CONFIGURAZIONE MUTT ##
function configura_mutt {
echo "Imposto la configurazione di mutt $(date "+%d%m%Y %H:%M:%S")" >> /home/thegod/02_Ripristino.log
echo "set copy=no" > /home/thegod/.muttrc
chown thegod:thegod /home/thegod/.muttrc
echo "set copy=no" > /root/.muttrc
}

## FUNZIONE RIAVVIO SERVIZI ##
function riavvio_servizi {
echo "Riavvio e abilito tutti i servizi al boot $(date "+%d%m%Y %H:%M:%S")" >> /home/thegod/02_Ripristino.log
systemctl restart isc-dhcp-server
systemctl restart bind9
systemctl restart apache2
systemctl restart postfix
systemctl restart dovecot
systemctl restart spamassassin
systemctl enable isc-dhcp-server
systemctl enable bind9
systemctl enable apache2
systemctl enable postfix
systemctl enable dovecot
systemctl enable spamassassin
echo "Fine Script: $(date "+%d%m%Y %H:%M:%S")" >> /home/thegod/02_Ripristino.log
}

inizio_script
check_utente
check_data
recupero_bck
install_dhcp
dhcp_log
ripristino_dhcp
restart_dhcp
install_dns
ripristino_dns
modifica_dns
restart_dns
install_apache2
abilita_moduli
restart_apache2
install_mysql
security_mysql
crea_cnf
crea_db
ripristino_db
installo_certbot
ripristino_certificati
ripristino_apache2
disattiva_moduli
log_apache
ripristino_contenuti_statici
restart_apache_conf
installa_mail
crea_spamd
permessi_spamd
ripristino_conf_posta
prepara_dir
ripristino_mail
crea_dh
abilita_dh
installa_mutt
configura_mutt
riavvio_servizi
