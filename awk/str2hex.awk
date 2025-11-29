#! /usr/bin/env --split-string awk -f

{
  gsub(".", ",$" q("&"))
  gsub("\$\047\047\047", dq("\047"))
  print "printf -v " q("hex[" KEY "]") " " q("%02x") " " dq("\047") "{" substr($0, 2) "}"
}
