#! /usr/bin/env bash

___ () {
  case "${1}" in
  ( 'copy' ) ${namespace["${backend}"]}container${sep[namespace]}resource${sep[namespace]}copy "${@:2}" ;;
  ( * ) return 1 ;;
  esac
}
