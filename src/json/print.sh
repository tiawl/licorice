#! /usr/bin/env bash

json::print::pretty () {
  # TODO: json::tokenize | awk "${awk[repeat]}${awk[json/pretty-print]}"
  json::tokenize | awk -f ./awk/repeat.awk -f ./awk/json/pretty-print.awk
}

json::print::compact () {
  json::tokenize | awk '{print}' ORS=''
}
