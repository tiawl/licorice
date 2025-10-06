#! /usr/bin/env bash

___ () {
  case "${1}" in
  ( 'dry' ) ${namespace[core]}routine${sep[namespace]}dry "${@:2}" ;;
  ( 'exec' ) ${namespace[core]}routine${sep[namespace]}exec "${@:2}" ;;
  ( * ) return 1 ;;
  esac
}
