#! /usr/bin/env bash

___ () {
  case "${1}" in
  ( 'prune' ) ${namespace["${backend}"]}image${sep[namespace]}builder${sep[namespace]}prune "${@:2}" ;;
  ( * ) return 1 ;;
  esac
}
