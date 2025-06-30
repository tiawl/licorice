#! /usr/bin/env bash

___ () {
  shift
  case "${1}" in
  ( 'get' ) ${namespace["${backend}"]}network${sep[namespace]}ip${sep[namespace]}get "${@}" ;;
  ( 'list' ) : ;;
  ( * ) return 1 ;;
  esac
}
