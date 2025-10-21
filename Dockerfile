
# Verwende die gleiche Basisversion (oder aktualisiere zu 8.15.5/9.1.5)
FROM docker.elastic.co/elasticsearch/elasticsearch:7.16.1@sha256:1000eae211ce9e3fcd1850928eea4ee45a0a5173154df954f7b4c7a093b849f8

# Wechsle zu root, um Pakete zu installieren und Konfigurationen zu ändern
USER root

# Installiere openssh-server und bash
RUN apt-get update && \
    apt-get install -y openssh-server bash && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Erstelle SSH-Verzeichnis für den Elasticsearch-Benutzer (1000)
RUN mkdir -p /home/elasticsearch/.ssh && \
    chown 1000:0 /home/elasticsearch/.ssh && \
    chmod 0700 /home/elasticsearch/.ssh

# Kopiere öffentlichen SSH-Schlüssel (optional, falls du ihn im Repo hast)
# Alternativ: Render fügt den Schlüssel automatisch hinzu, wenn im Dashboard konfiguriert
# COPY --chown=1000:0 config/authorized_keys /home/elasticsearch/.ssh/authorized_keys
# RUN chmod 0600 /home/elasticsearch/.ssh/authorized_keys

# Setze Shell für Benutzer 1000 auf /bin/bash
RUN usermod -s /bin/bash elasticsearch

# Kopiere die Elasticsearch-Konfig (wie im Original)
COPY --chown=1000:0 config/elasticsearch.yml /usr/share/elasticsearch/config/elasticsearch.yml

# Berechtigungen für Keystore (wie im Original)
RUN chmod g+ws /usr/share/elasticsearch/config

# Erstelle SSH-Host-Schlüssel
RUN ssh-keygen -A

# Starte SSH-Dienst und Elasticsearch im selben Container
CMD service ssh start && /usr/local/bin/docker-entrypoint.sh

# Wechsle zurück zum Elasticsearch-Benutzer
USER 1000:0
