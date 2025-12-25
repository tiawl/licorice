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

@test 'base' {
  local main hex
  main="$(realpath 'bats/tests/unit/routine_resolve/base.json')"
  hex="$(printf '%s' "${main}" | hexdump -v -e '/1 "%02x"')"
  "${exe}"::core::routine::dry::resolve "${main}"

  eq "${?}" '0'

  local filter id
  for id in 'inventory' 'import'
  do
    local -n get kind keys val len parent
    get="JSONGET_${id}"
    kind="JSONKIND_${id}"
    keys="JSONKEYS_${id}"
    val="JSONVALUES_${id}"
    len="JSONLENGTH_${id}"
    parent="JSONPARENT_${id}"
    declare -p "${!get}" "${!kind}" "${!keys}" "${!val}" "${!len}" "${!parent}"

    eq "${#get[@]}" '0'
    eq "${#kind[@]}" '1'
    str eq "${kind[.]}" 'object'
    eq "${#keys[@]}" '1'
    str empty "${keys[.]}"
    eq "${#val[@]}" '1'
    str empty "${val[.]}"
    eq "${#len[@]}" '1'
    eq "${len[.]}" '0'
    eq "${#parent[@]}" '0'

    unset -n get kind keys val len parent
  done

  local -n get kind keys val len parent
  get="JSONGET_${hex}"
  kind="JSONKIND_${hex}"
  keys="JSONKEYS_${hex}"
  val="JSONVALUES_${hex}"
  len="JSONLENGTH_${hex}"
  parent="JSONPARENT_${hex}"
  declare -p "${!get}" "${!kind}" "${!keys}" "${!val}" "${!len}" "${!parent}"

  eq "${#get[@]}" '2'
  str eq "${get[".\"routine\".0.\"object1\".\"member1\""]}" 'false'
  str eq "${get[".\"routine\".0.\"object1\".\"member2\""]}" 'true'

  eq "${#kind[@]}" '6'
  str eq "${kind[.]}" 'object'
  str eq "${kind[".\"routine\""]}" 'array'
  str eq "${kind[".\"routine\".0"]}" 'object'
  str eq "${kind[".\"routine\".0.\"object1\""]}" 'object'
  str eq "${kind[".\"routine\".0.\"object1\".\"member1\""]}" 'boolean'
  str eq "${kind[".\"routine\".0.\"object1\".\"member2\""]}" 'boolean'

  eq "${#keys[@]}" '3'
  str eq "${keys[.]}" ".\"routine\""
  str eq "${keys[".\"routine\".0"]}" ".\"object1\""
  str eq "${keys[".\"routine\".0.\"object1\""]}" $'."member1"\n."member2"'

  eq "${#val[@]}" '4'
  str empty "${val[.]}"
  str empty "${val[".\"routine\""]}"
  str empty "${val[".\"routine\".0"]}"
  str eq "${val[".\"routine\".0.\"object1\""]}" $'false\ntrue'

  eq "${#len[@]}" '4'
  eq "${len[.]}" '1'
  eq "${len[".\"routine\""]}" '1'
  eq "${len[".\"routine\".0"]}" '1'
  eq "${len[".\"routine\".0.\"object1\""]}" '2'

  eq "${#parent[@]}" '5'
  str eq "${parent[".\"routine\""]}" '.'
  str eq "${parent[".\"routine\".0"]}" ".\"routine\""
  str eq "${parent[".\"routine\".0.\"object1\""]}" ".\"routine\".0"
  str eq "${parent[".\"routine\".0.\"object1\".\"member1\""]}" ".\"routine\".0.\"object1\""
  str eq "${parent[".\"routine\".0.\"object1\".\"member2\""]}" ".\"routine\".0.\"object1\""
}
