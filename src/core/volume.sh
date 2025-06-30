#! /usr/bin/env bash

___ () {
  case "${1}" in
  ( 'create' ) ${namespace["${backend}"]}volume${sep[namespace]}create "${@}" ;;
  ( 'remove' ) : ;;
  ( 'list' ) ${namespace["${backend}"]}volume${sep[namespace]}list "${@}" ;;
  ( 'created' ) ${namespace["${backend}"]}volume${sep[namespace]}created "${@}" ;;
  ( * ) return 1 ;;
  esac
}
