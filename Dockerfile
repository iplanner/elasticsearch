# The official Elasticsearch Docker image
FROM docker.elastic.co/elasticsearch/elasticsearch:7.16.1

# ----------------------------------------------------
# NEUE SCHRITTE FÜR SSH
# ----------------------------------------------------

# 1. Temporär zu 'root' wechseln, da das Basis-Image keinen SSH-Server hat
USER root

# 2. Update der Paketliste und Installation von openssh-server
RUN apt-get update && apt-get install -y openssh-server \
    && rm -rf /var/lib/apt/lists/*

# 3. Den SSH-Server vorbereiten
# Der Home-Ordner des Benutzers 'elasticsearch' (UID 1000) ist in der Regel /usr/share/elasticsearch.
RUN mkdir -p /usr/share/elasticsearch/.ssh \
    && chown 1000:0 /usr/share/elasticsearch/.ssh \
    && chmod 0700 /usr/share/elasticsearch/.ssh

# ----------------------------------------------------
# BESTEHENDE SCHRITTE
# ----------------------------------------------------

# Copy our config file over
COPY --chown=1000:0 config/elasticsearch.yml /usr/share/elasticsearch/config/elasticsearch.yml

# Allow Elasticsearch to create `elasticsearch.keystore`
RUN chmod g+ws /usr/share/elasticsearch/config

# 4. Zurück zum Nicht-Root-Benutzer wechseln (Wichtig für Sicherheit!)
USER 1000:0