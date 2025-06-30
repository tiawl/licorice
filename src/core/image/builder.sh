#! /usr/bin/env bash

___ () {
  shift
  case "${1}" in
  ( 'prune' ) ${namespace["${backend}"]}image${sep[namespace]}builder${sep[namespace]}prune ;;
  ( * ) return 1 ;;
  esac
}
