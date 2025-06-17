#! /usr/bin/env bash

network_create () { #HELP <network_name>|Create a new network
  shift

  local json endpoint logged_endpoint method http_code
  json="{\"Name\":\"${1}\",\"Driver\":\"bridge\",\"EnableIPv4\":true,\"EnableIPv6\":true,\"ConfigOnly\":false}"
  endpoint="http://${version[docker_api]}/networks/create"
  logged_endpoint="${endpoint}?$(gojq --null-input --raw-output '['"${json}"' | to_entries[] | .key + "=" + .value] | join("&")')"
  method='POST'
  readonly json endpoint logged_endpoint method

  printf '%s %s\n' "${method}" "${logged_endpoint//\"/\\\"}" >&2

  coproc HTTP_CODE { sed "${sed[colored_http_code]}"; }
  defer 'exec {HTTP_CODE[1]}>&- 3>&-; read_http_code <&${HTTP_CODE[0]}; wait "${HTTP_CODE_PID}" 2> /dev/null || :; printf "%s\n" "${http_code}" >&2'

  exec 3>&${HTTP_CODE[1]}

  curl --silent --fail --request "${method}" --unix-socket "${path[docker_socket]}" --header 'Content-Type: application/json' --data "${json}" --write-out "%{stderr}%{scheme} %{response_code}\n" "${endpoint}" 2>&3 \
    | gojq '.' >&2
}
