#!/bin/bash
set -e

# ENTFERNT: echo "Starting SSH service in the background..."
# ENTFERNT: /usr/sbin/sshd -D > /dev/null 2>&1 & 

echo "Starting Elasticsearch service..."
# Führt den ursprünglichen Elasticsearch-Entrypoint als Hauptprozess aus.
exec /usr/local/bin/docker-entrypoint.sh "$@"