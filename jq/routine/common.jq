#! /usr/bin/env --split-string gojq --from-file

{
  var: {
    user: "__"
  },
  fn: {
    privileged: ("routine" + $ARGS.named.NAMESPACE_SEP),
    user: ("user" + $ARGS.named.NAMESPACE_SEP)
  },
  sep: $ARGS.named.NAMESPACE_SEP
} as $NAMESPACE |
{
  privileged: -1,
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

def exit(code): (
  "routine: " + . + "\n" | halt_error(code)
);

def debug_var(varname): (
  if (varname | type != $JSON.TYPE.STRING) then (
    "debug_empty takes only 1 arg" | exit(1)
  ) else . end |
  debug(varname + " = \(.)")
);

{
  ASSERT: 0,
  AND: 1
} as $DISPATCH |

def __assert(conditional; message; jpath): (
  if (conditional | not) then ("assertion failed: (" + message + ") must succeed for " + jpath | exit(2)) end
);

def __and(conditional): (
  . and conditional
);

def unreachable(fn): (
  "reached unreachable code into " + fn + "()" | exit(3)
);

def assert(dispatch; conditionnal; message; jpath): (
  if (dispatch == $DISPATCH.ASSERT) then (
    __assert(conditionnal; message; jpath)
  ) elif (dispatch == $DISPATCH.AND) then (
    __and(conditionnal)
  ) else unreachable("assert") end
);

def permission_denied(mode): (
  if (mode != $MODE.privileged) then (
    "\"unsafe\" can only be used as privileged user" | exit(1)
  ) end
);
