#! /usr/bin/env bash

___ () {
  case "${1}" in
  ( 'get' ) ${namespace["${backend}"]}network${sep[namespace]}ip${sep[namespace]}get "${@:2}" ;;
  ( 'list' ) : ;;
  ( * ) return 1 ;;
  esac
}
