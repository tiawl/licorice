#! /usr/bin/env --split-string awk -f

{
  key = substr($0, 1, length($0) - 12)
  print "inventory::resolve::inventory::rec " q($0) " " q(key) " " dq("${JSONGET_inventory[" q($0) "]}") " " dq("${@}")
}
