#! /usr/bin/env bash

___ () { #HELP <network>|List all ip addresses used on <network>
  local endpoint method
  endpoint="http://${version[docker_api]}/networks/${1}"
  method='GET'
  readonly endpoint method

  print '%s %s\n' "${method}" "${endpoint//\"/\\\"}" >&2

  coproc HTTP_CODE {
    json::parse
    json::get - scheme
    print '%s ' "${GET}"
    json::get - response_code
    print '%s\n' "${GET}"
  }
  defer 'exec {HTTP_CODE[1]}>&- 3>&-; sed "${sed[colored_http_code]}" <&${HTTP_CODE[0]} >&2'

  exec 3>&${HTTP_CODE[1]}

  curl --silent --fail --request "${method}" --unix-socket "${path[docker_socket]}" --write-out '%{stderr}%{json}' "${endpoint}" 2>&3 \
    | gojq --raw-output '.Containers | to_entries[].value.IPv4Address | sub("/[0-9]+$"; "")'
}
