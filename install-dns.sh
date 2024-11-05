#!/bin/bash

# Variables
SCRIPT_PATH="/usr/local/bin/change_dns.sh"
PLIST_PATH="/Library/LaunchDaemons/com.$USER.dnscheck.plist"
LOGFILE="/Users/$USER/Desktop/NoFap/approche-dns/change_dns.log"

# Étape 1 : Créer le script change_dns.sh
cat << 'EOF' > $SCRIPT_PATH
#!/bin/bash

logfile="/Users/souheillassouad/Desktop/NoFap/approche-dns/change_dns.log"
echo "Script exécuté à $(date)" >> $logfile

dns1="1.1.1.3"
dns2="1.0.0.3"

network_services=$(networksetup -listallnetworkservices | tail -n +2)

for service in $network_services; do
    if [[ "$service" == "Thunderbolt*" || "$service" == "Bridge" ]]; then
        echo "$service n'est pas un service réseau reconnu, il sera ignoré." >> $logfile
        continue
    fi

    current_dns=$(networksetup -getdnsservers "$service" 2>> $logfile)
    if [[ $? -ne 0 ]]; then
        echo "Erreur lors de la récupération des serveurs DNS pour $service : $current_dns" >> $logfile
        continue
    fi

    if [[ "$current_dns" != *"$dns1"* && "$current_dns" != *"$dns2"* ]]; then
        echo "Configuration des serveurs DNS pour $service" >> $logfile 
        sudo networksetup -setdnsservers "$service" $dns1 $dns2 2>> $logfile
        if [[ $? -eq 0 ]]; then
            echo "Serveurs DNS configurés pour $service avec succès." >> $logfile
        else
            echo "Erreur lors de la configuration des serveurs DNS pour $service." >> $logfile
        fi
    else
        echo "Les serveurs DNS pour $service sont déjà configurés correctement." >> $logfile
    fi
done

echo "Script terminé à $(date)" >> $logfile
EOF

# Étape 2 : Rendre le script exécutable
chmod 755 $SCRIPT_PATH

# Étape 3 : Créer le fichier .plist
cat << 'EOF' > $PLIST_PATH
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.souheillassouad.dnscheck</string>
    <key>ProgramArguments</key>
    <array>
        <string>/usr/local/bin/change_dns.sh</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>StartInterval</key>
    <integer>10</integer>
    <key>StandardOutPath</key>
    <string>/Users/souheillassouad/Desktop/NoFap/approche-dns/dnscheck_stdout.log</string>
    <key>StandardErrorPath</key>
    <string>/Users/souheillassouad/Desktop/NoFap/approche-dns/dnscheck_stderr.log</string>
</dict>
</plist>
EOF

# Étape 4 : Donner les permissions au fichier .plist et au script
chmod 644 $PLIST_PATH

# Étape 5 : Charger le .plist dans launchd
sudo launchctl load -w $PLIST_PATH

echo "Installation terminée."
