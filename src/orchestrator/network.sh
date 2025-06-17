#! /usr/bin/env bash

network () {
  case "${1}" in
  ( 'connect' ) : ;;
  ( 'disconnect' ) : ;;
  ( 'create' ) network_create "${@}" ;;
  ( 'remove' ) : ;;
  ( 'list' ) network_list "${@}" ;;
  ( 'created' ) network_created "${@}" ;;
  ( 'ip' ) network_ip "${@}" ;;
  ( * ) return 1 ;;
  esac
}
