#! /usr/bin/env bash

network_connect () { #HELP <network_name> <container_name>|Connect <container_name> to <network_name>
  shift

  local json endpoint logged_endpoint method http_code
  json="{\"Container\":\"${2}\"}"
  endpoint="http://${version[docker_api]}/networks/${1}/connect"
  logged_endpoint="${endpoint}?$(gojq --null-input --raw-output '['"${json}"' | to_entries[] | .key + "=" + (.value | tostring)] | join("&")')"
  method='POST'
  readonly json endpoint logged_endpoint method

  printf '%s %s\n' "${method}" "${logged_endpoint//\"/\\\"}" >&2

  coproc HTTP_CODE { sed "${sed[colored_http_code]}"; }
  defer 'exec {HTTP_CODE[1]}>&- 3>&-; read_http_code <&${HTTP_CODE[0]}; wait "${HTTP_CODE_PID}" 2> /dev/null || :; printf "%s\n" "${http_code}" >&2'

  exec 3>&${HTTP_CODE[1]}

  curl --silent --fail --request "${method}" --unix-socket "${path[docker_socket]}" --header 'Content-Type: application/json' --data "${json}" --write-out "%{stderr}%{scheme} %{response_code}\n" "${endpoint}" 2>&3 \
    | gojq '.' >&2
}
