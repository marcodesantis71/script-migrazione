#!/bin/bash
# script finali per la migrazione da Ubuntu 16 a Ubuntu 18
# Primo script da eseguire
# Lo script effettua:
# 1) Rimozione pacchetti non utili
# 2) Inserimento chiavi SSH
# 3) Resize del disco
# 4) Personalizzazione Profile
# 5) Modifica configurazione rete, file hosts e hostname
# 6) Update sistema
# 7) Rimozione Firewall
# 8) Sync orario
#
# Script creato da Marco de Santis

## FUNZIONE INZIO SCRIPT ##
function inizio_script {
echo "Inizio Script: $(date "+%d%m%Y %H:%M:%S")" >> /home/thegod/01_Impostazioni.log
}

## FUNZIONE CHECK UTENTE ##
function check_utente {
echo "Controllo l'utente $(date "+%d%m%Y %H:%M:%S")" >> /home/thegod/01_Impostazioni.log

if [ "$(whoami)" != "root" ]; then
        echo "Lo script va lanciato con utente root"
        exit -1
fi
}

## FUNZIONE RIMOZIONE SNAPD ##
function remove_snapd {
echo "Rimuovo package inutile $(date "+%d%m%Y %H:%M:%S")" >> /home/thegod/01_Impostazioni.log
apt autoremove --purge snapd -y
}

## FUNZIONE SPAZIO DISCO ##

function resize_fs {
echo "Sistemo lo spazio $(date "+%d%m%Y %H:%M:%S")" >> /home/thegod/01_Impostazioni.log
vgdisplay
echo "Dammi i giga:"
read giga
lvdisplay
echo "Dammi il LV:"
read lv

lvextend -L+${giga}G ${lv}
resize2fs ${lv}
df -h / >> /home/thegod/01_Impostazioni.log

}

## FUNZIONE CHIAVI SSH ##

function user_key {
echo "CONFIGURAZIONE SSH" ### ">> /home/thegod/01_Impostazioni.log
echo "COPIO CHIAVI $(date "+%d%m%Y %H:%M:%S")" >> /home/thegod/01_Impostazioni.log
mkdir /home/thegod/.ssh

echo "
-----BEGIN RSA PRIVATE KEY-----
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
-----END RSA PRIVATE KEY-----" > /home/thegod/.ssh/id_rsa

echo "
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDfaVGSuh0gSvTl84B/zTHkdtaPCRcvL9bwGuIbsZRnMqvFSmlULqv+POfPwp8/ZqAOF12QxViNlEbYJvu0GtUs5MMG0XDlu0GsV3tcbiSoPwP3/Yhv/Spbuf/nZf8C4FttYao1iyf+crFLlsVfcRl/trIbYoDbZpq5bTisxMX6jSM5Q6lGQCDEXDgMqiOXa3stWEGfXNW3f/alHTXedIBYg6DYSFQtaui4AyBu75EQMY7gMRHmTxHkOdcK/55KaifNYYhzPoDm/otoepn0BrV8riLSlVAGMXtAlC1aFJjO+8QM6c2vOyjxfHn/o1GGV/klQ79b9nbEqZHJSO3assdT6pRfsHCT+StGTWoC+Yl38D952r6BT93CKOmt46q8uXXCJl88goXVsixNAANZUP9tOY+Tw+YQN4jSnMhFlMeH/Tp4JmOFn8Odfx7hVWCqmQE7UljqI4LiMouVQAifIgZpP0MICgbRWH0+Zn1z05EJI45y2UFwmrK/2wEhh4ZTzbutFVSelx4jPmROp4pZGI0C3USqBwI+6c+kHLKSHXyOdSyyu0Ib6y5G2xmk5HsPq6uxvjRYkC5cFGf5YO05nMn0czQHaVRa8uuLssud3qgjS/CAxwZ9Uago3lqABkCUhdYVlALuaODe9S2pg23xwVDkkV3b/5vQKVUApRe5ZxfLEw== thegod@master" > /home/thegod/.ssh/id_rsa.pub

echo "
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCo6AMJQa+80GzQfYAAkTPBdw5omswT9CH1jFMMF32A9EqmSysDosayNb9vEul2FdixdJtVYHk5rDnmaWI2Gjb3rMTU7CCnCaLai54yzuLaKJYXTcHnauFrNi97dTqG1BB0h5a+2vUhC/oy79OD6MpmrORS1hiS1VxEZQvvNIvXoGpig4sHsmr51UtX836w5AqpW2jpUDQUYj8IJllNnxHatGAsOai25tCIezcCBPoFAL1CWlVt1bE3VHbOKwgb9fIBOEl8ax5Z5XZqycPW2jibqSzUn2RQdtkUiIOaxv20TcY3SiZGDrCUoFXFa1uc7lB/+f6scrynj6260Xu8Zs8v8/uvHdw4Bejvlxf33MAkEpP1mKlp9kMbYJPkNq28xY5hIsv4LpbMcnf2t7a7/OLh/iiQ2+8MnqG69IhYpOleVjskcktUZyskWz81rGgHTkL6tIoHHukjFFeqnFhOGKbo9KrA/gw7ULIwXKiVAmY3zSA2EPDGAvjZaR7FYsehQv6YH8HC98LXjE0ot+uLoZrNj8lFVc0SH91DvBsvkN9q9B4Yid2WSmGYpLHAx2MymXwREC5rWZZSLL4mKAu2G5Xp6UY2OX7FICkwJoRhAccYbBItdo7eZoWpUVU5Ce6Zs/xq/6EOTRi39WI8FZzgx4D7xiaNXBCOtGzaTA5MULMluQ== thegod@TheGod-MBP
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDRtkhnSSzrvUR4Wm1v3MZiIQsc7zY0BwKfJJ9XGqB/NcHpnGuOs0aKAr4nMfEUPnPffCCKyNpC0jCOgzINSNAB96Lv/7GLH/a5Wv1a9wAJFLuwQr5LF5Y9UrjJ3UC1uCMKfnFTXlfBtXGVFFnupkjh3ywwgtg7o3gA63ut2T5C7lel9eA5yZ6GTeqWVHXDNx04dMevHo1Jp0d1WcuZuGwq304AxNk7g/2L2MHQ6OQzF19JIlg4xV3OVBT8LkWzf+uK6gF7YtAodWqd7vEZdqoUGhBAe1wUE3nApfK7KfkDRRIvIBGOPU4YtrKEVTyg3vSE8MztRxxG+hIb7novIQUZMwMV1lE0e60D2L/ga/GZDjM4y263lXUWGfW9juMUhdp6yn7HIKlQaSZZy7TKH572HFKM/0NL4Ze6u965g5xh5mEOcsBkq32fJHCSRk0RD+IX2t16a5qMH4RT6ONq0Wlhp71DO16MLobYCM7JrOuadzwOfpMjmjzTljALSymb/W4l5JLqhSSdGbXm3I2UcUvy1qJ2aObgIRPA3arB0TyNASPWm8Up12KA9ZMv2tYkNPBBMtr8Y8jRxqhFODa9iEMiScetval7KjBYVC0+bE+V3sq67uA4mLu3rz/dI5IXUSV+R/Tqp31nCygVDwMKC02qU5VWJYvDwL4DfODOjP2ouw== thegod@asus-eepc
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCijT0H16bIHZjv6RvI0o5FC0M5v0wpM0P+eYcX5UNimfK3F94UKPJ+5eNa/7nCyXBcKCrh45xSi4m/K94vQS9DGRHo7I10Errg/UXFoq1ISUCyv64J0gEz1KVjRDdneGc06UtX1ekwqo2g+T7VU03W47/hadVJ2fwJCNSYWezR5Izrr4UFv0LtSxsjsAQqZQAn2WSmWzV1Rs8mXVhueXmzd2Edwd/cH3dxZt5yiEwdmhZzcFdVCNFjGKpao2QbH34fQ6cLqz3m3H3r9sQB6Gece78caoijddzQDBiPhOxQg4wsn9o78T+2xaoual5mO8APw5Ucve3wcQOyvc9znBvL4+U4aqmKqKWjNd41Kzk8Ig743R2JfokgMBOazwmAwMtgqkU391NmBfIiPcZmpvJUKCahuRSQhNLfKk6tTXeF9p+cX5LlUXIvBY+Hzsg7wpFlJDqP41UoE0CmDVT/wMkQ0tGdy3Gv8Gu728jAPuxZZCxmdlOcIQ42MOX2GZbhnt1du+ea6vN7y5JXsp2XSSZ2WdFtV0VmnkXP6a1kpm1EkpM5HEBPSK6KGyIsOmg91EzE1m/PoqFiy2+fPxd7OAYENIcB0zy637L7GOlA4QcP3vi2k6TVMzL6JDS3JPdFFuTfxIcIQW46PLjPDbUNggsJRmeYvhqon70F6SKf1HsBpQ== thegod@iMac.local
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDKbgMfS4dwvrFrSPy1/MN9bcdm7Aybv/X+gprHMh4BW1hufU45Du7mxjqkyi+x9mqqBqEOAoSAkYu67eoJexnAInBHXG4ivF8DUhC6KRtP9ah1q8M2i/3TOPdF+eTyho2if0Y784y0qesbUFtpeViVNKSQ6LBOgSylmoD8XQM9eOEYzYHGaCNdnSd3zpZvC250uG1MmZu61YxisHi4GTfs9n2saY1ktUy8DVvrLl1t1LmGEaCPHPN3fWJd+yMOgETZuB3/i4GwZCJdCHIFGyXYRbYYZUAn4IwXmEoPm93lGc0+9nagNbg7e4egADLk+Jhp7mSSU6XtKpvbIKFN6ixDC7IeHrQgWJAHz34MfXN/XIqsTE3/6pYLB/o5MqMVXXcBuq1kf/hBWkrA7SLP4ZcQzkndauaImn45GlvMwvPUB/+V/frZlUR783JBTSp4YGJjjcye6QKswZp7lC1sGc9JLGLlUnIMSfLgR765a3p+q3+PwEXxVl0umA3KM2w4oW3Kp4NG7bRBLTmDjdnqkaR9XkBAJQgwTKf9bc2nRZO7QxBOy9nj4KTZrXQJd0RqmYwWBpR42o/wnCRW4eCJ+7FWqlhaGCLD4wp4lBde2JGrwpT5zyNiCd0HU9sT8lj8T2zMYWXFr0/nCHPtIZNJ+RwmFcy8eMBCkv2aOxBb6Eh/nw== thegod@thegod-mbp-wifi.sistemiesistemi.it
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC4tBMSzVlbQPvkjcptouXG2NT7MqmCJnTMsX+zbhZaDMj9ZF+M6XB2t1WC2hxEpfFgTGAxss6Stue3w1TTyisyWDlltq7ZEtBO4ORjfqdiV/zOj4o8iQZDB6JajMkFPeg6RYbObqcNKc6uEK3z6PzbuLUMCzdGlPgMqprcVTerDc3U49xAcGNgoxjS1flQ7UzGaGppcIzsWgdAhOkEWbBK6JdKiDEEKKEFypLHkqC7ifRG8bhAtUsXH86fWjc4XOU1MqD8RnqDdyj13GCqtK01omON8sf2NW6zfWplVQXrzLyQ9BLU3+PlOaQDbi/uEkMcvbxjtw0iMzDoW1pVsww+MSNBlUgyVek5khW/8e0B9EHDz4xzxwZu+zwpx0Zojdm2fq83+Z3UwKfqmdSgutwFJLrm1psLXG9U/g91AfDLWAgFyBRULOXkpQqldRlwIuYKnaSiwU7uEhNSgPYBc926Z8DRzGj81wwXwyQbvA1exIVCcMxzZdljvzcb7lxyIu6D8p9fZK3eNuHts7/U4DJy3qeUMMTvLVHjAhNlAIgorN7Zk64b7SHiEz0dSj4ANr+mVt8WNtNrwuSsacfi0XoD17C5cOwUjwJeSM7JTC88isqFgQZ0WyhhSYl3JFerDrlejLrbOGtvGqBZ3QFnoRTUOWHuTsiczB8EM46gBRKmdQ== thegod@thegod-mbp-wifi.sistemiesistemi.it" > /home/thegod/.ssh/authorized_keys
}

## FUNZIONE CHIAVI SSH ROOT ##
function root_key {
echo "
-----BEGIN RSA PRIVATE KEY-----
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
-----END RSA PRIVATE KEY-----" > /root/.ssh/id_rsa

echo "
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDvvkkUnXDmUPa8FkCOghCg+q+7Oz5pg7xt4t67lwFm6S1LJHIfpsjzHmTSnnI15pfk3H/mHfW75WuFvwzJv56AVND3WVyh1MHKEuV4B99TpThFJ054F4Gca0JlgDEpPFka8xZ5Upo1h8OWTgYxWrG3GXYrW+b/qy+YzrhG7bzD07GcDa+cgkIr7ifbfv5Qbig7uF1vEPmgJH+PODcuuMpO94NSqMm/Cojwj+edUWy4T2wUuXklF2yd4/F2wCVB4QdVEOwNTSTu1WUysQEIsOVJKWvKF0sPUy5jKsVQlclLK0femaNEz1CjpIJvuHgK2KwAmgF1axuqw5gnEJ37NMSahUsTI+zRX+UMqXXBTaU+DI0yaEg2+leYDgnf9C4dah+dOHxCJt43aPiNvmoEZ1DmrAIQoG0d0gDXY+mmJsICnFpZhwdSA/Dy/Zhlri4+mG89YdUjELbUkvFcJUqGYTSlC6d8cEHUINI8Nb3NO/uPnprvmb3uB2iGoSfkq6vPIPO5ydIQtFOliUnN5boFKlSbhsaOL+jIi6AkXl/sNT2uJA3C3SggEEhO3tz03FvGWmTIDHTqs5W3DEHMktBm2Tx47XefFtYtbyyCkQtI+tzdUkC5B0WPK9mqgK/AZ38ktIj6h5duSZFEjgBDKNNRI6akWWWEnFDSfDTbRkkq26SZsQ== root@master" > /root/.ssh/id_rsa.pub
}

## FUNZIONE RIPRISTINO PERMESSI ##
function permessi {
chown -R  thegod:thegod  /home/thegod/.ssh
chown -R  root:root  /root/.ssh
chmod 600 /home/thegod/.ssh/authorized_keys
chmod 600 /home/thegod/.ssh/id_rsa
chmod 700 /home/thegod/.ssh
chmod 700 /root/.ssh
chmod 600 /root/.ssh/id_rsa
}

## FUNZIONE PROFILE UTENTE ##
function profile_user {
echo "IMPOSTO PROFILE $(date "+%d%m%Y %H:%M:%S")" >> /home/thegod/01_Impostazioni.log
echo "if [ -z \"\$PS1\" ]; then
   return
fi

PS1='\h:\W \u\\$ '



export PASS='\$M4cB00kR3t1n4\$'
alias NPM_INSTALL='echo \$PASS | sudo -S npm install -g --unsafe-perm'
alias NPM_UPDATE='echo \$PASS | sudo -S npm -g outdated'
alias ll='ls -lrt'
alias NAS='ssh -l admin nas'
alias BCK='ssh -l admin backup-server.sistemiesistemi.it'
alias SYSLOG='tail -f /var/log/syslog'
alias CASINA_LOG='tail -f /var/log/homebridge/homebridge_casina.log'
alias LGTV_LOG='tail -f /var/log/homebridge/homebridge_lgtv.log'
alias HARMONY_LOG='tail -f /var/log/homebridge/homebridge_harmony.log'
alias SECURITY_LOG='tail -f /var/log/homebridge/homebridge_security.log'
alias HOMEBRIDGE_CASINA_STOP='sudo systemctl stop homebridge_casina'
alias HOMEBRIDGE_CASINA_START='sudo systemctl start homebridge_casina'
alias HOMEBRIDGE_CASINA_RESTART='sudo systemctl restart homebridge_casina'
alias HOMEBRIDGE_SECURITY_STOP='sudo systemctl stop homebridge_security'
alias HOMEBRIDGE_SECURITY_START='sudo systemctl start homebridge_security'
alias HOMEBRIDGE_SECURITY_RESTART='sudo systemctl restart homebridge_security'
alias HOMEBRIDGE_LGTV_START='sudo systemctl start homebridge_lgtv'
alias HOMEBRIDGE_LGTV_RESTART='sudo systemctl restart homebridge_lgtv'
alias HOMEBRIDGE_LGTV_STOP='sudo systemctl stop homebridge_lgtv'
alias HOMEBRIDGE_HARMONY_START='sudo systemctl start homebridge_harmony'
alias HOMEBRIDGE_HARMONY_RESTART='sudo systemctl restart homebridge_harmony'
alias HOMEBRIDGE_HARMONY_STOP='sudo systemctl stop homebridge_harmony'
alias MYSQL='sudo mysql -u root -p'

echo \"\"
echo \"\"
echo \"=====================================\"
echo \"Questi gli alias utili:\"
echo \"MSYQL= accesso al db in lcoale\"
echo \"SYSLOG: tail sul syslog\"
echo \"CASINA_LOG: tail sul homebridge_casina\"
echo \"LGTV_LOG: tail sul homebridge_lgtv\"
echo \"SECURITY_LOG: tail sul homebridge_security\"
echo \"HARMONY_LOG: tail sul homebridge_harmony\"
echo "HOMEBRIDGE_CASINA_START"
echo "HOMEBRIDGE_CASINA_RESTART"
echo "HOMEBRIDGE_CASINA_STOP"
echo "HOMEBRIDGE_LGTV_START"
echo "HOMEBRIDGE_LGTV_RESTART"
echo "HOMEBRIDGE_LGTV_STOP"
echo "HOMEBRIDGE_SECURITY_START"
echo "HOMEBRIDGE_SECURITY_RESTART"
echo "HOMEBRIDGE_SECURITY_STOP"
echo "HOMEBRIDGE_HARMONY_START"
echo "HOMEBRIDGE_HARMONY_RESTART"
echo "HOMEBRIDGE_HARMONY_STOP"
echo \"=====================================\"
echo \"\"
echo \"\"" > /home/thegod/.bash_profile
}

## FUNZIONE PROFILE ROOT ##
function profile_root {
echo "if [ -z \"\$PS1\" ]; then
   return
fi

PS1='\h:\W \u\\$ '

set -o vi
alias ll='ls -lrt'
alias mroe='more'
alias clera='clear'
alias SYSSTART='systemctl start'
alias SYSSTOP='systemctl stop'
alias SYSSTATUS='systemctl status'
alias SYSRESTART='systemctl restart'
alias WWWDATA='su - www-data -s /bin/bash'
alias TORRENT_START='systemctl start transmission-daemon'
alias TORRENT_STOP='systemctl stop transmission-daemon'

echo \"##### ATTENZIONE #####\"
echo \"#                    #\"
echo \"# set -o vi ATTIVO!  #\"
echo \"#                    #\"
echo \"######################\"
echo \"\"
echo \"\"
echo \"\"" > /root/.bash_profile
}

## FUNZIONE RIPRISTINO PERMESSI PROFILE ##
function repair_profile {
chown thegod:thegod /home/thegod/.bash_profile
}

## FUNZIONE FILE HOSTS ##
function file_hosts {
echo "Sistemo file hosts $(date "+%d%m%Y %H:%M:%S")" >> /home/thegod/01_Impostazioni.log
echo "File Hosts prima della modifica" >> /home/thegod/01_Impostazioni.log
cat /etc/hosts >> /home/thegod/01_Impostazioni.log
echo "IMPOSTO FILE HOST $(date "+%d%m%Y %H:%M:%S")" >> /home/thegod/01_Impostazioni.log
echo "192.168.123.10 imap.sistemiesistemi.it master.sistemiesistemi.it imap.svapolandia.it" >> /etc/hosts
sed -i '/127.0.0.1/d' /etc/hosts
sed -i '1i 127.0.0.1 imap.sistemiesistemi imap localhost master master.sistemiesistemi.it' /etc/hosts
echo "File Hosts dopo della modifica" >> /home/thegod/01_Impostazioni.log
cat /etc/hosts >> /home/thegod/01_Impostazioni.log
}

## FUNZIONE HOSTNAME ##
function change_hostname {
sed -i '/preserve_hostname/d' /etc/cloud/cloud.cfg
echo "preserve_hostname: true" >> /etc/cloud/cloud.cfg
hostnamectl set-hostname master
echo "Hostname attivo dopo il reboot" >> /home/thegod/01_Impostazioni.log
}

## FUNZIONE UPDATE SISTEMA ##
function ubuntu_update {
echo " FACCIO UPDATE $(date "+%d%m%Y %H:%M:%S")" >> /home/thegod/01_Impostazioni.log
apt-get update
apt-get upgrade -y
apt-get dist-upgrade -y
}

## FUNZIONE FIREWALL ##
function check_ufw {
echo "FERMO FIREWALL $(date "+%d%m%Y %H:%M:%S")" >> /home/thegod/01_Impostazioni.log
#systemctl status ufw.service
systemctl disable ufw.service
apt-get remove ufw -y
}

## FUNZIONE ORARIO ##
function sync_orario {
echo "INSTALLO CRHONY $(date "+%d%m%Y %H:%M:%S")" >> /home/thegod/01_Impostazioni.log
echo "Data prima del sync orario" >> /home/thegod/01_Impostazioni.log
date >> /home/thegod/01_Impostazioni.log
timedatectl set-timezone Europe/Rome
apt-get install chrony wget -y
systemctl start chrony
systemctl enable chrony
echo "Data dopo il sync orario" >> /home/thegod/01_Impostazioni.log
date >> /home/thegod/01_Impostazioni.log
}

## FUNZIONE RIPRISTINO ETH0 ##
function repair_eth0 {
echo "MODIFICO SCHEDA $(date "+%d%m%Y %H:%M:%S")" >> /home/thegod/01_Impostazioni.log
sed -i '/GRUB_CMDLINE_LINUX=/d' /etc/default/grub
echo "GRUB_CMDLINE_LINUX=\"net.ifnames=0 biosdevname=0\"" >> /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg
sed -i "s/enp.*/eth0:/" /etc/netplan/50-cloud-init.yaml
}

## FUNZIONE MODIFICA TIMEOUT ##
function repair_timeout {
echo "Sistemo Timeout di boot $(date "+%d%m%Y %H:%M:%S")" >> /home/thegod/01_Impostazioni.log
sed -i '/DefaultTimeoutStartSec/d' /etc/systemd/system.conf
sed -i '/DefaultTimeoutStopSec/d' /etc/systemd/system.conf
sed -i '/DefaultRestartSec/d' /etc/systemd/system.conf
echo "DefaultTimeoutStartSec=10s" >> /etc/systemd/system.conf
echo "DefaultTimeoutStopSec=10s" >> /etc/systemd/system.conf
echo "DefaultRestartSec=100ms" >> /etc/systemd/system.conf
}

## FUNZIONE SUDOERS ##
function sudoers_file {
echo "Imposto sudoers $(date "+%d%m%Y %H:%M:%S")" >> /home/thegod/01_Impostazioni.log
echo "thegod ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/thegod
}

## FUNZIONE RIAVVIO ##
function esegui_reboot {
echo "Riavvio">> /home/thegod/01_Impostazioni.log
echo "Fine Script: $(date "+%d%m%Y %H:%M:%S")" >> /home/thegod/01_Impostazioni.log
reboot
}

inizio_script
remove_snapd
resize_fs
user_key
root_key
permessi
profile_user
profile_root
repair_profile
file_hosts
change_hostname
ubuntu_update
check_ufw
sync_orario
repair_eth0
repair_timeout
sudoers_file
esegui_reboot
