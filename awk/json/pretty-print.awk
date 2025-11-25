#! /usr/bin/env --split-string awk -f

{
  TOKENS[0]=$0
  while (getline == 1) TOKENS[length(TOKENS)] = $0
  I = 0
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
  out = json_value(TOKENS[I])
  print out
}

function json_value(token,
                    out) {
  out = ""
  if (token == "{") {
    out = json_object(token)
  } else if (token == "[") {
    out = json_array(token)
  } else if (token ~ /^".*"$/) {
    out = json_string(token)
  } else if (token == "true" || token == "false") {
    out = json_boolean(token)
  } else if (token == "null") {
    out = json_null()
  } else {
    out = json_number(token)
  }
  return out
}

function json_object(token,
                     out) {
  out = COLOR["OBJECT"] "{" RESET
  OFFSET += 2
  token = next_token()
  if (token == "}") {
    OFFSET -= 2
    out = out COLOR["OBJECT"] "}" RESET
  } else {
    out = out "\n"
    while (1) {
      out = out indent() COLOR["KEY"] token RESET
      token = next_token()
      out = out COLOR["OBJECT"] ": " RESET
      token = next_token()
      out = out json_value(token)
      token = next_token()
      if (token == "}") {
        break
      } else if (token == ",") {
        out = out COLOR["OBJECT"] "," RESET "\n"
      }
      token = next_token()
    }
    OFFSET -= 2
    out = out "\n" indent() COLOR["OBJECT"] "}" RESET
  }
  return out
}

function json_array(token,
                    out) {
  out = COLOR["ARRAY"] "[" RESET
  OFFSET += 2
  token = next_token()
  if (token == "]") {
    OFFSET -= 2
    out = out COLOR["ARRAY"] "]" RESET
  } else {
    out = out "\n"
    while (1) {
      out = out indent() json_value(token)
      token = next_token()
      if (token == "]") {
        break
      } else if (token == ",") {
        out = out COLOR["ARRAY"] "," RESET "\n"
      }
      token = next_token()
    }
    OFFSET -= 2
    out = out "\n" indent() COLOR["ARRAY"] "]" RESET
  }
  return out
}

function json_string(token) {
  return COLOR["STRING"] token RESET
}

function json_number(token) {
  return COLOR["NUMBER"] token RESET
}

function json_boolean(token) {
  return COLOR["BOOLEAN"] token RESET
}

function json_null() {
  return COLOR["NULL"] "null" RESET
}

function next_token() {
  return TOKENS[++I]
}

function indent() {
  return sprintf("%*s", OFFSET, "")
}
