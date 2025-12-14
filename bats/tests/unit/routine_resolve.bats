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

@test 'resolve before running routine 1' {
  run "${exe}"::core::routine::dry::resolve <(cat <<EOF
{
  "routine": [
    {
      "object1": {
        "member1": false,
        "member2": true
      }
    }
  ]
}
EOF
)

#  eq "${status}" '0'
}
