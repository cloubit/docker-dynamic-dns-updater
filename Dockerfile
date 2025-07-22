# GLOBAL BUILD ARG
ARG UPDATE_DELAY=300
ARG USERNAME=_ydns_updater 
ARG GROUPNAME=_ydns_updater
ARG UID=5001
ARG GID=5001


# YDNS BUILDER
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
    curl

RUN set -x -e; \
    groupadd -g ${GID} ${GROUPNAME} && \
    useradd -u ${UID} -g ${GID} -s /dev/null -d /dev/null ${USERNAME}


# YDNS FINAL
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
COPY --from=builder /bin/sh /bin/ls /bin/cat /bin/grep /bin/sleep \
    /bin/
COPY --from=builder /etc/passwd /etc/shadow /etc/group \
    /etc/
COPY --from=builder /etc/ssl/cert* /etc/ssl/certs/\
    /etc/ssl/
COPY --from=builder /usr/bin/curl /usr/bin/cut /usr/bin/env \
    /usr/bin/
COPY --from=builder /usr/lib/libcurl* /usr/lib/libz* /usr/lib/libcares* /usr/lib/libnghttp2* /usr/lib/libidn2* /usr/lib/libpsl* /usr/lib/libssl* /usr/lib/libcrypto* /usr/lib/libbrotli* /usr/lib/libunistring* \
    /usr/lib/
COPY ./ydns_update.sh /opt/ydns_update.sh

WORKDIR /opt

USER ${USERNAME}

CMD ["/bin/sh", "/opt/ydns_update.sh"]
