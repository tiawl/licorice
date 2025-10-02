#! /usr/bin/env bash

___ () { #HELP <image_source> <tag_source> <new_image> <new_tag>|Create a tag <new_image>:<new_tag> that refers to <image_source>:<tag_source>
  local endpoint method
  endpoint="http://${version[docker_api]}/images/${1}${sep[tag]}${2}/tag?repo=${3}&tag=${4}"
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
