#! /usr/bin/env bash

path::base () {
  set -- "${1%"${1##*[!/]}"}" "${2:-}"
  set -- "${1##*/}" "${2:-}"
  set -- "${1%"${2:-}"}"
  print -- '%s' "${1:-/}"
}

path::dir () {
  set -- "${1:-.}"
  set -- "${1%%"${1##*[!/]}"}"

  if str not empty "${1##*/*}"
  then
    set -- '.'
  fi

  set -- "${1%/*}"
  set -- "${1%%"${1##*[!/]}"}"
  print -- '%s' "${1:-/}"
}

path::normalized () {
  if is dir "${1}"
  then
    CDPATH= cd -- "${1}"
    pwd
  else
    print -- '%s/%s\n' "$(path::normalized "$(path::dir "${1}")")" "$(path::base "${1}")"
  fi
}
