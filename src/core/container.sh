#! /usr/bin/env bash

___ () {
  case "${1}" in
  ( 'create' ) ${namespace["${backend}"]}container${sep[namespace]}create "${@}" ;;
  ( 'start' ) ${namespace["${backend}"]}container${sep[namespace]}start "${@}" ;;
  ( 'stop' ) ${namespace["${backend}"]}container${sep[namespace]}stop "${@}" ;;
  ( 'remove' ) : ;;
  ( 'up' ) ${namespace["${backend}"]}container${sep[namespace]}create "${@}"; ${namespace["${backend}"]}container${sep[namespace]}start "${@}" ;;
  ( 'down' ) : ;;
  ( 'exec' ) ${namespace["${backend}"]}container${sep[namespace]}exec "${@}" ;;
  ( 'status' ) ${namespace[core]}container${sep[namespace]}status "${@}" ;;
  ( 'resource' ) ${namespace[core]}container${sep[namespace]}resource "${@}" ;;
  ( * ) return 1 ;;
  esac
}
