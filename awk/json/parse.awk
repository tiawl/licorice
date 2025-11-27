#! /usr/bin/env --split-string awk -f

{
  delete KEYS
  I = 0
  PATH = ""
  NPATH = ""
  JSON_STRING = "^(\"[^\"\\\000-\037]*((\\[^u\000-\037]|\\u[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F])[^\"\\\000-\037]*)*\")$"
  JSON_NUMBER = "^-?(0|[1-9][0-9]*)([.][0-9]+)?([eE][+-]?[0-9]+)?$"
  JSON_ALLOWED_ESCAPED_CHARS = "\\[\"\\\/bfnrt]|\\u[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F]"
  json_value($0)
}

function json_value(token) {
  if (token == "{") {
    json_object(token)
  } else if (token == "[") {
    json_array(token)
  } else if (token ~ JSON_STRING) {
    json_string(token)
  } else if (token ~ JSON_NUMBER) {
    json_number(token)
  } else if (token == "true" || token == "false") {
    json_boolean(token)
  } else if (token == "null") {
    json_null(token)
  } else {
    error("malformed JSON string: neither array, object, number, string or atom")
  }
}

function json_keys() {
  print JSONKEYS "['" (PATH != "" ? PATH : ".") "']='" KEYS[(PATH != "" ? PATH : ".")] "'" \
        (NPATH != "" ? "\n" JSONKEYS "['" NPATH "']='" KEYS[PATH] "'" : "")
}

function json_object(token,
                     previous, nprevious) {
  json_kind("object")
  token = next_token()
  while (token != "}") {
    if (token !~ JSON_STRING) unexpected("string", token)
    if (PATH in KEYS) {
      # '\n' is used as separator between keys because it needs to be escaped in JSON strings
      KEYS[(PATH != "" ? PATH : ".")] = KEYS[(PATH != "" ? PATH : ".")] "\n." token
    } else KEYS[(PATH != "" ? PATH : ".")] = "." token
    previous = PATH
    PATH = PATH "." token
    if (NPATH != "") {
      nprevious = NPATH
      NPATH = NPATH "." token
    }
    token = next_token()
    if (token != ":") unexpected(":", token)
    token = next_token()
    json_value(token)
    PATH = previous
    if (NPATH != "") NPATH = nprevious
    token = next_token()
    if (token == "}") break
    else if (token != ",") unexpected("}> or <,", token)
    token = next_token()
  }
  json_keys()
}

function json_array(token,
                    i, previous, nprevious) {
  json_kind("array")
  i = 0
  token = next_token()
  while (token != "]") {
    previous = PATH
    NPATH = PATH "<-" (i + 1) ">"
    PATH = PATH "<" i ">"
    json_value(token)
    PATH = previous
    NPATH = ""
    token = next_token()
    if (token == "]") break
    else if (token != ",") unexpected("]> or <,", token)
    token = next_token()
    i += 1
  }
}

function json_string(token) {
  json_kind("string")
  token = substr(token, 2, length(token) - 2)
  gsub(JSON_ALLOWED_ESCAPED_CHARS, "", token)
  if (token ~ /["\\\000-\037]/) error("missing or invalid character escape")
  gsub("'", "'\"'\"'", token)
  json_primitive(token)
}

function json_number(token) {
  json_kind("number")
  json_primitive(token)
}

function json_boolean(token) {
  json_kind("boolean")
  json_primitive(token)
}

function json_null(token) {
  json_kind("null")
  json_primitive(token)
}

function json_primitive(token) {
  print JSONGET "['" PATH "']='" token "'" \
        (NPATH != "" ? "\n" JSONGET "['" NPATH "']='" token "'" : "")
}

function json_kind(kind) {
  print JSONKIND "['" (PATH != "" ? PATH : ".") "']='" kind "'" \
        (NPATH != "" ? "\n" JSONKIND "['" NPATH "']='" kind "'" : "")
}

function unexpected(expected, got) {
  error("expected <" expected "> but got <" got "> at input token " I)
}

function error(msg) {
  print msg >"/dev/stderr"
  exit 1
}

function next_token(token) {
  if (getline token == 1) {
    I++
    return token
  }
  error("Unexpected EOF")
}
