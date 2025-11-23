#! /usr/bin/env bash

source "${BASH_SOURCE[0]%/*}/print.sh"
source "${BASH_SOURCE[0]%/*}/object.sh"

json::tokenize () {
  local escape char string number keyword space egrep

  escape='(\\[^u[:cntrl:]]|\\u[0-9a-fA-F]{4})'
  char='[^[:cntrl:]"\\]'
  string='"'"${char}"'*('"${escape}${char}"'*)*"'
  number='-?(0|[1-9][0-9]*)([.][0-9]*)?([eE][+-]?[0-9]*)?'
  keyword='null|false|true'
  space='[[:space:]]+'

  if is func rg
  then
    egrep='rg'
  else
    egrep='egrep'
  fi

  if is file "${1:-}"
  then
    set -f
    ${egrep} -a -o --color=never "${string}"'|'"${number}"'|'"${keyword}"'|'"${space}"'|.' "${1}" | ${egrep} -v '^'"${space}"'$'
    set +f
  else
    set -f
    ${egrep} -a -o --color=never "${string}"'|'"${number}"'|'"${keyword}"'|'"${space}"'|.' | ${egrep} -v '^'"${space}"'$'
    set +f
  fi
}

json::from::protobuf () {
  sed --quiet "${sed[json/from/protobuf]}"
}

json::kind::assert () {
  local -n ref
  ref="JSONTYPE_${1}"
  if str not eq "${ref[.]}" "${2}"
  then
    unreachable "${3}" "This function can only be used with JSON ${2}s but ${1} is a JSON ${ref[.]}"
  fi
}

json::new () {
  declare -g -A "JSONGET_${1}" "JSONTYPE_${1}"
}

json::free () {
  unset "JSONGET_${1}" "JSONTYPE_${1}"
}

json::parse () {
  if is not set 'lastpipe'
  then
    unreachable "${FUNCNAME[0]}" 'lastpipe must be used to define new variables into current environment from JSON parsing'
  fi

  # TODO: JSONKEYS_
  json::free "${1:-stdin}"
  json::new "${1:-stdin}"
  json::tokenize | awk -v "JSONGET=JSONGET_${1:-stdin}" -v "JSONTYPE=JSONTYPE_${1:-stdin}" -f ./awk/json/parse.awk
  #source /proc/self/fd/0 <<< "
  #  $(json::tokenize | awk -v "JSONGET=JSONGET_${1:-stdin}" \
  #                         -v "JSONTYPE=JSONTYPE_${1:-stdin}" \
  #                         "${awk[json/parse]}")"
}

# TODO: rework everything below this comment:

json::encode () {
  local -n ref
  while gt "${#}" '0'
  do
    ref="${1}"
    if is associative "${!ref}"
    then
      json::program '($ARGS.positional | [.[:$n], .[$n:]] | transpose | map(last as $last | {(first): (if (($last | type == "number") or (($last | type == "string") and ($last | test("^[0-9]+$")))) then ($last | tostring) else (try ($last | fromjson) catch $last) end)}) | add) // {}' --argjson n "${#ref[@]}" --args -- "${!ref[@]}" "${ref[@]}"
    elif is indexed "${!ref}"
    then
      json::program '$ARGS.positional | map(. as $item | try (fromjson) catch $item)' --args -- "${ref[@]}"
    else
      error 'Only usable with indexed and associative array'
    fi
    shift
  done
  unset -n ref
}

# TODO: remove json_xs
json::stringify () {
  json_xs -f string -t json
}

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

# TODO: remove YAML support
json::from::yaml () {
  json::filter --yaml-input --monochrome-output --compact-output "${@}"
}
