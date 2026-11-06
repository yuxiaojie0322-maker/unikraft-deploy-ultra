#!/bin/sh
set -e

if [ -s /nezha.yaml ]; then
  /nezha-agent -c /nezha.yaml >/dev/null 2>&1 &
fi

exec /app run -c /config.json
