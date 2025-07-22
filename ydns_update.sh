#!/bin/sh

update_domain() {
  if [ -z ${1+x} ]
  then
    echo "No domain passed."
    return 0
  fi
  if [ -z ${2+x} ]
  then
    echo "No IP Version passed."
    return 0
  fi
  OUT=$(curl -${2} --basic --silent -u "${YDNS_USER}:${YDNS_PASSWD}" https://ydns.io/api/v1/update/?host=${1})
    echo "Status update: '${1}', ${OUT}";
}

domains=$(env | grep ^DOMAIN | cut -d '=' -f2)

if [ -z "${domains}" ]
then
    echo "No domains set."
    exit 1
fi

if [ -z "${ENABLE_IPV4}" ] && [ -z "${ENABLE_IPV6}" ]
then
    echo "No IP version enabled."
    exit 1
fi

while [ true ]
do
    for domain in ${domains}
    do
        if [ -n "${ENABLE_IPV4}" ]
        then
            update_domain ${domain} 4
        fi
        if [ -n "${ENABLE_IPV6}" ]
        then
            update_domain ${domain} 6
        fi
    done
    sleep ${UPDATE_DELAY}
done
