FROM debian:buster-slim as builder
ARG TARGETARCH

ARG BUILD_DEPENDENCIES="           \
        ca-certificates            \
        build-essential            \
        file                       \
        g++                        \
        gcc                        \
        git                        \
        libz-dev                   \
        pkg-config"

RUN set -ex \
    && apt-get update \
    && apt-get install -y ${BUILD_DEPENDENCIES} \
    && echo "no" | dpkg-reconfigure dash

ARG VERSION=v1.5.5

RUN set -ex \
    && git clone -b ${VERSION} --depth=1 https://github.com/facebook/zstd /opt/zstd

WORKDIR /opt/zstd

RUN set -ex \
    && LDFLAGS="-static" make clean check \
    && mkdir dist \
    && cp programs/zstd zstd-${VERSION}-linux-$(uname -m) \
    && sha256sum zstd-${VERSION}-linux-$(uname -m) > dist/checksums.txt \
    && mv zstd-${VERSION}-linux-$(uname -m) dist/

FROM debian:buster-slim

WORKDIR /opt/zstd

COPY --from=builder /opt/zstd/dist /opt/zstd/dist

VOLUME /dist

CMD cp -rf dist/* /dist/
