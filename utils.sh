#!/bin/bash

# Directorio donde está el docker-compose.yml
DEVCONTAINER_DIR="/workspaces/.devcontainer"

function start_mongodb() {
  echo "Iniciando MongoDB y Mongo Express..."

  # Detener otros servicios de bases de datos si están corriendo
  down_services

  # Iniciar servicios de MongoDB
  docker-compose -f ${DEVCONTAINER_DIR}/docker-compose.yml up -d db mongo_express

cd "$DEVCONTAINER_DIR"
  # Cargar variables de entorno
  if [ -f ".env" ]; then
    . ./.env
  #  echo "Variables de entorno cargadas desde $(pwd)/.env"
  else
    echo "Advertencia: No se encontró el archivo .env"
  fi

  echo "MongoDB está disponible en localhost:27017"
  echo "Mongo Express está disponible en http://localhost:8081"
#  echo "Credenciales Mongo Express: ${MONGO_INITDB_ROOT_USERNAME} / ${MONGO_INITDB_ROOT_PASSWORD}"
}

function stop_mongodb() {
  echo "Deteniendo MongoDB y Mongo Express..."
  down_services
  echo "Servicios de MongoDB detenidos"
}

function start_mysql() {
  echo "Iniciando MySQL y phpMyAdmin..."

  # Detener otros servicios de bases de datos si están corriendo
  down_services

  # Iniciar servicios de MySQL
  docker-compose -f ${DEVCONTAINER_DIR}/docker-compose.yml up -d mysql phpmyadmin

  cd "$DEVCONTAINER_DIR"
  # Cargar variables de entorno
  if [ -f ".env" ]; then
    . ./.env
  #  echo "Variables de entorno cargadas desde $(pwd)/.env"
  else
    echo "Advertencia: No se encontró el archivo .env"
  fi

  echo "MySQL está disponible en localhost:3306"
  echo "phpMyAdmin está disponible en http://localhost:8082"
  echo "Credenciales phpMyAdmin: ${MYSQL_USER} / ${MYSQL_PASSWORD}"
}

function stop_mysql() {
  echo "Deteniendo MySQL y phpMyAdmin..."
  down_services
  echo "Servicios de MySQL detenidos"
}

function start_postgres() {
  echo "Iniciando PostgreSQL y pgAdmin..."

  # Detener otros servicios de bases de datos si están corriendo
  down_services

  # Iniciar servicios de PostgreSQL
  docker-compose -f ${DEVCONTAINER_DIR}/docker-compose.yml up -d postgres pgadmin
  cd "$DEVCONTAINER_DIR"
  # Cargar variables de entorno
  if [ -f ".env" ]; then
    . ./.env
  #  echo "Variables de entorno cargadas desde $(pwd)/.env"
  else
    echo "Advertencia: No se encontró el archivo .env"
  fi
  echo "PostgreSQL está disponible en localhost:5432"
  echo "pgAdmin está disponible en http://localhost:8083"
  echo "Credenciales pgAdmin: ${PG_ADMIN_EMAIL} / ${PG_ADMIN_PASSWORD}"
}

function stop_postgres() {
  echo "Deteniendo PostgreSQL y pgAdmin..."
  down_services
  echo "Servicios de PostgreSQL detenidos"
}

function down_services() {
  # Detener solo los servicios de bases de datos y sus herramientas de administración
  if docker-compose -f ${DEVCONTAINER_DIR}/docker-compose.yml ps --services | grep -q "db"; then
    docker-compose -f ${DEVCONTAINER_DIR}/docker-compose.yml stop db mongo_express
  fi

  if docker-compose -f ${DEVCONTAINER_DIR}/docker-compose.yml ps --services | grep -q "mysql"; then
    docker-compose -f ${DEVCONTAINER_DIR}/docker-compose.yml stop mysql phpmyadmin
  fi

  if docker-compose -f ${DEVCONTAINER_DIR}/docker-compose.yml ps --services | grep -q "postgres"; then
    docker-compose -f ${DEVCONTAINER_DIR}/docker-compose.yml stop postgres pgadmin
  fi
}

# Solo ejecutar el case si se llama como script, no cuando se carga con source
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  case "$1" in
    start-mongodb)
      start_mongodb
      ;;
    stop-mongodb)
      stop_mongodb
      ;;
    start-mysql)
      start_mysql
      ;;
    stop-mysql)
      stop_mysql
      ;;
    start-postgres)
      start_postgres
      ;;
    stop-postgres)
      stop_postgres
      ;;
    *)
      echo "Uso: $0 {start-mongodb|stop-mongodb|start-mysql|stop-mysql|start-postgres|stop-postgres}"
      exit 1
      ;;
  esac
  exit 0
fi
