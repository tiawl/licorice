#! /usr/bin/env bash

___ () { #HELP <container> <network>|List <container> ip address on <network_id>
  local endpoint method
  endpoint="http://${version[docker_api]}/containers/${1}/json"
  method='GET'
  readonly endpoint method

  print '%s %s\n' "${method}" "${endpoint//\"/\\\"}" >&2

  coproc HTTP_CODE {
    json::filter '.scheme + " " + (.response_code | tostring)'
  }
  defer 'exec {HTTP_CODE[1]}>&- 3>&-; sed "${sed[colored_http_code]}" <&${HTTP_CODE[0]} >&2'

  exec 3>&${HTTP_CODE[1]}

  curl --silent --fail --request "${method}" --unix-socket "${path[docker_socket]}" --write-out '%{stderr}%{json}' "${endpoint}" 2>&3 \
    | json::filter '.NetworkSettings.Networks[$net].IPAddress' --arg net "${2}"
}
