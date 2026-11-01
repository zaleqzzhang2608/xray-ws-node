#!/bin/sh
# VLESS inbound from env. TRANSPORT: ws (default) | xhttp-packet | xhttp-one
set -eu
UUID="${UUID:-00000000-0000-0000-0000-000000000000}"
PORT="${PORT:-8080}"
WSPATH="${WSPATH:-/tk-rail}"
TRANSPORT="${TRANSPORT:-ws}"
case "$WSPATH" in
  /*) ;;
  *) WSPATH="/$WSPATH" ;;
esac
if [ "$UUID" = "00000000-0000-0000-0000-000000000000" ] || [ "$UUID" = "CHANGE_ME" ]; then
  echo "WARNING: set a real UUID env before handing out client links" >&2
fi
CFG=/tmp/xray-config.json
case "$TRANSPORT" in
  xhttp-packet|xhttp-one)
    MODE="packet-up"; [ "$TRANSPORT" = "xhttp-one" ] && MODE="stream-one"
    STREAM="\"network\": \"xhttp\", \"xhttpSettings\": { \"path\": \"${WSPATH}\", \"mode\": \"${MODE}\" }"
    ;;
  *)
    STREAM="\"network\": \"ws\", \"security\": \"none\", \"wsSettings\": { \"path\": \"${WSPATH}\" }"
    ;;
esac
cat > "$CFG" <<JSON
{
  "log": { "loglevel": "warning" },
  "inbounds": [
    {
      "listen": "0.0.0.0",
      "port": ${PORT},
      "protocol": "vless",
      "settings": {
        "clients": [ { "id": "${UUID}" } ],
        "decryption": "none"
      },
      "streamSettings": { ${STREAM} },
      "sniffing": { "enabled": true, "destOverride": ["http", "tls", "quic"] }
    }
  ],
  "outbounds": [ { "protocol": "freedom" } ]
}
JSON
echo "starting xray on port ${PORT} path ${WSPATH} transport ${TRANSPORT}"
exec /usr/local/bin/xray run -c "$CFG"
