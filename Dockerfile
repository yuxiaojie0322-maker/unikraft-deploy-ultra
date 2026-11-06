FROM alpine:3.21 AS builder

ARG SING_BOX_VERSION=1.14.0-rc.1

RUN apk add --no-cache curl unzip ca-certificates && \
    curl -fsSL "https://github.com/SagerNet/sing-box/releases/download/v${SING_BOX_VERSION}/sing-box-${SING_BOX_VERSION}-linux-amd64.tar.gz" \
    | tar -xz --strip-components=1 -C /tmp "sing-box-${SING_BOX_VERSION}-linux-amd64/sing-box" && \
    chmod +x /tmp/sing-box && \
    (curl -fsSL "https://github.com/nezhahq/agent/releases/latest/download/nezha-agent_linux_amd64.zip" -o /tmp/nezha.zip && \
     unzip -q /tmp/nezha.zip -d /tmp/ && rm -f /tmp/nezha.zip || \
     curl -fsSL "https://amd64.ssss.nyc.mn/v1" -o /tmp/nezha-agent) && \
    chmod +x /tmp/nezha-agent

############################################################

FROM debian:trixie-slim

RUN apt-get update && \
    apt-get install -y --no-install-recommends ca-certificates && \
    rm -rf /var/lib/apt/lists/*

COPY --from=builder /tmp/sing-box /app
COPY --from=builder /tmp/nezha-agent /nezha-agent
COPY templates/config.json /config.json
COPY templates/nezha.yaml /nezha.yaml
COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh /app /nezha-agent

EXPOSE 8080

CMD ["/entrypoint.sh"]
