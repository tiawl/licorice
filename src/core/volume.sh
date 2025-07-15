#! /usr/bin/env bash

___ () {
  case "${1}" in
  ( 'create' ) ${namespace["${backend}"]}volume${sep[namespace]}create "${@:2}" ;;
  ( 'remove' ) : ;;
  ( 'list' ) ${namespace["${backend}"]}volume${sep[namespace]}list "${@:2}" ;;
  ( 'created' ) ${namespace["${backend}"]}volume${sep[namespace]}created "${@:2}" ;;
  ( * ) return 1 ;;
  esac
}
