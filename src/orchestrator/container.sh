#! /usr/bin/env bash

container () {
  case "${1}" in
  ( 'create' ) container_create "${@}" ;;
  ( 'start' ) container_start "${@}" ;;
  ( 'stop' ) container_stop "${@}" ;;
  ( 'remove' ) : ;;
  ( 'up' ) container create "${@}"; container start "${@}" ;;
  ( 'down' ) : ;;
  ( 'status' ) container_status "${@}" ;;
  ( 'resource' ) container_resource "${@}" ;;
  ( 'exec' ) container_exec "${@}" ;;
  ( * ) return 1 ;;
  esac
}
