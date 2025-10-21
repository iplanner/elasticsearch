
# Verwende die gleiche Basisversion (oder aktualisiere zu 8.15.5/9.1.5)
FROM docker.elastic.co/elasticsearch/elasticsearch:7.16.1@sha256:1000eae211ce9e3fcd1850928eea4ee45a0a5173154df954f7b4c7a093b849f8

# Wechsle zu root für Installation und Konfiguration
USER root

# Installiere openssh-server und bash
RUN apt-get update && \
    apt-get install -y openssh-server bash && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Erstelle /run/sshd und setze korrekte Berechtigungen
RUN mkdir -p /run/sshd && \
    chmod 755 /run/sshd

# Erstelle /etc/ssh und generiere Host-Schlüssel
RUN mkdir -p /etc/ssh && \
    ssh-keygen -A && \
    chown -R root:root /etc/ssh && \
    chmod 600 /etc/ssh/ssh_host_*_key

# Erstelle SSH-Verzeichnis für den Benutzer elasticsearch (1000)
RUN mkdir -p /home/elasticsearch/.ssh && \
    chown 1000:0 /home/elasticsearch/.ssh && \
    chmod 0700 /home/elasticsearch/.ssh

# Setze Shell für Benutzer elasticsearch auf /bin/bash (wie von Render gefordert)
RUN usermod -s /bin/bash elasticsearch

# Kopiere Elasticsearch-Konfig
COPY --chown=1000:0 config/elasticsearch.yml /usr/share/elasticsearch/config/elasticsearch.yml

# Berechtigungen für Keystore
RUN chmod g+ws /usr/share/elasticsearch/config

# Erstelle ein Start-Skript
RUN echo '#!/bin/bash\n\
# Prüfe und erstelle SSH-Host-Schlüssel, falls nicht vorhanden\n\
if [ ! -f /etc/ssh/ssh_host_ed25519_key ]; then\n\
  ssh-keygen -A\n\
  chown root:root /etc/ssh/ssh_host_*_key\n\
  chmod 600 /etc/ssh/ssh_host_*_key\n\
fi\n\
# Starte SSH-Dienst\n\
/usr/sbin/sshd\n\
# Starte Elasticsearch als Benutzer elasticsearch\n\
exec gosu elasticsearch /usr/local/bin/docker-entrypoint.sh' > /start.sh && \
chmod +x /start.sh

# Wechsle zurück zum Nicht-Root-Benutzer (wie von Render gefordert)
USER elasticsearch

# Starte SSH und Elasticsearch
CMD ["/start.sh"]