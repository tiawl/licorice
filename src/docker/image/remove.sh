#! /usr/bin/env bash

___ () { #HELP <image> <tag>|Remove <image>
  local endpoint method
  endpoint="http://${version[docker_api]}/images/${1}${sep[tag]}${2}"
  method='DELETE'
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
    | json::print::pretty >&2
}
