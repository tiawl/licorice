#! /usr/bin/env bash

___ () { #HELP <volume_name>|Create a new volume
  local json endpoint logged_endpoint method http_code
  json="{\"Name\":\"${1}\"}"
  endpoint="http://${version[docker_api]}/volumes/create"
  logged_endpoint="${endpoint}?$(gojq --null-input --raw-output --argjson JSON "${json}" '[$JSON | to_entries[] | .key + "=" + (.value | tostring)] | join("&")')"
  method='POST'
  readonly json endpoint logged_endpoint method

  printf '%s %s\n' "${method}" "${logged_endpoint//\"/\\\"}" >&2

  coproc HTTP_CODE { sed "${sed[colored_http_code]}"; }
  defer 'exec {HTTP_CODE[1]}>&- 3>&-; read_http_code <&${HTTP_CODE[0]}; wait "${HTTP_CODE_PID}" 2> /dev/null || :; printf "%s\n" "${http_code}" >&2'

  exec 3>&${HTTP_CODE[1]}

  curl --silent --fail --request "${method}" --unix-socket "${path[docker_socket]}" --header 'Content-Type: application/json' --data "${json}" --write-out "%{stderr}%{scheme} %{response_code}\n" "${endpoint}" 2>&3 \
    | json_pp >&2
}
