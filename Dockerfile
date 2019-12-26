ARG buildId
FROM ubuntu:bionic
LABEL maintainer="AgileSyndro.me"

ARG opensslVersion=1.0.2u
ENV BASE_BUILD_ID=${buildId}
ENV OPENSSL_VERSION=${opensslVersion}

ENV APP_USER=appbot
ENV DEBIAN_FRONTEND=noninteractive
RUN useradd -c "${APP_USER}" -s /bin/false -m $APP_USER -d /app;

RUN set -eux; \
  apt-get update -y; \
  apt-get upgrade -y; \
  apt-get dist-upgrade -y; \
  apt-get install -y \
    apt-transport-https \
    curl \
    gnupg; \
  apt-get dist-upgrade -y; \
  apt-get install -y \
    build-essential \
    checkinstall \
    jq \
    less \
    tzdata \
    unzip \
    zlib1g-dev; \
  apt-get clean all;

ENV TINI_VERSION v0.18.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /usr/bin/tini
RUN chmod +x /usr/bin/tini

WORKDIR /build

RUN curl -LO https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz \
 && tar -xzvf openssl-${OPENSSL_VERSION}.tar.gz \
 && cd openssl-${OPENSSL_VERSION} \
 && ./config --prefix=/usr/openssl --openssldir=/usr/openssl shared zlib \
 && make \
 && make test \
 && make install

RUN cd /etc/ld.so.conf.d/ \
 && echo '/usr/openssl/lib' > ${OPENSSL_VERSION}.conf \
 && ldconfig -v


RUN rm /usr/bin/c_rehash \
 && rm /usr/bin/openssl

ENV PATH ${PATH}:/usr/openssl/bin
ENV OPENSSL_PATH /usr/openssl/bin

#Check time
RUN which openssl \
 && openssl version -a

RUN mkdir -p /app/src \
 && mkdir -p /app/data \
&& chown -R ${APP_USER}:${APP_USER} /app

WORKDIR /app

RUN . /etc/lsb-release \
 && echo ${DISTRIB_ID}-${DISTRIB_RELEASE}

ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["/bin/bash"]
