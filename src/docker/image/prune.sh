#! /usr/bin/env bash

___ () { #HELP <pattern>|Remove unused images matching <pattern>
  local img
  on noglob
  for img in $(${namespace[core]}image list "${1}")
  do
    ${namespace[core]}image remove "${img%:*}" "${img#*:}"
  done
  off noglob
}
