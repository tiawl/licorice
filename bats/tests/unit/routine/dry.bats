#! /usr/bin/env bats

setup () {
  env --ignore-environment SDIR="${PWD}" BASH_ENV="${PWD}"/src/index.sh bash --norc --noprofile "${PWD}"/compile.sh
  bin="$(printf '%s' bin/*)"
  if [[ ! -x "${bin:-}" ]]
  then
    printf 'Tests can not run because %s is not executable\n' "${bin:-}" >&2
    exit 1
  fi
  source <(head -n-1 "${bin}")
  on errexit inherit_errexit errtrace functrace noclobber nounset pipefail lastpipe extglob
  exe="$(basename "${bin}")"
  "${exe}"::core::init
}
export -f setup

routine_resolve::check_env () {
  local key id filter
  for key in 'inventory' 'import' 'routine'
  do
    case "${key}" in
    ( 'routine' ) id="${1}" ;;
    ( * ) id="${key}" ;;
    esac
    for filter in 'get' 'kind' 'keys' 'values' 'length' 'parent'
    do
      local -n ref
      ref="JSON${filter^^}_${id}"
      if gt "${BATS_TRACE_LEVEL:-0}" '0'
      then
        echo "     ${ref[@]@A}" >&3
      fi
      jq --exit-status \
        --arg KEY "${key}" \
        --arg FILTER "${filter}" \
        --arg LEN "${#ref[@]}" \
        '.[$KEY] | .[$FILTER] | length == ($LEN | tonumber)' "${2}/expected.json" > /dev/null
      jq --exit-status \
        --arg KEY "${key}" \
        --arg FILTER "${filter}" \
        'def tobool: (
           if (. == "true") then true
           elif (. == "false") then false
           else . end
         );
         (($ARGS.positional | [.[:$N], .[$N:]] | transpose | map({ (first): ((last | tonumber?) // (last | tobool)) }) | add) // {}) as $OUTPUT | .[$KEY] | .[$FILTER] == $OUTPUT' "${2}/expected.json" \
         --argjson N "${#ref[@]}" --args "${!ref[@]}" "${ref[@]}" > /dev/null
      unset -n ref
    done
  done
}

@test 'routine_resolve' {
  local test_name test_dir
  for test_dir in "$(realpath bats/tests/unit/routine/resolve)"/*
  do
    if is file "${test_dir}/input.json" && is file "${test_dir}/expected.json"
    then
      "${exe}"::core::routine::dry::resolve "${test_dir}/input.json"

      eq "${?}" '0'

      routine_resolve::check_env "$(printf '%s' "${test_dir}/input.json" | hexdump -v -e '/1 "%02x"')" "${test_dir}"

      printf '   ✓ %s: %s\n' "${BATS_TEST_DESCRIPTION}" "$(basename "${test_dir}")" >&3
    fi
  done
}
