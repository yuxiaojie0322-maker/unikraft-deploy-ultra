#!/usr/bin/env bash
set -euo pipefail

UUID="${1:?UUID is required}"
ARGO_DOMAIN="${2:-}"
ARGO_TOKEN="${3:-}"
NEZHA_SERVER="${4:-}"
NEZHA_KEY="${5:-}"

if [[ -n "$ARGO_DOMAIN" || -n "$ARGO_TOKEN" ]]; then
  if [[ -z "$ARGO_DOMAIN" || -z "$ARGO_TOKEN" ]]; then
    echo "ARGO_DOMAIN and ARGO_TOKEN must both be set or both omitted" >&2
    exit 1
  fi
  cp templates/config.direct-tunnel.json templates/config.json
else
  cp templates/config.direct.json templates/config.json
fi

python3 - "$UUID" "$ARGO_TOKEN" <<'PY'
import json
import sys
from pathlib import Path

uuid, argo_token = sys.argv[1], sys.argv[2]
path = Path("templates/config.json")
data = json.loads(path.read_text(encoding="utf-8"))

def replace(obj):
    if isinstance(obj, dict):
        return {k: replace(v) for k, v in obj.items()}
    if isinstance(obj, list):
        return [replace(v) for v in obj]
    if isinstance(obj, str):
        if obj == "YOUR_UUID":
            return uuid
        if obj == "YOUR_TOKEN" and argo_token:
            return argo_token
        return obj
    return obj

path.write_text(json.dumps(replace(data), indent=2) + "\n", encoding="utf-8")
PY

if [[ -n "$NEZHA_SERVER" && -n "$NEZHA_KEY" ]]; then
  PORT="${NEZHA_SERVER##*:}"
  NEZHA_TLS="false"
  if [[ "$PORT" == "443" || "$PORT" == "8443" || "$PORT" == "2096" || "$PORT" == "2087" || "$PORT" == "2083" || "$PORT" == "2053" ]]; then
    NEZHA_TLS="true"
  fi
  cat > templates/nezha.yaml <<EOF
client_secret: ${NEZHA_KEY}
debug: false
disable_auto_update: true
disable_command_execute: false
disable_force_update: true
disable_nat: false
disable_send_query: false
gpu: false
insecure_tls: true
ip_report_period: 1800
report_delay: 4
server: ${NEZHA_SERVER}
skip_connection_count: true
skip_procs_count: true
temperature: false
tls: ${NEZHA_TLS}
use_gitee_to_upgrade: false
use_ipv6_country_code: false
uuid: ${UUID}
EOF
  echo "Prepared templates/nezha.yaml for ${NEZHA_SERVER} (uuid=${UUID})"
else
  : > templates/nezha.yaml
fi

echo "Prepared templates/config.json"
