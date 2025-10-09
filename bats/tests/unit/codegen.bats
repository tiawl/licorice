#! /usr/bin/env bats

setup () {
  source src/index.sh
  on errexit inherit_errexit errtrace functrace noclobber nounset pipefail lastpipe extglob
}
export -f setup

# TODO: sanitize()

@test 'codegen: harden' {
  run gojq --raw-output --yaml-input "$(< jq/routine/common.jq)$(< jq/routine/types.jq)$(< jq/routine/codegen.jq) define(-1; \$MODE.internal; false; false)" --arg NAMESPACE_SEP '::' --arg EXE 'null' --arg BACKEND 'null' --arg FUNCTIONS 'null' <<EOF
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
    - harden:
        command:
        - literal: ssh-keygen
        as:
        - literal: ssh_keygen
EOF
  eq "${status}" '0'
  eq "${#lines[@]}" '6'
  str eq "${lines[0]}" 'routine::test ()'
  str eq "${lines[1]}" '{'
  str eq "${lines[2]}" "    harden 'ssh'"
  str eq "${lines[3]}" '    harden "${harden_me}"'
  str eq "${lines[4]}" "    harden 'ssh-keygen' 'ssh_keygen'"
  str eq "${lines[5]}" '}'
}

@test 'codegen: assign' {
  run gojq --raw-output --yaml-input "$(< jq/routine/common.jq)$(< jq/routine/types.jq)$(< jq/routine/codegen.jq) define(-1; \$MODE.internal; false; false)" --arg NAMESPACE_SEP '::' --arg EXE 'null' --arg BACKEND 'null' --arg FUNCTIONS 'null' <<EOF
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
  str eq "${lines[0]}"  'routine::test ()'
  str eq "${lines[1]}"  '{'
  str eq "${lines[2]}"  "    local 'my_var1' 'my_var2'"
  str eq "${lines[3]}"  "    global 'my_var3' 'my_var4'"
  str eq "${lines[4]}"  "    local -A 'my_var5' 'my_var6'"
  str eq "${lines[5]}"  "    global -A 'my_var7' 'my_var8'"
  str eq "${lines[6]}"  "    local -a 'my_var9' 'my_var10'"
  str eq "${lines[7]}"  "    global -a 'my_var11' 'my_var12'"
  str eq "${lines[8]}"  '    local -n "${A}" "${B}"'
  str eq "${lines[9]}"  '    global -n "${C}" "${D}"'
  str eq "${lines[10]}" '}'

  # FAILURE CASES:
  run gojq --raw-output --yaml-input "$(< jq/routine/common.jq)$(< jq/routine/types.jq)$(< jq/routine/codegen.jq) define(-1; \$MODE.internal; false; false)" --arg NAMESPACE_SEP '::' --arg EXE 'null' --arg BACKEND 'null' --arg FUNCTIONS 'null' <<EOF > /dev/null 2>&1
define:
  name: test
  group:
    commands:
    - assign:
        vars:
        - - literal: my_var1
EOF
  not eq "${status}" '0'
  run gojq --raw-output --yaml-input "$(< jq/routine/common.jq)$(< jq/routine/types.jq)$(< jq/routine/codegen.jq) define(-1; \$MODE.internal; false; false)" --arg NAMESPACE_SEP '::' --arg EXE 'null' --arg BACKEND 'null' --arg FUNCTIONS 'null' <<EOF > /dev/null 2>&1
define:
  name: test
  group:
    commands:
    - assign:
        vars:
        - - literal: my_var1
        scope: local
        value:
        - - literal: test
EOF
  not eq "${status}" '0'
}

@test 'codegen: mutate' {
  run gojq --raw-output --yaml-input "$(< jq/routine/common.jq)$(< jq/routine/types.jq)$(< jq/routine/codegen.jq) define(-1; \$MODE.internal; false; false)" --arg NAMESPACE_SEP '::' --arg EXE 'null' --arg BACKEND 'null' --arg FUNCTIONS 'null' <<EOF
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
  str eq "${lines[0]}" 'routine::test ()'
  str eq "${lines[1]}" '{'
  str eq "${lines[2]}" "    A='prefix_'\"\${A[K]}\""
  str eq "${lines[3]}" "    arr=('aa' 'bb' 'cc')"
  str eq "${lines[4]}" "    assoc=('key1' 'val1' 'key2' 'val2')"
  str eq "${lines[5]}" "    : 'a random sentence'"
  str eq "${lines[6]}" '}'

  # FAILURE CASES:
  run gojq --raw-output --yaml-input "$(< jq/routine/common.jq)$(< jq/routine/types.jq)$(< jq/routine/codegen.jq) define(-1; \$MODE.internal; false; false)" --arg NAMESPACE_SEP '::' --arg EXE 'null' --arg BACKEND 'null' --arg FUNCTIONS 'null' <<EOF > /dev/null 2>&1
define:
  name: test
  group:
    commands:
    - mutate:
        name:
          var: A
EOF
  not eq "${status}" '0'
  run gojq --raw-output --yaml-input "$(< jq/routine/common.jq)$(< jq/routine/types.jq)$(< jq/routine/codegen.jq) define(-1; \$MODE.internal; false; false)" --arg NAMESPACE_SEP '::' --arg EXE 'null' --arg BACKEND 'null' --arg FUNCTIONS 'null' <<EOF > /dev/null 2>&1
define:
  name: test
  group:
    - mutate:
        name:
          var: A
        scope: local
        value:
        - - literal: test
EOF
  not eq "${status}" '0'
}

@test 'codegen: define' {
  # TODO: change define.group with define.body.group
  run gojq --raw-output --yaml-input "$(< jq/routine/common.jq)$(< jq/routine/types.jq)$(< jq/routine/codegen.jq) define(-1; \$MODE.internal; false; false)" --arg NAMESPACE_SEP '::' --arg EXE 'null' --arg BACKEND 'null' --arg FUNCTIONS 'null' <<EOF
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
                    command:
                    - literal: AAA
                    args: []
          - call:
              command:
              - literal: AA
              args: []
    - call:
        command:
        - literal: A
        args: []
EOF
  eq "${status}" '0'
  eq "${#lines[@]}" '16'
  str eq "${lines[0]}"  'routine::test ()'
  str eq "${lines[1]}"  '{'
  str eq "${lines[2]}"  '    user::A ()'
  str eq "${lines[3]}"  '    {'
  str eq "${lines[4]}"  '        user::AA ()'
  str eq "${lines[5]}"  '        {'
  str eq "${lines[6]}"  '            user::AAA ()'
  str eq "${lines[7]}"  '            {'
  str eq "${lines[8]}"  "                harden 'true'"
  str eq "${lines[9]}"  '            }'
  str eq "${lines[10]}" "            routine::call \"\$(echo 'user::''AAA')\""
  str eq "${lines[11]}" '        }'
  str eq "${lines[12]}" "        routine::call \"\$(echo 'user::''AA')\""
  str eq "${lines[13]}" '    }'
  str eq "${lines[14]}" "    routine::call \"\$(echo 'user::''A')\""
  str eq "${lines[15]}" '}'
}

@test 'codegen: readonly' {
  run gojq --raw-output --yaml-input "$(< jq/routine/common.jq)$(< jq/routine/types.jq)$(< jq/routine/codegen.jq) define(-1; \$MODE.internal; false; false)" --arg NAMESPACE_SEP '::' --arg EXE 'null' --arg BACKEND 'null' --arg FUNCTIONS 'null' <<EOF
define:
  name: test
  group:
    commands:
    - readonly:
      - - literal: prefix_
        - var: A
        - literal: _suffix
      - - literal: B
EOF
  eq "${status}" '0'
  eq "${#lines[@]}" '4'
  str eq "${lines[0]}" 'routine::test ()'
  str eq "${lines[1]}" '{'
  str eq "${lines[2]}" "    readonly -- 'prefix_'\"\${A}\"'_suffix' 'B'"
  str eq "${lines[3]}" '}'
}

@test 'codegen: if' {
  run gojq --raw-output --yaml-input "$(< jq/routine/common.jq)$(< jq/routine/types.jq)$(< jq/routine/codegen.jq) define(-1; \$MODE.internal; false; false)" --arg NAMESPACE_SEP '::' --arg EXE 'null' --arg BACKEND 'null' --arg FUNCTIONS 'null' <<EOF
define:
  name: test
  group:
    commands:
    - if:
        conditional:
          group:
            commands:
            - raw:
                command: true
                args: []
        then:
          group:
            commands:
            - raw:
                command: true
                args: []
    - if:
        conditional:
          not:
            not:
              not:
                group:
                  commands:
                  - raw:
                      command: true
                      args: []
        then:
          group:
            commands:
            - raw:
                command: true
                args: []
    - if:
        conditional:
          group:
            commands:
            - raw:
                command: true
                args: []
        then:
          group:
            commands:
            - raw:
                command: true
                args: []
        else:
        - then:
            group:
              commands:
              - raw:
                  command: false
                  args: []
    - if:
        conditional:
          group:
            commands:
            - raw:
                command: true
                args: []
        then:
          group:
            commands:
            - raw:
                command: true
                args: []
        else:
        - conditional:
            group:
              commands:
              - raw:
                  command: false&&true
                  args: []
          then:
            group:
              commands:
              - raw:
                  command: false&&true
                  args: []
        - then:
            group:
              commands:
              - raw:
                  command: false
                  args: []
    - if:
        conditional:
          group:
            commands:
            - raw:
                command: true
                args: []
        then:
          group:
            commands:
            - if:
                conditional:
                  group:
                    commands:
                    - raw:
                        command: true
                        args: []
                then:
                  group:
                    commands:
                    - if:
                        conditional:
                          group:
                            commands:
                            - raw:
                                command: true
                                args: []
                        then:
                          group:
                            commands:
                            - raw:
                                command: true
                                args: []
        else:
        - then:
            group:
              commands:
              - if:
                  conditional:
                    group:
                      commands:
                      - raw:
                          command: true
                          args: []
                  then:
                    group:
                      commands:
                      - raw:
                          command: true
                          args: []
                  else:
                  - then:
                      group:
                        commands:
                        - if:
                            conditional:
                              group:
                                commands:
                                - raw:
                                    command: true
                                    args: []
                            then:
                              group:
                                commands:
                                - raw:
                                    command: true
                                    args: []
                            else:
                            - conditional:
                                group:
                                  commands:
                                  - raw:
                                      command: false&&true
                                      args: []
                              then:
                                group:
                                  commands:
                                  - raw:
                                      command: false&&true
                                      args: []
                            - then:
                                group:
                                  commands:
                                  - raw:
                                      command: false
                                      args: []
EOF
  eq "${status}" '0'
  eq "${#lines[@]}" '40'
  str eq "${lines[0]}"  'routine::test ()'
  str eq "${lines[1]}"  '{'
  str eq "${lines[2]}"  '    if { true; }; then {'
  str eq "${lines[3]}"  '        true'
  str eq "${lines[4]}"  '    } fi'
  str eq "${lines[5]}"  '    if { ! { ! { ! { true; }; }; }; }; then {'
  str eq "${lines[6]}"  '        true'
  str eq "${lines[7]}"  '    } fi'
  str eq "${lines[8]}"  '    if { true; }; then {'
  str eq "${lines[9]}"  '        true'
  str eq "${lines[10]}" '    } else {'
  str eq "${lines[11]}" '        false'
  str eq "${lines[12]}" '    } fi'
  str eq "${lines[13]}" '    if { true; }; then {'
  str eq "${lines[14]}" '        true'
  str eq "${lines[15]}" '    } elif { false&&true; }; then {'
  str eq "${lines[16]}" '        false&&true'
  str eq "${lines[17]}" '    } else {'
  str eq "${lines[18]}" '        false'
  str eq "${lines[19]}" '    } fi'
  str eq "${lines[20]}" '    if { true; }; then {'
  str eq "${lines[21]}" '        if { true; }; then {'
  str eq "${lines[22]}" '            if { true; }; then {'
  str eq "${lines[23]}" '                true'
  str eq "${lines[24]}" '            } fi'
  str eq "${lines[25]}" '        } fi'
  str eq "${lines[26]}" '    } else {'
  str eq "${lines[27]}" '        if { true; }; then {'
  str eq "${lines[28]}" '            true'
  str eq "${lines[29]}" '        } else {'
  str eq "${lines[30]}" '            if { true; }; then {'
  str eq "${lines[31]}" '                true'
  str eq "${lines[32]}" '            } elif { false&&true; }; then {'
  str eq "${lines[33]}" '                false&&true'
  str eq "${lines[34]}" '            } else {'
  str eq "${lines[35]}" '                false'
  str eq "${lines[36]}" '            } fi'
  str eq "${lines[37]}" '        } fi'
  str eq "${lines[38]}" '    } fi'
  str eq "${lines[39]}" '}'
}

@test 'codegen: loop' {
  run gojq --raw-output --yaml-input "$(< jq/routine/common.jq)$(< jq/routine/types.jq)$(< jq/routine/codegen.jq) define(-1; \$MODE.internal; false; false)" --arg NAMESPACE_SEP '::' --arg EXE 'null' --arg BACKEND 'null' --arg FUNCTIONS 'null' <<EOF
define:
  name: test
  group:
    commands:
    - loop:
        range:
          initial:
            arithmetic:
              assignment:
                left:
                  literal: i
                right:
                  number: 0
          conditional:
            arithmetic:
              lt:
                left:
                  literal: i
                right:
                  number: 10
          update:
            arithmetic:
              increment:
                left:
                  literal: i
                right:
                  number: 1
        do:
          group:
            commands:
            - raw:
                command: true
                args: []
EOF
  eq "${status}" '0'
  eq "${#lines[@]}" '6'
  str eq "${lines[0]}" 'routine::test ()'
  str eq "${lines[1]}" '{'
  str eq "${lines[2]}" '    for (( i = 0; i < 10; i += 1 )); do {'
  str eq "${lines[3]}" '        true'
  str eq "${lines[4]}" '    } done'
  str eq "${lines[5]}" '}'
  # TODO: @test 'codegen: loop iterator'
  # TODO: @test 'codegen: loop conditional'
  # TODO: @test 'codegen: nested loops'
}

# TODO: @test 'codegen: switch'
# TODO: @test 'codegen: defer'
# TODO: @test 'codegen: register'
# TODO: @test 'codegen: parameters'
# TODO: @test 'codegen: capture/restore'

@test 'codegen: on/off' {
  run gojq --raw-output --yaml-input "$(< jq/routine/common.jq)$(< jq/routine/types.jq)$(< jq/routine/codegen.jq) define(-1; \$MODE.internal; false; false)" --arg NAMESPACE_SEP '::' --arg EXE 'null' --arg BACKEND 'null' --arg FUNCTIONS 'null' <<EOF
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
  str eq "${lines[0]}" 'routine::test ()'
  str eq "${lines[1]}" '{'
  str eq "${lines[2]}" "    on 'errexit' 'inherit_errexit' 'errtrace' 'functrace' 'noclubber' 'nounset' 'pipefail' 'lastpipe' 'extglob'"
  str eq "${lines[3]}" "    off 'errexit' 'inherit_errexit' 'errtrace' 'functrace' 'noclubber' 'nounset' 'pipefail' 'lastpipe' 'extglob'"
  str eq "${lines[4]}" '}'
}

# TODO: @test 'codegen: json'
# TODO: @test 'codegen: color'
# TODO: @test 'codegen: source'
# TODO: @test 'codegen: arithmetic'
# TODO: @test 'codegen: print'
# TODO: @test 'codegen: return'
# TODO: @test 'codegen: skip'
# TODO: @test 'codegen: split'
# TODO: @test 'codegen: routine'
# TODO: @test 'codegen: group'
# TODO: @test 'codegen: raw'
# TODO: @test 'codegen: coproc'
# TODO: @test 'codegen: initialized'
# TODO: @test 'codegen: core'
