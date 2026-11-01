FROM alpine:3.20
RUN apk add --no-cache ca-certificates unzip wget \
 && wget -q https://github.com/XTLS/Xray-core/releases/download/v25.10.15/Xray-linux-64.zip -O /tmp/xray.zip \
 && echo "df22ad60c1251c9fb63d7f85b3677872edf61c6715eba64b06adbfec658f4938  /tmp/xray.zip" | sha256sum -c - \
 && unzip -q /tmp/xray.zip -d /tmp/xray \
 && install -m 0755 /tmp/xray/xray /usr/local/bin/xray \
 && rm -rf /tmp/xray /tmp/xray.zip
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
