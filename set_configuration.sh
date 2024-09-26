#!/bin/bash
set -x

# Funzione per aggiungere un dominio fidato
add_trusted_domain() {
    local domain=$1
    TRUSTED_INDEX=$(docker exec -u www-data app-server php occ --no-warnings config:system:get trusted_domains | wc -l)
    docker exec -u www-data app-server php occ --no-warnings config:system:set trusted_domains $TRUSTED_INDEX --value="$domain"
}

# Aggiungi sempre i domini fidati
add_trusted_domain "nginx-server"
add_trusted_domain "management.polis-net.it"

# Installa e configura OnlyOffice
docker exec -u www-data app-server php occ --no-warnings app:install onlyoffice
docker exec -u www-data app-server php occ --no-warnings config:system:set onlyoffice DocumentServerUrl --value="/ds-vpath/"
docker exec -u www-data app-server php occ --no-warnings config:system:set onlyoffice DocumentServerInternalUrl --value="http://onlyoffice-document-server/"
docker exec -u www-data app-server php occ --no-warnings config:system:set onlyoffice StorageUrl --value="http://nginx-server/"
docker exec -u www-data app-server php occ --no-warnings config:system:set onlyoffice jwt_secret --value="secret"

# Verifica i domini fidati
echo "Trusted domains after configuration:"
docker exec -u www-data app-server php occ --no-warnings config:system:get trusted_domains
