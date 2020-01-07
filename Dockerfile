ARG buildId
FROM ubuntu:bionic
LABEL maintainer="AgileSyndro.me"

ARG opensslVersion=1.0.2u
ARG tiniVersion=v0.18.0

ENV BASE_BUILD_ID=${buildId}
ENV OPENSSL_VERSION=${opensslVersion}
ENV TINI_VERSION=${tiniVersion}

ENV APP_USER=appbot
ENV DEBIAN_FRONTEND=noninteractive
RUN useradd -c "${APP_USER}" -s /bin/false -m $APP_USER -d /app;

WORKDIR /build

# We want the best of the best in our base, ignore version pinning here
# hadolint ignore=DL3008
RUN set -eux \
&& apt-get update -y \
&& apt-get install --no-install-recommends -y \
    apt-transport-https \
    curl \
    gnupg \
&& apt-get install --no-install-recommends -y \
    build-essential \
    ca-certificates \
    checkinstall \
    jq \
    less \
    tzdata \
    unzip \
    zlib1g-dev \
&& apt-get clean all \
&& rm -rf /var/lib/apt/lists/* \
  && curl -L -o /usr/bin/tini https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini \
 && chmod +x /usr/bin/tini \
 && curl -LO https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz \
 && tar --strip-components 1 -xzvf openssl-${OPENSSL_VERSION}.tar.gz \
 && ./config --prefix=/usr/local/ssl --openssldir=/usr/openssl shared zlib no-legacy \
 && make \
 && make test \
 && make install \
 && echo '/usr/openssl/lib' > /etc/ld.so.conf.d/${OPENSSL_VERSION}.conf \
 && ldconfig -v \
 && rm /usr/bin/c_rehash \
 && rm /usr/bin/openssl \
 && mkdir -p /app/src \
 && mkdir -p /app/data \
 && chown -R ${APP_USER}:${APP_USER} /app

ENV PATH ${PATH}:/usr/local/ssl/bin
ENV OPENSSL_PATH /usr/local/ssl

WORKDIR /app

ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["/bin/bash"]
