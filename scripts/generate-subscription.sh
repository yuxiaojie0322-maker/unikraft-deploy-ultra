#!/usr/bin/env bash
set -euo pipefail

UUID="${1:?UUID is required}"
FQDN="${2:?FQDN is required}"
ARGO_DOMAIN="${3:-}"
NODE_PREFIX="${4:-Unikraft}"

if [[ -n "$ARGO_DOMAIN" ]]; then
  TEMPLATE="templates/sub.direct-tunnel.txt"
else
  TEMPLATE="templates/sub.direct.txt"
fi

python3 - "$UUID" "$FQDN" "$ARGO_DOMAIN" "$NODE_PREFIX" "$TEMPLATE" <<'PY'
import sys
import urllib.parse
from pathlib import Path

uuid, fqdn, argo_domain, node_prefix, template = sys.argv[1:6]
text = Path(template).read_text(encoding="utf-8")
text = text.replace("YOUR_UUID", uuid)
text = text.replace("xxx.sin.unikraft.app", fqdn)
text = text.replace("NODE_PREFIX", node_prefix)
if argo_domain:
    text = text.replace("ARGO_DOMAIN", argo_domain)
print(text, end="")
PY

