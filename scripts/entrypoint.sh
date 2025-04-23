#!/bin/bash

# Crear usuario administrador de Wildfly si no existe
if [ -n "$WILDFLY_ADMIN_USER" ] && [ -n "$WILDFLY_ADMIN_PASSWORD" ]; then
    echo "Configurando usuario administrador de Wildfly..."
    /opt/wildfly/bin/add-user.sh -u "$WILDFLY_ADMIN_USER" -p "$WILDFLY_ADMIN_PASSWORD" --silent -r ManagementRealm
fi

# Ejecutar el comando que se le pase (por defecto sleep infinity)
exec "$@"
