#! /usr/bin/env bash

json::object::new () {
  json::new "${1}"
  local -n ref
  ref="JSONTYPE_${1}"
  ref[.]='object'
}

json::object::has () {
  json::kind::assert "${1}" 'object' "${FUNCNAME[0]}"
  local -n ref
  ref="JSONTYPE_${1}"
  str not empty "${ref["${2}"]}"
}

json::object::delete () {
  json::kind::assert "${1}" 'object' "${FUNCNAME[0]}"
  local -n typeref
  typeref="JSONTYPE_${1}"
  local egrep old_ifs regex
  old_ifs="${IFS}"
  regex="${2//\\/\\\\}"
  regex="${regex//\//\\/}"
  regex="${regex//\./\\.}"
  regex="${regex//\*/\\*}"
  regex="${regex//\[/\\[}"
  regex="${regex//\]/\\]}"
  regex="${regex//\(/\\(}"
  regex="${regex//\)/\\)}"
  regex="${regex//\{/\\{}"
  regex="${regex//\}/\\\}}"
  regex="${regex//\$/\\$}"
  regex="${regex//\^/\\^}"
  regex="${regex//\|/\\|}"
  regex="${regex//\+/\\+}"
  regex="^${regex//\?/\\?}"

  if is func rg
  then
    egrep='rg'
  else
    egrep='egrep'
  fi

  IFS=$'\n'
  set -f
  unset $(
    print '%s\n' "${!typeref[@]}" | ${egrep} "${regex}" \
      | awk -v "JSONGET=JSONGET_${1}" \
            -v "JSONTYPE=JSONTYPE_${1}" \
            -v "JSONKEYS=JSONKEYS_${1}" \
            "{ print JSONGET \"['\" \$0 \"']\n\" JSONTYPE \"['\" \$0 \"']\n\" JSONKEYS \"['\" \$0 \"']\"; }"
  )
  set +f
  IFS="${old_ifs}"
}

json::object::set () {
  json::kind::assert "${1}" 'object' "${FUNCNAME[0]}"
  local -n typeref getret
  typeref="JSONTYPE_${1}"
  getref="JSONGET_${1}"
  json::object::delete "${1}" "${2}"
  # TODO
}

json::object::merge () {
  json::kind::assert "${1}" 'object' "${FUNCNAME[0]}"
  json::kind::assert "${2}" 'object' "${FUNCNAME[0]}"
  # TODO
}
