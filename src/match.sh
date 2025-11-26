#! /usr/bin/env bash

match () {
  local egrep

  if is func rg
  then
    egrep='rg'
  else
    egrep='egrep'
  fi

  set -f
  ${egrep} --color=never "${@}"
  set +f
}

match::noseparator () {
  local option

  if is func rg
  then
    option='--no-context-separator'
  else
    option='--no-group-separator'
  fi

  match "${option}" "${@}"
}
