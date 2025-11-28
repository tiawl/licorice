#! /usr/bin/env --split-string awk -f

{
  key = substr($0, 1, length($0) - 12)
  print "json::kind::error " q(HEX) " " q($0) " " q("string") " " dq("${FUNCNAME[0]}") "\n" \
        "json::object::set " q(HEX) " " q(key) " " q("inventory") dq("." edq("inventory") "." edq("${JSONGET_" HEX "[" q($0) "]}"))"
}
