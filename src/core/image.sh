#! /usr/bin/env bash

___ () {
  case "${1}" in
  ( 'build' ) ${namespace["${backend}"]}image${sep[namespace]}build "${@}" ;;
  ( 'merge' ) ${namespace["${backend}"]}image${sep[namespace]}merge "${@}" ;;
  ( 'pull' ) ${namespace["${backend}"]}image${sep[namespace]}pull "${@}" ;;
  ( 'list' ) ${namespace["${backend}"]}image${sep[namespace]}list "${@}" ;;
  ( 'remove' ) ${namespace["${backend}"]}image${sep[namespace]}remove "${@}" ;;
  ( 'prune' ) ${namespace["${backend}"]}image${sep[namespace]}prune "${@}" ;;
  ( 'builder' ) ${namespace[core]}image${sep[namespace]}builder "${@}" ;;
  ( 'tag' ) ${namespace[core]}image${sep[namespace]}tag "${@}" ;;
  ( * ) return 1 ;;
  esac
}
