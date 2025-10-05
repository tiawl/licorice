#! /usr/bin/env bash

___ () { #HELP <container_name> <detached> <user> <cmd>|Run a command inside <container_name>
  local json create_endpoint start_endpoint logged_endpoint method exec_id
  json="{\"AttachStdin\": false,\"AttachStdout\": true, \"AttachStderr\": true,\"Tty\": false,\"Cmd\": ${4}, \"User\": \"${3}\"}"
  create_endpoint="http://${version[docker_api]}/containers/${1}/exec"
  logged_endpoint="${create_endpoint}?$(json::to::queryString "${json}")"
  method='POST'
  readonly json create_endpoint logged_endpoint method

  print '%s %s\n' "${method}" "${logged_endpoint//\"/\\\"}" >&2

  coproc HTTP_CODE {
    json::filter '.scheme + " " + (.response_code | tostring)'
  }

  exec 3>&${HTTP_CODE[1]}

  exec_id="$(
    request::docker::json "${method}" "${create_endpoint}" "${json}" 2>&3 \
      | json::filter '.Id'
  )"

  exec {HTTP_CODE[1]}>&- 3>&-
  sed "${sed[http-logger]}" <&${HTTP_CODE[0]} >&2

  start_endpoint="http://${version[docker_api]}/exec/${exec_id}/start?Detach=${2}"
  readonly start_endpoint

  print '%s %s\n' "${method}" "${start_endpoint//\"/\\\"}" >&2

  coproc HTTP_CODE {
    json::filter '.scheme + " " + (.response_code | tostring)'
  }
  defer 'exec {HTTP_CODE[1]}>&- 3>&-; sed "${sed[http-logger]}" <&${HTTP_CODE[0]} >&2'

  exec 3>&${HTTP_CODE[1]}

  request::docker "${method}" "${start_endpoint}" 2>&3
}
