#! /usr/bin/env bash

___ () {
  case "${1}" in
  ( 'build' ) ${namespace[core]}image${sep[namespace]}build "${@}" ;;
  ( 'merge' ) ${namespace[core]}image${sep[namespace]}merge "${@}" ;;
  ( 'pull' ) ${namespace[core]}image${sep[namespace]}pull "${@}" ;;
  ( 'list' ) ${namespace[core]}image${sep[namespace]}list "${@}" ;;
  ( 'remove' ) ${namespace[core]}image${sep[namespace]}remove "${@}" ;;
  ( 'prune' ) ${namespace[core]}image${sep[namespace]}prune "${@}" ;;
  ( 'builder' ) ${namespace[core]}image${sep[namespace]}builder "${@}" ;;
  ( 'tag' ) ${namespace[core]}image${sep[namespace]}tag "${@}" ;;
  ( * ) return 1 ;;
  esac
}
