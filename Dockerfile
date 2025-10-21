# Das offizielle Elasticsearch Docker Image (ohne SHA256 Digest)
FROM docker.elastic.co/elasticsearch/elasticsearch:7.16.1

# ----------------------------------------------------
# SCHRITTE FÜR SSH-UNTERSTÜTZUNG (Muss als 'root' ausgeführt werden)
# ----------------------------------------------------
USER root

ENV ES_JAVA_OPTS="-Xms512m -Xmx512m"

# 1. Installiere openssh-server und lösche Paketlisten
RUN apt-get update && apt-get install -y openssh-server \
    && rm -rf /var/lib/apt/lists/*

# 2. Erzeuge Host-Schlüssel (Wichtig für den SSH-Daemon)
RUN ssh-keygen -A

# 3. Erlaube Root-Login (Render verbindet sich oft als Root, um den Dienst zu injizieren)
# Optional, aber oft notwendig für Render
RUN echo "PermitRootLogin yes" >> /etc/ssh/sshd_config

# 4. Erstelle das .ssh Verzeichnis mit korrekten Berechtigungen für den Elasticsearch-Benutzer (UID 1000)
# Das Home-Verzeichnis des Elasticsearch-Benutzers ist standardmäßig /usr/share/elasticsearch
RUN mkdir -p /usr/share/elasticsearch/.ssh \
    && chown 1000:0 /usr/share/elasticsearch/.ssh \
    && chmod 0700 /usr/share/elasticsearch/.ssh

# ----------------------------------------------------
# EIGENE KONFIGURATION UND ENTRYPOINT
# ----------------------------------------------------

# 5. Kopiere unser Wrapper-Skript und mache es ausführbar
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Kopiere die Elasticsearch-Konfiguration (wie in Ihrem Original-Dockerfile)
COPY --chown=1000:0 config/elasticsearch.yml /usr/share/elasticsearch/config/elasticsearch.yml

# Erlaube Elasticsearch, `elasticsearch.keystore` zu erstellen (wie in Ihrem Original-Dockerfile)
RUN chmod g+ws /usr/share/elasticsearch/config

# 6. Wechsle zurück zum Nicht-Root-Benutzer (Sicherheitsbest Practice)
USER 1000:0

# 7. Setze das Wrapper-Skript als Haupt-Entrypoint des Containers
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

# 8. Behalte die ursprüngliche Elasticsearch CMD (wird an das Entrypoint-Skript übergeben)
CMD ["eswrapper"]