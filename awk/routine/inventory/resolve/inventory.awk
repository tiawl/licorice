#! /usr/bin/env --split-string awk -f

{
  key = substr($0, 1, length($0) - 12)
  print "${FUNCNAME[0]}::rec " q($0) " " q(key) " " dq("${JSONGET_inventory[" q($0) "]}") " " dq("${@}")
}
