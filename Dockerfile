# GLOBAL BUILD ARG
ARG UPDATE_DELAY=900
ARG USERNAME=_ddns_updater 
ARG GROUPNAME=_ddns_updater
ARG UID=5001
ARG GID=5001


# DDNS BUILDER
FROM alpine:latest AS builder

ARG USERNAME \
    GROUPNAME \
    UID \
    GID

ENV USERNAME=${USERNAME} \
    GROUPNAME=${GROUPNAME} \
    UID=${UID} \
    GID=${GID}


RUN set -x -e; \
  apk --update --no-cache add \
    shadow \
    curl \
    sed

RUN set -x -e; \
    groupadd -g ${GID} ${GROUPNAME} && \
    useradd -u ${UID} -g ${GID} -s /dev/null -d /dev/null ${USERNAME}


# DDNS FINAL
FROM scratch

ARG UPDATE_DELAY \
    USERNAME \
    GROUPNAME \
    UID \
    GID

ENV UPDATE_DELAY=${UPDATE_DELAY} \
    USERNAME=${USERNAME} \
    GROUPNAME=${GROUPNAME} \
    UID=${UID} \
    GID=${GID}
    
COPY --from=builder /lib/*musl* \
    /lib/
COPY --from=builder /bin/sh /bin/date /bin/sleep /bin/sed /bin/kill /bin/chmod \
    /bin/
COPY --from=builder /etc/passwd /etc/shadow /etc/group \
    /etc/
COPY --from=builder /etc/ssl/*.pem \
    /etc/ssl/
COPY --from=builder /etc/ssl/certs/*.crt \
    /etc/ssl/certs/
COPY --from=builder /usr/bin/curl /usr/bin/cut /usr/bin/env \
    /usr/bin/
COPY --from=builder /usr/lib/libcurl* /usr/lib/libz* /usr/lib/libcares* /usr/lib/libnghttp2* /usr/lib/libnghttp3* /usr/lib/libidn2* /usr/lib/libpsl* /usr/lib/libssl* /usr/lib/libcrypto* /usr/lib/libbrotli* /usr/lib/libunistring* \
    /usr/lib/
COPY --chmod=755 ./ddns_update.sh /opt/ddns_update.sh

WORKDIR /opt
RUN chmod +x ./ddns_update.sh

USER ${USERNAME}

HEALTHCHECK --interval=20s --timeout=30s --start-period=10s --retries=3 \
    CMD kill -0 1 || exit 1

ENTRYPOINT ["./ddns_update.sh"]
