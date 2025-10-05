#! /usr/bin/env bash

___ () { #HELP <name>|Succeed if a network with <name> is found. Fail otherwise
  local filters endpoint method
  filters="{\"name\":{\"${1}\":true}}"
  method='GET'
  endpoint="http://${version[docker_api]}/networks?filters=$(url encode "${filters}")"
  readonly filters endpoint method

  print '%s %s\n' "${method}" "$(url decode "${endpoint}")" >&2

  coproc HTTP_CODE {
    json::filter '.scheme + " " + (.response_code | tostring)'
  }
  defer 'exec {HTTP_CODE[1]}>&- 3>&-; sed "${sed[http-logger]}" <&${HTTP_CODE[0]} >&2'

  exec 3>&${HTTP_CODE[1]}

  request::docker "${method}" "${endpoint}" 2>&3 \
    | json::test 'length > 0'
}
