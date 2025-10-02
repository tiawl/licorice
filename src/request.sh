#! /usr/bin/env bash

request::docker () {
  local method endpoint
  method="${1}"
  endpoint="${2}"
  shift 2
  curl --silent --fail --no-buffer --output - --request "${method}" --unix-socket "${path[docker_socket]}" --write-out '%{stderr}%{json}' "${@}" "${endpoint}"
}

request::docker::json () {
  local method endpoint json
  method="${1}"
  endpoint="${2}"
  json="${3}"
  shift 3
  request::docker "${method}" "${endpoint}" --header 'Content-Type: application/json' --data "${json}"
}

request::docker::tar () {
  local method endpoint
  method="${1}"
  endpoint="${2}"
  shift 2
  request::docker "${method}" "${endpoint}" --header 'Content-Type: application/x-tar' --data-binary '@-'
}
