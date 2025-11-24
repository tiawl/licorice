#! /usr/bin/env --split-string awk -f

{
  TOKENS[0]=$0
  while (getline == 1) TOKENS[length(TOKENS)] = $0
  delete KEYS
  I = 0
  J = 0
  PATH = ""
  JSON_STRING = "^(\"[^\"\\\000-\037]*((\\[^u\000-\037]|\\u[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F])[^\"\\\000-\037]*)*\")$"
  JSON_NUMBER = "^-?(0|[1-9][0-9]*)([.][0-9]+)?([eE][+-]?[0-9]+)?$"
  JSON_ALLOWED_ESCAPED_CHARS = "\\[\"\\\/bfnrt]|\\u[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F]"
  out = json_value(TOKENS[I])
  print substr(out, 1, length(out) - 1)
}

function json_value(token,
                    out) {
  out = ""
  if (token == "{") {
    out = json_object(token)
  } else if (token == "[") {
    out = json_array(token)
  } else if (token ~ JSON_STRING) {
    out = json_string(token)
  } else if (token ~ JSON_NUMBER) {
    out = json_number(token)
  } else if (token == "true" || token == "false") {
    out = json_boolean(token)
  } else if (token == "null") {
    out = json_null(token)
  } else {
    error("malformed JSON string: neither array, object, number, string or atom")
  }
  return out
}

function json_object(token,
                     out, previous) {
  out = json_kind("object")
  token = next_token()
  if (token == "}") {
    # '\n' is used as separator between keys because it needs to be escaped in JSON strings
    if (length(PATH) > 0) {
      out = out JSONKEYS "['" PATH "']='" KEYS[PATH] "'\n"
    } else {
      out = out JSONKEYS "['.']='" KEYS["."] "'\n"
    }
  } else {
    while (1) {
      if (token !~ JSON_STRING) unexpected("string", token)
      if (PATH in KEYS) {
        # '\n' is used as separator between keys because it needs to be escaped in JSON strings
        if (length(PATH) > 0) {
          KEYS[PATH] = KEYS[PATH] "\n." token
        } else {
          KEYS["."] = KEYS["."] "\n." token
        }
      } else {
        if (length(PATH) > 0) KEYS[PATH] = "." token; else KEYS["."] = "." token
      }
      previous = PATH
      PATH = PATH "." token
      token = next_token()
      if (token != ":") unexpected(":", token)
      token = next_token()
      out = out json_value(token)
      PATH = previous
      token = next_token()
      if (token == "}") {
        # '\n' is used as separator between keys because it needs to be escaped in JSON strings
        if (length(PATH) > 0) {
          out = out JSONKEYS "['" PATH "']='" KEYS[PATH] "'\n"
        } else {
          out = out JSONKEYS "['.']='" KEYS["."] "'\n"
        }
        break
      } else if (token != ",") {
        unexpected("}> or <,", token)
      }
      token = next_token()
    }
  }
  return out
}

function json_array(token,
                    out, i) {
  out = json_kind("array")
  i = 0
  token = next_token()
  if (token != "]") {
    while (1) {
      PATH = PATH "<" i ">"
      save_token()
      out = out json_value(token)
      sub(i ">$", "-" (i + 1) ">", PATH)
      restore_token()
      out = out json_value(token)
      sub("<-" (i + 1) ">$", "", PATH)
      token = next_token()
      if (token == "]") {
        break
      } else if (token != ",") {
        unexpected("]> or <,", token)
      }
      token = next_token()
      i += 1
    }
  }
  return out
}

function json_string(token) {
  token = substr(token, 2, length(token) - 2)
  gsub(JSON_ALLOWED_ESCAPED_CHARS, "", token)
  if (token ~ /["\\\000-\037]/) error("missing or invalid character escape")
  return json_kind("string") json_primitive(token)
}

function json_number(token) {
  return json_kind("number") json_primitive(token)
}

function json_boolean(token) {
  return json_kind("boolean") json_primitive(token)
}

function json_null(token) {
  return json_kind("null") json_primitive(token)
}

function json_primitive(token,
                        out) {
  out = token
  gsub("'", "'\"'\"'", out)
  sub("^\"?", JSONGET "['" PATH "']='", out)
  sub("\"?$", "'\n", out)
  return out
}

function json_kind(kind,
                   out) {
  if (length(PATH) > 0) out = JSONKIND "['" PATH "']='" kind "'\n"
  else out = JSONKIND "['.']='" kind "'\n"
  return out
}

function unexpected(expected, got) {
  error("expected <" expected "> but got <" got "> at input token " I)
}

function error(msg) {
  print msg >"/dev/stderr"
  exit 1
}

function next_token() {
  return TOKENS[++I]
}

function save_token() {
  J = I
}

function restore_token () {
  I = J
}
