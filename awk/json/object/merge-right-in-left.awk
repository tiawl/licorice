#! /usr/bin/env --split-string awk -f

{
  PATH_RIGHT = $0
  getline JSON_LEFT
  getline JSON_RIGHT
  PATH_LEFT = ROOT_LEFT substr(PATH_RIGHT, length(ROOT_RIGHT) + 1)
  print JSON_LEFT "[" q(PATH_LEFT) "]=" dq("${" JSON_RIGHT "[" q(PATH_RIGHT) "]}")
}
