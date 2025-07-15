#! /usr/bin/env bash

___ () {
  case "${1}" in
  ( 'build' ) ${namespace["${backend}"]}image${sep[namespace]}build "${@:2}" ;;
  ( 'merge' ) ${namespace["${backend}"]}image${sep[namespace]}merge "${@:2}" ;;
  ( 'pull' ) ${namespace["${backend}"]}image${sep[namespace]}pull "${@:2}" ;;
  ( 'list' ) ${namespace["${backend}"]}image${sep[namespace]}list "${@:2}" ;;
  ( 'remove' ) ${namespace["${backend}"]}image${sep[namespace]}remove "${@:2}" ;;
  ( 'prune' ) ${namespace["${backend}"]}image${sep[namespace]}prune "${@:2}" ;;
  ( 'builder' ) ${namespace[core]}image${sep[namespace]}builder "${@:2}" ;;
  ( 'tag' ) ${namespace[core]}image${sep[namespace]}tag "${@:2}" ;;
  ( * ) return 1 ;;
  esac
}
