#! /usr/bin/env bash

___ () { #HELP <pattern>|Remove unused images matching <pattern>
  shift
  local img
  set -f
  for img in $(${namespace[core]}image list "${1}")
  do
    ${namespace[core]}image remove "${img%:*}" "${img#*:}"
  done
  set +f
}
