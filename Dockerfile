FROM node:12-buster-slim

ARG USERNAME=node
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN set -eux \
  ; sed -i 's/\(.*\)\(security\|deb\).debian.org\(.*\)main/\1ftp2.cn.debian.org\3main contrib non-free/g' /etc/apt/sources.list \
  ; apt-key adv --keyserver hkp://pool.sks-keyservers.net --recv-keys 023EDB0B \
  ; echo deb https://dl.bintray.com/gauge/gauge-deb stable main | tee -a /etc/apt/sources.list \
  ; apt-get update \
  ; apt-get upgrade -y \
  ; DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
      gauge zsh git sqlite3 iproute2 chromium-driver \
  ; apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/*

ENV CHROME_DEVEL_SANDBOX=/usr/bin/chromium
ENV TAIKO_BROWSER_PATH=${CHROME_DEVEL_SANDBOX}
ENV TAIKO_SKIP_CHROMIUM_DOWNLOAD=true


ARG js_runner_url=https://github.com/getgauge/gauge-js/releases/download/v2.3.6/gauge-js-offline-2.3.6.zip
ARG html_report_url=https://github.com/getgauge/html-report/releases/download/v4.0.8/html-report-4.0.8-linux.x86_64.zip
ARG json_report_url=https://github.com/getgauge-contrib/json-report/releases/download/v0.3.2/json-report-0.3.2-linux.x86_64.zip
#ARG spectacle_report_url=https://github.com/getgauge/spectacle/releases/download/v0.1.3/spectacle-0.1.3-linux.x86_64.zip

WORKDIR /app
RUN set -eux \
  ; chown $USER_UID:$USER_GID /app \
  ; chmod 4755 ${CHROME_DEVEL_SANDBOX}
USER $USERNAME

RUN set -eux \
  ; gauge telemetry off \
  ; mkdir tmp \
  ; cd tmp \
  ; wget -q ${js_runner_url} \
  ; wget -q ${html_report_url} \
  ; wget -q ${json_report_url} \
  #; wget -q ${spectacle_report_url} \
  ; gauge install js -f gauge-js-*.zip \
  ; gauge install html-report -f html-report-*.zip \
  ; gauge install json-report -f json-report-*.zip \
  #; gauge install spectacle-report -f spectacle-*.zip \
  ; cd .. \
  ; rm -rf tmp \
  ; gauge init js \
  ; gauge run


