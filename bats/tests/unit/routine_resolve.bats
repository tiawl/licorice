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
  exe="$(path::base "${bin}")"
  "${exe}"::core::init
}
export -f setup

check_env () {
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
      declare -p "${!ref}"
      jq --exit-status \
        --arg KEY "${key}" \
        --arg FILTER "${filter}" \
        --arg LEN "${#ref[@]}" \
        '.[$KEY] | .[$FILTER] | length == ($LEN | tonumber)' "bats/tests/unit/routine_resolve/${2}/expected.json" > /dev/null
      jq --exit-status \
        --arg KEY "${key}" \
        --arg FILTER "${filter}" \
        'def tobool: (
           if (. == "true") then true
           elif (. == "false") then false
           else . end
         );
         (($ARGS.positional | [.[:$N], .[$N:]] | transpose | map({ (first): ((last | tonumber?) // (last | tobool)) }) | add) // {}) as $OUTPUT | .[$KEY] | .[$FILTER] == $OUTPUT' "bats/tests/unit/routine_resolve/${2}/expected.json" \
         --argjson N "${#ref[@]}" --args "${!ref[@]}" "${ref[@]}" > /dev/null
      unset -n ref
    done
  done
}

@test 'TODO' {
  local test_name test_input hex
  for test_name in 'base'
  do
    test_input="$(realpath "bats/tests/unit/routine_resolve/${test_name}/input.json")"
    hex="$(printf '%s' "${test_input}" | hexdump -v -e '/1 "%02x"')"
    "${exe}"::core::routine::dry::resolve "${test_input}"

    eq "${?}" '0'

    check_env "${hex}" "${test_name}"
  done
}
