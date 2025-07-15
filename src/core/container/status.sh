#! /usr/bin/env bash

___ () {
  case "${1}" in
  ( 'get' ) ${namespace["${backend}"]}container${sep[namespace]}status${sep[namespace]}get "${@:2}" ;;
  ( 'created' ) ${namespace["${backend}"]}container${sep[namespace]}status${sep[namespace]}created "${@:2}" ;;
  ( 'running' ) ${namespace["${backend}"]}container${sep[namespace]}status${sep[namespace]}running "${@:2}" ;;
  ( 'healthy' ) ${namespace["${backend}"]}container${sep[namespace]}status${sep[namespace]}healthy "${@:2}" ;;
  ( * ) return 1 ;;
  esac
}
