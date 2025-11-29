#! /usr/bin/env --split-string awk -f

{
  key = substr($0, 1, length($0) - 12)
  # new line is used as separator between key and inventory varname
  print "json::kind::error " q("inventory") " " q($0) " " q("string") " " dq("${FUNCNAME[0]}") "\n" \
        "resolved+=($" q(key "\n") dq("${JSONGET_inventory[" a($0) "]}") ")\n" \
        "json::object::set " q("inventory") " " q(key) " " q("inventory") " " dq("." edq("inventory") "." edq("${JSONGET_inventory[" q($0) "]}"))
}
