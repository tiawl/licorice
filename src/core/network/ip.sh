#! /usr/bin/env bash

___ () {
  shift
  case "${1}" in
  ( 'get' ) ${namespace[core]}network${sep[namespace]}ip${sep[namespace]}get "${@}" ;;
  ( 'list' ) : ;;
  ( * ) return 1 ;;
  esac
}
