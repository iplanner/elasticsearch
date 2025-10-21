# Das offizielle Elasticsearch Docker Image (ohne SHA256 Digest)
FROM docker.elastic.co/elasticsearch/elasticsearch:7.16.1

# ----------------------------------------------------
# VORBEREITUNG (Konfiguration und Sicherheits-Setup)
# ----------------------------------------------------
USER root

# JVM-Speicher (Behalten: Wichtig, um Abstürze zu vermeiden)
ENV ES_JAVA_OPTS="-Xms512m -Xmx512m"

# 1. Installiere openssh-server (Behalten: Notwendig für Render's SSH-Daemon)
# HINWEIS: Wir fügen hier `net-tools` hinzu, falls Sie weiterhin intern debuggen möchten.
RUN apt-get update && apt-get install -y openssh-server net-tools \
    && rm -rf /var/lib/apt/lists/*

# 2. Erzeuge Host-Schlüssel (Behalten: Render benötigt diese oft)
RUN ssh-keygen -A

# 3. Erlaube Root-Login (Behalten: Erleichtert Render's Setup)
RUN echo "PermitRootLogin yes" >> /etc/ssh/sshd_config

# 4. Erstelle das .ssh Verzeichnis für den Elastic-Benutzer (Behalten: Render braucht es, um den Schlüssel zu platzieren)
RUN mkdir -p /usr/share/elasticsearch/.ssh \
    && chown 1000:0 /usr/share/elasticsearch/.ssh \
    && chmod 0700 /usr/share/elasticsearch/.ssh

# Kopiere die Elasticsearch-Konfiguration
COPY --chown=1000:0 config/elasticsearch.yml /usr/share/elasticsearch/config/elasticsearch.yml
RUN chmod g+ws /usr/share/elasticsearch/config

# ----------------------------------------------------
# RÜCKKEHR ZUM ORIGINAL-START
# ----------------------------------------------------

# LÖSCHEN SIE DIE FOLGENDEN ZEILEN (5, 7, 8) aus Ihrem Originalversuch:
# ENTRYPOINT/CMD des Basis-Images wird automatisch verwendet.
# USER 1000:0 
# ENTRYPOINT ["/usr/local/bin/entrypoint.sh"] 
# CMD ["eswrapper"] 

# Nur den Benutzerwechsel behalten
USER 1000:0