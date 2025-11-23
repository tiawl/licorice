#! /usr/bin/env --split-string awk -f

{
  TOKENS[0]=$0
  delete empty
  while (getline == 1) TOKENS[length(TOKENS)] = $0
  I = 0
  NTOKENS = length(TOKENS)
  while (I < NTOKENS) {
    if (TOKENS[I] == "}" || TOKENS[I] == "]") {
      offset -= 2
    } else {
      empty[length(empty) - 1] = 0
    }
    if (TOKENS[I] == ",") {
      out = out TOKENS[I]
    } else if (TOKENS[I] == ":") {
      out = out TOKENS[I] " "
      colon = 1
    } else if (colon == 1) {
      colon = 0
      out = out TOKENS[I]
    } else if (out == "") {
      out = TOKENS[I]
    } else if ((TOKENS[I] == "}" || TOKENS[I] == "]") && (empty[length(empty) - 1] == 1)) {
      out = out TOKENS[I]
    } else {
      out = out "\n" sprintf("%*s", offset, "") TOKENS[I]
    }
    if (TOKENS[I] == "}" || TOKENS[I] == "]") {
      delete empty[length(empty) - 1]
    }
    if (TOKENS[I] == "{" || TOKENS[I] == "[") {
      empty[length(empty)] = 1
      offset += 2
    }
    ++I
  }
  print out
}
