#! /usr/bin/env bash

___ () { #HELP <repository> <tag> <context> [<buildargs>]|Build an image from a Dockerfile
  filter_docker_output () {
    json::filter --join-output '. | if (.id == "moby.buildkit.trace") then (.aux | @base64d) elif has("errorDetail") then ("vertexes {\n  error: \"" + .errorDetail.message + "\"\n}\n" | halt_error(1)) else empty end'
  }

  decode_buildkit_protobuf () {
    protoc --decode=moby.buildkit.v1.StatusResponse --descriptor_set_in=<(base64 -d <<< "${buf[descriptor_set_control]}") --proto_path=/dev/fd <(print '%s' "${buf[vendor_control]}")
  }

  local repo tag context json method endpoint
  repo="${1}"
  tag="${2}"
  context="${3}"
  json="${4:-"{}"}"
  method='POST'
  readonly repo tag context json method

  endpoint="http://${version[docker_api]}/build?version=2&t=${repo}${sep[tag]}${tag}&buildargs=$(url encode "${json}")"
  readonly endpoint

  print '%s %s\n' "${method}" "$(url decode "${endpoint}")" >&2

  local response
  coproc HTTP_CODE {
    json::filter '.scheme + " " + (.response_code | tostring)'
  }
  defer 'exec {HTTP_CODE[1]}>&- 4>&-; sed "${sed[colored_http_code]}" <&${HTTP_CODE[0]} >&2'

  exec 4>&${HTTP_CODE[1]}

  tar --directory "${context}" --create --file=- . \
    | curl --silent --fail --request "${method}" --unix-socket "${path[docker_socket]}" --data-binary '@-' --header 'Content-Type: application/x-tar' --no-buffer --write-out '%{stderr}%{json}' "${endpoint}" 2>&4 \
    | while read -r response
      do
        print '%s' "${response}" \
          | {
              filter_docker_output 2>&3 \
                | decode_buildkit_protobuf
            } 3>&1 \
          | json::from::protobuf \
          | json::filter "${jq[image-build-logging]}" --arg image "${repo}" >&2
      done
}
