#! /usr/bin/env --split-string gojq --from-file

def debug(msgs): (
  (msgs | debug | empty), .
);

def exit: (
  "routine: " + . + "\n" | halt_error(1)
);

def debug_var(varname): (
  if (varname | type != "string") then (
    "debug_empty takes only 1 arg" | exit
  ) else . end |
  debug(varname + " = \(.)")
);
