#! /usr/bin/env bash

match () {
  local egrep

  if is func rg
  then
    egrep='rg'
  else
    egrep='egrep'
  fi

  on noglob
  if not ${egrep} --color=never "${@}"
  then
    off noglob
    return 1
  fi
  off noglob
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
