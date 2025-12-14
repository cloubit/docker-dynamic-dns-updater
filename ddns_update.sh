#!/bin/sh

# --- Exit on unset variables (safe), treat empty as error later when needed--
set -u

# --- Logging helpers --------------------------------------------------------
log() {
    # Normal message
    printf '%s\n' "$*" >&2
}

fail() {
    # Error message + exit
    printf 'ERROR: %s\n' "$*" >&2
    exit 1
}

# --- Validate required environment variables --------------------------------
[ -n "${DDNS_TOKEN:-}" ]  || fail "DDNS_TOKEN not set."
[ -n "${UPDATE_DELAY:-}" ] || fail "UPDATE_DELAY not set."
[ -n "${APIURL_BASE:-}" ]  || fail "APIURL_BASE not set. This is required for curl." # Fügen Sie diese Validierung hinzu, falls sie im vorherigen Schritt fehlte.

# Collect DDOMAIN* environment variables
domains=$(env | sed -n 's/^DDOMAIN[0-9]*=//p')

[ -n "${domains}" ] || fail "No domains defined (expected DDOMAIN1=..., DDOMAIN2=...)."

# IP versions enabled?
[ -n "${ENABLE_IPV4:-}" ] || [ -n "${ENABLE_IPV6:-}" ] || fail "No IP version enabled (ENABLE_IPV4 or ENABLE_IPV6 must be set)."

# --- Function: update a single domain ---------------------------------------
update_domain() {
    domain=${1:-}
    ip_version=${2:-}

    [ -n "${domain}" ]     || { log "$(date -Is) No domain passed."; return 1; }
    [ -n "${ip_version}" ] || { log "$(date -Is) No IP version passed."; return 1; }

    # Determine curl switch: -4 or -6
    case "$ip_version" in
        4) curl_switch="-4" ;;
        6) curl_switch="-6" ;;
        *) log "$(date -Is) Invalid IP version: $ip_version"; return 1 ;;
    esac

    # 1. Basic Auth Parameter vorbereiten
    local ddns_user_safe="${DDNS_USER:-}"
    
    local auth_param=""
    if [ -n "${ddns_user_safe}" ]; then
        auth_param="${ddns_user_safe}:${DDNS_TOKEN}"
    else
        auth_param=":${DDNS_TOKEN}"
    fi

    # Perform update
    if response=$(
        eval curl ${curl_switch} --silent --show-error --fail \
        --basic -u ${auth_param} \
        "${APIURL_BASE}${domain}" 2>&1
    ); then
        log "$(date -Is) Updated '${domain}' (IPv${ip_version}): ${response}"
    else
        log "$(date -Is) Update failed for '${domain}' (IPv${ip_version}): ${response}"
    fi
}

# --- Main update loop --------------------------------------------------------
log "$(date -Is) Starting DDNS updater..."
log "$(date -Is) Domains: ${domains}"
log "$(date -Is) Update delay: ${UPDATE_DELAY}s"
[ -n "${ENABLE_IPV4:-}" ] && log "$(date -Is) IPv4 enabled"
[ -n "${ENABLE_IPV6:-}" ] && log "$(date -Is) IPv6 enabled"

while true
do
    OIFS="$IFS"
    IFS='
    '
    for domain in ${domains}
    do
        if [ -n "${ENABLE_IPV4:-}" ]; then
            update_domain "${domain}" 4
        fi

        if [ -n "${ENABLE_IPV6:-}" ]; then
            update_domain "${domain}" 6
        fi
    done
    IFS="$OIFS"
    sleep "${UPDATE_DELAY}"
done
