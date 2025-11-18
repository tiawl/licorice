#! /usr/bin/env --split-string gojq --from-file

-2 as $NOINDENT |

def incrIndent(ARGS): (
  if (. == $NOINDENT) then $NOINDENT else (. + ARGS.i) end
);

def indent(ARGS): (
  ((" " * ((ARGS.level | incrIndent({"i": 1})) * 4)) // "") + .
);

def Literal(ARGS): (
  (if (ARGS.quoted) then "'" else "" end) + . + (if (ARGS.quoted) then "'" else "" end)
);
def _Literal(ARGS): (.literal | Literal(ARGS));

def Char: (
  if (.char == "asterisk") then "*"
  elif (.char == "tilde") then "~"
  elif (.char == "atsign") then "@"
  elif (.char == "newline") then "$'\\n'"
  else unreachable("Char") end
);

def _Char: (.char | Char);
def Path: (.);
def _Path: (.["path"] | Path);
def Integer: (tostring);
def _Integer: (.int | Integer);
def Key: (.);
def _Key: (.key | Key);

def Reference: (
  if (has("integer")) then _Integer
  elif (has("key")) then _Key
  elif (has("char") and (.char == "asterisk")) then _Char
  elif (has("char") and (.char == "atsign")) then _Char
  else unreachable("Reference") end
);

def OptionalReference: (
  if (has("reference")) then Reference else "" end
);

def Sanitized(ARGS): (
  def SanitizedElement(ARGS): (
    def Dereferenced(ARGS): (
      def Expansion(ARGS): (
        # TODO
        .
      );

      def OptionalExpansion(ARGS): (
        if (has("expansion")) then Expansion(ARGS) else "" end
      );

      def DereferencedVariable(ARGS): (
        (
          if (quoted) then "\"" else "" end
        ) + "${" + .varname + OptionalReference + OptionalExpansion + "}" + (
          if (quoted) then "\"" else "" end
        )
      );

      def DereferencedSpecial(ARGS): (
        # TODO
        .special
        .reference?
        .expansion?
      );

      def DereferencedParameter(ARGS): (
        # TODO
        .parameter
        .expansion?
      );

      if (has("varname")) then DereferencedVariable(ARGS)
      elif (has("special")) then DereferencedSpecial(ARGS)
      elif (has("parameter")) then DereferencedParameter(ARGS)
      else unreachable("Dereferenced") end
    );

    if (has("literal")) then _Literal({"quoted": ARGS.quoted})
    elif (has("char")) then _Char
    elif (has("path")) then _Path
    elif (has("varname") or has("special") or has("parameter")) then Dereferenced(ARGS)
    # TODO: elif _InternalLiteral
    else unreachable("SanitizedElement") end
  );

  map(SanitizedElement(ARGS))
);

def _Input(ARGS): (
  def Input(ARGS): (
    Sanitized({
      "mode": ARGS.mode,
      "quoted": true
    })
  );

  .["input"] | Input(ARGS)
);

def _Output: (
  # TODO
  .
);

def Redirection(ARGS): (
  if (has("input")) then _Input(ARGS)
  elif (has("output")) then _Output
  else unreachable("Redirection") end
)

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
            "mode": if (has("mode")) then .mode else $previous.mode end,
            "output": $previous.output + if (has("output")) then ($sep.line + .output) else "" end
          }
        ) | .output
      ) + $sep.["last"] + (
        (
          "}" + (
            if (has("redirections")) then (
              " " + (.redirections | map(Redirection({
                "mode": ARGS.mode
              })))
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
