#! /usr/bin/env --split-string awk -f

# 1. Map the 'import' array to an object where values from the array are keys into the new object
# 2. Imported filepaths are relative to the file they are into: so here we absolute them
BEGIN {
  i = 0
  values = repeat(q("null") " ", LENGTH)
  while (i < LENGTH) {
    print "JSONGET_file[" q(ROOT "/") dq("${JSONGET_file[" q("." edq("import") "[" i "]") "]}") "]=" q("null") "\n" \
          "JSONKIND_file[" q(ROOT "/") dq("${JSONGET_file[" q("." edq("import") "[" i "]") "]}") "]=" q("null")
    i++
  }
  print "JSONKEYS_file[" q("." dq("import")) "]=" q(ROOT "/") dq("${JSONVALUES_file[" q("." edq("import")) "]//$" q("\n") "/$" q("\n" ROOT "/") "}") "\n" \
        "JSONVALUES_file[" q("." dq("import")) "]=" q(sub(values, 1, length(values) - 1)) "\n" \
        "unset " q("JSON") "{GET,KIND}" q("_file[") dq("'") q("." dq("import") "<") "{0.." (LENGTH - 1) "}" q(">") dq("'") q("]") "\n" \
        "JSONKIND_file[" q("." dq("import")) "]=" q("object")
}
