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
            "{
                print JSONGET \"['\" \$0 \"']\n\" \
                      JSONKIND \"['\" \$0 \"']\n\" \
                      JSONKEYS \"['\" \$0 \"']\"
             }"
  )
  set +f
  IFS="${old_ifs}"
}

json::object::merge () {
  json::kind::assert "${1}" "${2}" 'object' "${FUNCNAME[0]}"
  json::kind::assert "${3}" "${4}" 'object' "${FUNCNAME[0]}"

  local -n getref kindref keysref
  getref="JSONGET_${3}"
  kindref="JSONKIND_${3}"
  keysref="JSONKEYS_${3}"
  local regex egrep
  regex="${4}"
  json::object::__::fix_regex 'regex'

  if is func rg
  then
    egrep='rg --no-context-separator'
  else
    egrep='egrep --no-group-separator'
  fi

  set -f
  {
    print "%s\nJSONGET_${1}\nJSONGET_${3}\n" "${!getref[@]}"
    print "%s\nJSONKIND_${1}\nJSONKIND_${3}\n" "${!kindref[@]}"
    print "%s\nJSONKEYS_${1}\nJSONKEYS_${3}\n" "${!keysref[@]}"
  } | ${egrep} -A 2 "^${regex}" \
    | awk -v "ROOT_LEFT=${2}" -v "ROOT_RIGHT=${4}" \
        "{
            PATH_RIGHT = \$0
            getline JSON_LEFT
            getline JSON_RIGHT
            PATH_LEFT = ROOT_LEFT substr(PATH_RIGHT, length(ROOT_RIGHT) + 1)
            print JSON_LEFT \"['\" PATH_LEFT \"']=\042\${\" JSON_RIGHT \"['\" PATH_RIGHT \"']}\042\"
         }" \
    | source /proc/self/fd/0
}

json::object::set () {
  json::kind::assert "${1}" "." 'object' "${FUNCNAME[0]}"
  json::object::delete "${1}" "${2}"

  source /proc/self/fd/0 <<< "$(
    regex="${4}"
    json::object::__::fix_regex 'regex'

    if is func rg
    then
      egrep='rg --no-context-separator'
    else
      egrep='egrep --no-group-separator'
    fi

    declare -n getref kindref keysref
    getref="JSONGET_${3}"
    kindref="JSONKIND_${3}"
    keysref="JSONKEYS_${3}"
    set -f
    {
      print "%s\nJSONGET_${1}\nJSONGET_${3}\n" "${!getref[@]}"
      print "%s\nJSONKIND_${1}\nJSONKIND_${3}\n" "${!kindref[@]}"
      if str eq "${kindref["${4}"]}" 'object'
      then
        print "%s\nJSONKEYS_${1}\nJSONKEYS_${3}\n" "${!keysref[@]}"
      fi
    } | ${egrep} -A 2 "^${regex}" \
      | awk -v "ROOT_LEFT=${2}" -v "ROOT_RIGHT=${4}" \
          "{
              PATH_RIGHT = \$0
              getline JSON_LEFT
              getline JSON_RIGHT
              PATH_LEFT = ROOT_LEFT substr(PATH_RIGHT, length(ROOT_RIGHT) + 1)
              print JSON_LEFT \"['\" PATH_LEFT \"']=\042\${\" JSON_RIGHT \"['\" PATH_RIGHT \"']}\042\"
           }"
  )"
}
