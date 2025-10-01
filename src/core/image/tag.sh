#! /usr/bin/env bash

___ () {
  case "${1}" in
  ( 'compute' ) ${namespace["${backend}"]}image${sep[namespace]}tag${sep[namespace]}compute "${@:2}" ;;
  ( 'create' ) ${namespace["${backend}"]}image${sep[namespace]}tag${sep[namespace]}create "${@:2}" ;;
  ( 'list' ) ${namespace["${backend}"]}image${sep[namespace]}tag${sep[namespace]}list "${@:2}" ;;
  ( 'defined' ) ${namespace["${backend}"]}image${sep[namespace]}tag${sep[namespace]}defined "${@:2}" ;;
  ( * ) return 1 ;;
  esac
}
