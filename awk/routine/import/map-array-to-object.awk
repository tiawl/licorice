#! /usr/bin/env --split-string awk -f

# 1. Map the 'import' array to an object where values from the array are keys into the new object
# 2. Imported filepaths are relative to the file they are into: so here we absolute them
BEGIN {
  i = 0
  get = ""
  kind = ""
  unset = "unset"
  keys = ""
  values = ""
  while (i < LENGTH) {
    get = get "JSONGET_file[" q(ROOT "/") dq("${JSONGET_file[" q("." edq("import") "[" i "]") "]}") "]=" q("null") "\n"
    kind = kind "JSONKIND_file[" q(ROOT "/") dq("${JSONGET_file[" q("." edq("import") "[" i "]") "]}") "]=" q("null") "\n"
    keys = keys q(ROOT "/") dq("${JSONGET_file[" q("." edq("import") "[" i "]") "]}") " "
    values = values q("null") " "
    unset = unset " " q("JSONGET_file[" dq("." edq("import") "[" i "]") "]") " " \
          q("JSONKIND_file[" dq("." edq("import") "[" i "]") "]")
    i++
  }
  print get kind unset "\n" \
           "JSONKEYS_file[" q("." dq("import")) "]=" q(sub(keys, 1, length(keys) - 1)) "\n" \
           "JSONVALUES_file[" q("." dq("import")) "]=" q(sub(values, 1, length(values) - 1)) "\n" \
           "JSONKIND_file[" q("." dq("import")) "]=" q("object")
}
