#! /usr/bin/env bash

___ () { #HELP <network>|List all ip addresses used on <network>
  local endpoint method
  endpoint="http://${version[docker_api]}/networks/${1}"
  method='GET'
  readonly endpoint method

  print '%s %s\n' "${method}" "${endpoint//\"/\\\"}" >&2

  coproc HTTP_CODE {
    json::filter '.scheme + " " + (.response_code | tostring)'
  }
  defer 'exec {HTTP_CODE[1]}>&- 3>&-; sed "${sed[colored_http_code]}" <&${HTTP_CODE[0]} >&2'

  exec 3>&${HTTP_CODE[1]}

  request::docker "${method}" "${endpoint}" 2>&3 \
    | json::filter '.Containers | to_entries[].value.IPv4Address | sub("/[0-9]+$"; "")'
}
