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
# 11) Transmission-bit
# 12) Samba Server
# 13) Influx, Telegraf, Grafana
# 14) Riavvio Servizi
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
path_scripts="${path_nas}/SCRIPTS/"
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
scp -r -o StrictHostKeyChecking=no ${user_nas}@${ip_nas}:${path_servizi}/telegraf/telegraf_${data}.tar /home/thegod/
scp -r -o StrictHostKeyChecking=no ${user_nas}@${ip_nas}:${path_mysql}/*_${data}.sql /home/thegod/
scp -r -o StrictHostKeyChecking=no ${user_nas}@${ip_nas}:${path_certificati}/*_${data}.tar /home/thegod/
scp -r -o StrictHostKeyChecking=no ${user_nas}@${ip_nas}:${path_scripts}/*_${data}.sh /home/thegod/
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

function add_repo_trasmission {
	echo "Aggiungo repo per transmissionbit $(date "+%d%m%Y %H:%M:%S")" >> /home/thegod/02_Ripristino.log
	echo "deb http://ppa.launchpad.net/transmissionbt/ppa/ubuntu bionic main
deb-src http://ppa.launchpad.net/transmissionbt/ppa/ubuntu bionic main" > /etc/apt/sources.list.d/transmissionbt-ubuntu-ppa-cosmic.list
	apt-get update
}

function install_transmission {
	echo "Installo transmissionbit $(date "+%d%m%Y %H:%M:%S")" >> /home/thegod/02_Ripristino.log
	apt-get install transmission-cli transmission-common transmission-daemon -y
}

function crea_cartelle_transmission {
	echo "Creo cartelle per transmissionbit $(date "+%d%m%Y %H:%M:%S")" >> /home/thegod/02_Ripristino.log
	systemctl stop transmission-daemon
	mkdir -p /srv/Multimedia/Completi
	mkdir -p /srv/Multimedia/Incompleti
}

function sistema_permessi_transmission {
	echo "Sistemo permessi cartelle per transmissionbit $(date "+%d%m%Y %H:%M:%S")" >> /home/thegod/02_Ripristino.log
        chgrp -R debian-transmission /srv
        chmod -R 775 /srv
}

function modifica_conf_transmission {
	echo "Sistemo setting.json per transmissionbit $(date "+%d%m%Y %H:%M:%S")" >> /home/thegod/02_Ripristino.log
        sed -i '/}/d' /var/lib/transmission-daemon/info/settings.json
        sed -i '/utp-enabled/d' /var/lib/transmission-daemon/info/settings.json
        echo "    \"utp-enabled\": true," >> /var/lib/transmission-daemon/info/settings.json
        sed -i '/download-dir/d' /var/lib/transmission-daemon/info/settings.json
        echo "    \"download-dir\": \"/srv/Multimedia/Completi\"," >> /var/lib/transmission-daemon/info/settings.json
        sed -i '/incomplete-dir/d' /var/lib/transmission-daemon/info/settings.json
        echo "    \"incomplete-dir\": \"/srv/Multimedia/Incompleti\"," >> /var/lib/transmission-daemon/info/settings.json
        sed -i '/rpc-password/d' /var/lib/transmission-daemon/info/settings.json
        echo "    \"rpc-password\": \"M4rc03S4r4\"," >> /var/lib/transmission-daemon/info/settings.json
        sed -i '/rpc-username/d' /var/lib/transmission-daemon/info/settings.json
        echo "    \"rpc-username\": \"marco\"," >> /var/lib/transmission-daemon/info/settings.json
        sed -i '/rpc-whitelist/d' /var/lib/transmission-daemon/info/settings.json
        echo "    \"rpc-whitelist\": \"127.0.0.1, 192.168.123.*, 10.8.0.*\"" >> /var/lib/transmission-daemon/info/settings.json
        echo "}" >> /var/lib/transmission-daemon/info/settings.json
	killall -HUP transmission-daemon
	systemctl start transmission-daemon
}

function disabilita_ppa_transmission {
	echo "rimuovo ppa transmission $(date "+%d%m%Y %H:%M:%S")" >> /home/thegod/02_Ripristino.log
	rm /etc/apt/sources.list.d/transmissionbt-ubuntu-ppa-cosmic.list
}

function installa_samba {
	echo "Installo samba $(date "+%d%m%Y %H:%M:%S")" >> /home/thegod/02_Ripristino.log
	apt-get  install samba -y
}

function configurazione_samba {
	echo "Configuro samba $(date "+%d%m%Y %H:%M:%S")" >> /home/thegod/02_Ripristino.log
	mv /etc/samba/smb.conf /etc/samba/smb.conf_old
	echo "#
# Sample configuration file for the Samba suite for Debian GNU/Linux.
#
#
# This is the main Samba configuration file. You should read the
# smb.conf(5) manual page in order to understand the options listed
# here. Samba has a huge number of configurable options most of which
# are not shown in this example
#
# Some options that are often worth tuning have been included as
# commented-out examples in this file.
#  - When such options are commented with \";\", the proposed setting
#    differs from the default Samba behaviour
#  - When commented with \"#\", the proposed setting is the default
#    behaviour of Samba but the option is considered important
#    enough to be mentioned here
#
# NOTE: Whenever you modify this file you should run the command
# \"testparm\" to check that you have not made any basic syntactic
# errors.

#======================= Global Settings =======================

[global]

## Browsing/Identification ###

# Change this to the workgroup/NT-domain name your Samba server will part of
   workgroup = WORKGROUP

# server string is the equivalent of the NT Description field
	server string = %h server (Samba, Ubuntu)

# Windows Internet Name Serving Support Section:
# WINS Support - Tells the NMBD component of Samba to enable its WINS Server
#   wins support = no

# WINS Server - Tells the NMBD components of Samba to be a WINS Client
# Note: Samba can be either a WINS Server, or a WINS Client, but NOT both
;   wins server = w.x.y.z

# This will prevent nmbd to search for NetBIOS names through DNS.
   dns proxy = no

#### Networking ####

# The specific set of interfaces / networks to bind to
# This can be either the interface name or an IP address/netmask;
# interface names are normally preferred
   interfaces = 127.0.0.0/8 enp0s5

# Only bind to the named interfaces and/or networks; you must use the
# 'interfaces' option above to use this.
# It is recommended that you enable this feature if your Samba machine is
# not protected by a firewall or is a firewall itself.  However, this
# option cannot handle dynamic or non-broadcast interfaces correctly.
;   bind interfaces only = yes



#### Debugging/Accounting ####

# This tells Samba to use a separate log file for each machine
# that connects
   log file = /var/log/samba/log.%m

# Cap the size of the individual log files (in KiB).
   max log size = 1000

# If you want Samba to only log through syslog then set the following
# parameter to 'yes'.
#   syslog only = no

# We want Samba to log a minimum amount of information to syslog. Everything
# should go to /var/log/samba/log.{smbd,nmbd} instead. If you want to log
# through syslog you should set the following parameter to something higher.
   syslog = 0

# Do something sensible when Samba crashes: mail the admin a backtrace
   panic action = /usr/share/samba/panic-action %d


####### Authentication #######

# Server role. Defines in which mode Samba will operate. Possible
# values are \"standalone server\", \"member server\", \"classic primary
# domain controller\", \"classic backup domain controller\", \"active
# directory domain controller\".
#
# Most people will want \"standalone sever\" or \"member server\".
# Running as \"active directory domain controller\" will require first
# running \"samba-tool domain provision\" to wipe databases and create a
# new domain.
   server role = standalone server

# If you are using encrypted passwords, Samba will need to know what
# password database type you are using.
   passdb backend = tdbsam

   obey pam restrictions = yes

# This boolean parameter controls whether Samba attempts to sync the Unix
# password with the SMB password when the encrypted SMB password in the
# passdb is changed.
   unix password sync = yes

# For Unix password sync to work on a Debian GNU/Linux system, the following
# parameters must be set (thanks to Ian Kahan <<kahan@informatik.tu-muenchen.de> for
# sending the correct chat script for the passwd program in Debian Sarge).
   passwd program = /usr/bin/passwd %u
   passwd chat = *Enter\snew\s*\spassword:* %n\n *Retype\snew\s*\spassword:* %n\n *password\supdated\ssuccessfully* .

# This boolean controls whether PAM will be used for password changes
# when requested by an SMB client instead of the program listed in
# 'passwd program'. The default is 'no'.
   pam password change = yes

# This option controls how unsuccessful authentication attempts are mapped
# to anonymous connections
   map to guest = bad user

########## Domains ###########

#
# The following settings only takes effect if 'server role = primary
# classic domain controller', 'server role = backup domain controller'
# or 'domain logons' is set
#

# It specifies the location of the user's
# profile directory from the client point of view) The following
# required a [profiles] share to be setup on the samba server (see
# below)
;   logon path = \\%N\profiles\%U
# Another common choice is storing the profile in the user's home directory
# (this is Samba's default)
#   logon path = \\%N\%U\profile

# The following setting only takes effect if 'domain logons' is set
# It specifies the location of a user's home directory (from the client
# point of view)
;   logon drive = H:
#   logon home = \\%N\%U

# The following setting only takes effect if 'domain logons' is set
# It specifies the script to run during logon. The script must be stored
# in the [netlogon] share
# NOTE: Must be store in 'DOS' file format convention
;   logon script = logon.cmd

# This allows Unix users to be created on the domain controller via the SAMR
# RPC pipe.  The example command creates a user account with a disabled Unix
# password; please adapt to your needs
; add user script = /usr/sbin/adduser --quiet --disabled-password --gecos \"\" %u

# This allows machine accounts to be created on the domain controller via the
# SAMR RPC pipe.
# The following assumes a \"machines\" group exists on the system
; add machine script  = /usr/sbin/useradd -g machines -c \"%u machine account\" -d /var/lib/samba -s /bin/false %u

# This allows Unix groups to be created on the domain controller via the SAMR
# RPC pipe.
; add group script = /usr/sbin/addgroup --force-badname %g

############ Misc ############

# Using the following line enables you to customise your configuration
# on a per machine basis. The %m gets replaced with the netbios name
# of the machine that is connecting
;   include = /home/samba/etc/smb.conf.%m

# Some defaults for winbind (make sure you're not using the ranges
# for something else.)
;   idmap uid = 10000-20000
;   idmap gid = 10000-20000
;   template shell = /bin/bash

# Setup usershare options to enable non-root users to share folders
# with the net usershare command.

# Maximum number of usershare. 0 (default) means that usershare is disabled.
;   usershare max shares = 100

# Allow users who've been granted usershare privileges to create
# public shares, not just authenticated ones
   usershare allow guests = yes

#======================= Share Definitions =======================

# Un-comment the following (and tweak the other settings below to suit)
# to enable the default home directory shares. This will share each
# user's home directory as \\server\username
;[homes]
;   comment = Home Directories
;   browseable = no

# By default, the home directories are exported read-only. Change the
# next parameter to 'no' if you want to be able to write to them.
;   read only = yes

# File creation mask is set to 0700 for security reasons. If you want to
# create files with group=rw permissions, set next parameter to 0775.
;   create mask = 0700

# Directory creation mask is set to 0700 for security reasons. If you want to
# create dirs. with group=rw permissions, set next parameter to 0775.
;   directory mask = 0700

# By default, \\server\username shares can be connected to by anyone
# with access to the samba server.
# Un-comment the following parameter to make sure that only \"username\"
# can connect to \\server\username
# This might need tweaking when using external authentication schemes
;   valid users = %S

# Un-comment the following and create the netlogon directory for Domain Logons
# (you need to configure Samba to act as a domain controller too.)
;[netlogon]
;   comment = Network Logon Service
;   path = /home/samba/netlogon
;   guest ok = yes
;   read only = yes

# Un-comment the following and create the profiles directory to store
# users profiles (see the \"logon path\" option above)
# (you need to configure Samba to act as a domain controller too.)
# The path below should be writable by all users so that their
# profile directory may be created the first time they log on
;[profiles]
;   comment = Users profiles
;   path = /home/samba/profiles
;   guest ok = no
;   browseable = no
;   create mask = 0600
;   directory mask = 0700

[printers]
   comment = All Printers
   browseable = no
   path = /var/spool/samba
   printable = yes
   guest ok = no
   read only = yes
   create mask = 0700

# Windows clients look for this share name as a source of downloadable
# printer drivers
[print$]
   comment = Printer Drivers
   path = /var/lib/samba/printers
   browseable = yes
   read only = yes
   guest ok = no
# Uncomment to allow remote administration of Windows print drivers.
# You may need to replace 'lpadmin' with the name of the group your
# admin users are members of.
# Please note that you also need to set appropriate Unix permissions
# to the drivers directory for these users to have write rights in it
;   write list = root, @lpadmin

[Master-Multimedia]

comment = needs username and password to access
path = /srv/Multimedia
available = yes
browseable = yes
guest ok = yes
writable = yes
public = yes" > /etc/samba/smb.conf
}

function creo_utenti_samba {
	echo "Creo utenti samba $(date "+%d%m%Y %H:%M:%S")" >> /home/thegod/02_Ripristino.log
	useradd -m marco
	(echo "marco"; echo "marco") | smbpasswd -a marco
	smbpasswd -e marco
}
	
function installa_influxdb {
	echo "Installo influxdb $(date "+%d%m%Y %H:%M:%S")" >> /home/thegod/02_Ripristino.log
	sudo curl -sL https://repos.influxdata.com/influxdb.key | sudo apt-key add -
	source /etc/lsb-release
	echo "deb https://repos.influxdata.com/${DISTRIB_ID,,} ${DISTRIB_CODENAME} stable" | sudo tee /etc/apt/sources.list.d/influxdb.list
	apt-get update
	apt-get install influxdb -y
	systemctl restart influxd
}

function crea_db_influx {
	echo "Creo DB Influx $(date "+%d%m%Y %H:%M:%S")" >> /home/thegod/02_Ripristino.log
	influx -precision rfc3339 -execute 'create database "telegraf"';
	influx -precision rfc3339 -execute "create user telegraf with password '\$M4cB00kR3t1n4\$'";
}

function install_telegraf {
	echo "Installo telgraf $(date "+%d%m%Y %H:%M:%S")" >> /home/thegod/02_Ripristino.log
	apt-get install telegraf -y
}

## FUNZIONE RIPRISTINO BCK TELEGRAF ##
function ripristino_telegraf {
echo "RIPRISTINO TELEGRAF $(date "+%d%m%Y %H:%M:%S")" >> /home/thegod/02_Ripristino.log
tar -xvf telegraf_${data}.tar
cp /home/thegod/etc/telegraf/telegraf.conf /etc/telegraf
}

function install_grafana {
	echo "Installo grafana $(date "+%d%m%Y %H:%M:%S")" >> /home/thegod/02_Ripristino.log
	curl https://packages.grafana.com/gpg.key | sudo apt-key add -
	echo "deb https://packages.grafana.com/oss/deb stable main" | sudo tee /etc/apt/sources.list.d/grafana.list
	apt-get update
	apt install grafana -y
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
systemctl restart transmission-daemon.service
systemctl restart nmbd
systemctl restart influxd
systemctl restart telegraf
systemctl restart grafana-server
systemctl enable isc-dhcp-server
systemctl enable bind9
systemctl enable apache2
systemctl enable postfix
systemctl enable dovecot
systemctl enable spamassassin
systemctl enable transmission-daemon.service
systemctl enable nmbd
systemctl enable influxd
systemctl enable telegraf
systemctl enable grafana-server
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
add_repo_trasmission
install_transmission
crea_cartelle_transmission
sistema_permessi_transmission
modifica_conf_transmission
disabilita_ppa_transmission
installa_samba
configurazione_samba
creo_utenti_samba
installa_influxdb
crea_db_influx
install_telegraf
ripristino_telegraf
install_grafana
riavvio_servizi
