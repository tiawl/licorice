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

json::print::pretty () {
  local input
  input="$(cat)"
  print '%s\n' "${input:-"{}"}" | json_pp --json_opt 'indent,space_after,indent_length=2'
}

json::print::oneline () {
  local input
  input="$(cat)"
  print '%s\n' "${input:-"{}"}" | json_pp --json_opt ''
}

json::from::protobuf () {
  sed --quiet "${sed[json/from/protobuf]}"
}

json::parse () {
  if is not set 'lastpipe'
  then
    error '%s: lastpipe must be used' "${FUNCNAME[0]}"
  fi

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
    json::print::oneline | ${grep} -a -o --color=never "${string}"'|'"${number}"'|'"${keyword}"'|'"${space}"'|.' | ${grep} -v '^'"${space}"'$'
    set +f
  }

  local json_get_init
  json_get_init="$(declare -f json::get::init || :)"
  json_get_init="${json_get_init#$'json::get::init () \n{'}"
  json_get_init="${json_get_init%"}"}"
  source /proc/self/fd/0 <<< "
    ${json_get_init:-"declare -A json_get=()"}
    $(json::parse::tokenize \
        | tee >(sed --quiet -e "${sed[json/get]}" -e "s/^/json_get[${1:--}]=\"/; s/$/\"/; p") \
              > /dev/null)"
  source /proc/self/fd/0 <<< "
    json::get::init () {
      ${json_get[@]@A}
    }
    json::get () {
      case \"\${1:-}\" in
      $(for file in ${!json_get[@]}
        do
          print '( %s ) shift; %s ;;\n' "${file}" "${json_get["${file}"]}"
        done)
      ( * ) error 'Unknown parsed file: %s' \"\${1}\" ;;
      esac
    }
    json::has () {
      json::get \"\${@}\" 2> /dev/null
    }"
  unset -f json::parse::tokenize
}
