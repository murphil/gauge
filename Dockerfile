FROM ubuntu:focal

ARG USERNAME=gauge
ARG USER_UID=1000
ARG USER_GID=$USER_UID

ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
ENV TIMEZONE=Asia/Shanghai

ENV NODE_HOME=/opt/node NODE_VERSION=12.16.3
ENV PATH=${NODE_HOME}/bin:$PATH

RUN set -eux \
  ; apt-get update \
  ; apt-get upgrade -y \
  ; DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
      locales tzdata ca-certificates xz-utils \
      procps zsh gnupg git iproute2 curl \
  ; ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime \
  ; echo "$TIMEZONE" > /etc/timezone \
  ; sed -i /etc/locale.gen \
		-e 's/# \(en_US.UTF-8 UTF-8\)/\1/' \
		-e 's/# \(zh_CN.UTF-8 UTF-8\)/\1/' \
	; locale-gen \
  \
  ; mkdir -p ${NODE_HOME} \
  ; curl https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-x64.tar.xz \
    | tar xJ -C ${NODE_HOME} --strip-components 1 \
  ; chown -R root:root ${NODE_HOME} \
  \
  ; apt-key adv --keyserver hkp://pool.sks-keyservers.net --recv-keys 023EDB0B \
  ; echo deb https://dl.bintray.com/gauge/gauge-deb stable main | tee -a /etc/apt/sources.list \
  ; apt-get update \
  ; DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
      gauge chromium-browser \
  ; apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/*

ENV TAIKO_BROWSER_PATH=/usr/bin/chromium
ENV TAIKO_SKIP_CHROMIUM_DOWNLOAD=true
ENV headless_chrome=true

WORKDIR /app
RUN set -eux \
  ; chown $USER_UID:$USER_GID /app
USER $USERNAME

RUN set -x \
  ; gauge telemetry off \
  ; gauge init js \
  ; sed -i 's!\(: headless\)!\1, args: ['"\'--no-sandbox\'"']!' tests/step_implementation.js \
  ; gauge run
