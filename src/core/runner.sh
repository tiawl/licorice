#! /usr/bin/env bash

___ () {
  case "${1}" in
  ( 'dry' ) ${namespace[core]}runner${sep[namespace]}dry "${@}" ;;
  ( 'exec' ) ${namespace[core]}runner${sep[namespace]}exec "${@}" ;;
  ( * ) return 1 ;;
  esac
}
