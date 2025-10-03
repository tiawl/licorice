#! /usr/bin/env --split-string gojq --from-file

def internals(level): (
  [
    {
      define: {
        name: "call",
        group: {
          commands: [
            {assign: {vars: [[{literal: "authorized"}]], scope: "local"}},
            {
              register: {
                into: {var: "authorized"},
                group: {commands: [{raw: {command: "compgen", args: [[{literal: "-A"}], [{literal: "function"}], [{literal: "-X"}], [{literal: ("!" + $NAMESPACE.fn.user + "*")}]]}}]}
              }
            },
            {parameters: [[{var: "authorized"}], [{literal: "|"}], [{parameter: 1}]]},
            {
              switch: {
                evaluate: [{parameter: 2}, {parameter: 1, replace: {all: [{char: "newline"}], with: [{parameter: 2}]}}, {parameter: 2}],
                branches: [
                  {pattern: [{char: "asterisk"}, {parameter: 2}, {parameter: 3, replace: {end: [{literal: " "}, {char: "asterisk"}], match: "longest"}}, {parameter: 2}, {char: "asterisk"}], group: {commands: [{source: {from: [{print: {format: "%s", args: [[{parameter: 3}]]}}]}}]}},
                  {pattern: [{char: "asterisk"}], group: {commands: [{group: {commands: [{print: {format: "Unknown \"%s\". You probably forgot to harden a command, to define a function or to enable a disabled builtin\\n", args: [[{parameter: 3}]]}}], redirections: [{output: {left: {fd: 1}, right: {fd: 2}}}]}}, {return: 1}]}}
                ]
              }
            }
          ]
        }
      }
    },
    {
      define: {
        name: "autoincr",
        group: {
          commands: [
            {assign: {vars: [[{literal: "ref"}]], type: "reference", scope: "local"}},
            {mutate: {name: {var: "ref"}, value: [[{parameter: 1}]]}},
            {mutate: {name: {var: "ref"}, value: [[{literal: "1"}]]}},
            {assign: {vars: [[{literal: "fn"}]], scope: "local"}},
            {
              register: {
                into: {var: "fn"},
                group: {commands: [{raw: {command: "declare", args: [[{literal: "-f"}], [{special: "FUNCNAME", index: 0}]], pipe: {group: {commands: [{raw: {command: "sed", args: [[{var: "sed", key: [{literal: "autoincr"}]}]]}}]}}}}]}
              }
            },
            {source: {string: [[{var: "fn"}]]}}
          ]
        }
      }
    },
    {
      define: {
        name: "color",
        group: {
          commands: [
            {assign: {vars: [[{literal: "i"}]], scope: "local"}},
            {
              register: {
                into: {var: "i"},
                arithmetic: {remainder: {left: {arithmetic: {substraction: {left: {parameter: 1}, right: {number: 1}}}}, right: {number: ($ARGS.positional | length)}}}
              }
            },
            {assign: {vars: [[{literal: "colors"}]], type: "indexed", scope: "local"}},
            {mutate: {name: {var: "colors"}, type: "indexed", value: [$ARGS.positional | map([{literal: .}])]}},
            {assign: {vars: [[{literal: "ref"}]], type: "reference", scope: "local"}},
            {mutate: {name: {var: "ref"}, value: [[{parameter: 2}]]}},
            {mutate: {name: {var: "ref"}, value: [[{var: "colors", key: [{var: "i"}]}]]}}
          ]
        }
      }
    },
    {
      define: {
        name: "xtrace",
        group: {
          commands: [
            {raw: {command: ($NAMESPACE.fn.internal + "autoincr"), args: [[{literal: "reply"}]]}},
            {parameters: [[{parameter: 1}], [{var: "reply"}]]},
            {raw: {command: ($NAMESPACE.fn.internal + "color"), args: [[{parameter: 2}], [{literal: "reply"}]]}},
            {parameters: [[{parameter: 1}], [{parameter: 2}], [{var: "reply"}]]},
            {group: {commands: [{print: {format: "%b\\033[1m%s\\033[0m > %s\\n", args: [[{literal: "\\033[38;5;"}, {parameter: 3}, {literal: "m"}], [{parameter: 2}], [{parameter: 1}]]}}], redirections: [{output: {left: {fd: 1}, right: {fd: 2}}}]}}
          ]
        }
      }
    },
    {
      define: {
        name: "register",
        group: {
          commands: [
            {assign: {vars: [[{literal: "ref"}]], type: "reference", scope: "local"}},
            {mutate: {name: {var: "ref"}, value: [[{parameter: 1}]]}},
            {assign: {vars: [[{literal: "source_me"}]], type: "indexed", scope: "local"}},
            {coproc: {name: "CAT", group: {commands: [{raw: {command: "cat", args: []}}]}}},
            {register: {into: {var: "ref"}, group: {commands: [{source: {string: [[{parameter: 2}]]}}, {group: {commands: [{raw: {command: "declare", args:[[{literal: "-f"}], [{literal: ($NAMESPACE.fn.internal + "autoincr")}]]}}], redirections: [{output: {left: {fd: 1}, right: {var: "CAT", index: 1}}}]}}]}}},
            {raw: {command: "exec", args: [[{unsafe: "{CAT[1]}>&-"}]]}},
            {group: {commands: [{raw: {command: "mapfile", args: [[{literal: "source_me"}]]}}], redirections: [{input: {var: "CAT", index: 0}}]}},
            {source: {string: [[{var: "source_me", key: [{char: "atsign"}]}]]}}
          ]
        }
      }
    }
  ] | map(define(level; $MODE.internal; false; false)) | join("")
);

def main(level): (
  {
    define: {
      name: "main",
      group: {
        commands: (
          [
            {on: [[{literal: "errexit"}], [{literal: "inherit_errexit"}], [{literal: "errtrace"}], [{literal: "functrace"}], [{literal: "noclobber"}], [{literal: "nounset"}], [{literal: "pipefail"}], [{literal: "lastpipe"}], [{literal: "extglob"}]]},
            {raw: {command: ($EXE + $NAMESPACE.sep + "core" + $NAMESPACE.sep + "init"), args: []}},
            {assign: {vars: [[{literal: "USER"}], [{literal: "HOME"}], [{literal: "RUNNER"}]], scope: "global"}},
            {
              register: {
                group: {commands: [{skip: [[{literal: "\\u"}]]}, {print: {format: "%s", args: [[{special: "last", "prompt": true}]]}}]},
                into: {special: "last"}
              }
            },
            {mutate: {name: {var: "USER"}, value: [[{special: "USER", default: [{special: "last"}]}]]}},
            {print: {format: "%s", var: "HOME", args: [[{char: "tilde"}]]}},
            {mutate: {name: {var: "RUNNER"}, value: [[{literal: $RUNNER}]]}},
            {readonly: [[{literal: "USER"}], [{literal: "HOME"}], [{literal: "RUNNER"}]]},
            {initialized: true}
          ] + .group.commands
        )
      }
    }
  } | define(level; $MODE.internal; false; false)
);

def write: (
  -1 as $level |
  $FUNCTIONS + "\n" +
  internals($level) +
  main($level) +
  $NAMESPACE.fn.internal + "main \"${@}\""
);

write
