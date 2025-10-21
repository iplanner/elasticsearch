# Das offizielle Elasticsearch Docker Image
FROM docker.elastic.co/elasticsearch/elasticsearch:7.16.1

# ----------------------------------------------------
# VORBEREITUNG ALS ROOT
# ----------------------------------------------------
USER root

# JVM-Speicher (WICHTIG gegen Abstürze)
ENV ES_JAVA_OPTS="-Xms512m -Xmx512m"

# 1. Installiere openssh-server und net-tools
# `net-tools` für zukünftige Shell-Diagnosen
RUN apt-get update && apt-get install -y openssh-server net-tools \
    && rm -rf /var/lib/apt/lists/*

# 2. Erzeuge Host-Schlüssel und konfiguriere SSH
RUN ssh-keygen -A \
    && echo "PermitRootLogin yes" >> /etc/ssh/sshd_config

# 3. Erstelle das .ssh Verzeichnis für den Elastic-Benutzer
RUN mkdir -p /usr/share/elasticsearch/.ssh \
    && chown 1000:0 /usr/share/elasticsearch/.ssh \
    && chmod 0700 /usr/share/elasticsearch/.ssh

# ----------------------------------------------------
# EIGENE KONFIGURATION UND RÜCKKEHR ZUM NORMALEN START
# ----------------------------------------------------

# Kopiere die Elasticsearch-Konfiguration
COPY --chown=1000:0 config/elasticsearch.yml /usr/share/elasticsearch/config/elasticsearch.yml
RUN chmod g+ws /usr/share/elasticsearch/config

# WICHTIG: Zurück zum Nicht-Root-Benutzer wechseln.
# Die ENTRYPOINT und CMD des Basis-Images bleiben erhalten.
USER 1000:0