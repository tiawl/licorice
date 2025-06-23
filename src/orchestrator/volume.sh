#! /usr/bin/env bash

volume () {
  case "${1}" in
  ( 'create' ) volume_create "${@}" ;;
  ( 'remove' ) : ;;
  ( 'list' ) volume_list "${@}" ;;
  ( 'created' ) volume_created "${@}" ;;
  ( * ) return 1 ;;
  esac
}
