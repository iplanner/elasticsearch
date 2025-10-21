#!/bin/bash
set -e

echo "Starting SSH service in the background..."
# Starte den SSH-Daemon. Er sollte im Hintergrund laufen, damit der Hauptprozess 
# (Elasticsearch) im Vordergrund laufen kann.
/usr/sbin/sshd

echo "Starting Elasticsearch service..."
# Führt den ursprünglichen Elasticsearch-Entrypoint aus,
# welcher wiederum die CMD (eswrapper) aufruft.
# Der "$@" Teil übergibt alle Argumente (wie die CMD) an das Skript.
exec /usr/local/bin/docker-entrypoint.sh "$@"