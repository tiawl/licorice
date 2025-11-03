#! /usr/bin/env --split-string gojq --from-file

-2 as $NOINDENT |

def incrIndent(ARGS): (
  if (. == $NOINDENT) then $NOINDENT else (. + ARGS.i) end
);

def indent(ARGS): (
  ((" " * ((ARGS.level | incrIndent({"i": 1})) * 4)) // "") + .
);

def _Input: (
  # TODO
  .
);

def _Output: (
  # TODO
  .
);

def _Define(ARGS): (
  def Define(ARGS): (
    def Group(ARGS): (
      (
        if (ARGS.multilined and (ARGS.nested_register | not)) then
          {"first": "\n", "line": "\n", "last": "\n"}
        else
          {"first": " ", "line": "; ", "last": "; "}
        end
      ) as $sep |

      (
        ("{" + $sep.["first"]) | if (ARGS.indent_first) then (indent({"level": ARGS.level})) end
      ) + (
        reduce .commands[] as $item (
          {
            "mode": ARGS.mode,
            "output": ""
          };
          . as $previous |
          $item | Command({
            "level": ARGS.level | incrIndent({"i": 1}),
            "mode": $previous.mode,
            "multilines": ARGS.multilined,
            "nested_register": ARGS.nested_register
          }) | {
            "mode": .mode,
            "output": $previous.output + if (has("output")) then ($sep.line + .output) else "" end
          }
        ) | .output
      ) + $sep.["last"] + (
        (
          "}" + (
            if (has("redirections")) then (
              " " + (
                .redirections | map(
                  if (has("input")) then _Input
                  elif (has("output")) then _Output
                  else unreachable("Group") end
                )
              )
            ) else "" end
          )
        ) | indent({"level": ARGS.level})
      )
    );

    (
      (
        (
          if (ARGS.user_defined) then
            $NAMESPACE.fn.user
          else
            $NAMESPACE.fn.privileged
          end
        ) + .name + " ()\n"
      ) | indent({"level": ARGS.level})
    ) + (
      .body | Group({
        "level": ARGS.level,
        "mode": ARGS.mode,
        "multilined": true,
        "indent_first": true,
        "nested_register": ARGS.nested_register
      })
    ) + "\n"
  );

  .define | Define(ARGS)
);

def _Define_privileged: (
  _Define(-1; $MODE.privileged; false; false)
);

def Routine: (
  {
    "define": {
      "name": "root",
      "body": .routine
    }
  } | _Define_privileged
);
