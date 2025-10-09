#! /usr/bin/env --split-string gojq --from-file

{
  var: {
    user: "__"
  },
  fn: {
    internal: ("routine" + $ARGS.named.NAMESPACE_SEP),
    user: ("user" + $ARGS.named.NAMESPACE_SEP)
  },
  sep: $ARGS.named.NAMESPACE_SEP
} as $NAMESPACE |
{
  internal: -1,
  quiet: 0,
  user: 1
} as $MODE |
{
  TYPE: {
    NULL: "null",
    BOOLEAN: "boolean",
    NUMBER: "number",
    STRING: "string",
    ARRAY: "array",
    OBJECT: "object"
  }
} as $JSON |
{
  SCOPE: {
    LOCAL: "local",
    GLOBAL: "global"
  },
  TYPE: {
    STRING: "string",
    ASSOCIATIVE: "associative",
    INDEXED: "indexed",
    REFERENCE: "reference"
  }
} as $BASH |

def debug(msgs): (
  (msgs | debug | empty), .
);

def exit: (
  "routine: " + . + "\n" | halt_error(1)
);

def debug_var(varname): (
  if (varname | type != $JSON.TYPE.STRING) then (
    "debug_empty takes only 1 arg" | exit
  ) else . end |
  debug(varname + " = \(.)")
);

def assert(conditional; message): (
  if (conditional | not) then ("routine: assertion failed: " + message + "\n" | halt_error(2)) end
);

def unreachable(fn): (
  "routine: reached unreachable code into " + fn + "()\n" | halt_error(3)
);

def permission_denied(mode): (
  if (mode != $MODE.internal) then (
    "\"unsafe\" can only be used as internal user" | exit
  ) end |
);
