#! /usr/bin/env bash

___ () { #HELP <container_name> <detached> <user> <cmd>|Run a command inside <container_name>
  local json create_endpoint start_endpoint logged_endpoint method exec_id
  json="{\"AttachStdin\": false,\"AttachStdout\": true, \"AttachStderr\": true,\"Tty\": false,\"Cmd\": ${4}, \"User\": \"${3}\"}"
  create_endpoint="http://${version[docker_api]}/containers/${1}/exec"
  logged_endpoint="${create_endpoint}?$(gojq --null-input --raw-output --argjson JSON "${json}" '[$JSON | to_entries[] | .key + "=" + (.value | tostring)] | join("&")')"
  method='POST'
  readonly json create_endpoint logged_endpoint method

  print '%s %s\n' "${method}" "${logged_endpoint//\"/\\\"}" >&2

  coproc HTTP_CODE {
    json::parse
    json::get - scheme
    scheme="${GET}"
    print '%s ' "${GET}"
    json::get - response_code
    print '%s\n' "${GET}"
  }

  exec 3>&${HTTP_CODE[1]}

  exec_id="$(
    curl --silent --fail --request "${method}" --unix-socket "${path[docker_socket]}" --header 'Content-Type: application/json' --data "${json}" --write-out '%{stderr}%{json}' --output - "${create_endpoint}" 2>&3 \
      | json::parse
    json::get - Id
  )"

  exec {HTTP_CODE[1]}>&- 3>&-
  sed "${sed[colored_http_code]}" <&${HTTP_CODE[0]} >&2

  start_endpoint="http://${version[docker_api]}/exec/${exec_id}/start?Detach=${2}"
  readonly start_endpoint

  print '%s %s\n' "${method}" "${start_endpoint//\"/\\\"}" >&2

  coproc HTTP_CODE {
    json::parse
    json::get - scheme
    print '%s ' "${GET}"
    json::get - response_code
    print '%s\n' "${GET}"
  }
  defer 'exec {HTTP_CODE[1]}>&- 3>&-; sed "${sed[colored_http_code]}" <&${HTTP_CODE[0]} >&2'

  exec 3>&${HTTP_CODE[1]}

  curl --silent --fail --request "${method}" --unix-socket "${path[docker_socket]}" --write-out '%{stderr}%{json}' --output - "${start_endpoint}" 2>&3
}
