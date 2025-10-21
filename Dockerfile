# Elasticsearch 7.16.1
FROM docker.elastic.co/elasticsearch/elasticsearch:7.16.1

# ---- Root werden, um Pakete/SSH zu installieren
USER root

# (A) SSH-Server installieren (RHEL/CentOS-basiert) ODER (Debian/Ubuntu-Fallback)
# ES 7.x Images sind i. d. R. yum-basiert; wir bauen aber einen Fallback ein.
RUN (yum -y update && \
     yum -y install openssh-server openssh-clients which procps-ng && \
     yum clean all) || \
    (apt-get update && \
     DEBIAN_FRONTEND=noninteractive apt-get install -y openssh-server openssh-client procps && \
     rm -rf /var/lib/apt/lists/* && \
     mkdir -p /run/sshd)

# (B) Host-Keys erzeugen (falls nicht vorhanden)
RUN ssh-keygen -A

# (C) SSH härten: Root-Login & Passwörter aus
RUN sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config && \
    sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config && \
    sed -i 's@^#\?AuthorizedKeysFile.*@AuthorizedKeysFile .ssh/authorized_keys@g' /etc/ssh/sshd_config

# (D) Dem Elasticsearch-User eine Shell geben und HOME umziehen (NICHT auf Persistent Disk mounten!)
#     Standard-User im Image: "elasticsearch" (UID 1000, GID 0)
RUN usermod -s /bin/bash elasticsearch && \
    usermod -d /home/elasticsearch -m elasticsearch

# (E) ~/.ssh anlegen (korrekte Rechte) - KEINE Keys hier rein backen; Render injiziert zur Laufzeit.
RUN install -d -o 1000 -g 0 -m 700 /home/elasticsearch/.ssh

# (F) Deine ES-Konfiguration wie gehabt kopieren
COPY --chown=1000:0 config/elasticsearch.yml /usr/share/elasticsearch/config/elasticsearch.yml

# (G) Workaround aus deinem Dockerfile beibehalten
RUN chmod g+ws /usr/share/elasticsearch/config

# (H) Startskript kopieren (startet sshd + Elasticsearch)
COPY start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh

# (I) Ports freigeben (22 für SSH, 9200/9300 für ES)
EXPOSE 22 9200 9300

# WICHTIG: Wir lassen USER root, damit sshd als root gestartet werden kann.
# Elasticsearch selbst starten wir im Skript als User elasticsearch.
USER root

# Original-ENTRYPOINT wird vom ES-Image gesetzt; wir überschreiben ihn bewusst:
ENTRYPOINT ["/usr/local/bin/start.sh"]