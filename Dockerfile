FROM node:12-buster-slim

ARG USERNAME=node
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN set -eux \
  ; apt-get update \
  ; apt-get upgrade -y \
  ; DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
      procps zsh gnupg git iproute2 curl \
  ; apt-key adv --keyserver hkp://pool.sks-keyservers.net --recv-keys 023EDB0B \
  ; echo deb https://dl.bintray.com/gauge/gauge-deb stable main | tee -a /etc/apt/sources.list \
  ; apt-get update \
  ; DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
      gauge chromium-driver \
  ; apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/*

ENV TAIKO_BROWSER_PATH=/usr/bin/chromium
ENV TAIKO_SKIP_CHROMIUM_DOWNLOAD=true
ENV headless_chrome=true

WORKDIR /app
RUN set -eux \
  ; chown $USER_UID:$USER_GID /app
USER $USERNAME

RUN set -eux \
  ; gauge telemetry off \
  ; gauge init js \
  ; sed -i 's!\(: headless\)!\1, args: ['"\'--no-sandbox\'"']!' tests/step_implementation.js \
  ; gauge run
