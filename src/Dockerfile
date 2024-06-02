# syntax=docker/dockerfile:1

FROM dublok/base-linux:alpine-v1

# set version label
ARG BUILD_DATE
ARG VERSION
ARG OPENSSH_RELEASE
LABEL build_version="Version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="Dublok"
ARG TARGETPLATFORM=""
ARG ARCH=""

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
    OPENSSH_RELEASE=$(curl -sL "http://dl-cdn.alpinelinux.org/alpine/v3.20/main/${ARCH}/APKINDEX.tar.gz" | tar -xz -C /tmp && \
    awk '/^P:openssh-server-pam$/,/V:/' /tmp/APKINDEX | sed -n 2p | sed 's/^V://'); \
  fi && \
  apk add --no-cache \
    openssh-client==${OPENSSH_RELEASE} \
    openssh-server-pam==${OPENSSH_RELEASE} \
    openssh-sftp-server==${OPENSSH_RELEASE} && \
  printf "Version: ${VERSION}\nBuild-date: ${BUILD_DATE}" > /build_version && \
  echo "**** setup openssh environment ****" && \
  sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config && \
  usermod --shell /bin/bash abc && \
  rm -rf \
    /tmp/* \
    $HOME/.cache

# add local files
COPY /root /

# Ensure correct permissions for all scripts in s6-overlay directory
RUN find /etc/s6-overlay/ -type f -exec chmod 744 {} \; && \
    chmod 744 /docker-mods

EXPOSE 2222

VOLUME /config
