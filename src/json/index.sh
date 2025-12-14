#! /usr/bin/env bash

source "${BASH_SOURCE[0]%/*}/print.sh"
source "${BASH_SOURCE[0]%/*}/object.sh"

json::tokenize () {
  local escape char string number keyword space

  escape='(\\[^u[:cntrl:]]|\\u[0-9a-fA-F]{4})'
  char='[^[:cntrl:]"\\]'
  string='"'"${char}"'*('"${escape}${char}"'*)*"'
  number='-?(0|[1-9][0-9]*)([.][0-9]*)?([eE][+-]?[0-9]*)?'
  keyword='null|false|true'
  space='[[:space:]]+'

  if is file "${1:-}" || is pipe "${1:-}"
  then
    match -a -o "${string}"'|'"${number}"'|'"${keyword}"'|'"${space}"'|.' "${1}" | match -v '^'"${space}"'$'
  else
    match -a -o "${string}"'|'"${number}"'|'"${keyword}"'|'"${space}"'|.' | match -v '^'"${space}"'$'
  fi
}

json::from::protobuf () {
  sed --quiet "${sed[json/from/protobuf]}"
}

json::kind::assert () {
  local -n ref
  ref="JSONKIND_${1}"
  if str not eq "${ref["${2}"]}" "${3}"
  then
    unreachable "${4}" "This function can only be used with JSON ${3}s but ${1}[${2}] is a JSON ${ref["${2}"]}"
  fi
}

json::kind::error () {
  local -n ref
  ref="JSONKIND_${1}"
  if str not eq "${ref["${2}"]}" "${3}"
  then
    error "The ${4} function can only be used with JSON ${3}s but ${1}[${2}] is a JSON ${ref["${2}"]}"
  fi
}

json::__::check::lastpipe () {
  if is not set 'lastpipe'
  then
    unreachable "${1}" 'This function needs lastpipe shell option to be used'
  fi
}

json::parse () {
  json::__::check::lastpipe "${FUNCNAME[0]}"

  if eq "${#}" '1'
  then
    set -- '' "${1}"
  fi

  json::tokenize "${1:-}" \
    | awk -v "ID=${2}" "${awk[quoting]}${awk[json/parse]}" \
    | source /proc/self/fd/0
}

# TODO: rework everything below this comment:

json::filter () {
  gojq --raw-output "${@}"
}

json::program () {
  json::filter --null-input --compact-output --monochrome-output "${@}"
}

json::test () {
  json::filter --exit-status "${@}" > /dev/null
}

json::to::queryString () {
  json::filter --null-input --argjson CONVERTME "${1}" '[$CONVERTME | to_entries[] | .key + "=" + (.value | tostring)] | join("&")'
}
