#! /usr/bin/env bash

___ () {
  shift
  case "${1}" in
  ( 'compute' ) ${namespace["${backend}"]}image${sep[namespace]}tag${sep[namespace]}compute "${@}" ;;
  ( 'create' ) ${namespace["${backend}"]}image${sep[namespace]}tag${sep[namespace]}create "${@}" ;;
  ( 'list' ) ${namespace["${backend}"]}image${sep[namespace]}tag${sep[namespace]}list "${@}" ;;
  ( 'defined' ) ${namespace["${backend}"]}image${sep[namespace]}tag${sep[namespace]}defined "${@}" ;;
  ( * ) return 1 ;;
  esac
}
