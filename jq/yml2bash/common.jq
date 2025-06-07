#! /usr/bin/env --split-string gojq --from-file

def exit: (
  "runner: " + . + "\n" | halt_error(1)
);
