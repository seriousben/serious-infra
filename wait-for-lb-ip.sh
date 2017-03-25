#!/usr/bin/env bash
set -e
set -o pipefail

ATTEMPT_SLEEP=10s
MAX_ATTEMPT=30

get_lb_data() {
    _service_json=$(kubectl get services -o json)
    _lb_json=$(echo "$_service_json" | jq '.items | map(select(.metadata.name == "frontend")) | .[]')
    _data=$(echo "$_lb_json" | jq '{name: .metadata.name, external_ip: .status.loadBalancer.ingress | .[0].ip}')
    echo "$_data"
}

main() {
    attemptCount=0
    while true; do
        _lb_data=$(get_lb_data)
        # echo "ATTEMPT #$attemptCount => $_lb_data"
        _lb_ip=$(echo "$_lb_data" | jq ".external_ip")
        if [ "$_lb_ip" != "null" ] && [ ! -z "$_lb_ip" ]; then
            echo "$_lb_data"
            exit 0
        fi
        attemptCount=$((attemptCount + 1))
        if [ $attemptCount -gt $MAX_ATTEMPT ]; then
            echo "Timeout while waiting for loadbalancer IP" 1>&2
            exit 1
        fi
        sleep $ATTEMPT_SLEEP
    done
}

main
