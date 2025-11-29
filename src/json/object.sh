#! /usr/bin/env bash

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

    IFS=$'\n'
    {
      match "^${regex}" \
      | awk -v "JSONGET=JSONGET_${1}" \
            -v "JSONKIND=JSONKIND_${1}" \
            -v "JSONKEYS=JSONKEYS_${1}" \
            -v "JSONVALUES=JSONVALUES_${1}" \
            -v "JSONLENGTH=JSONLENGTH_${1}" \
            -v "JSONPARENT=JSONPARENT_${1}" \
            "${awk[quoting]}"'{
                print JSONGET "[" q($0) "]\n" \
                      JSONKIND "[" q($0) "]\n" \
                      JSONKEYS "[" q($0) "]\n" \
                      JSONVALUES "[" q($0) "]\n" \
                      JSONLENGTH "[" q($0) "]\n" \
                      JSONPARENT "[" q($0) "]"
             }'
    } <<< "${!kindref[@]}"
  )
  set +f
  IFS="${old_ifs}"
}

json::object::merge () {
  json::kind::assert "${1}" "${2}" 'object' "${FUNCNAME[0]}"
  json::kind::assert "${3}" "${4}" 'object' "${FUNCNAME[0]}"
  json::object::has::assert "${1}" "${2}" "${FUNCNAME[0]}"
  json::object::has::assert "${3}" "${4}" "${FUNCNAME[0]}"

  local -n getref kindref keysref valref lenref parentref
  getref="JSONGET_${3}"
  kindref="JSONKIND_${3}"
  keysref="JSONKEYS_${3}"
  valref="JSONVALUES_${3}"
  lenref="JSONLENGTH_${3}"
  parentref="JSONPARENT_${3}"

  local regex
  regex="${4}"
  json::object::__::fix_regex 'regex'

  {
    print "%s\nJSONGET_${1}\nJSONGET_${3}\n" "${!getref[@]}"
    print "%s\nJSONKIND_${1}\nJSONKIND_${3}\n" "${!kindref[@]}"
    print "%s\nJSONKEYS_${1}\nJSONKEYS_${3}\n" "${!keysref[@]}"
    print "%s\nJSONVALUES_${1}\nJSONVALUES_${3}\n" "${!valref[@]}"
    print "%s\nJSONLENGTH_${1}\nJSONLENGTH_${3}\n" "${!lenref[@]}"
    print "%s\nJSONPARENT_${1}\nJSONPARENT_${3}\n" "${!parentref[@]}"
  } | match::noseparator -A 2 "^${regex}" \
    | awk -v "ROOT_LEFT=${2}" -v "ROOT_RIGHT=${4}" "${awk[quoting]}${awk[json/object/merge-right-in-left]}" \
    | source /proc/self/fd/0
}

json::object::set () {
  local -n getref kindref keysref valref lenref parentref
  parentref="JSONPARENT_${3}"

  json::kind::assert "${1}" "${2}" 'object' "${FUNCNAME[0]}"
  json::kind::assert "${3}" "${parentref["${4}"]}" 'object' "${FUNCNAME[0]}"
  json::object::has::assert "${1}" "${2}" "${FUNCNAME[0]}"
  json::object::has::assert "${3}" "${4}" "${FUNCNAME[0]}"

  json::object::delete "${1}" "${2}"

  getref="JSONGET_${3}"
  kindref="JSONKIND_${3}"
  keysref="JSONKEYS_${3}"
  valref="JSONVALUES_${3}"
  lenref="JSONLENGTH_${3}"

  local regex
  regex="${4}"
  json::object::__::fix_regex 'regex'

  {
    print "%s\nJSONGET_${1}\nJSONGET_${3}\n" "${!getref[@]}"
    print "%s\nJSONKIND_${1}\nJSONKIND_${3}\n" "${!kindref[@]}"
    case "${kindref["${4}"]}" in
    ( 'string' )
      print "%s\nJSONLENGTH_${1}\nJSONLENGTH_${3}\n" "${!lenref[@]}" ;;
    ( 'array' )
      print "%s\nJSONVALUES_${1}\nJSONVALUES_${3}\n" "${!valref[@]}"
      print "%s\nJSONLENGTH_${1}\nJSONLENGTH_${3}\n" "${!lenref[@]}"
      print "%s\nJSONPARENT_${1}\nJSONPARENT_${3}\n" "${!parentref[@]}" ;;
    ( 'object' )
      print "%s\nJSONKEYS_${1}\nJSONKEYS_${3}\n" "${!keysref[@]}"
      print "%s\nJSONVALUES_${1}\nJSONVALUES_${3}\n" "${!valref[@]}"
      print "%s\nJSONLENGTH_${1}\nJSONLENGTH_${3}\n" "${!lenref[@]}"
      print "%s\nJSONPARENT_${1}\nJSONPARENT_${3}\n" "${!parentref[@]}" ;;
    ( * ) : ;;
    esac
  } | match::noseparator -A 2 "^${regex}" \
    | awk -v "ROOT_LEFT=${2}" -v "ROOT_RIGHT=${4}" "${awk[quoting]}${awk[json/object/merge-right-in-left]}" \
    | source /proc/self/fd/0
}
