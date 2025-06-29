#! /usr/bin/env bash

___ () {
  case "${1}" in
  ( 'connect' ) ${namespace[core]}network${sep[namespace]}connect "${@}" ;;
  ( 'disconnect' ) ${namespace[core]}network${sep[namespace]}disconnect "${@}" ;;
  ( 'create' ) ${namespace[core]}network${sep[namespace]}create "${@}" ;;
  ( 'remove' ) : ;;
  ( 'list' ) ${namespace[core]}network${sep[namespace]}list "${@}" ;;
  ( 'created' ) ${namespace[core]}network${sep[namespace]}created "${@}" ;;
  ( 'ip' ) ${namespace[core]}network${sep[namespace]}ip "${@}" ;;
  ( * ) return 1 ;;
  esac
}
