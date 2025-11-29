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

  if is file "${1:-}"
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

json::new () {
  declare -g -A 'JSON'{GET,KIND,KEYS,VALUES,LENGTH,PARENT}"_${1}"
}

json::free () {
  unset 'JSON'{GET,KIND,KEYS,VALUES,LENGTH,PARENT}"_${1}"
}

json::parse () {
  if is not set 'lastpipe'
  then
    unreachable "${FUNCNAME[0]}" 'lastpipe must be used to define new variables into current environment from JSON parsing'
  fi

  if eq "${#}" '1'
  then
    set -- '' "${1}"
  fi

  json::free "${2}"
  json::new "${2}"
  json::tokenize "${1:-}" | awk -v "JSONGET=JSONGET_${2}" \
                                -v "JSONKIND=JSONKIND_${2}" \
                                -v "JSONKEYS=JSONKEYS_${2}" \
                                -v "JSONVALUES=JSONVALUES_${2}" \
                                -v "JSONLENGTH=JSONLENGTH_${2}" \
                                -v "JSONPARENT=JSONPARENT_${2}" \
                                -f ./awk/json/parse.awk
  # TODO:                       "${awk[json/parse]}" | source /proc/self/fd/0
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
