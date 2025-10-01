#! /usr/bin/env bash

___ () { #HELP <image> <tag>|Succeed if the <image>:<tag> is found. Fail otherwise
  local filters endpoint method
  filters="{\"reference\":{\"${1}${sep[tag]}${2}\":true}}"
  method='GET'
  endpoint="http://${version[docker_api]}/images/json?filters=$(url encode "${filters}")"
  readonly filters endpoint method

  print '%s %s\n' "${method}" "$(url decode "${endpoint}")" >&2

  coproc HTTP_CODE {
    json::filter '.scheme + " " + (.response_code | tostring)'
  }
  defer 'exec {HTTP_CODE[1]}>&- 3>&-; sed "${sed[colored_http_code]}" <&${HTTP_CODE[0]} >&2'

  exec 3>&${HTTP_CODE[1]}

  curl --silent --fail --request "${method}" --unix-socket "${path[docker_socket]}" --write-out '%{stderr}%{json}' "${endpoint}" 2>&3 \
    | json::test 'length > 0'
}
