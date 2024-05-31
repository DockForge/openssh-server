# syntax=docker/dockerfile:1

FROM dublok/base-linux:alpine

# set version label
ARG BUILD_DATE
ARG VERSION
ARG OPENSSH_RELEASE
LABEL build_version="DockForge version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="Dublok"
ARG TARGETPLATFORM=""
ARG ARCH=""
ARG Alpine_Version="v3.19"

RUN echo "Building for platform: ${TARGETPLATFORM}"
RUN echo "Architecture set to: ${ARCH}"

RUN \
  echo "**** install runtime packages ****" && \
  apk add --no-cache --upgrade \
    logrotate \
    nano \
    netcat-openbsd \
    sudo && \
  echo "**** install openssh-server ****" && \
  if [ -z ${OPENSSH_RELEASE+x} ]; then \
    OPENSSH_RELEASE=$(curl -sL "http://dl-cdn.alpinelinux.org/alpine/${Alpine_Version}/main/${ARCH}/APKINDEX.tar.gz" | tar -xz -C /tmp && \
    awk '/^P:openssh-server-pam$/,/V:/' /tmp/APKINDEX | sed -n 2p | sed 's/^V://'); \
  fi && \
  apk add --no-cache \
    openssh-client==${OPENSSH_RELEASE} \
    openssh-server-pam==${OPENSSH_RELEASE} \
    openssh-sftp-server==${OPENSSH_RELEASE} && \
  echo "**** setup openssh environment ****" && \
  sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config && \
  usermod --shell /bin/bash abc && \
  rm -rf \
    /tmp/* \
    $HOME/.cache

# add local files
COPY /root /

EXPOSE 2222

VOLUME /config