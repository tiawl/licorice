#! /usr/bin/env --split-string awk -f

{
  I = 0
  PATH = "."
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
  print JSONKEYS "['" PATH "']='" KEYS[PATH] "'"
}

function json_values() {
  print JSONVALUES "['" PATH "']='" VALUES[PATH] "'"
}

function json_length(n) {
  print JSONLENGTH "['" PATH "']='" n "'"
}

function json_parent() {
  print JSONPARENT "['" PATH "']='" PARENT[PATH] "'"
}

function json_structured_value () {
  if (PARENT[PATH] in VALUES) {
    # '\n' is used as separator between values
    VALUES[PARENT[PATH]] = VALUES[PARENT[PATH]] "\n"
  } else VALUES[PARENT[PATH]] = ""
}

function json_object(token,
                     i, parent) {
  json_kind("object")
  json_structured_value()
  i = 0
  token = next_token()
  while (token != "}") {
    if (token !~ JSON_STRING) unexpected("string", token)
    if (PATH in KEYS) {
      # '\n' is used as separator between keys
      KEYS[PATH] = KEYS[PATH] "\n." token
    } else KEYS[PATH] = "." token
    parent = PATH
    PATH = PATH (PATH == "." ? "" : ".") token
    PARENT[PATH] = parent
    json_parent()
    token = next_token()
    if (token != ":") unexpected(":", token)
    token = next_token()
    json_value(token)
    PATH = parent
    i++
    token = next_token()
    if (token == "}") break
    else if (token != ",") unexpected("}> or <,", token)
    token = next_token()
  }
  json_keys()
  json_values()
  json_length(i)
}

function json_array(token,
                    i, parent) {
  json_kind("array")
  json_structured_value()
  i = 0
  token = next_token()
  while (token != "]") {
    parent = PATH
    PATH = PATH "." i
    PARENT[PATH] = parent
    json_parent()
    json_value(token)
    PATH = parent
    i++
    token = next_token()
    if (token == "]") break
    else if (token != ",") unexpected("]> or <,", token)
    token = next_token()
  }
  json_values()
  json_length(i)
}

function json_string(token,
                     unescaped) {
  json_kind("string")
  token = substr(token, 2, length(token) - 2)
  json_length(length(token))
  unescaped = token
  gsub(JSON_ALLOWED_ESCAPED_CHARS, "", unescaped)
  if (unescaped ~ /["\\\000-\037]/) error("missing or invalid character escape")
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

function json_primitive(token,
                        path) {
  if (PARENT[PATH] in VALUES) {
    # '\n' is used as separator between values
    VALUES[PARENT[PATH]] = VALUES[PARENT[PATH]] "\n" token
  } else VALUES[PARENT[PATH]] = token
  print JSONGET "['" PATH "']='" token "'"
}

function json_kind(kind) {
  print JSONKIND "['" PATH "']='" kind "'"
}

function unexpected(expected, got) {
  error("expected <" expected "> but got <" got "> at input token " I)
}

function error(msg) {
  print msg > "/dev/stderr"
  exit 1
}

function next_token(token) {
  if (getline token == 1) {
    I++
    return token
  }
  error("Unexpected EOF")
}
