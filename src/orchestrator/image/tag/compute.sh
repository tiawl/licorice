#! /usr/bin/env bash

image_tag_compute() { #HELP <key> <ctx_or_str> [<key> <ctx_or_str>] [...]|Compute a tag from contexts and arbitrary strings. Possible keys: 'context'/'string'
  shift

  : "$({
    while gt "${#}" '0'
    do
      if str eq "${1}" 'context'
      then
        if is dir "${2}"
        then
          tar --directory "${2}" --create --file=- --sort=name --mtime='UTC 2019-01-01' --group=0 --owner=0 --numeric-owner .
        else
          error 'image tag compute: %s is not a directory' "${2}"
        fi
      elif str eq "${1}" 'string'
      then
        printf '%s' "${2}"
      else
        error 'image tag compute: unknown %s' "${1}"
      fi
      shift 2
    done
    declare -f image_build
  } | sha256sum)"
  : "${_%% *}"
  printf '%s' "${_:0:20}"
}
