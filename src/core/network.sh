#! /usr/bin/env bash

___ () {
  case "${1}" in
  ( 'connect' ) ${namespace["${backend}"]}network${sep[namespace]}connect "${@:2}" ;;
  ( 'disconnect' ) ${namespace["${backend}"]}network${sep[namespace]}disconnect "${@:2}" ;;
  ( 'create' ) ${namespace["${backend}"]}network${sep[namespace]}create "${@:2}" ;;
  ( 'remove' ) : ;;
  ( 'list' ) ${namespace["${backend}"]}network${sep[namespace]}list "${@:2}" ;;
  ( 'created' ) ${namespace["${backend}"]}network${sep[namespace]}created "${@:2}" ;;
  ( 'ip' ) ${namespace[core]}network${sep[namespace]}ip "${@:2}" ;;
  ( * ) return 1 ;;
  esac
}
