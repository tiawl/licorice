#! /usr/bin/env bash

___ () { #HELP <network_name> <container_name>|Connect <container_name> to <network_name>
  local json endpoint logged_endpoint method
  json="{\"Container\":\"${2}\"}"
  endpoint="http://${version[docker_api]}/networks/${1}/connect"
  logged_endpoint="${endpoint}?$(json::to::queryString "${json}")"
  method='POST'
  readonly json endpoint logged_endpoint method

  print '%s %s\n' "${method}" "${logged_endpoint//\"/\\\"}" >&2

  coproc HTTP_CODE {
    json::filter '.scheme + " " + (.response_code | tostring)'
  }
  defer 'exec {HTTP_CODE[1]}>&- 3>&-; sed "${sed[colored_http_code]}" <&${HTTP_CODE[0]} >&2'

  exec 3>&${HTTP_CODE[1]}

  curl --silent --fail --request "${method}" --unix-socket "${path[docker_socket]}" --header 'Content-Type: application/json' --data "${json}" --write-out '%{stderr}%{json}' "${endpoint}" 2>&3 \
    | json::print::pretty >&2
}
