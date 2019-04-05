#!/bin/bash

# script finali per la migrazione da Ubuntu 16 a Ubuntu 18
# Terzo script da eseguire
# Lo script effettua:
# 1) Check data
# 2) Installazione nodejs
# 3) Installazione npm
# 4) Installazione pre-requisiti
# 5) Installazione HB (con retry in caso di errore)
# 6) Crezione cartelle
# 7) Ripristino Key File LG
# 8) Creazione File config.json
# 9) Creazione file di init
# 10) Crea file di configurazione del demone
# 11) Creazione nuovi binari e relativa modifica e link
# 12) Creazione log
#
# Script creato da Marco de Santis

## EXPORT VARIABILI ##
data="06_03_2019_1000"

## FUNZIONE INZIO SCRIPT ##
function inizio_script {
echo "Inizio Script: $(date "+%d%m%Y %H:%M:%S")" >> /home/thegod/03_homebridge.log
}

## FUNZIONE CHECK UTENTE ##
function check_utente {
echo "Controllo l'utente $(date "+%d%m%Y %H:%M:%S")" >> /home/thegod/03_homebridge.log

if [ "$(whoami)" != "root" ]; then
        echo "Lo script va lanciato con utente root"
        exit -1
fi
}

## FUNZIONE INSTALLAZIONE REPO ##
function installa_repo {
echo "Installo repository per ultima versione nodejs $(date "+%d%m%Y %H:%M:%S")" >> /home/thegod/03_homebridge.log
curl -sL https://deb.nodesource.com/setup_11.x | sudo bash -
}

## FUNZIONE INSTALLAZIONE NODE E NPM ##
function installa_node_npm {
echo "Installo node e npm $(date "+%d%m%Y %H:%M:%S")" >> /home/thegod/03_homebridge.log
sudo apt-get install nodejs -y
}

## FUNZIONE PREREQUISITI ##
function installa_pre {
echo "Installo prerequisiti $(date "+%d%m%Y %H:%M:%S")" >> /home/thegod/03_homebridge.log
apt-get install libavahi-compat-libdnssd-dev -y
}

## FUNZIONE INSTALLAZIONE HOMEBRIDGE ##
function installa_homebridge {
echo "Installo core homebridge $(date "+%d%m%Y %H:%M:%S")" >> /home/thegod/03_homebridge.log
sudo npm install -g --unsafe-perm homebridge
if [[ $? != 0 ]] ;
then
        echo "Homebridge in errore. Riprovo" >> /home/thegod/03_homebridge.log
        installa_homebridge
else
        echo "Homebridge Installato correttamente" >> /home/thegod/03_homebridge.log
fi
}

## FUNZIONE CREAZIONE CARTELLE CONF INSTANZE ##
function crea_cartelle {
echo "Creo le cartelle $(date "+%d%m%Y %H:%M:%S")" >> /home/thegod/03_homebridge.log
mkdir .homebridge_casina >> /home/thegod/03_homebridge.log
mkdir .homebridge_lgtv >> /home/thegod/03_homebridge.log
mkdir .homebridge_security >> /home/thegod/03_homebridge.log
mkdir .homebridge_harmony >> /home/thegod/03_homebridge.log
}

## FUNZIONE RIPRISTINO FILE KEY LGTV ##
function key_lg {
echo "Ripristino file key lg $(date "+%d%m%Y %H:%M:%S")" >> /home/thegod/03_homebridge.log
for i in $(ls homebridge*_*.tar); do tar -xvf $i; done
cp -R /home/thegod/home/thegod/.homebridge_multimedia/lgtvKeyFile /home/thegod/.homebridge_lgtv/
cp -R /home/thegod/home/thegod/.homebridge_multimedia/lgtvKeyFile1 /home/thegod/.homebridge_lgtv/
}
 
## FUNZIONE CREAZIONE CONFIG.JSON CASINA ##
function crea_config_casina {
echo "Creo file config.json casina $(date "+%d%m%Y %H:%M:%S")" >> /home/thegod/03_homebridge.log
echo "{
 \"bridge\": {
  \"name\": \"Casina Nostra\",
  \"username\": \"CC:22:3D:E3:CE:22\",
  \"port\": 51827,
  \"pin\": \"032-55-154\"
 },

 \"plugins\": [
     \"homebridge-eveatmo\",
         \"homebridge-broadlink-rm\",
         \"homebridge-alexa\"
   ],
 \"platforms\": [
 {
            \"platform\": \"eveatmo\",
            \"name\": \"eveatmo platform\",
            \"extra_co2_sensor\": true,
            \"co2_alert_threshold\": 1000,
            \"ttl\": 540,
            \"auth\": {
                \"client_id\": \"5c545b0ed1f99313008c4844\",
                \"client_secret\": \"FugOwwcShUg5fhJAEG7UD4jsWJkv252oeivDVW\",
                \"username\": \"marco_desantis@icloud.com\",
                \"password\": \"M4rc01971\"
            }
        },
  {
   \"platform\": \"BroadlinkRM\",
   \"name\": \"Broadlink RM\",
   \"hideScanFrequencyButton\": false,
   \"hideLearnButton\": false,
   \"hideWelcomeMessage\": true,
   \"accessories\": [
{
\"name\":\"Luce Natale\",
\"type\":\"switch\",
\"host\": \"192.168.123.64\",
\"data\":{
  \"on\":\"b2003801072107220721072207220622072206220722072206221b0e0622072206221b0e06231b0e06221b0e0623062206221b0e0600013e062207220721072206220722072107220722062207221b0d0722072107221b0f05221b0e07211c0d0721072306221b0e0600013d072108210722072108210721082107210821072207211c0d0721072207211c0e06221b0e06221b0e0722062207211c0d0700013c082107220721082107210821072108210721082107221b0d0820082108201c0e07211c0d07211c0d0721082107221b0e0700013b082108210721082108200821082107210820082108201d0c08211c0c08201d0c08211c0d08201c0d1c0c1d0c1d0b1d0c0900013b082108210720092008210820092008200821082009201c0c09201c0d08201d0c08201d0c08201d0c1d0c1d0c1c0d1c0c080005dc\",
  \"off\": \"b21a3400092109210921092109210921092109210921092109211d0d0921092109211d0d09211e0d09211d0d09211d0d092109210900013c00000000\"
}
}
   ]
  },
  {
    \"platform\": \"Alexa\",
    \"name\": \"Alexa\",
    \"username\": \"pinkpanther1971\",
    \"password\": \"tunfuh-nexvEk-diccu6\",
    \"pin\": \"032-55-154\",
    \"refresh\": 15
        }
]
}" > /home/thegod/.homebridge_casina/config.json
}

## FUNZIONE CREAZIONE CONFIG.JSON SECURITY ##
function crea_config_security {
echo "Creo file config.json security $(date "+%d%m%Y %H:%M:%S")" >> /home/thegod/03_homebridge.log
echo "{
        \"bridge\": {
                \"name\": \"Security\",
                \"username\": \"CC:22:3D:E3:CE:24\",
                \"port\": 51829,
                \"pin\": \"032-55-154\"
        },

        \"plugins\": [
                \"homebridge-foscamcamera\",
                \"homebridge-ifttt\"
        ],
        \"platforms\": [

                {
                        \"platform\": \"FoscamCamera\",
                        \"name\": \"Sottoscala\",
                        \"cameras\": [{
                                \"username\": \"Marco\",
                                \"password\": \"M4rc03S4r4!\",
                                \"host\": \"192.168.123.43\",
                                \"port\": 5101,
                                \"stay\": 8,
                                \"away\": 10,
                                \"night\": 6,
                                \"armPreset\": \"avvio\",
                                \"disarmPreset\": \"avvio\",
                                \"sensitivity\": 2,
                                \"videoConfig\": {
                                        \"source\": \"-re -i rtsp://Marco:M4rc03S4r4!@cam-understair.sistemiesistemi.it:554/videoMain\",
                                        \"stillImageSource\": \"-i http://cam-understair:5101/cgi-bin/CGIProxy.fcgi?cmd=snapPicture2&usr=Marco&pwd=M4rc03S4r4!&\",
                                        \"maxStreams\": 2,
                                        \"maxWidth\": 1280,
                                        \"maxHeight\": 720,
                                        \"maxFPS\": 30
                                }
                        }]
                },
{
                        \"platform\": \"FoscamCamera\",
                        \"name\": \"Kitchen\",
                        \"cameras\": [{
                                \"username\": \"Marco\",
                                \"password\": \"M4rc03S4r4!\",
                                \"host\": \"192.168.123.41\",
                                \"port\": 5100,
                                \"stay\": 8,
                                \"away\": 10,
                                \"night\": 6,
                                \"armPreset\": \"Startup\",
                                \"disarmPreset\": \"Startup\",
                                \"sensitivity\": 4,
                                \"videoConfig\": {
                                        \"source\": \"-re -i rtsp://Marco:M4rc03S4r4!@cam-kitchen.sistemiesistemi.it:554/videoMain\",
                                        \"stillImageSource\": \"-i http://cam-kitchen:5100/cgi-bin/CGIProxy.fcgi?cmd=snapPicture2&usr=Marco&pwd=M4rc03S4r4!&\",
                                        \"maxStreams\": 2,
                                        \"maxWidth\": 1280,
                                        \"maxHeight\": 720,
                                        \"maxFPS\": 30,
                                        \"maxBitrate\": 600
                                }
                        }]
                },
{
                        \"platform\": \"FoscamCamera\",
                        \"name\": \"External\",
                        \"cameras\": [{
                                \"username\": \"Marco\",
                                \"password\": \"M4rc03S4r4!\",
                                \"host\": \"192.168.123.45\",
                                \"port\": 5104,
                                \"stay\": 8,
                                \"away\": 10,
                                \"night\": 6,
                                \"sensitivity\": 4,
                                \"videoConfig\": {
                                        \"source\": \"-re -i rtsp://Marco:M4rc03S4r4!@cam-external.sistemiesistemi.it:5104/videoMain\",
                                        \"stillImageSource\": \"-i http://cam-external:5104/cgi-bin/CGIProxy.fcgi?cmd=snapPicture2&usr=Marco&pwd=M4rc03S4r4!&\",
                                        \"maxStreams\": 2,
                                        \"maxWidth\": 1280,
                                        \"maxHeight\": 720,
                                        \"maxFPS\": 30
                                }
                        }]
                },
{
                        \"platform\": \"FoscamCamera\",
                        \"name\": \"Office\",
                        \"cameras\": [{
                                \"username\": \"Marco\",
                                \"password\": \"M4rc03S4r4!\",
                                \"host\": \"192.168.123.44\",
                                \"port\": 5103,
                                \"stay\": 8,
                                \"away\": 10,
                                \"night\": 6,
                                \"armPreset\": \"Avvio\",
                                \"disarmPreset\": \"Avvio\",
                                \"sensitivity\": 4,
                                \"videoConfig\": {
                                        \"source\": \"-re -i rtsp://Marco:M4rc03S4r4!@cam-office.sistemiesistemi.it:554/videoMain\",
                                        \"stillImageSource\": \"-i http://cam-office:5103/cgi-bin/CGIProxy.fcgi?cmd=snapPicture2&usr=Marco&pwd=M4rc03S4r4!&\",
                                        \"maxStreams\": 2,
                                        \"maxWidth\": 1280,
                                        \"maxHeight\": 720,
                                        \"maxFPS\": 30
                                }
                        }]
                },
{
                        \"platform\": \"FoscamCamera\",
                        \"name\": \"Leaving\",
                        \"cameras\": [{
                                \"username\": \"Marco\",
                                \"password\": \"M4rc03S4r4!\",
                                \"host\": \"192.168.123.42\",
                                \"port\": 5102,
                                \"stay\": 8,
                                \"away\": 14,
                                \"night\": 6,
                                \"sensitivity\": 4,
                                \"videoConfig\": {
                                        \"source\": \"-re -i rtsp://Marco:M4rc03S4r4!@cam-leaving.sistemiesistemi.it:5102/videoMain\",
                                        \"stillImageSource\": \"-i http://cam-leaving:5102/cgi-bin/CGIProxy.fcgi?cmd=snapPicture2&usr=Marco&pwd=M4rc03S4r4!&\",
                                        \"maxStreams\": 2,
                                        \"maxWidth\": 1280,
                                        \"maxHeight\": 720,
                                        \"maxFPS\": 30
                                }
                        }]
                },
                {
                        \"platform\": \"IFTTT\",
                        \"name\": \"IFTTT\",
                        \"makerkey\": \"htaU0GiL0Ua9VugjL6M2nlHXCTlo5RAfJGA_jolZjh6\",
                        \"accessories\": [{
                                \"name\": \"Allarme\",
                                \"buttons\": [{
                                                \"caption\": \"Attiva\",
                                                \"triggerOn\": \"Attiva\",
                                                \"triggerOff\": \"Disattiva\"
                                        },
                                        {
                                                \"caption\": \"Romeo\",
                                                \"triggerOn\": \"Romeo\",
                                                \"triggerOff\": \"Disattiva\"
                                        },
                                        {
                                                \"caption\": \"Panico\",
                                                \"triggerOn\": \"Panico\",
                                                \"triggerOff\": \"Disattiva\"
                                        },
                                        {
                                                \"caption\": \"Porta\",
                                                \"triggerOn\": \"Porta\",
                                                \"triggerOff\": \"Disattiva\"
                                        },
                                        {
                                                \"caption\": \"Soggiorno\",
                                                \"triggerOn\": \"Soggiorno\",
                                                \"triggerOff\": \"Disattiva\"
                                        }


                                ]
                        }]
                }
        ]
}" > /home/thegod/.homebridge_security/config.json
}

## FUNZIONE CREAZIONE CONFIG.JSON LGTV ##
function crea_config_lgtv {
echo "Creo file config.json lgvt $(date "+%d%m%Y %H:%M:%S")" >> /home/thegod/03_homebridge.log
echo "{
        \"bridge\": {
                \"name\": \"TV_LG\",
                \"username\": \"CC:22:3D:E3:CE:23\",
                \"port\": 51828,
                \"pin\": \"032-55-154\"
        },

\"plugins\": [
          \"homebridge-webos-tv\",
         \"homebridge-broadlink-rm\"
                      ],
  \"accessories\": [
    {
      \"accessory\": \"webostv\",
      \"name\": \"LG Camera\",
      \"ip\": \"192.168.123.36\",
      \"mac\": \"e8:f2:e2:9d:09:2b\",
      \"broadcastAdr\": \"192.168.123.255\",
      \"keyFile\": \"/home/thegod/.homebridge_lgtv/lgtvKeyFile\",
      \"pollingInterval\": 5,
      \"volumeControl\": \"slider\",
      \"mediaControl\": false,
      \"inputs\":[
          {
            \"appId\": \"com.webos.app.livetv\",
            \"name\": \"Live TV\"
          },
          {
            \"appId\": \"com.webos.app.hdmi1\",
            \"name\": \"AppleTV\"
          }
      ],
\"remoteControlButtons\": [\"MUTE\", \"HOME\", \"MENU\", \"0\", \"1\", \"2\", \"3\", \"4\", \"5\", \"6\", \"7\", \"8\", \"9\"]
    }
],
\"platforms\": [
    {
            \"platform\": \"BroadlinkRM\",
            \"name\": \"Broadlink RM\",
            \"hideScanFrequencyButton\": false,
            \"hideLearnButton\": false,
            \"hideWelcomeMessage\": true,
            \"accessories\": [
                {
                \"name\":\"AccendiTV\",
                \"type\":\"switch\",
                \"host\": \"192.168.123.65\",
                \"pingIPAddress\": \"192.168.123.36\",
                \"pingIPAddressStateOnly\": true,
                \"pingFrequency\": 5,
                \"data\":{
                  \"on\":\"2600800000012a8f13121311133713111312131212121312133613371212133613371336133613371311131213121237131212121312131212371336133613121336133712371336130005200001294713000c4700012a4613000c4700012a4613000c4700012a4613000c4700012a4613000c4700012a4613000c4700012a4615000d050000000000000000\",
                  \"off\": \"260060000001279213121312123713111312131213111312133613371311133712371336133712371311131213121336131213111312131213361336133712121337123713361336130005200001294713000c470001294812000c480001294713000d050000000000000000\"
                }
                }
                   ]

    }
]
}" > /home/thegod/.homebridge_lgtv/config.json
}

## FUNZIONE CREAZIONE CONFIG.JSON HARMONY ##
function crea_config_harmony {
echo "Creo file config.json harmony $(date "+%d%m%Y %H:%M:%S")" >> /home/thegod/03_homebridge.log
echo "{
        \"bridge\": {
                \"name\": \"Homebridge\",
                \"username\": \"CC:22:3D:E3:CE:25\",
                \"port\": 51830,
                \"pin\": \"031-45-154\"
        },
        \"plugins\": [
                \"homebridge-harmony\"
        ],
        \"platforms\": [{
        \"platform\": \"HarmonyHubWebSocket\",
    \"name\": \"Harmony_Hub\",
    \"hubIP\": \"192.168.123.66\",
    \"TVPlatformMode\" : true,
    \"mainActivity\" : \"VediTV\"
    \"devicesToPublishAsAccessoriesSwitch\" : [\"SoundBar;VolumeUp\",\"SoundBar;VolumeDown\",\"SoundBar;Mute\",\"TV Leaving;ChannelUp\",\"TV Leaving;ChannelDown\",\"TV Leaving;Info\",\"TV Leaving;InputTv\",\"TV Leaving;Number1\",\"TV Leaving;Number2\",\"TV Leaving;Number3\",\"TV Leaving;Number4\",\"TV Leaving;Number5\",\"TV Leaving;Number6\",\"TV Leaving;Number7\",\"TV Leaving;Number8\",\"TV Leaving;Number9\",\"TV Leaving;Number0\"]
        }]
}" > /home/thegod/.homebridge_harmony/config.json
}

## FUNZIONE CAMBIO PERMESSI ##
function cambio_permessi {
echo "Sistemo i permessi $(date "+%d%m%Y %H:%M:%S")" >> /home/thegod/03_homebridge.log
sudo chown -R thegod:thegod .homebridge*
}

## FUNZIONE RIMOZIONE VECCHIA CARTELLA ##
function rimuovi_dir {
echo "Rimuovo la dir non usata $(date "+%d%m%Y %H:%M:%S")" >> /home/thegod/03_homebridge.log
rm -rf /home/thegod/.homebridge
}

## FUNZIONE CREAZIONE INIT CASINA ##
function init_casina {
echo "CREO IL FILE DI INIT CASINA $(date "+%d%m%Y %H:%M:%S")" >> /home/thegod/03_homebridge.log
sudo echo "[Unit]
Description=Node.js HomeKit Server
After=syslog.target network-online.target

[Service]
Type=simple
User=thegod
EnvironmentFile=/etc/default/homebridge_casina
# Adapt this to your specific setup (could be /usr/bin/homebridge)
# See comments below for more information
ExecStart=/usr/bin/homebridge_casina \$HOMEBRIDGE_OPTS
Restart=on-failure
RestartSec=3
KillMode=process
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=homebridge_casina

[Install]
WantedBy=multi-user.target" > /etc/systemd/system/homebridge_casina.service
}

## FUNZIONE CREAZIONE INIT SECURITY ##
function init_security {
echo "CREO IL FILE DI INIT SECURITY $(date "+%d%m%Y %H:%M:%S")" >> /home/thegod/03_homebridge.log
sudo echo "[Unit]
Description=Node.js HomeKit Server
After=syslog.target network-online.target

[Service]
Type=simple
User=thegod
EnvironmentFile=/etc/default/homebridge_security
# Adapt this to your specific setup (could be /usr/bin/homebridge)
# See comments below for more information
ExecStart=/usr/bin/homebridge_security \$HOMEBRIDGE_OPTS
Restart=on-failure
RestartSec=3
KillMode=process
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=homebridge_security

[Install]
WantedBy=multi-user.target" > /etc/systemd/system/homebridge_security.service
}

## FUNZIONE CREAZIONE INIT HARMONY ##
function init_harmony {
echo "CREO IL FILE DI HARMONY $(date "+%d%m%Y %H:%M:%S")" >> /home/thegod/03_homebridge.log
sudo echo "[Unit]
Description=Node.js HomeKit Server
After=syslog.target network-online.target

[Service]
Type=simple
User=thegod
EnvironmentFile=/etc/default/homebridge_harmony
# Adapt this to your specific setup (could be /usr/bin/homebridge)
# See comments below for more information
ExecStart=/usr/bin/homebridge_harmony \$HOMEBRIDGE_OPTS
Restart=on-failure
RestartSec=3
KillMode=process
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=homebridge_harmony

[Install]
WantedBy=multi-user.target" > /etc/systemd/system/homebridge_harmony.service
}

## FUNZIONE CREAZIONE INIT LGVT ##
function init_lgvt {
echo "CREO IL FILE DI LGTV $(date "+%d%m%Y %H:%M:%S")" >> /home/thegod/03_homebridge.log
echo "[Unit]
Description=Node.js HomeKit Server
After=syslog.target network-online.target

[Service]
Type=simple
User=thegod
EnvironmentFile=/etc/default/homebridge_lgtv
# Adapt this to your specific setup (could be /usr/bin/homebridge)
# See comments below for more information
ExecStart=/usr/bin/homebridge_lgtv \$HOMEBRIDGE_OPTS
Restart=on-failure
RestartSec=3
KillMode=process
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=homebridge_lgtv

[Install]
WantedBy=multi-user.target" > /etc/systemd/system/homebridge_lgtv.service
}

## FUNZIONE PERMESSI FILE INIT ##
function permessi_init {
echo "Sistemo i permessi $(date "+%d%m%Y %H:%M:%S")" >> /home/thegod/03_homebridge.log
chmod 644 /etc/systemd/system/homebridge_*
}

## FUNZIONE CONF DEMONE CASINA ##
function conf_demone_casina {
echo "Creo i file di configurazione per l'istanza CASINA $(date "+%d%m%Y %H:%M:%S")" >> /home/thegod/03_homebridge.log
sudo echo "# Defaults / Configuration options for homebridge
# The following settings tells homebridge where to find the config.json file and where to persist the data (i.e. pairing and others)
HOMEBRIDGE_OPTS=-D -I -U /home/thegod/.homebridge_casina/

# If you uncomment the following line, homebridge will log more
# You can display this via systemd's journalctl: journalctl -f -u homebridge
# DEBUG=*" > /etc/default/homebridge_casina
}

## FUNZIONE CONF DEMONE SECURITY ##
function conf_demone_security {
echo "Creo i file di configurazione per l'istanza SECURITY $(date "+%d%m%Y %H:%M:%S")" >> /home/thegod/03_homebridge.log
sudo echo "# Defaults / Configuration options for homebridge
# The following settings tells homebridge where to find the config.json file and where to persist the data (i.e. pairing and others)
HOMEBRIDGE_OPTS=-D -I -U /home/thegod/.homebridge_security/

# If you uncomment the following line, homebridge will log more
# You can display this via systemd's journalctl: journalctl -f -u homebridge
# DEBUG=*" > /etc/default/homebridge_security
}

## FUNZIONE CONF DEMONE HARMONY ##
function conf_demone_harmony {
echo "Creo i file di configurazione per l'istanza HARMONY $(date "+%d%m%Y %H:%M:%S")" >> /home/thegod/03_homebridge.log
sudo echo "# Defaults / Configuration options for homebridge
# The following settings tells homebridge where to find the config.json file and where to persist the data (i.e. pairing and others)
HOMEBRIDGE_OPTS=-D -I -U /home/thegod/.homebridge_harmony/

# If you uncomment the following line, homebridge will log more
# You can display this via systemd's journalctl: journalctl -f -u homebridge
# DEBUG=*" > /etc/default/homebridge_harmony
}

## FUNZIONE CONF DEMONE LGTV ##
function conf_demone_lvtg {
echo "Creo i file di configurazione per l'istanza LGTV $(date "+%d%m%Y %H:%M:%S")" >> /home/thegod/03_homebridge.log
sudo echo "# Defaults / Configuration options for homebridge
# The following settings tells homebridge where to find the config.json file and where to persist the data (i.e. pairing and others)
HOMEBRIDGE_OPTS=-D -I -U /home/thegod/.homebridge_lgtv/

# If you uncomment the following line, homebridge will log more
# You can display this via systemd's journalctl: journalctl -f -u homebridge
# DEBUG=*" > /etc/default/homebridge_lgtv
}

## FUNZIONE NUOVI BINARI ##
function crea_binari {
echo "Creo i nuovi binari $(date "+%d%m%Y %H:%M:%S")" >> /home/thegod/03_homebridge.log
sudo cp /usr/lib/node_modules/homebridge/bin/homebridge /usr/lib/node_modules/homebridge/bin/homebridge_casina
sudo cp /usr/lib/node_modules/homebridge/bin/homebridge /usr/lib/node_modules/homebridge/bin/homebridge_lgtv
sudo cp /usr/lib/node_modules/homebridge/bin/homebridge /usr/lib/node_modules/homebridge/bin/homebridge_security
sudo cp /usr/lib/node_modules/homebridge/bin/homebridge /usr/lib/node_modules/homebridge/bin/homebridge_harmony
}

## FUNZIONE SED BINARI ISTANZE ##
function sed_binari {
echo "Sistemo i nuovi binari $(date "+%d%m%Y %H:%M:%S")" >> /home/thegod/03_homebridge.log
sudo sed -i 's/homebridge/homebridge_casina/g' /usr/lib/node_modules/homebridge/bin/homebridge_casina
sudo sed -i 's/homebridge/homebridge_lgtv/g' /usr/lib/node_modules/homebridge/bin/homebridge_lgtv
sudo sed -i 's/homebridge/homebridge_security/g' /usr/lib/node_modules/homebridge/bin/homebridge_security
sudo sed -i 's/homebridge/homebridge_harmony/g' /usr/lib/node_modules/homebridge/bin/homebridge_harmony
}

## FUNZIONE LINK SIMBOLICI ##
function crea_link {
echo "Creo i nuovi link ai nuovi binari $(date "+%d%m%Y %H:%M:%S")" >> /home/thegod/03_homebridge.log
sudo ln -s /usr/lib/node_modules/homebridge/bin/homebridge_casina /usr/bin/homebridge_casina
sudo ln -s /usr/lib/node_modules/homebridge/bin/homebridge_lgtv /usr/bin/homebridge_lgtv
sudo ln -s /usr/lib/node_modules/homebridge/bin/homebridge_security /usr/bin/homebridge_security
sudo ln -s /usr/lib/node_modules/homebridge/bin/homebridge_harmony /usr/bin/homebridge_harmony
}

## FUNZIONE LOG ##
function crea_log {
echo "Creo i log $(date "+%d%m%Y %H:%M:%S")" >> /home/thegod/03_homebridge.log
sudo echo "

if \$programname == 'homebridge_casina' then /var/log/homebridge/homebridge_casina.log
if \$programname == 'homebridge_casina' then stop


if \$programname == 'homebridge_lgtv' then /var/log/homebridge/homebridge_lgtv.log
if \$programname == 'homebridge_lgtv' then stop

if \$programname == 'homebridge_harmony' then /var/log/homebridge/homebridge_harmony.log
if \$programname == 'homebridge_harmony' then stop

if \$programname == 'homebridge_security' then /var/log/homebridge/homebridge_security.log
if \$programname == 'homebridge_security' then stop     " >> /etc/rsyslog.d/50-default.conf
}

## FUNZIONE FINE SCRIPT ##
function fine_script {
echo "Fine Script: $(date "+%d%m%Y %H:%M:%S")" >> /home/thegod/03_homebridge.log
}

inizio_script
check_utente
installa_repo
installa_node_npm
installa_pre
installa_homebridge
crea_cartelle
key_lg
crea_config_casina
crea_config_security
crea_config_lgtv
crea_config_harmony
cambio_permessi
rimuovi_dir
init_casina
init_security
init_harmony
init_lgvt
permessi_init
conf_demone_casina
conf_demone_security
conf_demone_harmony
conf_demone_lvtg
crea_binari
sed_binari
crea_link
crea_log
fine_script
