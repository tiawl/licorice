#! /usr/bin/env bash

json::object::__::print_keys () {
  local -n ref
  ref="JSON${1}_${3}"
  print "%s\nJSON${1}_${2}\nJSON${1}_${3}\n" "${!ref[@]}"
}

json::object::__::fix_regex () {
  local -n ref
  ref="${1}"
  ref="${ref//\\/\\\\}"
  ref="${ref//\//\\/}"
  ref="${ref//\./\\.}"
  ref="${ref//\*/\\*}"
  ref="${ref//\[/\\[}"
  ref="${ref//\]/\\]}"
  ref="${ref//\(/\\(}"
  ref="${ref//\)/\\)}"
  ref="${ref//\{/\\{}"
  ref="${ref//\}/\\\}}"
  ref="${ref//\$/\\$}"
  ref="${ref//\^/\\^}"
  ref="${ref//\|/\\|}"
  ref="${ref//\+/\\+}"
  ref="${ref//\?/\\?}"
}

json::object::has () {
  local -n parentref kindref
  parentref="JSONPARENT_${1}"

  if is not var "parentref[${2}]"
  then
    return 1
  fi

  json::kind::assert "${1}" "${parentref["${2}"]}" 'object' "${FUNCNAME[0]}"
  kindref="JSONKIND_${1}"
  str not empty "${kindref["${2}"]}"
}

json::object::has::assert () {
  if not json::object::has "${1}" "${2}"
  then
    unreachable "${3}" "The JSON object '${1}' must have this key '${2}'"
  fi
}

json::object::delete () {
  local -n parentref
  parentref="JSONPARENT_${1}"

  json::kind::assert "${1}" "${parentref["${2}"]}" 'object' "${FUNCNAME[0]}"
  json::object::has::assert "${1}" "${2}" "${FUNCNAME[0]}"

  word splitting $'\n'
  on noglob
  unset $(
    off noglob

    declare -n kindref
    kindref="JSONKIND_${1}"
    regex="${2}"
    json::object::__::fix_regex 'regex'

    word splitting $'\n'
    {
      match "^${regex}" \
      | awk -v "ID=${1}" "${awk[quoting]}"'{
                print "JSONGET_" ID "[" q($0) "]\n" \
                      "JSONKIND_" ID "[" q($0) "]\n" \
                      "JSONKEYS_" ID "[" q($0) "]\n" \
                      "JSONVALUES_" ID "[" q($0) "]\n" \
                      "JSONLENGTH_" ID "[" q($0) "]\n" \
                      "JSONPARENT_" ID "[" q($0) "]"
            }'
    } <<< "${!kindref[@]}"
  )
  off noglob
  word splitting reset
}

json::object::merge () {
  json::__::check::lastpipe "${FUNCNAME[0]}"

  json::kind::assert "${1}" "${2}" 'object' "${FUNCNAME[0]}"
  json::kind::assert "${3}" "${4}" 'object' "${FUNCNAME[0]}"
  json::object::has::assert "${1}" "${2}" "${FUNCNAME[0]}"
  json::object::has::assert "${3}" "${4}" "${FUNCNAME[0]}"

  local regex
  regex="${4}"
  json::object::__::fix_regex 'regex'

  {
    json::object::__::print_keys 'GET' "${1}" "${3}"
    json::object::__::print_keys 'KIND' "${1}" "${3}"
    json::object::__::print_keys 'KEYS' "${1}" "${3}"
    json::object::__::print_keys 'VALUES' "${1}" "${3}"
    json::object::__::print_keys 'LENGTH' "${1}" "${3}"
    json::object::__::print_keys 'PARENT' "${1}" "${3}"
  } | match::noseparator -A 2 "^${regex}" \
    | awk -v "ROOT_LEFT=${2}" -v "ROOT_RIGHT=${4}" "${awk[quoting]}${awk[json/object/merge-right-in-left]}" \
    | source /proc/self/fd/0
}

json::object::set () {
  json::__::check::lastpipe "${FUNCNAME[0]}"

  local -n getref kindref parentref
  getref="JSONGET_${3}"
  kindref="JSONKIND_${3}"
  parentref="JSONPARENT_${3}"

  json::kind::assert "${1}" "${2}" 'object' "${FUNCNAME[0]}"
  json::kind::assert "${3}" "${parentref["${4}"]}" 'object' "${FUNCNAME[0]}"
  json::object::has::assert "${1}" "${2}" "${FUNCNAME[0]}"
  json::object::has::assert "${3}" "${4}" "${FUNCNAME[0]}"

  json::object::delete "${1}" "${2}"

  local regex
  regex="${4}"
  json::object::__::fix_regex 'regex'

  {
    json::object::__::print_keys 'GET' "${1}" "${3}"
    json::object::__::print_keys 'KIND' "${1}" "${3}"
    case "${kindref["${4}"]}" in
    ( 'string'|'array'|'object' )
      json::object::__::print_keys 'LENGTH' "${1}" "${3}" ;;&
    ( 'array'|'object' )
      json::object::__::print_keys 'VALUES' "${1}" "${3}"
      json::object::__::print_keys 'PARENT' "${1}" "${3}" ;;&
    ( 'object' )
      json::object::__::print_keys 'KEYS' "${1}" "${3}" ;;
    esac
  } | match::noseparator -A 2 "^${regex}" \
    | awk -v "ROOT_LEFT=${2}" -v "ROOT_RIGHT=${4}" "${awk[quoting]}${awk[json/object/merge-right-in-left]}" \
    | source /proc/self/fd/0
}
