#!/bin/bash

# Percorso del log file
LOG_FILE="/var/log/letsencrypt-renew.log"

# Funzione per loggare i messaggi
log_message() {
    echo "$(date): $1" >> "$LOG_FILE"
}

# Inizia il processo di rinnovo
log_message "Iniziando il processo di rinnovo dei certificati"

# Tenta di rinnovare i certificati
certbot renew -q

# Controlla se il rinnovo ha avuto successo
if [ $? -eq 0 ]; then
    log_message "Rinnovo dei certificati completato con successo"

    # Riavvia il container Nginx
    if docker-compose restart nginx; then
        log_message "Container Nginx riavviato con successo"
    else
        log_message "Errore durante il riavvio del container Nginx"
    fi
else
    log_message "Errore durante il rinnovo dei certificati"
fi

# Pulisci i log vecchi (opzionale)
find "$LOG_FILE" -mtime +30 -delete
