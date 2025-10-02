#! /usr/bin/env bash

___ () { #HELP <container>|Return the status of the given <container>
  local endpoint method
  method='GET'
  endpoint="http://${version[docker_api]}/containers/${1}/json"
  readonly endpoint method

  print '%s %s\n' "${method}" "$(url decode "${endpoint}")" >&2

  coproc HTTP_CODE {
    json::filter '.scheme + " " + (.response_code | tostring)'
  }
  defer 'exec {HTTP_CODE[1]}>&- 3>&-; sed "${sed[colored_http_code]}" <&${HTTP_CODE[0]} >&2'

  exec 3>&${HTTP_CODE[1]}

  request::docker "${method}" "${endpoint}" 2>&3 \
    | json::filter '.State.Status'
}
