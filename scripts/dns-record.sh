#!/bin/bash
# DNS entry structure:
# <host_name>.<cluster_name>.<host_dns_domain>

# Requires $DO_TOKEN exported
source /etc/profile.d

HOST_DEFAULT_INTERFACE="$(awk '$2 == 00000000 { print $1 }' /proc/net/route)"
HOST_DEFAULT_ADDRESS="$(ip addr show dev "$HOST_DEFAULT_INTERFACE" | awk '$1 == "inet" { sub("/.*", "", $2); print $2 }')"

HOST_DNS_NAME=$(echo $HOSTNAME | awk 'BEGIN { FS="." } { print $1  }').$(echo $HOSTNAME | awk 'BEGIN { FS="." } { print $2  }')  # short hostame + clustername
HOST_DNS_ZONE="brq.1mlkv.xyz"     # the dns zone / domain

DO_DOMAIN="$HOST_DNS_ZONE"

generate_post_data() {
cat <<EOF
{
  "type": "A",
  "name": "$HOST_DNS_NAME",
  "data": "$HOST_DEFAULT_ADDRESS",
  "priority": null,
  "port": null,
  "ttl": 1800,
  "weight": null,
  "flags": null,
  "tag": null
}
EOF
}

function is_present () {
    curl -s -X GET \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $DO_TOKEN" \
    "https://api.digitalocean.com/v2/domains/$DO_DOMAIN/records" | jq \
    --arg HOST_DNS_NAME "$HOST_DNS_NAME" \
    --arg HOST_DEFAULT_ADDRESS "$HOST_DEFAULT_ADDRESS" \
    '.domain_records | .[] | select(.type == "A") | select(.name=$HOST_DNS_NAME) | select(.data==$HOST_DEFAULT_ADDRESS) '
}

function is_matching () {
    curl -s -X GET \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $DO_TOKEN" \
    "https://api.digitalocean.com/v2/domains/$DO_DOMAIN/records" | jq \
    --arg HOST_DNS_NAME "$HOST_DNS_NAME" \
    '.domain_records | .[] | select(.type == "A") | select(.name=$HOST_DNS_NAME)'
}
function create_record () {
    curl -s -X POST \
                        --json "$(generate_post_data)" \
                         -H "Authorization: Bearer $DO_TOKEN" \
                         "https://api.digitalocean.com/v2/domains/brq.1mlkv.xyz/records"
}
function delete_record () {
    curl -s -X DELETE \
                            -H "Content-Type: application/json" \
                            -H "Authorization: Bearer $DO_TOKEN" \
                            "https://api.digitalocean.com/v2/domains/$DO_DOMAIN/records/$do_record_delete"
}

echo "My hostname is $HOST_DNS_NAME.$DO_DOMAIN "
echo "My ip address is $HOST_DEFAULT_ADDRESS"

echo "Checking for record: $HOST_DEFAULT_ADDRESS  $HOST_DNS_NAME.$DO_DOMAIN"
    is_present=$(is_present $HOST_DNS_NAME $HOST_DEFAULT_ADDRESS)
# Record NOT found
if test -z "$is_present"; then
    echo -e "No DNS record found, updating ..."
    do_record_id=$(echo -e "$(create_record)"  | jq .domain_record.id)  # call create_record function and assign the id to the do_record_id variable
    echo $do_record_id
else
# Record IS found
    do_record_id=$(echo -e "$is_present "  | jq .id | tail -1)
    echo "Record found: $do_record_id"
    echo -e "$is_present" | jq
fi

# Cleanup obsolete records

echo "Checking for records matching: $HOST_DNS_NAME.$DO_DOMAIN"
    # is_matching=$(is_matching $HOST_DNS_NAME)
    is_matching_list=$(is_matching $HOST_DNS_NAME | jq .id | tr '\n' ' ')
    if test -z "$is_matching"; then
        for x in ${is_matching_list[*]};do
            echo $x
            if [ $x != $do_record_id ];then
                do_record_delete="$x"
                delete_record $do_record_delete
                echo -e "record id $x... deleted"
                sleep 1
            else
                echo "(active record)"
            fi
        done
    fi

exit 0
