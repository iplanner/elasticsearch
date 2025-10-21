#!/bin/bash
set -e

echo "Starting SSH service in the background..."
# Starte sshd mit '-D' (Debug/Foreground mode) und leite die Ausgabe um.
/usr/sbin/sshd -D > /dev/null 2>&1 & 
# WICHTIG: Die Umleitung kann helfen, dass SSH nicht in die Logs von ES schreibt,
# wenn Render die Log-Streams zusammenführt.

echo "Starting Elasticsearch service..."
exec /usr/local/bin/docker-entrypoint.sh "$@"