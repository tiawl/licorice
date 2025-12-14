#! /usr/bin/env bash

json::print::pretty () {
  json::tokenize | awk "${awk[repeat]}${awk[json/pretty-print]}"
}

json::print::compact () {
  json::tokenize | awk '{print}' ORS=''
}
