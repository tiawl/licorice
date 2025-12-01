#! /usr/bin/env --split-string awk -f

{
  gsub(".", " " dq("'") q("&"))
  gsub(q("'"), dq("\047"))
  print "printf -v " q("hex[" KEY "]") " " q("%02x") $0
}
