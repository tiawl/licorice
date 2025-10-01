#! /usr/bin/env bash

___ () { #HELP <yaml_file> [<arg1> <args2> ...]|Execute the runner described by the <yaml_file>. Optional arguments are used by the executed runner
  local script
  script="$(${namespace[core]}runner dry "${1}")"
  readonly script

  shift

  env --ignore-environment BASH="${BASH:-}" bash --norc --noprofile <(print '%s' "${script}") "${@}"
}
