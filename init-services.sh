#!/bin/bash
set -e

# Directorio donde están los archivos
CONFIG_DIR="/workspaces/.devcontainer"
#echo "Usando directorio de configuración: $CONFIG_DIR"

# Configurar permisos de Docker
sudo chmod 666 /var/run/docker.sock || echo "No se pudieron cambiar los permisos del socket Docker"
export DOCKER_HOST=unix:///var/run/docker.sock

# Cambiar al directorio donde están los archivos
cd "$CONFIG_DIR"
#echo "Cambiando al directorio $(pwd)"

# Cargar variables de entorno
if [ -f ".env" ]; then
  . ./.env
#  echo "Variables de entorno cargadas desde $(pwd)/.env"
else
  echo "Advertencia: No se encontró el archivo .env"
fi

echo "Configurando servicios de bases de datos..."

# Verificar que Docker esté disponible
if command -v docker &> /dev/null && command -v docker-compose &> /dev/null; then
  # Detener servicios previos
#  echo "Deteniendo servicios previos..."
  docker-compose stop db mongo_express mysql phpmyadmin postgres pgadmin || echo "No se pudieron detener los servicios"
  # Iniciar MongoDB si está habilitado
  if [ "${ENABLE_MONGODB}" = "true" ]; then
    docker-compose up -d db mongo_express
    echo "MongoDB disponible en: localhost:27017"
    echo "Mongo Express disponible en: http://localhost:8081"
#  else
#    echo "MongoDB está desactivado (${ENABLE_MONGODB})"
  fi

  # Iniciar MySQL si está habilitado
  if [ "${ENABLE_MYSQL}" = "true" ]; then
    docker-compose up -d mysql phpmyadmin
    echo "MySQL disponible en: localhost:3306"
    echo "phpMyAdmin disponible en: http://localhost:8082"
#  else
#    echo "MySQL está desactivado (${ENABLE_MYSQL})"
  fi

  # Iniciar PostgreSQL si está habilitado
  if [ "${ENABLE_POSTGRES}" = "true" ]; then
    docker-compose up -d postgres pgadmin
    echo "PostgreSQL disponible en: localhost:5432"
    echo "pgAdmin disponible en: http://localhost:8083"
#  else
#    echo "PostgreSQL está desactivado (${ENABLE_POSTGRES})"
  fi

  echo "Configuración de servicios completada"
else
  echo "Error: Docker o Docker Compose no están disponibles"
  exit 1
fi
