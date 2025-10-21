# The official Elasticsearch Docker image
FROM docker.elastic.co/elasticsearch/elasticsearch:7.16.1@sha256:1000eae211ce9e3fcd1850928eea4ee45a0a5173154df954f7b4c7a093b849f9

# ----------------------------------------------------
# NEUE SCHRITTE FÜR SSH (WICHTIG!)
# ----------------------------------------------------

# 1. Temporär zu 'root' wechseln, da das Basis-Image keinen SSH-Server hat
USER root

# 2. Update der Paketliste und Installation von openssh-server
# Das Basis-Image von Elastic Search basiert auf einem minimalen Debian (Buster/Bullseye).
# Die `apt` Befehle sollten daher funktionieren.
RUN apt-get update && apt-get install -y openssh-server \
    && rm -rf /var/lib/apt/lists/*

# 3. Den SSH-Server vorbereiten
# Das offizielle Elastic Search Image verwendet den Benutzer 'elasticsearch' (UID 1000).
# Der Home-Ordner des Benutzers 'elasticsearch' ist in der Regel `/usr/share/elasticsearch`.
# Wir erstellen das ~/.ssh Verzeichnis dort und setzen die Berechtigungen (chmod 0700).
# HINWEIS: Prüfen Sie ggf. in der Shell, wo das Home-Verzeichnis liegt, falls es nicht `/usr/share/elasticsearch` ist.
RUN mkdir -p /usr/share/elasticsearch/.ssh \
    && chown 1000:0 /usr/share/elasticsearch/.ssh \
    && chmod 0700 /usr/share/elasticsearch/.ssh

# ----------------------------------------------------
# BESTEHENDE SCHRITTE
# ----------------------------------------------------

# Copy our config file over
COPY --chown=1000:0 config/elasticsearch.yml /usr/share/elasticsearch/config/elasticsearch.yml

# Allow Elasticsearch to create `elasticsearch.keystore`
# to circumvent https://github.com/elastic/ansible-elasticsearch/issues/430
RUN chmod g+ws /usr/share/elasticsearch/config

# 4. Zurück zum Nicht-Root-Benutzer wechseln (Wichtig für Sicherheit!)
USER 1000:0 

# Optional: Render kann eventuell einen anderen SSH-Befehl ausführen, wenn er
# erkennt, dass SSH installiert ist. Falls es Probleme gibt, kann man
# den SSH-Port 22 freigeben, aber Render verwaltet die Port-Weiterleitung meist automatisch.
# EXPOSE 22

# WICHTIG: Die ursprüngliche ENTRYPOINT/CMD des Elastic Search Images muss erhalten bleiben,
# damit Elastic Search startet, ABER Render muss den SSH-Dienst starten können.
# Render erledigt das in der Regel, indem es in den Container `rservice` injectiert.