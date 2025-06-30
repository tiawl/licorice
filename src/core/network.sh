#! /usr/bin/env bash

___ () {
  case "${1}" in
  ( 'connect' ) ${namespace["${backend}"]}network${sep[namespace]}connect "${@}" ;;
  ( 'disconnect' ) ${namespace["${backend}"]}network${sep[namespace]}disconnect "${@}" ;;
  ( 'create' ) ${namespace["${backend}"]}network${sep[namespace]}create "${@}" ;;
  ( 'remove' ) : ;;
  ( 'list' ) ${namespace["${backend}"]}network${sep[namespace]}list "${@}" ;;
  ( 'created' ) ${namespace["${backend}"]}network${sep[namespace]}created "${@}" ;;
  ( 'ip' ) ${namespace[core]}network${sep[namespace]}ip "${@}" ;;
  ( * ) return 1 ;;
  esac
}
