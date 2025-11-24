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

json::object::delete () {
  json::kind::assert "${1}" '.' 'object' "${FUNCNAME[0]}"
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

    if is func rg
    then
      egrep='rg'
    else
      egrep='egrep'
    fi

    set -f
    print '%s\n' "${!kindref[@]}" | ${egrep} "^${regex}" \
      | awk -v "JSONGET=JSONGET_${1}" \
            -v "JSONKIND=JSONKIND_${1}" \
            -v "JSONKEYS=JSONKEYS_${1}" \
            "{ print JSONGET \"['\" \$0 \"']\n\" JSONKIND \"['\" \$0 \"']\n\" JSONKEYS \"['\" \$0 \"']\"; }"
  )
  set +f
  IFS="${old_ifs}"
}

json::object::merge () {
  json::kind::assert "${1}" "${2}" 'object' "${FUNCNAME[0]}"
  json::kind::assert "${3}" "${4}" 'object' "${FUNCNAME[0]}"

  source /proc/self/fd/0 <<< "$(
    regex="${4}"
    json::object::__::fix_regex 'regex'

    if is func rg
    then
      egrep='rg'
    else
      egrep='egrep'
    fi

    for func in GET KIND KEYS
    do
      declare -n ref
      ref="JSON${func}_${3}"
      set -f
      print '%s\n' "${!ref[@]}" | ${egrep} "^${regex}" \
        | awk -v "JSON_LEFT=JSON${func}_${1}" -v "ROOT_LEFT=${2}" \
              -v "JSON_RIGHT=JSON${func}_${3}" -v "ROOT_RIGHT=${4}" \
              "{
                  path = ROOT_LEFT substr(\$0, length(ROOT_RIGHT) + 1)
                  print JSON_LEFT \"['\" path \"']=\042\${\" JSON_RIGHT \"['\" \$0 \"']}\042\"
               }"
      set +f
      unset -n ref
    done
  )"
}

json::object::set () {
  json::kind::assert "${1}" "." 'object' "${FUNCNAME[0]}"
  json::object::delete "${1}" "${2}"

  source /proc/self/fd/0 <<< "$(
    regex="${4}"
    json::object::__::fix_regex 'regex'

    if is func rg
    then
      egrep='rg'
    else
      egrep='egrep'
    fi

    declare -a funcs
    funcs=( 'GET' 'KIND' )
    declare -n kind
    kind="JSONKIND_${3}"
    if str eq "${kind["${4}"]}" 'object'
    then
      funcs+=( 'KEYS' )
    fi

    for func in "${funcs[@]}"
    do
      declare -n ref
      ref="JSON${func}_${3}"
      set -f
      print '%s\n' "${!ref[@]}" | ${egrep} "^${regex}" \
        | awk -v "JSON_LEFT=JSON${func}_${1}" -v "ROOT_LEFT=${2}" \
              -v "JSON_RIGHT=JSON${func}_${3}" -v "ROOT_RIGHT=${4}" \
              "{
                  path = ROOT_LEFT substr(\$0, length(ROOT_RIGHT) + 1)
                  print JSON_LEFT \"['\" path \"']=\042\${\" JSON_RIGHT \"['\" \$0 \"']}\042\"
               }"
      set +f
      unset -n ref
    done
  )"
}
