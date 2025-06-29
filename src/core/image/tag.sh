#! /usr/bin/env bash

___ () {
  shift
  case "${1}" in
  ( 'compute' ) ${namespace[core]}image${sep[namespace]}tag${sep[namespace]}compute "${@}" ;;
  ( 'create' ) ${namespace[core]}image${sep[namespace]}tag${sep[namespace]}create "${@}" ;;
  ( 'list' ) ${namespace[core]}image${sep[namespace]}tag${sep[namespace]}list "${@}" ;;
  ( 'defined' ) ${namespace[core]}image${sep[namespace]}tag${sep[namespace]}defined "${@}" ;;
  ( * ) return 1 ;;
  esac
}
