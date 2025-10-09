#! /usr/bin/env bash

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

json::stringify () {
  json_xs -f string -t json
}

json::validate () {
  json_xs -t none
}

json::print::pretty () {
  local input
  input="$(cat)"
  print '%s' "${input:-"{}"}" | gojq --monochrome-output
}

json::print::compact () {
  local input
  input="$(cat)"
  print '%s' "${input:-"{}"}" | gojq --monochrome-output --compact-output
}

json::from::protobuf () {
  sed --quiet "${sed[json/from/protobuf]}"
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

json::from::yaml () {
  json::filter --yaml-input --monochrome-output --compact-output "${@}"
}
