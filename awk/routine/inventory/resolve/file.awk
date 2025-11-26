#! /usr/bin/env --split-string awk -f

{
  key = substr($0, 1, length($0) - 12)
  print "json::kind::assert " q("file") " " q($0) " " q("string") " " dq("${FUNCNAME[0]}") "\n" \
        "json::object::set " q("file") " " q(key) " " q("inventory") dq("." edq("inventory") "." edq("${JSONGET_file[" q($0) "]}"))"
}
