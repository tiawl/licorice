#! /usr/bin/env bash

___ () {
  case "${1}" in
  ( 'create' ) ${namespace[core]}volume${sep[namespace]}create "${@}" ;;
  ( 'remove' ) : ;;
  ( 'list' ) ${namespace[core]}volume${sep[namespace]}list "${@}" ;;
  ( 'created' ) ${namespace[core]}volume${sep[namespace]}created "${@}" ;;
  ( * ) return 1 ;;
  esac
}
