#! /usr/bin/env bash

json::encode () {
  local -n ref
  ref="${1}"
  if is associative "${!ref}"
  then
    gojq --null-input --raw-output --monochrome-output --compact-output '($ARGS.positional | [.[:$n], .[$n:]] | transpose | map(last as $last | {(first): (if (($last | type == "number") or (($last | type == "string") and ($last | test("^[0-9]+$")))) then ($last | tostring) else (try ($last | fromjson) catch $last) end)}) | add) // {}' --argjson n "${#ref[@]}" --args -- "${!ref[@]}" "${ref[@]}"
  elif is indexed "${!ref}"
  then
    gojq --null-input --raw-output --monochrome-output --compact-output '$ARGS.positional | map(. as $item | try (fromjson) catch $item)' --args -- "${ref[@]}"
  else
    error 'Only usable with indexed and associative array'
  fi
  unset -n ref
}

json::parse::tokenize () {
  local escape char string number keyword space grep

  escape='(\\[^u[:cntrl:]]|\\u[0-9a-fA-F]{4})'
  char='[^[:cntrl:]"\\]'
  string='"'"${char}"'*('"${escape}${char}"'*)*"'
  number='-?(0|[1-9][0-9]*)([.][0-9]*)?([eE][+-]?[0-9]*)?'
  keyword='null|false|true'
  space='[[:space:]]+'

  if is func rg
  then
    grep='rg'
  else
    grep='egrep'
  fi

  set -f
  ${grep} -a -o --color=never "${string}"'|'"${number}"'|'"${keyword}"'|'"${space}"'|.' | ${grep} -v '^'"${space}"'$'
  set +f
}

json::validate () {
  json_pp 2> /dev/null
}

json::parse () {
  json::validate \
    | json::parse::tokenize \
    | tee \
      >(sed --quiet "${sed[json/get]}") \
      > /dev/null
}

json::get () {
  : MARKER
}

json () {
  case "${1}" in
  ( encode ) json::encode "${@:2}" ;;
  ( parse ) json::parse "${@:2}" ;;
  ( validate ) json::validate "${@:2}" ;;
  ( get ) json::get "${@:2}" ;;
  ( * ) error 'Unknown json subcommand: "%s"' "${1}" ;;
  esac
}
