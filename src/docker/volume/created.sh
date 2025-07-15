#! /usr/bin/env bash

___ () { #HELP <name>|Succeed if a volume with <name> is found. Fail otherwise
  local filters endpoint method http_code
  filters="{\"name\":{\"${1}\":true}}"
  method='GET'
  endpoint="http://${version[docker_api]}/volumes?filters=$(url encode "${filters}")"
  readonly filters endpoint method

  printf '%s %s\n' "${method}" "$(url decode "${endpoint}")" >&2

  coproc HTTP_CODE { sed "${sed[colored_http_code]}"; }
  defer 'exec {HTTP_CODE[1]}>&- 3>&-; read_http_code <&${HTTP_CODE[0]}; wait "${HTTP_CODE_PID}" 2> /dev/null || :; printf "%s\n" "${http_code}" >&2'

  exec 3>&${HTTP_CODE[1]}

  curl --silent --fail --request "${method}" --unix-socket "${path[docker_socket]}" --write-out "%{stderr}%{scheme} %{response_code}\n" "${endpoint}" 2>&3 \
    | gojq --exit-status '.Volumes | length > 0' > /dev/null
}
