#!/bin/bash

set -e

ALIASES="/etc/mail/sympa_aliases"
VIRTUAL_ALIASES="/etc/mail/sympa_virtual_aliases"
SYMPAQUEUE="/home/sympa/libexec/queue"
SYMPABOUNCEQUEUE="/home/sympa/libexec/bouncequeue"

add() {
  
    local listname=$1
    local domain=$2

    cat << EOF >> $ALIASES
${domain}-${listname}:             "| $SYMPAQUEUE       ${listname}@${domain}"
${domain}-${listname}-request:     "| $SYMPAQUEUE       ${listname}-request@${domain}"
${domain}-${listname}-editor:      "| $SYMPAQUEUE       ${listname}-editor@${domain}"
${domain}-${listname}-subscribe:   "| $SYMPAQUEUE       ${listname}-subscribe@${domain}"
${domain}-${listname}-unsubscribe: "| $SYMPAQUEUE       ${listname}-unsubscribe@${domain}"
${domain}-${listname}-owner:       "| $SYMPABOUNCEQUEUE ${listname}@${domain}"
EOF

    cat << EOF >> $VIRTUAL_ALIASES
${listname}@${domain}             ${domain}-${listname}@localhost
${listname}-request@${domain}     ${domain}-${listname}-request@localhost
${listname}-editor@${domain}      ${domain}-${listname}-editor@localhost
${listname}-subscribe@${domain}   ${domain}-${listname}-subscribe@localhost
${listname}-unsubscribe@${domain} ${domain}-${listname}-unsubscribe@localhost
${listname}-owner@${domain}       ${domain}-${listname}-owner@localhost
EOF

    postalias $ALIASES
    postmap $VIRTUAL_ALIASES

}

del() {

    local listname=$1
    local domain=$2

    sed -i "/^${domain}-${listname}\(-[a-z][a-z]*\)\{0,1\}:/d" $ALIASES
    sed -i "/ ${domain}-${listname}\(-[a-z][a-z]*\)\{0,1\}@/d" $VIRTUAL_ALIASES

    postalias $ALIASES
    postmap $VIRTUAL_ALIASES

}

OPERATION=${1:-0}
LISTNAME=${2:-0}
DOMAIN=${3:-0}
FILE=${4:-0}

case "$OPERATION" in
  add)
    add $LISTNAME $DOMAIN
    ;;
  del)
    del $LISTNAME $DOMAIN
    ;;
  *)
    echo "Script called with unknown argument \`$1'" >&2
    exit 1
    ;;
esac

exit 0

