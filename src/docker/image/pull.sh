#! /usr/bin/env bash

___ () { #HELP <registry> <project> <image> <tag>|Download <image> from <registry>
  local endpoint method img
  img="${1}${sep[image]}${2}${sep[image]}${3}${sep[tag]}${4}"
  endpoint="http://${version[docker_api]}/images/create?fromImage=${img}"
  method='POST'
  readonly endpoint method img

  print '%s %s\n' "${method}" "${endpoint//\"/\\\"}" >&2

  coproc HTTP_CODE {
    json::filter '.scheme + " " + (.response_code | tostring)'
  }
  defer 'exec {HTTP_CODE[1]}>&- 3>&-; sed "${sed[colored_http_code]}" <&${HTTP_CODE[0]} >&2'

  exec 3>&${HTTP_CODE[1]}

  request::docker "${method}" "${endpoint}" 2>&3 \
    | json::filter '"image pull '"${img}"' > " + .status + (if .progress | length > 0 then " " else "" end) + .progress' >&2
}
