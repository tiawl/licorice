#! /usr/bin/env bash

___ () {
  case "${1}" in
  ( 'create' ) ${namespace[core]}container${sep[namespace]}create "${@}" ;;
  ( 'start' ) ${namespace[core]}container${sep[namespace]}start "${@}" ;;
  ( 'stop' ) ${namespace[core]}container${sep[namespace]}stop "${@}" ;;
  ( 'remove' ) : ;;
  ( 'up' ) ${namespace[core]}container create "${@}"; ${namespace[core]}container start "${@}" ;;
  ( 'down' ) : ;;
  ( 'status' ) ${namespace[core]}container${sep[namespace]}status "${@}" ;;
  ( 'resource' ) ${namespace[core]}container${sep[namespace]}resource "${@}" ;;
  ( 'exec' ) ${namespace[core]}container${sep[namespace]}exec "${@}" ;;
  ( * ) return 1 ;;
  esac
}
