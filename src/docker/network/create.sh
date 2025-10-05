#! /usr/bin/env bash

___ () { #HELP <network_name> <isolated>|Create a new network
  local json endpoint logged_endpoint method
  json="{\"Name\":\"${1}\",\"Driver\":\"bridge\",\"EnableIPv4\":true,\"EnableIPv6\":true,\"ConfigOnly\":false,\"Scope\":\"local\",\"Internal\":${2}}"
  endpoint="http://${version[docker_api]}/networks/create"
  logged_endpoint="${endpoint}?$(json::to::queryString "${json}")"
  method='POST'
  readonly json endpoint logged_endpoint method

  print '%s %s\n' "${method}" "${logged_endpoint//\"/\\\"}" >&2

  coproc HTTP_CODE {
    json::filter '.scheme + " " + (.response_code | tostring)'
  }
  defer 'exec {HTTP_CODE[1]}>&- 3>&-; sed "${sed[http-logger]}" <&${HTTP_CODE[0]} >&2'

  exec 3>&${HTTP_CODE[1]}

  request::docker::json "${method}" "${endpoint}" "${json}" 2>&3 \
    | json::print::pretty >&2
}
