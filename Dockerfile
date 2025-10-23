# Offizielles Elasticsearch-Image
FROM docker.elastic.co/elasticsearch/elasticsearch:7.16.1

# Als root nur Dateirechte anpassen – kein SSH, kein eigener Entry
USER root

# JVM-Heap konservativ (an Render-Instanz anpassen)
ENV ES_JAVA_OPTS="-Xms512m -Xmx512m"

# (Optional) Verzeichnisrechte fixen, falls Render-Disk gemountet wird
RUN mkdir -p /usr/share/elasticsearch/data \
 && chown -R 1000:0 /usr/share/elasticsearch

# Eigene ES-Konfiguration kopieren
COPY --chown=1000:0 config/elasticsearch.yml /usr/share/elasticsearch/config/elasticsearch.yml

# Zurück zu elasticsearch-User (1000)
USER 1000:0

# Kein ENTRYPOINT/CMD nötig – das Basis-Image startet ES korrekt