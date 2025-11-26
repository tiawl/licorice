#! /usr/bin/env bash

# TODO: keep JSONKEYS ?

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

json::object::new () {
  json::new "${1}"
  declare -g -A "JSONKEYS_${1}"
  local -n kindref keysref
  kindref="JSONKIND_${1}"
  kindref[.]='object'
  keysref="JSONKEYS_${1}"
  keysref[.]=''
}

json::object::has () {
  json::kind::assert "${1}" '.' 'object' "${FUNCNAME[0]}"
  local -n ref
  ref="JSONKIND_${1}"
  str not empty "${ref["${2}"]}"
}

json::object::has::assert () {
  if not json::object::has "${1}" "${2}"
  then
    unreachable "${3}" "The JSON object '${1}' must have this key '${2}'"
  fi
}

json::object::delete () {
  json::kind::assert "${1}" '.' 'object' "${FUNCNAME[0]}"
  json::object::has::assert "${1}" "${2}" "${FUNCNAME[0]}"

  local old_ifs
  old_ifs="${IFS}"
  readonly old_ifs

  IFS=$'\n'
  set -f
  unset $(
    set +f

    declare -n kindref
    kindref="JSONKIND_${1}"
    regex="${2}"
    json::object::__::fix_regex 'regex'

    print '%s\n' "${!kindref[@]}" | match "^${regex}" \
      | awk -v "JSONGET=JSONGET_${1}" \
            -v "JSONKIND=JSONKIND_${1}" \
            -v "JSONKEYS=JSONKEYS_${1}" \
            "${awk[quoting]}"'{
                print JSONGET "[" q($0) "]\n" \
                      JSONKIND "[" q($0) "]\n" \
                      JSONKEYS "[" q($0) "]"
             }'
  )
  set +f
  IFS="${old_ifs}"
}

json::object::merge () {
  json::kind::assert "${1}" "${2}" 'object' "${FUNCNAME[0]}"
  json::kind::assert "${3}" "${4}" 'object' "${FUNCNAME[0]}"
  json::object::has::assert "${1}" "${2}" "${FUNCNAME[0]}"
  json::object::has::assert "${3}" "${4}" "${FUNCNAME[0]}"

  local -n getref kindref keysref
  getref="JSONGET_${3}"
  kindref="JSONKIND_${3}"
  keysref="JSONKEYS_${3}"

  local regex
  regex="${4}"
  json::object::__::fix_regex 'regex'

  {
    print "%s\nJSONGET_${1}\nJSONGET_${3}\n" "${!getref[@]}"
    print "%s\nJSONKIND_${1}\nJSONKIND_${3}\n" "${!kindref[@]}"
    print "%s\nJSONKEYS_${1}\nJSONKEYS_${3}\n" "${!keysref[@]}"
  } | match::noseparator -A 2 "^${regex}" \
    | awk -v "ROOT_LEFT=${2}" -v "ROOT_RIGHT=${4}" "${awk[quoting]}${awk[json/object/merge-right-in-left]}" \
    | source /proc/self/fd/0
}

json::object::set () {
  json::kind::assert "${1}" '.' 'object' "${FUNCNAME[0]}"
  json::kind::assert "${3}" '.' 'object' "${FUNCNAME[0]}"
  json::object::has::assert "${1}" "${2}" "${FUNCNAME[0]}"
  json::object::has::assert "${3}" "${4}" "${FUNCNAME[0]}"

  json::object::delete "${1}" "${2}"

  local -n getref kindref keysref
  getref="JSONGET_${3}"
  kindref="JSONKIND_${3}"
  keysref="JSONKEYS_${3}"

  local regex
  regex="${4}"
  json::object::__::fix_regex 'regex'

  {
    print "%s\nJSONGET_${1}\nJSONGET_${3}\n" "${!getref[@]}"
    print "%s\nJSONKIND_${1}\nJSONKIND_${3}\n" "${!kindref[@]}"
    if str eq "${kindref["${4}"]}" 'object'
    then
      print "%s\nJSONKEYS_${1}\nJSONKEYS_${3}\n" "${!keysref[@]}"
    fi
  } | match::noseparator -A 2 "^${regex}" \
    | awk -v "ROOT_LEFT=${2}" -v "ROOT_RIGHT=${4}" "${awk[quoting]}${awk[json/object/merge-right-in-left]}" \
    | source /proc/self/fd/0
}
