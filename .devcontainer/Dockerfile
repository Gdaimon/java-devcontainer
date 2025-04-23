# Primera etapa: Builder base
FROM maven:3.9.6-eclipse-temurin-21 AS builder
# Nota: usamos valores fijos en lugar de variables para el FROM inicial
WORKDIR /build

# Segunda etapa: WildFly base
FROM mcr.microsoft.com/devcontainers/base:ubuntu AS wildfly-base
# Definimos los ARGs aquí para su uso en esta etapa
ARG JAVA_VERSION
ARG WILDFLY_VERSION

# Instalación de Java
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends openjdk-${JAVA_VERSION}-jdk curl unzip rsync \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Instalación de WildFly
RUN curl -fsSL https://github.com/wildfly/wildfly/releases/download/${WILDFLY_VERSION}/wildfly-${WILDFLY_VERSION}.tar.gz | tar -xzC /opt \
    && ln -s /opt/wildfly-${WILDFLY_VERSION} /opt/wildfly \
    && mkdir -p /opt/wildfly/standalone/deployments

# Configuración de permisos y ajustes
RUN chmod -R 775 /opt/wildfly/standalone/configuration/ \
    && chmod -R 775 /opt/wildfly/standalone/deployments/ \
    && chmod -R 775 /opt/wildfly/bin/*.sh \
    && sed -i 's/<inet-address value="${jboss.bind.address.management:127.0.0.1}"\/>/<inet-address value="${jboss.bind.address.management:0.0.0.0}"\/>/g' /opt/wildfly/standalone/configuration/standalone.xml \
    && echo 'JAVA_OPTS="$JAVA_OPTS -agentlib:jdwp=transport=dt_socket,address=0.0.0.0:8787,server=y,suspend=n"' >> /opt/wildfly/bin/standalone.conf

# Tercera etapa: Entorno final de desarrollo
FROM wildfly-base AS devenv
ARG JAVA_VERSION
ARG MAVEN_VERSION
ARG WILDFLY_ADMIN_USER

# Copiar los scripts de inicialización
COPY scripts/entrypoint.sh /usr/local/bin/entrypoint.sh
COPY init-services.sh /usr/local/bin/init-services.sh
COPY utils.sh /usr/local/bin/utils.sh

# Instalación de Maven
RUN curl -fsSL https://archive.apache.org/dist/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz | tar -xzC /opt \
    && ln -s /opt/apache-maven-${MAVEN_VERSION}/bin/mvn /usr/local/bin/mvn

# Creación de scripts de utilidad
RUN echo '#!/bin/bash\n/opt/wildfly/bin/standalone.sh -b 0.0.0.0 -bmanagement 0.0.0.0 "$@"' > /usr/local/bin/start-wildfly \
    && chmod +x /usr/local/bin/start-wildfly \
    && echo '#!/bin/bash\n/opt/wildfly/bin/standalone.sh -b 0.0.0.0 -bmanagement 0.0.0.0 --debug "$@"' > /usr/local/bin/debug-wildfly \
    && chmod +x /usr/local/bin/debug-wildfly

# Instalación de Docker
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends docker.io git \
    && apt-get clean && rm -rf /var/lib/apt/lists/* \
    && curl -L "https://github.com/docker/compose/releases/download/v2.24.6/docker-compose-linux-$(uname -m)" -o /usr/local/bin/docker-compose \
    && chmod +x /usr/local/bin/docker-compose \
    && mkdir -p /usr/local/lib/docker/cli-plugins \
    && ln -sf /usr/local/bin/docker-compose /usr/local/lib/docker/cli-plugins/docker-compose

# Dar permisos de ejecución a los scripts
RUN chmod +x /usr/local/bin/entrypoint.sh \
    && chmod +x /usr/local/bin/init-services.sh \
    && chmod +x /usr/local/bin/utils.sh \
    && mkdir -p /workspaces/.devcontainer \
    && ln -sf /usr/local/bin/utils.sh /workspaces/.devcontainer/utils.sh \
    && chown -R vscode:vscode /opt/wildfly-${WILDFLY_VERSION} /opt/wildfly /workspaces \
    && echo 'source /usr/local/bin/utils.sh' >> /home/vscode/.bashrc_custom \
    && echo 'if [ -f ~/.bashrc_custom ]; then source ~/.bashrc_custom; fi' >> /home/vscode/.bashrc

# Variables de entorno
ENV JAVA_HOME=/usr/lib/jvm/java-${JAVA_VERSION}-openjdk-amd64 \
    WILDFLY_HOME=/opt/wildfly \
    PATH=$PATH:/usr/lib/jvm/java-${JAVA_VERSION}-openjdk-amd64/bin:/opt/wildfly/bin

# Cambiar al usuario vscode para el ambiente de desarrollo
USER vscode
WORKDIR /workspaces

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["sleep", "infinity"]
