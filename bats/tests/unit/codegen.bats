#! /usr/bin/env bats

setup () {
  source src/index.sh
  on errexit inherit_errexit errtrace functrace noclobber nounset pipefail lastpipe extglob
}
export -f setup

# TODO: @test "codegen: harden"
# TODO: @test "codegen: assign"
# TODO: @test "codegen: mutate"
# TODO: @test "codegen: define"
# TODO: @test "codegen: readonly"
# TODO: @test "codegen: if"
# TODO: @test "codegen: if/else"
# TODO: @test "codegen: if/elif/else"
# TODO: @test "codegen: nested if"
# TODO: @test "codegen: nested if/elif/else"
# TODO: @test "codegen: loop arithmetic"
# TODO: @test "codegen: loop iterator"
# TODO: @test "codegen: loop conditional"
# TODO: @test "codegen: nested loops"
# TODO: @test "codegen: switch"
# TODO: @test "codegen: defer"
# TODO: @test "codegen: register"
# TODO: @test "codegen: parameters"
# TODO: @test "codegen: capture/restore"

@test "codegen: on/off" {
  run gojq --raw-output --yaml-input "$(< jq/yml2bash/common.jq)$(< jq/yml2bash/codegen.jq) define(-1; \$MODE.internal; false; false)" --arg NAMESPACE_SEP '::' --arg EXE 'null' --arg BACKEND 'null' --arg FUNCTIONS 'null' <<EOF
define:
  name: main
  group:
    commands:
    - on:
      - - literal: errexit
      - - literal: inherit_errexit
      - - literal: errtrace
      - - literal: functrace
      - - literal: noclubber
      - - literal: nounset
      - - literal: pipefail
      - - literal: lastpipe
      - - literal: extglob
    - off:
      - - literal: errexit
      - - literal: inherit_errexit
      - - literal: errtrace
      - - literal: functrace
      - - literal: noclubber
      - - literal: nounset
      - - literal: pipefail
      - - literal: lastpipe
      - - literal: extglob
EOF
  eq "${status}" '0'
  eq "${#lines[@]}" '5'
  str eq "${lines[0]}" 'runner::main ()'
  str eq "${lines[1]}" '{'
  str eq "${lines[2]}" "    on 'errexit' 'inherit_errexit' 'errtrace' 'functrace' 'noclubber' 'nounset' 'pipefail' 'lastpipe' 'extglob'"
  str eq "${lines[3]}" "    off 'errexit' 'inherit_errexit' 'errtrace' 'functrace' 'noclubber' 'nounset' 'pipefail' 'lastpipe' 'extglob'"
  str eq "${lines[4]}" '}'
}

# TODO: @test "codegen: json"
# TODO: @test "codegen: color"
# TODO: @test "codegen: source"
# TODO: @test "codegen: arithmetic"
# TODO: @test "codegen: print"
# TODO: @test "codegen: return"
# TODO: @test "codegen: skip"
# TODO: @test "codegen: split"
# TODO: @test "codegen: runner"
# TODO: @test "codegen: group"
# TODO: @test "codegen: raw"
# TODO: @test "codegen: coproc"
# TODO: @test "codegen: initialized"
# TODO: @test "codegen: core"
