#! /usr/bin/env bash

___ () {
  case "${1}" in
  ( 'dry' ) ${namespace[core]}runner${sep[namespace]}dry "${@:2}" ;;
  ( 'exec' ) ${namespace[core]}runner${sep[namespace]}exec "${@:2}" ;;
  ( * ) return 1 ;;
  esac
}
