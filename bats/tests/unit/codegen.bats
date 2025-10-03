#! /usr/bin/env bats

setup () {
  source src/index.sh
  on errexit inherit_errexit errtrace functrace noclobber nounset pipefail lastpipe extglob
}
export -f setup

# TODO: sanitize()

@test "codegen: harden" {
  run gojq --raw-output --yaml-input "$(< jq/yml2bash/common.jq)$(< jq/yml2bash/codegen.jq) define(-1; \$MODE.internal; false; false)" --arg NAMESPACE_SEP '::' --arg EXE 'null' --arg BACKEND 'null' --arg FUNCTIONS 'null' <<EOF
define:
  name: test
  group:
    commands:
    - harden:
        command:
        - literal: ssh
    - harden:
        command:
        - var: harden_me
EOF
  eq "${status}" '0'
  eq "${#lines[@]}" '5'
  str eq "${lines[0]}" 'runner::test ()'
  str eq "${lines[1]}" '{'
  str eq "${lines[2]}" "    harden 'ssh'"
  str eq "${lines[3]}" '    harden "${harden_me}"'
  str eq "${lines[4]}" '}'
  # TODO: .harden.as
}

@test "codegen: assign" {
  run gojq --raw-output --yaml-input "$(< jq/yml2bash/common.jq)$(< jq/yml2bash/codegen.jq) define(-1; \$MODE.internal; false; false)" --arg NAMESPACE_SEP '::' --arg EXE 'null' --arg BACKEND 'null' --arg FUNCTIONS 'null' <<EOF
define:
  name: test
  group:
    commands:
    - assign:
        vars:
        - - literal: my_var1
        - - literal: my_var2
        scope: local
    - assign:
        vars:
        - - literal: my_var3
        - - literal: my_var4
        scope: global
    - assign:
        vars:
        - - literal: my_var5
        - - literal: my_var6
        type: associative
        scope: local
    - assign:
        vars:
        - - literal: my_var7
        - - literal: my_var8
        type: associative
        scope: global
    - assign:
        vars:
        - - literal: my_var9
        - - literal: my_var10
        type: indexed
        scope: local
    - assign:
        vars:
        - - literal: my_var11
        - - literal: my_var12
        type: indexed
        scope: global
    - assign:
        vars:
        - - var: A
        - - var: B
        type: reference
        scope: local
    - assign:
        vars:
        - - var: C
        - - var: D
        type: reference
        scope: global
EOF
  eq "${status}" '0'
  eq "${#lines[@]}" '11'
  str eq "${lines[0]}" 'runner::test ()'
  str eq "${lines[1]}" '{'
  str eq "${lines[2]}" "    local 'my_var1' 'my_var2'"
  str eq "${lines[3]}" "    global 'my_var3' 'my_var4'"
  str eq "${lines[4]}" "    local -A 'my_var5' 'my_var6'"
  str eq "${lines[5]}" "    global -A 'my_var7' 'my_var8'"
  str eq "${lines[6]}" "    local -a 'my_var9' 'my_var10'"
  str eq "${lines[7]}" "    global -a 'my_var11' 'my_var12'"
  str eq "${lines[8]}" '    local -n "${A}" "${B}"'
  str eq "${lines[9]}" '    global -n "${C}" "${D}"'
  str eq "${lines[10]}" '}'
  # TODO: failure case: .assign without .scope
  # TODO: failure case: .assign with .value
}

@test "codegen: mutate" {
  run gojq --raw-output --yaml-input "$(< jq/yml2bash/common.jq)$(< jq/yml2bash/codegen.jq) define(-1; \$MODE.internal; false; false)" --arg NAMESPACE_SEP '::' --arg EXE 'null' --arg BACKEND 'null' --arg FUNCTIONS 'null' <<EOF
define:
  name: test
  group:
    commands:
    - mutate:
        name:
          var: A
        value:
        - - literal: prefix_
          - var: A
            key:
            - literal: K
    - mutate:
        type: indexed
        name:
          var: arr
        value:
        - - literal: aa
        - - literal: bb
        - - literal: cc
    - mutate:
        type: associative
        name:
          var: assoc
        value:
        - - literal: key1
        - - literal: val1
        - - literal: key2
        - - literal: val2
    - mutate:
        name:
          special: last
        value:
        - - literal: a random sentence
EOF
  eq "${status}" '0'
  eq "${#lines[@]}" '7'
  str eq "${lines[0]}" 'runner::test ()'
  str eq "${lines[1]}" '{'
  str eq "${lines[2]}" "    A='prefix_'\"\${A[K]}\""
  str eq "${lines[3]}" "    arr=('aa' 'bb' 'cc')"
  str eq "${lines[4]}" "    assoc=('key1' 'val1' 'key2' 'val2')"
  str eq "${lines[5]}" "    : 'a random sentence'"
  str eq "${lines[6]}" '}'
  # TODO: failure case: .mutate without .value
  # TODO: failure case: .mutate with .scope
}

@test "codegen: define" {
  run gojq --raw-output --yaml-input "$(< jq/yml2bash/common.jq)$(< jq/yml2bash/codegen.jq) define(-1; \$MODE.internal; false; false)" --arg NAMESPACE_SEP '::' --arg EXE 'null' --arg BACKEND 'null' --arg FUNCTIONS 'null' <<EOF
define:
  name: test
  group:
    commands:
    - define:
        name: A
        group:
          commands:
          - define:
              name: AA
              group:
                commands:
                - define:
                    name: AAA
                    group:
                      commands:
                      - harden:
                          command:
                          - literal: true
                - call:
                    command: AAA
                    args: []
          - call:
              command: AA
              args: []
    - call:
        command: A
        args: []

EOF
  eq "${status}" '0'
  eq "${#lines[@]}" '16'
  str eq "${lines[0]}" 'runner::test ()'
  str eq "${lines[1]}" '{'
  str eq "${lines[2]}" "    user::A ()"
  str eq "${lines[3]}" "    {"
  str eq "${lines[4]}" "        user::AA ()"
  str eq "${lines[5]}" "        {"
  str eq "${lines[6]}" "            user::AAA ()"
  str eq "${lines[7]}" "            {"
  str eq "${lines[8]}" "                harden 'true'"
  str eq "${lines[9]}" '            }'
  str eq "${lines[10]}" "            runner::call \"\$(echo user::AAA)\""
  str eq "${lines[11]}" '        }'
  str eq "${lines[12]}" "        runner::call \"\$(echo user::AA)\""
  str eq "${lines[13]}" '    }'
  str eq "${lines[14]}" "    runner::call \"\$(echo user::A)\""
  str eq "${lines[15]}" '}'
}

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
  name: test
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
  str eq "${lines[0]}" 'runner::test ()'
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
