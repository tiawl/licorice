#! /usr/bin/env bash

___ () {
  shift
  case "${1}" in
  ( 'copy' ) ${namespace[core]}container${sep[namespace]}resource${sep[namespace]}copy "${@}" ;;
  ( * ) return 1 ;;
  esac
}
