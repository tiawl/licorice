#! /usr/bin/env bash

json::print::pretty () {
  local input
  input="$(cat)"
  #print '%s' "${input:-"{}"}" | json::tokenize | awk "${awk[json/pretty-print]}"
  print '%s' "${input:-"{}"}" | json::tokenize | awk -f ./awk/json/pretty-print.awk
}

json::print::compact () {
  local input
  input="$(cat)"
  print '%s' "${input:-"{}"}" | json::tokenize | awk '{print}' ORS=''
}
