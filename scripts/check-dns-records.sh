#/bin/bash

source $HOME/github/fcos-ops/scripts/do-token.sh

DO_DOMAIN="brq.1mlkv.xyz"

curl -s -X GET \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $DO_TOKEN" \
    "https://api.digitalocean.com/v2/domains/$DO_DOMAIN/records" |  jq '.domain_records | .[] | select(.type == "A") '
