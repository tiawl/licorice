#! /usr/bin/env bash

___ () {
  case "${1}" in
  ( 'create' ) ${namespace["${backend}"]}container${sep[namespace]}create "${@:2}" ;;
  ( 'start' ) ${namespace["${backend}"]}container${sep[namespace]}start "${@:2}" ;;
  ( 'stop' ) ${namespace["${backend}"]}container${sep[namespace]}stop "${@:2}" ;;
  ( 'remove' ) : ;;
  ( 'up' ) ${namespace["${backend}"]}container${sep[namespace]}create "${@:2}"; ${namespace["${backend}"]}container${sep[namespace]}start "${@:2}" ;;
  ( 'down' ) : ;;
  ( 'exec' ) ${namespace["${backend}"]}container${sep[namespace]}exec "${@:2}" ;;
  ( 'status' ) ${namespace[core]}container${sep[namespace]}status "${@:2}" ;;
  ( 'resource' ) ${namespace[core]}container${sep[namespace]}resource "${@:2}" ;;
  ( * ) return 1 ;;
  esac
}
