#! /usr/bin/env bash

___ () {
  shift
  case "${1}" in
  ( 'get' ) ${namespace["${backend}"]}container${sep[namespace]}status${sep[namespace]}get "${@}" ;;
  ( 'created' ) ${namespace["${backend}"]}container${sep[namespace]}status${sep[namespace]}created "${@}" ;;
  ( 'running' ) ${namespace["${backend}"]}container${sep[namespace]}status${sep[namespace]}running "${@}" ;;
  ( 'healthy' ) ${namespace["${backend}"]}container${sep[namespace]}status${sep[namespace]}healthy "${@}" ;;
  ( * ) return 1 ;;
  esac
}
