#! /usr/bin/env --split-string awk -f

{
  OFFSET = 0
  delete COLOR
  COLOR["NULL"] = "\033[0;90m"
  COLOR["BOOLEAN"] = "\033[0;35m"
  COLOR["NUMBER"] = "\033[0;35m"
  COLOR["STRING"] = "\033[0;32m"
  COLOR["ARRAY"] = "\033[1;39m"
  COLOR["OBJECT"] = "\033[1;39m"
  COLOR["KEY"] = "\033[0;36m"
  RESET = "\033[m"
  LINE = ""
  json_value($0)
  if (LINE != "") print LINE
}

function json_value(token) {
  if (token == "{") {
    json_object(token)
  } else if (token == "[") {
    json_array(token)
  } else if (token ~ /^".*"$/) {
    json_string(token)
  } else if (token == "true" || token == "false") {
    json_boolean(token)
  } else if (token == "null") {
    json_null()
  } else {
    json_number(token)
  }
}

function json_object(token) {
  OFFSET += 2
  token = next_token()
  if (token == "}") {
    OFFSET -= 2
    LINE = LINE COLOR["OBJECT"] "{}" RESET
  } else {
    print LINE COLOR["OBJECT"] "{" RESET
    LINE = ""
    while (token != "}") {
      LINE = LINE indent() COLOR["KEY"] token COLOR["OBJECT"] ": " RESET
      token = next_token()
      token = next_token()
      json_value(token)
      token = next_token()
      if (token == ",") {
        print LINE COLOR["OBJECT"] "," RESET
        LINE = ""
        token = next_token()
      }
    }
    OFFSET -= 2
    print LINE
    LINE = indent() COLOR["OBJECT"] "}" RESET
  }
}

function json_array(token) {
  OFFSET += 2
  token = next_token()
  if (token == "]") {
    OFFSET -= 2
    LINE = LINE COLOR["ARRAY"] "[]" RESET
  } else {
    print LINE COLOR["ARRAY"] "[" RESET
    LINE = ""
    while (token != "]") {
      LINE = LINE indent()
      json_value(token)
      token = next_token()
      if (token == ",") {
        print LINE COLOR["ARRAY"] "," RESET
        LINE = ""
        token = next_token()
      }
    }
    OFFSET -= 2
    print LINE
    LINE = indent() COLOR["ARRAY"] "]" RESET
  }
}

function json_string(token) {
  LINE = LINE COLOR["STRING"] token RESET
}

function json_number(token) {
  LINE = LINE COLOR["NUMBER"] token RESET
}

function json_boolean(token) {
  LINE = LINE COLOR["BOOLEAN"] token RESET
}

function json_null() {
  LINE = LINE COLOR["NULL"] "null" RESET
}

function next_token(token) {
  if (getline token == 1) return token
}

function indent() {
  return repeat(" ", OFFSET)
}
