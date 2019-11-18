FROM node:12-buster-slim

ARG USERNAME=node
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN set -eux \
  ; sed -i 's/\(.*\)\(security\|deb\).debian.org\(.*\)main/\1ftp.cn.debian.org\3main contrib non-free/g' /etc/apt/sources.list \
  ; apt-key adv --keyserver hkp://pool.sks-keyservers.net --recv-keys 023EDB0B \
  ; echo deb https://dl.bintray.com/gauge/gauge-deb stable main | tee -a /etc/apt/sources.list \
  ; apt-get update \
  ; apt-get upgrade -y \
  ; DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
      gauge chromium-driver zsh git sqlite3 \
  ; apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/*

ENV TAIKO_BROWSER_PATH=/usr/bin/chromium
USER $USERNAME
WORKDIR /app

RUN set -eux \
  ; gauge telemetry off \
  ; gauge install js \
  ; gauge install html-report
