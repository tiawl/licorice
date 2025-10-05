#! /usr/bin/env bash

___ () { #HELP <container_name> <image> <hostname> [<volumes>]|Create a new container from <image>
  local json endpoint logged_endpoint method img
  img="${2}"
  json="{\"Hostname\":\"${3}\",\"Image\":\"${img}${sep[tag]}$(${namespace[core]}image tag list "${img}")\",\"HostConfig\":{\"Mounts\":${4}}}"
  endpoint="http://${version[docker_api]}/containers/create?name=${1}"
  logged_endpoint="${endpoint}&$(json::to::queryString "${json}")"
  method='POST'
  readonly json endpoint logged_endpoint method img

  print '%s %s\n' "${method}" "${logged_endpoint//\"/\\\"}" >&2

  coproc HTTP_CODE {
    json::filter '.scheme + " " + (.response_code | tostring)'
  }
  defer 'exec {HTTP_CODE[1]}>&- 3>&-; sed "${sed[http-logger]}" <&${HTTP_CODE[0]} >&2'

  exec 3>&${HTTP_CODE[1]}

  request::docker::json "${method}" "${endpoint}" "${json}" 2>&3 \
    | json::print::pretty >&2
}
