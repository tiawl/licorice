#! /usr/bin/env bash

___ () {
  shift
  case "${1}" in
  ( 'get' ) ${namespace[core]}container${sep[namespace]}status${sep[namespace]}get "${@}" ;;
  ( 'created' ) ${namespace[core]}container${sep[namespace]}status${sep[namespace]}created "${@}" ;;
  ( 'running' ) ${namespace[core]}container${sep[namespace]}status${sep[namespace]}running "${@}" ;;
  ( 'healthy' ) ${namespace[core]}container${sep[namespace]}status${sep[namespace]}healthy "${@}" ;;
  ( * ) return 1 ;;
  esac
}
