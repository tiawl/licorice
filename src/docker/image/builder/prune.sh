#! /usr/bin/env bash

___ () { #HELP|Remove build cache
  local endpoint method
  endpoint="http://${version[docker_api]}/build/prune?all=true"
  method='POST'
  readonly endpoint method

  print '%s %s\n' "${method}" "${endpoint//\"/\\\"}" >&2

  coproc HTTP_CODE {
    json::filter '.scheme + " " + (.response_code | tostring)'
  }
  defer 'exec {HTTP_CODE[1]}>&- 3>&-; sed "${sed[colored_http_code]}" <&${HTTP_CODE[0]} >&2'

  exec 3>&${HTTP_CODE[1]}

  request::docker "${method}" "${endpoint}" 2>&3 \
    | json::print::pretty >&2
}
