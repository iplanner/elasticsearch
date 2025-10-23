# Offizielles ES-Image
FROM docker.elastic.co/elasticsearch/elasticsearch:7.16.1

# -----------------------------------------
# Root-Teil: SSH + Tools + User anpassen
# -----------------------------------------
USER root

# Speicher (an Instanz anpassen)
ENV ES_JAVA_OPTS="-Xms512m -Xmx512m"

# SSH-Server & Tools
RUN apt-get update \
 && apt-get install -y --no-install-recommends openssh-server net-tools ca-certificates \
 && rm -rf /var/lib/apt/lists/*

# sshd Runtime-Verzeichnis
RUN mkdir -p /var/run/sshd

# WICHTIG für Render-SSH: der laufende User MUSS eine Shell haben
# (im ES-Image ist der User "elasticsearch" mit UID 1000)
RUN usermod -s /bin/bash elasticsearch

# SSH-Verzeichnis für "elasticsearch"
RUN mkdir -p /usr/share/elasticsearch/.ssh \
 && chown 1000:0 /usr/share/elasticsearch/.ssh \
 && chmod 0700 /usr/share/elasticsearch/.ssh

# Root nicht als Login verwenden (Render authentifiziert am Edge)
# -> Root Login NICHT zusätzlich öffnen
RUN sed -i 's/^#\?PermitRootLogin .*/PermitRootLogin no/' /etc/ssh/sshd_config \
 && echo "PasswordAuthentication no" >> /etc/ssh/sshd_config \
 && echo "UsePAM no" >> /etc/ssh/sshd_config

# Elasticsearch-Konfiguration kopieren
COPY --chown=1000:0 config/elasticsearch.yml /usr/share/elasticsearch/config/elasticsearch.yml
RUN chmod g+ws /usr/share/elasticsearch/config

# WICHTIG: nicht-root zurück
USER 1000:0

# Keine Änderung an ENTRYPOINT/CMD -> Render startet ES wie gewohnt.
# sshd NICHT selbst starten (Render managed den SSH-Zugang).