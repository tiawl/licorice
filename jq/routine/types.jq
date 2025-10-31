#! /usr/bin/env --split-string gojq --from-file

def isRoutine: (
  def isFromEnum(fields; dispatch; jpath): (
    . as $input |
    if (fields | type != "array") then unreachable("(fields | type != \"array\") case into isFromEnum") end |
    if (fields | length > 0) then unreachable("(fields | length > 0) case into inFromEnum") end |
    if (fields | map(type == "string") | all) then unreachable("(fields | map(type == \"string\") | all) case into inFromEnum") end |
    if ($input | type == "string") then unreachable("($input | type == \"string\") case into inFromEnum") end |
    assert(dispatch; fields | contains([$input]); "fields | contains([$input])"; jpath)
  );

  def isEmpty(dispatch; jpath): (
    assert(dispatch; type == "object"; "type == \"object\""; jpath) |
    assert(dispatch; length == 0; "length == 0"; jpath)
  );

  def isIdentifier(dispatch; jpath): (
    assert(dispatch; type == "string"; "type == \"string\""; jpath) |
    assert(dispatch; test("^[a-zA-Z_][a-zA-Z0-9_]*$"); "test(\"^[a-zA-Z_][a-zA-Z0-9_]*$\")"; jpath)
  );

  def isNoSpace(dispatch; jpath): (
    assert(dispatch; type == "string"; "type == \"string\""; jpath) |
    assert(dispatch; test("^[^[:space:]]*$"); "test(\"^[^[:space:]]*$\")"; jpath)
  );

  def isChar(dispatch; jpath): (
    isFromEnum([
      "asterisk",
      "tilde",
      "atsign",
      "newline"
    ]; dispatch; jpath)
  );

  def isInteger(dispatch; jpath): (
    assert(dispatch; type == "number"; "type == \"number\""; jpath) |
    assert(dispatch; . == floor; ". == floor"; jpath)
  );

  def isParameter(dispatch; jpath): (
    assert(dispatch; isInteger(dispatch; jpath); "isInteger(dispatch; jpath)"; jpath) |
    assert(dispatch; . >= 0; ". >= 0"; jpath)
  );

  def isFileDescriptor(dispatch; jpath): (
    assert(dispatch; isInteger(dispatch; jpath); "isInteger(dispatch; jpath)"; jpath) |
    assert(dispatch; . > 0; ". > 0"; jpath)
  );

  def isSpecial(dispatch; jpath): (
    isFromEnum([
      "last",
      "FUNCNAME",
      "USER",
      "UID",
      "HOME",
      "ROUTINE",
      "at_parameters",
      "sep"
    ]; dispatch; jpath)
  );

  def isBinaryArithmeticOperator(dispatch; jpath): (
    isFromEnum([
      "Addition",
      "Substraction",
      "Remainder",
      "Gt",
      "Lt",
      "Ge",
      "Le",
      "Eq",
      "Ne",
      "Assignment",
      "Increment"
    ]; dispatch; jpath)
  );

  def isScope(dispatch; jpath): (
    isFromEnum([
      "Local",
      "Global"
    ]; dispatch; jpath)
  );

  def isType(dispatch; jpath): (
    isFromEnum([
      "String",
      "Associative",
      "Indexed",
      "Reference"
    ]; dispatch; jpath)
  );

  def isUnaryLogicalOperator(dispatch; jpath): (
    isFromEnum([
      "Not"
    ]; dispatch; jpath)
  );

  def isBinaryLogicalOperator(dispatch; jpath): (
    isFromEnum([
      "And",
      "Or"
    ]; dispatch; jpath)
  );

  def isOption(dispatch; jpath): (
    isFromEnum([
      "assoc_expand_once",
      "autocd",
      "cdable_vars",
      "cdspell",
      "checkhash",
      "checkjobs",
      "checkwinsize",
      "cmdhist",
      "compat31",
      "compat32",
      "compat40",
      "compat41",
      "compat42",
      "compat43",
      "compat44",
      "complete_fullquote",
      "direxpand",
      "dirspell",
      "dotglob",
      "execfail",
      "expand_aliases",
      "extdebug",
      "extglob",
      "extquote",
      "failglob",
      "force_fignore",
      "globasciiranges",
      "globstar",
      "gnu_errfmt",
      "histappend",
      "histreedit",
      "histverify",
      "hostcomplete",
      "huponexit",
      "inherit_errexit",
      "interactive_comments",
      "lastpipe",
      "lithist",
      "localvar_inherit",
      "localvar_unset",
      "login_shell",
      "mailwarn",
      "no_empty_cmd_completion",
      "nocaseglob",
      "nocasematch",
      "nullglob",
      "progcomp",
      "progcomp_alias",
      "promptvars",
      "restricted_shell",
      "shift_verbose",
      "sourcepath",
      "xpg_echo",
      "allexport",
      "braceexpand",
      "emacs",
      "errexit",
      "errtrace",
      "functrace",
      "hashall",
      "histexpand",
      "history",
      "ignoreeof",
      "keyword",
      "monitor",
      "noclobber",
      "noexec",
      "noglob",
      "nolog",
      "notify",
      "nounset",
      "onecmd",
      "physical",
      "pipefail",
      "posix",
      "privileged",
      "verbose",
      "vi",
      "xtrace"
    ]; dispatch; jpath)
  );

  def isNonEmptyArrayOfOption(dispatch; jpath): (
    assert(dispatch; type == "array"; "type == \"array\""; jpath) |
    assert(dispatch; length > 0; "length > 0"; jpath) |
    (to_entries | map(.value | isOption(dispatch; jpath + "[" + (.key | tostring) + "]")))
  );

  def isInternalLiteral(dispatch; jpath): (
    assert(dispatch; type == "string"; "type == \"string\""; jpath)
  );

  def isKey(dispatch; jpath): (
    assert(dispatch; type == "string"; "type == \"string\""; jpath)
  );

  def isLiteral(dispatch; jpath): (
    assert(dispatch; type == "string"; "type == \"string\""; jpath)
  );

  def isPath(dispatch; jpath): (
    assert(dispatch; type == "string"; "type == \"string\""; jpath)
  );

  def isRegex(dispatch; jpath): (
    assert(dispatch; type == "string"; "type == \"string\""; jpath)
  );

  def isDefaultStringExpansion(dispatch; jpath): (
    assert(dispatch; type == "object"; "type == \"object\""; jpath) |
    assert(dispatch; length == 1; "length == 1"; jpath) |
    assert(dispatch; has("default"); "has(\"default\")"; jpath) |
    assert(dispatch; .default | type == "string"; "type == \"string\""; jpath + ".default")
  );

  def isAlternateStringExpansion(dispatch; jpath): (
    assert(dispatch; type == "object"; "type == \"object\""; jpath) |
    assert(dispatch; length == 1; "length == 1"; jpath) |
    assert(dispatch; has("alternate"); "has(\"alternate\")"; jpath) |
    assert(dispatch; .alternate | type == "string"; "type == \"string\""; jpath + ".alternate")
  );

  def isPromptStringExpansion(dispatch; jpath): (
    assert(dispatch; type == "object"; "type == \"object\""; jpath) |
    assert(dispatch; length == 1; "length == 1"; jpath) |
    assert(dispatch; has("prompt"); "has(\"prompt\")"; jpath) |
    (.prompt | isEmpty(dispatch; jpath + ".prompt"))
  );

  def isRemoveStringExpansion(dispatch; jpath): (
    assert(dispatch; type == "object"; "type == \"object\""; jpath) |
    assert(dispatch; length == 3; "length == 3"; jpath) |
    assert(dispatch; has("short"); "has(\"short\")"; jpath) |
    assert(dispatch; .short | type == "boolean"; "type == \"boolean\""; jpath + ".short") |
    assert(dispatch; has("from_start"); "has(\"from_start\")"; jpath) |
    assert(dispatch; .from_start | type == "boolean"; "type == \"boolean\""; jpath + ".from_start") |
    assert(dispatch; has("pattern"); "has(\"pattern\")"; jpath) |
    (.pattern | isRegex(dispatch; jpath + ".pattern"))
  );

  def is_RemoveStringExpansion(dispatch; jpath): (
    assert(dispatch; type == "object"; "type == \"object\""; jpath) |
    assert(dispatch; length == 1; "length == 1"; jpath) |
    assert(dispatch; has("remove"); "has(\"remove\")"; jpath) |
    (.remove | isRemoveStringExpansion(dispatch; jpath + ".remove"))
  );

  def isReplaceStringExpansion(dispatch; jpath): (
    assert(dispatch; type == "object"; "type == \"object\""; jpath) |
    assert(dispatch; has("global"); "has(\"global\")"; jpath) |
    assert(dispatch; .global | type == "boolean"; "type == \"boolean\""; jpath + ".global") |
    assert(dispatch; has("match"); "has(\"match\")"; jpath) |
    (.["match"] | isRegex(dispatch; jpath)) |
    assert(dispatch; length == 3 or length == 2; "length == 3 or length == 2"; jpath) |
    if (length == 3) then (
      assert(dispatch; has("with"); "has(\"with\")"; jpath) |
      assert(dispatch; .with | type == "string"; "type == \"string\""; jpath + ".with")
    ) end
  );

  def is_ReplaceStringExpansion(dispatch; jpath): (
    assert(dispatch; type == "object"; "type == \"object\""; jpath) |
    assert(dispatch; length == 1; "length == 1"; jpath) |
    assert(dispatch; has("replace"); "has(\"replace\")"; jpath) |
    (.replace | isReplaceStringExpansion(dispatch; jpath + ".replace"))
  );

  def isStringExpansion(dispatch; jpath): (
    assert(dispatch; isDefaultStringExpansion($DISPATCH.AND; jpath) or
      isAlternateStringExpansion($DISPATCH.AND; jpath) or
      isPromptStringExpansion($DISPATCH.AND; jpath) or
      is_RemoveStringExpansion($DISPATCH.AND; jpath) or
      is_ReplaceStringExpansion($DISPATCH.AND; jpath); "isDefaultStringExpansion($DISPATCH.AND; jpath) or isAlternateStringExpansion($DISPATCH.AND; jpath) or isPromptStringExpansion($DISPATCH.AND; jpath) or is_RemoveStringExpansion($DISPATCH.AND; jpath) or is_ReplaceStringExpansion($DISPATCH.AND; jpath)"; jpath)
  );

  def isArrayReference(dispatch; jpath): (
    assert(dispatch; isInteger($DISPATCH.AND; jpath) or
      isKey($DISPATCH.AND; jpath); "isInteger($DISPATCH.AND; jpath) or isKey($DISPATCH.AND; jpath)"; jpath)
  );

  def isArrayIdentifier(dispatch; jpath): (
    assert(dispatch; type == "object"; "type == \"object\""; jpath) |
    assert(dispatch; length == 2; "length == 2"; jpath) |
    assert(dispatch; has("name"); "has(\"name\")"; jpath) |
    (.name | isIdentifier(dispatch; jpath + ".name")) |
    assert(dispatch; has("reference"); "has(\"reference\")"; jpath) |
    (.reference | isArrayReference(dispatch; jpath + ".reference"))
  );

  def isArrayExpansion(dispatch; jpath): (
    assert(dispatch; type == "object"; "type == \"object\""; jpath) |
    assert(dispatch; has("reference"); "has(\"reference\")"; jpath) |
    (.reference | isArrayReference(dispatch; jpath + ".reference")) |
    assert(dispatch; has("offset"); "has(\"offset\")"; jpath) |
    (.offset | isInteger(dispatch; jpath + ".offset")) |
    assert(dispatch; length == 3 or length == 2; "length == 3 or length == 2"; jpath) |
    if (length == 3) then (
      assert(dispatch; has("length"); "has(\"length\")"; jpath) |
      (.["length"] | isInteger(dispatch; jpath + ".length"))
    ) end
  );

  def isDereferencedVariable(dispatch; jpath): (
    assert(dispatch; type == "object"; "type == \"object\""; jpath) |
    assert(dispatch; has("name"); "has(\"name\")"; jpath) |
    (.name | isIdentifier(dispatch; jpath + ".name")) |
    assert(dispatch; length == 3 or length == 2 or length == 1; "length == 3 or length == 2 or length == 1"; jpath) |
    if (length == 3) then (
      assert(dispatch; has("array_expansion"); "has(\"array_expansion\")"; jpath) |
      (.array_expansion | isArrayExpansion(dispatch; jpath + ".array_expansion")) |
      assert(dispatch; has("string_expansion"); "has(\"string_expansion\")"; jpath) |
      (.string_expansion | isStringExpansion(dispatch; jpath + ".string_expansion"))
    ) elif (length == 2) then (
      assert(dispatch; has("array_expansion") or has("string_expansion"); "has(\"array_expansion\") or has(\"string_expansion\")"; jpath) |
      if (has("array_expansion")) then (
        (.array_expansion | isArrayExpansion(dispatch; jpath + ".array_expansion"))
      ) else (
        (.string_expansion | isStringExpansion(dispatch; jpath + ".string_expansion"))
      ) end
    ) end
  );

  def isDereferencedSpecial(dispatch; jpath): (
    assert(dispatch; type == "object"; "type == \"object\""; jpath) |
    assert(dispatch; has("special"); "has(\"special\")"; jpath) |
    (.special | isSpecial(dispatch; jpath + ".special")) |
    assert(dispatch; length == 3 or length == 2 or length == 1; "length == 3 or length == 2 or length == 1"; jpath) |
    if (length == 3) then (
      assert(dispatch; has("array_expansion"); "has(\"array_expansion\")"; jpath) |
      (.array_expansion | isArrayExpansion(dispatch; jpath + ".array_expansion")) |
      assert(dispatch; has("string_expansion"); "has(\"string_expansion\")"; jpath) |
      (.string_expansion | isStringExpansion(dispatch; jpath + ".string_expansion"))
    ) elif (length == 2) then (
      assert(dispatch; has("array_expansion") or has("string_expansion"); "has(\"array_expansion\") or has(\"string_expansion\")"; jpath) |
      if (has("array_expansion")) then (
        (.array_expansion | isArrayExpansion(dispatch; jpath + ".array_expansion"))
      ) else (
        (.string_expansion | isStringExpansion(dispatch; jpath + ".string_expansion"))
      ) end
    ) end
  );

  def isDereferencedParameter(dispatch; jpath): (
    assert(dispatch; type == "object"; "type == \"object\""; jpath) |
    assert(dispatch; has("parameter"); "has(\"parameter\")"; jpath) |
    (.parameter | isParameter(dispatch; jpath + ".parameter")) |
    assert(dispatch; length == 2 or length == 1; "length == 2 or length == 1"; jpath) |
    if (length == 2) then (
      assert(dispatch; has("expansion"); "has(\"expansion\")"; jpath) |
      (.expansion | isStringExpansion(dispatch; jpath + ".expansion"))
    ) end
  );

  def isDereferenced(dispatch; jpath): (
    assert(dispatch; isDereferencedVariable($DISPATCH.AND; jpath) or
      isDereferencedSpecial($DISPATCH.AND; jpath) or
      isDereferencedParameter($DISPATCH.AND; jpath); "isDereferencedVariable($DISPATCH.AND; jpath) or isDereferencedSpecial($DISPATCH.AND; jpath) or isDereferencedParameter($DISPATCH.AND; jpath)"; jpath)
  );

  def isSanitized(dispatch; jpath): (
    assert(dispatch; isLiteral($DISPATCH.AND; jpath) or
      isChar($DISPATCH.AND; jpath) or
      isDereferenced($DISPATCH.AND; jpath) or
      isPath($DISPATCH.AND; jpath) or
      isInternalLiteral($DISPATCH.AND; jpath); "isLiteral($DISPATCH.AND; jpath) or isChar($DISPATCH.AND; jpath) or isDereferenced($DISPATCH.AND; jpath) or isPath($DISPATCH.AND; jpath) or isInternalLiteral($DISPATCH.AND; jpath)"; jpath)
  );

  def isArrayOfSanitized(dispatch; jpath): (
    assert(dispatch; type == "array"; "type == \"array\""; jpath) |
    (to_entries | map(.value | isSanitized(dispatch; jpath + "[" + (.key | tostring) + "]")))
  );

  def isNonEmptyArrayOfSanitized(dispatch; jpath): (
    assert(dispatch; type == "array"; "type == \"array\""; jpath) |
    assert(dispatch; length > 0; "length > 0"; jpath) |
    (to_entries | map(.value | isSanitized(dispatch; jpath + "[" + (.key | tostring) + "]")))
  );

  def isInput(dispatch; jpath): (
    isSanitized(dispatch; jpath)
  );

  def isFile(dispatch; jpath): (
    assert(dispatch; isPath($DISPATCH.AND; jpath) or
      isFileDescriptor($DISPATCH.AND; jpath) or
      isDereferenced($DISPATCH.AND; jpath); "isPath($DISPATCH.AND; jpath) or isFileDescriptor($DISPATCH.AND; jpath) or isDereferenced($DISPATCH.AND; jpath)"; jpath)
  );

  def isOutput(dispatch; jpath): (
    assert(dispatch; type == "object"; "type == \"object\""; jpath) |
    assert(dispatch; length == 3; "length == 3"; jpath) |
    assert(dispatch; has("left"); "has(\"left\")"; jpath) |
    (.left | isFileDescriptor(dispatch; jpath + ".left")) |
    assert(dispatch; has("appending"); "has(\"appending\")"; jpath) |
    assert(dispatch; .appending | type == "boolean"; "type == \"boolean\""; jpath + ".appending") |
    assert(dispatch; has("right"); "has(\"right\")"; jpath) |
    (.right | isFile(dispatch; jpath + ".right"))
  );

  def isRedirection(dispatch; jpath): (
    assert(dispatch; isInput($DISPATCH.AND; jpath) or
      isOutput($DISPATCH.AND; jpath); "isInput($DISPATCH.AND; jpath) or isOutput($DISPATCH.AND; jpath)"; jpath)
  );

  def isArrayOfRedirection(dispatch; jpath): (
    assert(dispatch; type == "array"; "type == \"array\""; jpath) |
    (to_entries | map(.value | isRedirection(dispatch; jpath + "[" + (.key | tostring) + "]")))
  );

  def isImageBuilderPrune(dispatch; jpath): (
    isEmpty(dispatch; jpath)
  );

  def isImageTagDefined(dispatch; jpath): (
    assert(dispatch; type == "object"; "type == \"object\""; jpath) |
    assert(dispatch; length == 2; "length == 2"; jpath) |
    assert(dispatch; has("image"); "has(\"image\")"; jpath) |
    (.image | isSanitized(dispatch; jpath + ".image")) |
    assert(dispatch; has("tag"); "has(\"tag\")"; jpath) |
    (.tag | isSanitized(dispatch; jpath + ".tag"))
  );

  def isImage(dispatch; jpath): (
    assert(dispatch; type == "object"; "type == \"object\""; jpath) |
    assert(dispatch; length == 2; "length == 2"; jpath) |
    assert(dispatch; has("image"); "has(\"image\")"; jpath) |
    (.image | isSanitized(dispatch; jpath + ".image")) |
    assert(dispatch; has("tag"); "has(\"tag\")"; jpath) |
    (.tag | isSanitized(dispatch; jpath + ".tag"))
  );

  def isImageTagCreate(dispatch; jpath): (
    assert(dispatch; type == "object"; "type == \"object\""; jpath) |
    assert(dispatch; length == 2; "length == 2"; jpath) |
    assert(dispatch; has("from"); "has(\"from\")"; jpath) |
    (.from | isImage(dispatch; jpath + ".from")) |
    assert(dispatch; has("to"); "has(\"to\")"; jpath) |
    (.to | isImage(dispatch; jpath + ".to"))
  );

  def isBuildArg(dispatch; jpath): (
    assert(dispatch; type == "object"; "type == \"object\""; jpath) |
    assert(dispatch; length == 2; "length == 2"; jpath) |
    assert(dispatch; has("name"); "has(\"name\")"; jpath) |
    (.name | isIdentifier(dispatch; jpath + ".name")) |
    assert(dispatch; has("value"); "has(\"value\")"; jpath) |
    (.value | isSanitized(dispatch; jpath + ".value"))
  );

  def isArrayOfBuildArg(dispatch; jpath): (
    assert(dispatch; type == "array"; "type == \"array\""; jpath) |
    (to_entries | map(.value | isBuildArg(dispatch; jpath + "[" + (.key | tostring) + "]")))
  );

  def isContext(dispatch; jpath): (
    assert(dispatch; type == "object"; "type == \"object\""; jpath) |
    assert(dispatch; length == 2; "length == 2"; jpath) |
    assert(dispatch; has("path"); "has(\"path\")"; jpath) |
    (.["path"] | isSanitized(dispatch; jpath + ".path")) |
    assert(dispatch; has("args"); "has(\"args\")"; jpath) |
    (.args | isArrayOfBuildArg(dispatch; jpath + ".args"))
  );

  def isNonEmptyArrayOfContext(dispatch; jpath): (
    assert(dispatch; type == "array"; "type == \"array\""; jpath) |
    assert(dispatch; length > 0; "length > 0"; jpath) |
    (to_entries | map(.value | isContext(dispatch; jpath + "[" + (.key | tostring) + "]")))
  );

  def isImageTagCompute(dispatch; jpath): (
    assert(dispatch; type == "object"; "type == \"object\""; jpath) |
    assert(dispatch; length == 1; "length == 1"; jpath) |
    assert(dispatch; has("input"); "has(\"input\")"; jpath) |
    (.["input"] | isNonEmptyArrayOfContext(dispatch; jpath + ".input"))
  );

  def isImageBuild(dispatch; jpath): (
    assert(dispatch; type == "object"; "type == \"object\""; jpath) |
    assert(dispatch; length == 3; "length == 3"; jpath) |
    assert(dispatch; has("image"); "has(\"image\")"; jpath) |
    (.image | isSanitized(dispatch; jpath + ".image")) |
    assert(dispatch; has("tag"); "has(\"tag\")"; jpath) |
    (.tag | isSanitized(dispatch; jpath + ".tag")) |
    assert(dispatch; has("context"); "has(\"context\")"; jpath) |
    (.context | isContext(dispatch; jpath + ".context"))
  );

  def isImageMerge(dispatch; jpath): (
    assert(dispatch; type == "object"; "type == \"object\""; jpath) |
    assert(dispatch; length == 4; "length == 4"; jpath) |
    assert(dispatch; has("image"); "has(\"image\")"; jpath) |
    (.image | isSanitized(dispatch; jpath + ".image")) |
    assert(dispatch; has("tag"); "has(\"tag\")"; jpath) |
    (.tag | isSanitized(dispatch; jpath + ".tag")) |
    assert(dispatch; has("base"); "has(\"base\")"; jpath) |
    (.base | isSanitized(dispatch; jpath + ".base")) |
    assert(dispatch; has("chain"); "has(\"chain\")"; jpath) |
    (.chain | isNonEmptyArrayOfContext(dispatch; jpath + ".chain"))
  );

  def isImagePrune(dispatch; jpath): (
    assert(dispatch; type == "object"; "type == \"object\""; jpath) |
    assert(dispatch; length == 1; "length == 1"; jpath) |
    assert(dispatch; has("pattern"); "has(\"pattern\")"; jpath) |
    (.pattern | isRegex(dispatch; jpath + ".pattern"))
  );

  def isImagePull(dispatch; jpath): (
    assert(dispatch; type == "object"; "type == \"object\""; jpath) |
    assert(dispatch; length == 4; "length == 4"; jpath) |
    assert(dispatch; has("registry"); "has(\"registry\")"; jpath) |
    (.registry | isSanitized(dispatch; jpath + ".registry")) |
    assert(dispatch; has("library"); "has(\"library\")"; jpath) |
    (.library | isSanitized(dispatch; jpath + ".library")) |
    assert(dispatch; has("image"); "has(\"image\")"; jpath) |
    (.image | isSanitized(dispatch; jpath + ".image")) |
    assert(dispatch; has("tag"); "has(\"tag\")"; jpath) |
    (.tag | isSanitized(dispatch; jpath + ".tag"))
  );

  def isImageRemove(dispatch; jpath): (
    assert(dispatch; type == "object"; "type == \"object\""; jpath) |
    assert(dispatch; length == 2; "length == 2"; jpath) |
    assert(dispatch; has("image"); "has(\"image\")"; jpath) |
    (.image | isSanitized(dispatch; jpath + ".image")) |
    assert(dispatch; has("tag"); "has(\"tag\")"; jpath) |
    (.tag | isSanitized(dispatch; jpath + ".tag"))
  );

  def isContainerResourceCopy(dispatch; jpath): (
    assert(dispatch; type == "object"; "type == \"object\""; jpath) |
    assert(dispatch; length == 3; "length == 3"; jpath) |
    assert(dispatch; has("name"); "has(\"name\")"; jpath) |
    (.name | isSanitized(dispatch; jpath + ".name")) |
    assert(dispatch; has("source"); "has(\"source\")"; jpath) |
    (.source | isSanitized(dispatch; jpath + ".source")) |
    assert(dispatch; has("target"); "has(\"target\")"; jpath) |
    (.target | isSanitized(dispatch; jpath + ".target"))
  );

  def isContainerStatusGet(dispatch; jpath): (
    assert(dispatch; type == "object"; "type == \"object\""; jpath) |
    assert(dispatch; length == 1; "length == 1"; jpath) |
    assert(dispatch; has("name"); "has(\"name\")"; jpath) |
    (.name | isSanitized(dispatch; jpath + ".name"))
  );

  def isContainerStatusCreated(dispatch; jpath): (
    assert(dispatch; type == "object"; "type == \"object\""; jpath) |
    assert(dispatch; length == 1; "length == 1"; jpath) |
    assert(dispatch; has("name"); "has(\"name\")"; jpath) |
    (.name | isSanitized(dispatch; jpath + ".name"))
  );

  def isContainerStatusRunning(dispatch; jpath): (
    assert(dispatch; type == "object"; "type == \"object\""; jpath) |
    assert(dispatch; length == 1; "length == 1"; jpath) |
    assert(dispatch; has("name"); "has(\"name\")"; jpath) |
    (.name | isSanitized(dispatch; jpath + ".name"))
  );

  def isContainerStatusHealthy(dispatch; jpath): (
    assert(dispatch; type == "object"; "type == \"object\""; jpath) |
    assert(dispatch; length == 1; "length == 1"; jpath) |
    assert(dispatch; has("name"); "has(\"name\")"; jpath) |
    (.name | isSanitized(dispatch; jpath + ".name"))
  );

  def isVolume(dispatch; jpath): (
    assert(dispatch; type == "object"; "type == \"object\""; jpath) |
    assert(dispatch; length == 2; "length == 2"; jpath) |
    assert(dispatch; has("source"); "has(\"source\")"; jpath) |
    (.source | isSanitized(dispatch; jpath + ".source")) |
    assert(dispatch; has("target"); "has(\"target\")"; jpath) |
    (.target | isSanitized(dispatch; jpath + ".target"))
  );

  def isArrayOfVolume(dispatch; jpath): (
    assert(dispatch; type == "array"; "type == \"array\""; jpath) |
    (to_entries | map(.value | isVolume(dispatch; jpath + "[" + (.key | tostring) + "]")))
  );

  def isContainerCreate(dispatch; jpath): (
    assert(dispatch; type == "object"; "type == \"object\""; jpath) |
    assert(dispatch; length == 4; "length == 4"; jpath) |
    assert(dispatch; has("name"); "has(\"name\")"; jpath) |
    (.name | isSanitized(dispatch; jpath + ".name")) |
    assert(dispatch; has("image"); "has(\"image\")"; jpath) |
    (.image | isSanitized(dispatch; jpath + ".image")) |
    assert(dispatch; has("hostname"); "has(\"hostname\")"; jpath) |
    (.hostname | isSanitized(dispatch; jpath + ".hostname")) |
    assert(dispatch; has("volumes"); "has(\"volumes\")"; jpath) |
    (.volumes | isArrayOfVolume(dispatch; jpath + ".volumes"))
  );

  def isContainerExec(dispatch; jpath): (
    assert(dispatch; type == "object"; "type == \"object\""; jpath) |
    assert(dispatch; length == 4; "length == 4"; jpath) |
    assert(dispatch; has("name"); "has(\"name\")"; jpath) |
    (.name | isSanitized(dispatch; jpath + ".name")) |
    assert(dispatch; has("detached"); "has(\"detached\")"; jpath) |
    (.detached | isSanitized(dispatch; jpath + ".detached")) |
    assert(dispatch; has("user"); "has(\"user\")"; jpath) |
    (.user | isSanitized(dispatch; jpath + ".user")) |
    assert(dispatch; has("command"); "has(\"command\")"; jpath) |
    (.command | isNonEmptyArrayOfSanitized(dispatch; jpath + ".command"))
  );

  def isContainerStart(dispatch; jpath): (
    assert(dispatch; type == "object"; "type == \"object\""; jpath) |
    assert(dispatch; length == 1; "length == 1"; jpath) |
    assert(dispatch; has("name"); "has(\"name\")"; jpath) |
    (.name | isSanitized(dispatch; jpath + ".name"))
  );

  def isContainerStop(dispatch; jpath): (
    assert(dispatch; type == "object"; "type == \"object\""; jpath) |
    assert(dispatch; length == 1; "length == 1"; jpath) |
    assert(dispatch; has("name"); "has(\"name\")"; jpath) |
    (.name | isSanitized(dispatch; jpath + ".name"))
  );

  def isNetworkIpGet(dispatch; jpath): (
    assert(dispatch; type == "object"; "type == \"object\""; jpath) |
    assert(dispatch; length == 2; "length == 2"; jpath) |
    assert(dispatch; has("container"); "has(\"container\")"; jpath) |
    (.container | isSanitized(dispatch; jpath + ".container")) |
    assert(dispatch; has("network"); "has(\"network\")"; jpath) |
    (.network | isSanitized(dispatch; jpath + ".network"))
  );

  def isNetworkCreate(dispatch; jpath): (
    assert(dispatch; type == "object"; "type == \"object\""; jpath) |
    assert(dispatch; length == 2; "length == 2"; jpath) |
    assert(dispatch; has("name"); "has(\"name\")"; jpath) |
    (.name | isSanitized(dispatch; jpath + ".name")) |
    assert(dispatch; has("isolated"); "has(\"isolated\")"; jpath) |
    (.isolated | isSanitized(dispatch; jpath + ".isolated"))
  );

  def isNetworkCreated(dispatch; jpath): (
    assert(dispatch; type == "object"; "type == \"object\""; jpath) |
    assert(dispatch; length == 1; "length == 1"; jpath) |
    assert(dispatch; has("name"); "has(\"name\")"; jpath) |
    (.name | isSanitized(dispatch; jpath + ".name"))
  );

  def isNetworkConnect(dispatch; jpath): (
    assert(dispatch; type == "object"; "type == \"object\""; jpath) |
    assert(dispatch; length == 2; "length == 2"; jpath) |
    assert(dispatch; has("container"); "has(\"container\")"; jpath) |
    (.container | isSanitized(dispatch; jpath + ".container")) |
    assert(dispatch; has("network"); "has(\"network\")"; jpath) |
    (.network | isSanitized(dispatch; jpath + ".network"))
  );

  def isNetworkDisconnect(dispatch; jpath): (
    assert(dispatch; type == "object"; "type == \"object\""; jpath) |
    assert(dispatch; length == 2; "length == 2"; jpath) |
    assert(dispatch; has("container"); "has(\"container\")"; jpath) |
    (.container | isSanitized(dispatch; jpath + ".container")) |
    assert(dispatch; has("network"); "has(\"network\")"; jpath) |
    (.network | isSanitized(dispatch; jpath + ".network"))
  );

  def isNetworkList(dispatch; jpath): (
    assert(dispatch; type == "object"; "type == \"object\""; jpath) |
    assert(dispatch; length == 1; "length == 1"; jpath) |
    assert(dispatch; has("pattern"); "has(\"pattern\")"; jpath) |
    (.pattern | isRegex(dispatch; jpath + ".pattern"))
  );

  def isVolumeCreate(dispatch; jpath): (
    assert(dispatch; type == "object"; "type == \"object\""; jpath) |
    assert(dispatch; length == 1; "length == 1"; jpath) |
    assert(dispatch; has("name"); "has(\"name\")"; jpath) |
    (.name | isSanitized(dispatch; jpath + ".name"))
  );

  def isVolumeCreated(dispatch; jpath): (
    assert(dispatch; type == "object"; "type == \"object\""; jpath) |
    assert(dispatch; length == 1; "length == 1"; jpath) |
    assert(dispatch; has("name"); "has(\"name\")"; jpath) |
    (.name | isSanitized(dispatch; jpath + ".name"))
  );

  def isVolumeList(dispatch; jpath): (
    assert(dispatch; type == "object"; "type == \"object\""; jpath) |
    assert(dispatch; length == 1; "length == 1"; jpath) |
    assert(dispatch; has("pattern"); "has(\"pattern\")"; jpath) |
    (.pattern | isRegex(dispatch; jpath + ".pattern"))
  );

  def isRoutineExec(dispatch; jpath): (
    assert(dispatch; type == "object"; "type == \"object\""; jpath) |
    assert(dispatch; length == 2; "length == 2"; jpath) |
    assert(dispatch; has("imported"); "has(\"imported\")"; jpath) |
    assert(dispatch; .imported | type == "string"; "type == \"string\""; jpath + ".imported") |
    assert(dispatch; has("args"); "has(\"args\")"; jpath) |
    (.args | isArrayOfSanitized(dispatch; jpath + ".args"))
  );

  def is_ImageBuilderPrune(dispatch; jpath): (
    assert(dispatch; type == "object"; "type == \"object\""; jpath) |
    assert(dispatch; length == 1; "length == 1"; jpath) |
    assert(dispatch; has("image.builder.prune"); "has(\"image.builder.prune\")"; jpath) |
    (.["image.builder.prune"] | isImageBuilderPrune(dispatch; jpath + ".[\"image.builder.prune\"]"))
  );

  def is_ImageTagDefined(dispatch; jpath): (
    assert(dispatch; type == "object"; "type == \"object\""; jpath) |
    assert(dispatch; length == 1; "length == 1"; jpath) |
    assert(dispatch; has("image.tag.defined"); "has(\"image.tag.defined\")"; jpath) |
    (.["image.tag.defined"] | isImageTagDefined(dispatch; jpath + ".[\"image.tag.defined\"]"))
  );

  def is_ImageTagCreate(dispatch; jpath): (
    assert(dispatch; type == "object"; "type == \"object\""; jpath) |
    assert(dispatch; length == 1; "length == 1"; jpath) |
    assert(dispatch; has("image.tag.create"); "has(\"image.tag.create\")"; jpath) |
    (.["image.tag.create"] | isImageTagCreate(dispatch; jpath + ".[\"image.tag.create\"]"))
  );

  def is_ImageTagCompute(dispatch; jpath): (
    assert(dispatch; type == "object"; "type == \"object\""; jpath) |
    assert(dispatch; length == 1; "length == 1"; jpath) |
    assert(dispatch; has("image.tag.compute"); "has(\"image.tag.compute\")"; jpath) |
    (.["image.tag.compute"] | isImageTagCompute(dispatch; jpath + ".[\"image.tag.compute\"]"))
  );

  def is_ImageBuild(dispatch; jpath): (
    assert(dispatch; type == "object"; "type == \"object\""; jpath) |
    assert(dispatch; length == 1; "length == 1"; jpath) |
    assert(dispatch; has("image.build"); "has(\"image.build\")"; jpath) |
    (.["image.build"] | isImageBuild(dispatch; jpath + ".[\"image.build\"]"))
  );

  def is_ImageMerge(dispatch; jpath): (
    assert(dispatch; type == "object"; "type == \"object\""; jpath) |
    assert(dispatch; length == 1; "length == 1"; jpath) |
    assert(dispatch; has("image.merge"); "has(\"image.merge\")"; jpath) |
    (.["image.merge"] | isImageMerge(dispatch; jpath + ".[\"image.merge\"]"))
  );

  def is_ImagePrune(dispatch; jpath): (
    assert(dispatch; type == "object"; "type == \"object\""; jpath) |
    assert(dispatch; length == 1; "length == 1"; jpath) |
    assert(dispatch; has("image.prune"); "has(\"image.prune\")"; jpath) |
    (.["image.prune"] | isImagePrune(dispatch; jpath + ".[\"image.prune\"]"))
  );

  def is_ImagePull(dispatch; jpath): (
    assert(dispatch; type == "object"; "type == \"object\""; jpath) |
    assert(dispatch; length == 1; "length == 1"; jpath) |
    assert(dispatch; has("image.pull"); "has(\"image.pull\")"; jpath) |
    (.["image.pull"] | isImagePull(dispatch; jpath + ".[\"image.pull\"]"))
  );

  def is_ImageRemove(dispatch; jpath): (
    assert(dispatch; type == "object"; "type == \"object\""; jpath) |
    assert(dispatch; length == 1; "length == 1"; jpath) |
    assert(dispatch; has("image.remove"); "has(\"image.remove\")"; jpath) |
    (.["image.remove"] | isImageRemove(dispatch; jpath + ".[\"image.remove\"]"))
  );

  def is_ContainerResourceCopy(dispatch; jpath): (
    assert(dispatch; type == "object"; "type == \"object\""; jpath) |
    assert(dispatch; length == 1; "length == 1"; jpath) |
    assert(dispatch; has("container.resource.copy"); "has(\"container.resource.copy\")"; jpath) |
    (.["container.resource.copy"] | isContainerResourceCopy(dispatch; jpath + ".[\"container.resource.copy\"]"))
  );

  def is_ContainerStatusGet(dispatch; jpath): (
    assert(dispatch; type == "object"; "type == \"object\""; jpath) |
    assert(dispatch; length == 1; "length == 1"; jpath) |
    assert(dispatch; has("container.status.get"); "has(\"container.status.get\")"; jpath) |
    (.["container.status.get"] | isContainerStatusGet(dispatch; jpath + ".[\"container.status.get\"]"))
  );

  def is_ContainerStatusCreated(dispatch; jpath): (
    assert(dispatch; type == "object"; "type == \"object\""; jpath) |
    assert(dispatch; length == 1; "length == 1"; jpath) |
    assert(dispatch; has("container.status.created"); "has(\"container.status.created\")"; jpath) |
    (.["container.status.created"] | isContainerStatusCreated(dispatch; jpath + ".[\"container.status.created\"]"))
  );

  def is_ContainerStatusRunning(dispatch; jpath): (
    assert(dispatch; type == "object"; "type == \"object\""; jpath) |
    assert(dispatch; length == 1; "length == 1"; jpath) |
    assert(dispatch; has("container.status.running"); "has(\"container.status.running\")"; jpath) |
    (.["container.status.running"] | isContainerStatusRunning(dispatch; jpath + ".[\"container.status.running\"]"))
  );

  def is_ContainerStatusHealthy(dispatch; jpath): (
    assert(dispatch; type == "object"; "type == \"object\""; jpath) |
    assert(dispatch; length == 1; "length == 1"; jpath) |
    assert(dispatch; has("container.status.healthy"); "has(\"container.status.healthy\")"; jpath) |
    (.["container.status.healthy"] | isContainerStatusHealthy(dispatch; jpath + ".[\"container.status.healthy\"]"))
  );

  def is_ContainerCreate(dispatch; jpath): (
    assert(dispatch; type == "object"; "type == \"object\""; jpath) |
    assert(dispatch; length == 1; "length == 1"; jpath) |
    assert(dispatch; has("container.create"); "has(\"container.create\")"; jpath) |
    (.["container.create"] | isContainerCreate(dispatch; jpath + ".[\"container.create\"]"))
  );

  def is_ContainerExec(dispatch; jpath): (
    assert(dispatch; type == "object"; "type == \"object\""; jpath) |
    assert(dispatch; length == 1; "length == 1"; jpath) |
    assert(dispatch; has("container.exec"); "has(\"container.exec\")"; jpath) |
    (.["container.exec"] | isContainerExec(dispatch; jpath + ".[\"container.exec\"]"))
  );

  def is_ContainerStart(dispatch; jpath): (
    assert(dispatch; type == "object"; "type == \"object\""; jpath) |
    assert(dispatch; length == 1; "length == 1"; jpath) |
    assert(dispatch; has("container.start"); "has(\"container.start\")"; jpath) |
    (.["container.start"] | isContainerStart(dispatch; jpath + ".[\"container.start\"]"))
  );

  def is_ContainerStop(dispatch; jpath): (
    assert(dispatch; type == "object"; "type == \"object\""; jpath) |
    assert(dispatch; length == 1; "length == 1"; jpath) |
    assert(dispatch; has("container.stop"); "has(\"container.stop\")"; jpath) |
    (.["container.stop"] | isContainerStop(dispatch; jpath + ".[\"container.stop\"]"))
  );

  def is_NetworkIpGet(dispatch; jpath): (
    assert(dispatch; type == "object"; "type == \"object\""; jpath) |
    assert(dispatch; length == 1; "length == 1"; jpath) |
    assert(dispatch; has("network.ip.get"); "has(\"network.ip.get\")"; jpath) |
    (.["network.ip.get"] | isNetworkIpGet(dispatch; jpath + ".[\"network.ip.get\"]"))
  );

  def is_NetworkCreate(dispatch; jpath): (
    assert(dispatch; type == "object"; "type == \"object\""; jpath) |
    assert(dispatch; length == 1; "length == 1"; jpath) |
    assert(dispatch; has("network.create"); "has(\"network.create\")"; jpath) |
    (.["network.create"] | isNetworkCreate(dispatch; jpath + ".[\"network.create\"]"))
  );

  def is_NetworkCreated(dispatch; jpath): (
    assert(dispatch; type == "object"; "type == \"object\""; jpath) |
    assert(dispatch; length == 1; "length == 1"; jpath) |
    assert(dispatch; has("network.created"); "has(\"network.created\")"; jpath) |
    (.["network.created"] | isNetworkCreated(dispatch; jpath + ".[\"network.created\"]"))
  );

  def is_NetworkConnect(dispatch; jpath): (
    assert(dispatch; type == "object"; "type == \"object\""; jpath) |
    assert(dispatch; length == 1; "length == 1"; jpath) |
    assert(dispatch; has("network.connect"); "has(\"network.connect\")"; jpath) |
    (.["network.connect"] | isNetworkConnect(dispatch; jpath + ".[\"network.connect\"]"))
  );

  def is_NetworkDisconnect(dispatch; jpath): (
    assert(dispatch; type == "object"; "type == \"object\""; jpath) |
    assert(dispatch; length == 1; "length == 1"; jpath) |
    assert(dispatch; has("network.disconnect"); "has(\"network.disconnect\")"; jpath) |
    (.["network.disconnect"] | isNetworkDisconnect(dispatch; jpath + ".[\"network.disconnect\"]"))
  );

  def is_NetworkList(dispatch; jpath): (
    assert(dispatch; type == "object"; "type == \"object\""; jpath) |
    assert(dispatch; length == 1; "length == 1"; jpath) |
    assert(dispatch; has("network.list"); "has(\"network.list\")"; jpath) |
    (.["network.list"] | isNetworkList(dispatch; jpath + ".[\"network.list\"]"))
  );

  def is_VolumeCreate(dispatch; jpath): (
    assert(dispatch; type == "object"; "type == \"object\""; jpath) |
    assert(dispatch; length == 1; "length == 1"; jpath) |
    assert(dispatch; has("volume.create"); "has(\"volume.create\")"; jpath) |
    (.["volume.create"] | isVolumeCreate(dispatch; jpath + ".[\"volume.create\"]"))
  );

  def is_VolumeCreated(dispatch; jpath): (
    assert(dispatch; type == "object"; "type == \"object\""; jpath) |
    assert(dispatch; length == 1; "length == 1"; jpath) |
    assert(dispatch; has("volume.created"); "has(\"volume.created\")"; jpath) |
    (.["volume.created"] | isVolumeCreated(dispatch; jpath + ".[\"volume.created\"]"))
  );

  def is_VolumeList(dispatch; jpath): (
    assert(dispatch; type == "object"; "type == \"object\""; jpath) |
    assert(dispatch; length == 1; "length == 1"; jpath) |
    assert(dispatch; has("volume.list"); "has(\"volume.list\")"; jpath) |
    (.["volume.list"] | isVolumeList(dispatch; jpath + ".[\"volume.list\"]"))
  );

  def is_RoutineExec(dispatch; jpath): (
    assert(dispatch; type == "object"; "type == \"object\""; jpath) |
    assert(dispatch; length == 1; "length == 1"; jpath) |
    assert(dispatch; has("routine.exec"); "has(\"routine.exec\")"; jpath) |
    (.["routine.exec"] | isRoutineExec(dispatch; jpath + ".[\"routine.exec\"]"))
  );

  def is_Module(dispatch; jpath): (
    assert(dispatch; is_ImageBuilderPrune($DISPATCH.AND; jpath) or
      is_ImageTagDefined($DISPATCH.AND; jpath) or
      is_ImageTagCreate($DISPATCH.AND; jpath) or
      is_ImageTagCompute($DISPATCH.AND; jpath) or
      is_ImageBuild($DISPATCH.AND; jpath) or
      is_ImageMerge($DISPATCH.AND; jpath) or
      is_ImagePrune($DISPATCH.AND; jpath) or
      is_ImagePull($DISPATCH.AND; jpath) or
      is_ImageRemove($DISPATCH.AND; jpath) or
      is_ContainerResourceCopy($DISPATCH.AND; jpath) or
      is_ContainerStatusGet($DISPATCH.AND; jpath) or
      is_ContainerStatusCreated($DISPATCH.AND; jpath) or
      is_ContainerStatusRunning($DISPATCH.AND; jpath) or
      is_ContainerStatusHealthy($DISPATCH.AND; jpath) or
      is_ContainerCreate($DISPATCH.AND; jpath) or
      is_ContainerExec($DISPATCH.AND; jpath) or
      is_ContainerStart($DISPATCH.AND; jpath) or
      is_ContainerStop($DISPATCH.AND; jpath) or
      is_NetworkIpGet($DISPATCH.AND; jpath) or
      is_NetworkCreate($DISPATCH.AND; jpath) or
      is_NetworkCreated($DISPATCH.AND; jpath) or
      is_NetworkConnect($DISPATCH.AND; jpath) or
      is_NetworkDisconnect($DISPATCH.AND; jpath) or
      is_NetworkList($DISPATCH.AND; jpath) or
      is_VolumeCreate($DISPATCH.AND; jpath) or
      is_VolumeCreated($DISPATCH.AND; jpath) or
      is_VolumeList($DISPATCH.AND; jpath) or
      is_RoutineExec($DISPATCH.AND; jpath); "is_ImageBuilderPrune($DISPATCH.AND; jpath) or is_ImageTagDefined($DISPATCH.AND; jpath) or is_ImageTagCreate($DISPATCH.AND; jpath) or is_ImageTagCompute($DISPATCH.AND; jpath) or is_ImageBuild($DISPATCH.AND; jpath) or is_ImageMerge($DISPATCH.AND; jpath) or is_ImagePrune($DISPATCH.AND; jpath) or is_ImagePull($DISPATCH.AND; jpath) or is_ImageRemove($DISPATCH.AND; jpath) or is_ContainerResourceCopy($DISPATCH.AND; jpath) or is_ContainerStatusGet($DISPATCH.AND; jpath) or is_ContainerStatusCreated($DISPATCH.AND; jpath) or is_ContainerStatusRunning($DISPATCH.AND; jpath) or is_ContainerStatusHealthy($DISPATCH.AND; jpath) or is_ContainerCreate($DISPATCH.AND; jpath) or is_ContainerExec($DISPATCH.AND; jpath) or is_ContainerStart($DISPATCH.AND; jpath) or is_ContainerStop($DISPATCH.AND; jpath) or is_NetworkIpGet($DISPATCH.AND; jpath) or is_NetworkCreate($DISPATCH.AND; jpath) or is_NetworkCreated($DISPATCH.AND; jpath) or is_NetworkConnect($DISPATCH.AND; jpath) or is_NetworkDisconnect($DISPATCH.AND; jpath) or is_NetworkList($DISPATCH.AND; jpath) or is_VolumeCreate($DISPATCH.AND; jpath) or is_VolumeCreated($DISPATCH.AND; jpath) or is_VolumeList($DISPATCH.AND; jpath) or is_RoutineExec($DISPATCH.AND; jpath)"; jpath)
  );

  def isArithmeticExpr(dispatch; jpath): (
    def isArithmeticOperand(dispatch; jpath): (
      assert(dispatch; isInteger($DISPATCH.AND; jpath) or
        isIdentifier($DISPATCH.AND; jpath) or
        isDereferenced($DISPATCH.AND; jpath) or
        isArithmeticExpr($DISPATCH.AND; jpath); "isInteger($DISPATCH.AND; jpath) or isIdentifier($DISPATCH.AND; jpath) or isDereferenced($DISPATCH.AND; jpath) or isArithmeticExpr($DISPATCH.AND; jpath)"; jpath)
    );

    def isBinaryArithmeticExpr(dispatch; jpath): (
      assert(dispatch; type == "object"; "type == \"object\""; jpath) |
      assert(dispatch; length == 3; "length == 3"; jpath) |
      assert(dispatch; has("left"); "has(\"left\")"; jpath) |
      (.left | isArithmeticOperand(dispatch; jpath + ".left")) |
      assert(dispatch; has("operator"); "has(\"operator\")"; jpath) |
      (.operator | isBinaryArithmeticOperator(dispatch; jpath + ".operator")) |
      assert(dispatch; has("right"); "has(\"right\")"; jpath) |
      (.right | isArithmeticOperand(dispatch; jpath + ".right"))
    );

    isBinaryArithmeticExpr(dispatch; jpath)
  );

  def isAssign(dispatch; jpath): (
    assert(dispatch; type == "object"; "type == \"object\""; jpath) |
    assert(dispatch; has("scope"); "has(\"scope\")"; jpath) |
    (.scope | isScope(dispatch; jpath + ".scope")) |
    assert(dispatch; has("variables"); "has(\"variables\")"; jpath) |
    (.variables | isNonEmptyArrayOfSanitized(dispatch; jpath + ".variables")) |
    assert(dispatch; length == 3 or length == 2; "length == 3 or length == 2"; jpath) |
    if (length == 3) then (
      assert(dispatch; has("type"); "has(\"type\")"; jpath) |
      (.["type"] | isType(dispatch; jpath + ".type"))
    ) end
  );

  def isColor(dispatch; jpath): (
    assert(dispatch; type == "object"; "type == \"object\""; jpath) |
    assert(dispatch; length == 2; "length == 2"; jpath) |
    assert(dispatch; has("index"); "has(\"index\")"; jpath) |
    (.["index"] | isInteger(dispatch; jpath + ".index")) |
    assert(dispatch; has("variable"); "has(\"variable\")"; jpath) |
    (.variable | isSanitized(dispatch; jpath + ".variable"))
  );

  def isHarden(dispatch; jpath): (
    assert(dispatch; type == "object"; "type == \"object\""; jpath) |
    assert(dispatch; has("command"); "has(\"command\")"; jpath) |
    (.command | isSanitized(dispatch; jpath + ".command")) |
    assert(dispatch; length == 2 or length == 1; "length == 2 or length == 1"; jpath) |
    if (length == 2) then (
      assert(dispatch; has("as"); "has(\"as\")"; jpath) |
      (.["as"] | isType(dispatch; jpath + ".as"))
    ) end
  );

  def isJson(dispatch; jpath): (
    isNonEmptyArrayOfSanitized(dispatch; jpath)
  );

  def isMutable(dispatch; jpath): (
    assert(dispatch; isIdentifier($DISPATCH.AND; jpath) or
      isArrayIdentifier($DISPATCH.AND; jpath) or (
      isSpecial($DISPATCH.AND; jpath) and (. == "last")); "isIdentifier($DISPATCH.AND; jpath) or isArrayIdentifier($DISPATCH.AND; jpath) or (isSpecial($DISPATCH.AND; jpath) and (. == \"last\"))"; jpath)
  );

  def isMutate(dispatch; jpath): (
    assert(dispatch; type == "object"; "type == \"object\""; jpath) |
    assert(dispatch; has("name"); "has(\"name\")"; jpath) |
    (.name | isMutable(dispatch; jpath + ".name")) |
    assert(dispatch; has("value"); "has(\"value\")"; jpath) |
    (.value | isNonEmptyArrayOfSanitized(dispatch; jpath + ".value")) |
    assert(dispatch; length == 3 or length == 2; "length == 3 or length == 2"; jpath) |
    if (length == 3) then (
      assert(dispatch; has("type"); "has(\"type\")"; jpath) |
      (.["type"] | isType(dispatch; jpath + ".type"))
    ) end
  );

  def isOnOff(dispatch; jpath): (
    isNonEmptyArrayOfOption(dispatch; jpath)
  );

  def isParameters(dispatch; jpath): (
    isNonEmptyArrayOfSanitized(dispatch; jpath)
  );

  def isPrint(dispatch; jpath): (
    assert(dispatch; type == "object"; "type == \"object\""; jpath) |
    assert(dispatch; has("format"); "has(\"format\")"; jpath) |
    assert(dispatch; .format | type == "string"; "type == \"string\""; jpath + ".format") |
    assert(dispatch; has("args"); "has(\"args\")"; jpath) |
    (.args | isArrayOfSanitized(dispatch; jpath + ".args")) |
    assert(dispatch; length == 3 or length == 2; "length == 3 or length == 2"; jpath) |
    if (length == 3) then (
      assert(dispatch; has("variable"); "has(\"variable\")"; jpath) |
      (.variable | isIdentifier(dispatch; jpath + ".variable"))
    ) end
  );

  def isReadonly(dispatch; jpath): (
    isNonEmptyArrayOfSanitized(dispatch; jpath)
  );

  def isReturn(dispatch; jpath): (
    isInteger(dispatch; jpath)
  );

  def isSkip(dispatch; jpath): (
    isSanitized(dispatch; jpath)
  );

  def is_ArithmeticExpr(dispatch; jpath): (
    assert(dispatch; type == "object"; "type == \"object\""; jpath) |
    assert(dispatch; length == 1; "length == 1"; jpath) |
    assert(dispatch; has("arithmetic"); "has(\"arithmetic\")"; jpath) |
    (.arithmetic | isArithmeticExpr(dispatch; jpath + ".arithmetic"))
  );

  def is_Assign(dispatch; jpath): (
    assert(dispatch; type == "object"; "type == \"object\""; jpath) |
    assert(dispatch; length == 1; "length == 1"; jpath) |
    assert(dispatch; has("assign"); "has(\"assign\")"; jpath) |
    (.assign | isAssign(dispatch; jpath + ".assign"))
  );

  def is_Capture(dispatch; jpath): (
    assert(dispatch; type == "object"; "type == \"object\""; jpath) |
    assert(dispatch; length == 1; "length == 1"; jpath) |
    assert(dispatch; has("capture"); "has(\"capture\")"; jpath) |
    assert(dispatch; .["capture"] | type == "null"; "type == \"null\""; jpath + ".capture")
  );

  def is_Restore(dispatch; jpath): (
    assert(dispatch; type == "object"; "type == \"object\""; jpath) |
    assert(dispatch; length == 1; "length == 1"; jpath) |
    assert(dispatch; has("restore"); "has(\"restore\")"; jpath) |
    assert(dispatch; .restore | type == "null"; "type == \"null\""; jpath + ".restore")
  );

  def is_CaptureRestore(dispatch; jpath): (
    assert(dispatch; is_Capture($DISPATCH.AND; jpath) or
      is_Restore($DISPATCH.AND; jpath); "is_Capture($DISPATCH.AND; jpath) or is_Restore($DISPATCH.AND; jpath)"; jpath)
  );

  def is_Color(dispatch; jpath): (
    assert(dispatch; type == "object"; "type == \"object\""; jpath) |
    assert(dispatch; length == 1; "length == 1"; jpath) |
    assert(dispatch; has("color"); "has(\"color\")"; jpath) |
    (.color | isColor(dispatch; jpath + ".color"))
  );

  def is_Harden(dispatch; jpath): (
    assert(dispatch; type == "object"; "type == \"object\""; jpath) |
    assert(dispatch; length == 1; "length == 1"; jpath) |
    assert(dispatch; has("harden"); "has(\"harden\")"; jpath) |
    (.harden | isHarden(dispatch; jpath + ".harden"))
  );

  def is_Json(dispatch; jpath): (
    assert(dispatch; type == "object"; "type == \"object\""; jpath) |
    assert(dispatch; length == 1; "length == 1"; jpath) |
    assert(dispatch; has("json.encode"); "has(\"json.encode\")"; jpath) |
    (.["json.encode"] | isJson(dispatch; jpath + ".[\"json.encode\"]"))
  );

  def is_Mutate(dispatch; jpath): (
    assert(dispatch; type == "object"; "type == \"object\""; jpath) |
    assert(dispatch; length == 1; "length == 1"; jpath) |
    assert(dispatch; has("mutate"); "has(\"mutate\")"; jpath) |
    (.mutate | isMutate(dispatch; jpath + ".mutate"))
  );

  def is_On(dispatch; jpath): (
    assert(dispatch; type == "object"; "type == \"object\""; jpath) |
    assert(dispatch; length == 1; "length == 1"; jpath) |
    assert(dispatch; has("on"); "has(\"on\")"; jpath) |
    (.on | isOnOff(dispatch; jpath + ".on"))
  );

  def is_Off(dispatch; jpath): (
    assert(dispatch; type == "object"; "type == \"object\""; jpath) |
    assert(dispatch; length == 1; "length == 1"; jpath) |
    assert(dispatch; has("off"); "has(\"off\")"; jpath) |
    (.off | isOnOff(dispatch; jpath + ".off"))
  );

  def is_OnOff(dispatch; jpath): (
    assert(dispatch; is_On($DISPATCH.AND; jpath) or
      is_Off($DISPATCH.AND; jpath); "is_On($DISPATCH.AND; jpath) or is_Off($DISPATCH.AND; jpath)"; jpath)
  );

  def is_Parameters(dispatch; jpath): (
    assert(dispatch; type == "object"; "type == \"object\""; jpath) |
    assert(dispatch; length == 1; "length == 1"; jpath) |
    assert(dispatch; has("parameters"); "has(\"parameters\")"; jpath) |
    (.parameters | isParameters(dispatch; jpath + ".parameters"))
  );

  def is_Print(dispatch; jpath): (
    assert(dispatch; type == "object"; "type == \"object\""; jpath) |
    assert(dispatch; length == 1; "length == 1"; jpath) |
    assert(dispatch; has("print"); "has(\"print\")"; jpath) |
    (.print | isPrint(dispatch; jpath + ".print"))
  );

  def is_Readonly(dispatch; jpath): (
    assert(dispatch; type == "object"; "type == \"object\""; jpath) |
    assert(dispatch; length == 1; "length == 1"; jpath) |
    assert(dispatch; has("readonly"); "has(\"readonly\")"; jpath) |
    (.readonly | isReadonly(dispatch; jpath + ".readonly"))
  );

  def is_Return(dispatch; jpath): (
    assert(dispatch; type == "object"; "type == \"object\""; jpath) |
    assert(dispatch; length == 1; "length == 1"; jpath) |
    assert(dispatch; has("return"); "has(\"return\")"; jpath) |
    (.return | isInteger(dispatch; jpath + ".return"))
  );

  def is_Skip(dispatch; jpath): (
    assert(dispatch; type == "object"; "type == \"object\""; jpath) |
    assert(dispatch; length == 1; "length == 1"; jpath) |
    assert(dispatch; has("skip"); "has(\"skip\")"; jpath) |
    (.skip | isSanitized(dispatch; jpath + ".skip"))
  );

  def isGroup(dispatch; jpath): (
    def isCall(dispatch; jpath): (
      assert(dispatch; type == "object"; "type == \"object\""; jpath) |
      assert(dispatch; has("command"); "has(\"command\")"; jpath) |
      (.command | isSanitized(dispatch; jpath + ".command")) |
      assert(dispatch; has("args"); "has(\"args\")"; jpath) |
      (.args | isArrayOfSanitized(dispatch; jpath + ".args")) |
      assert(dispatch; length == 3 or length == 2; "length == 3 or length == 2"; jpath) |
      if (length == 3) then (
        assert(dispatch; has("pipe"); "has(\"pipe\")"; jpath) |
        (.pipe | isGroup(dispatch; jpath + ".pipe"))
      ) end
    );

    def isSourceable(dispatch; jpath): (
      assert(dispatch; isPrint($DISPATCH.AND; jpath) or
        isCall($DISPATCH.AND; jpath); "isPrint($DISPATCH.AND; jpath) or isCall($DISPATCH.AND; jpath)"; jpath)
    );

    def isNonEmptyArrayOfSourceable(dispatch; jpath): (
      assert(dispatch; type == "array"; "type == \"array\""; jpath) |
      assert(dispatch; length > 0; "length > 0"; jpath) |
      (to_entries | map(.value | isSourceable(dispatch; jpath + "[" + (.key | tostring) + "]")))
    );

    def isSource(dispatch; jpath): (
      assert(dispatch; isNonEmptyArrayOfSanitized(dispatch; jpath) or
        isNonEmptyArrayOfSourceable(dispatch; jpath); "isNonEmptyArrayOfSanitized(dispatch; jpath) or isNonEmptyArrayOfSourceable(dispatch; jpath)"; jpath)
    );

    def is_Source(dispatch; jpath): (
      assert(dispatch; type == "object"; "type == \"object\""; jpath) |
      assert(dispatch; length == 1; "length == 1"; jpath) |
      assert(dispatch; has("source"); "has(\"source\")"; jpath) |
      (.source | isSource(dispatch; jpath + ".source"))
    );

    def is_Call(dispatch; jpath): (
      assert(dispatch; type == "object"; "type == \"object\""; jpath) |
      assert(dispatch; length == 1; "length == 1"; jpath) |
      assert(dispatch; has("call"); "has(\"call\")"; jpath) |
      (.call | isCall(dispatch; jpath + ".call"))
    );

    def isDefer(dispatch; jpath): (
      assert(dispatch; is_Module($DISPATCH.AND; jpath) or
        is_Call($DISPATCH.AND; jpath); "is_Module($DISPATCH.AND; jpath) or is_Call($DISPATCH.AND; jpath)"; jpath)
    );

    def is_Defer(dispatch; jpath): (
      assert(dispatch; type == "object"; "type == \"object\""; jpath) |
      assert(dispatch; length == 1; "length == 1"; jpath) |
      assert(dispatch; has("defer"); "has(\"defer\")"; jpath) |
      (.defer | isDefer(dispatch; jpath + ".defer"))
    );

    def isInternalCall(dispatch; jpath): (
      assert(dispatch; type == "object"; "type == \"object\""; jpath) |
      assert(dispatch; has("command"); "has(\"command\")"; jpath) |
      (.command | isNoSpace(dispatch; jpath + ".command")) |
      assert(dispatch; has("args"); "has(\"args\")"; jpath) |
      (.args | isArrayOfSanitized(dispatch; jpath + ".args")) |
      assert(dispatch; length == 3 or length == 2; "length == 3 or length == 2"; jpath) |
      if (length == 3) then (
        assert(dispatch; has("pipe"); "has(\"pipe\")"; jpath) |
        (.pipe | isGroup(dispatch; jpath + ".pipe"))
      ) end
    );

    def is_InternalCall(dispatch; jpath): (
      assert(dispatch; type == "object"; "type == \"object\""; jpath) |
      assert(dispatch; length == 1; "length == 1"; jpath) |
      assert(dispatch; has("call"); "has(\"call\")"; jpath) |
      (.call | isInternalCall(dispatch; jpath + ".call"))
    );

    def isLogicalExpr(dispatch; jpath): (
      def isLogicalOperand(dispatch; jpath): (
        assert(dispatch; isLogicalExpr($DISPATCH.AND; jpath) or
          isGroup($DISPATCH.AND; jpath); "isLogicalExpr($DISPATCH.AND; jpath) or isGroup($DISPATCH.AND; jpath)"; jpath)
      );

      def isUnaryLogicalExpr(dispatch; jpath): (
        assert(dispatch; type == "object"; "type == \"object\""; jpath) |
        assert(dispatch; length == 2; "length == 2"; jpath) |
        assert(dispatch; has("operand"); "has(\"operand\")"; jpath) |
        (.operand | isLogicalOperand(dispatch; jpath + ".operand")) |
        assert(dispatch; has("operator"); "has(\"operator\")"; jpath) |
        (.operator | isUnaryLogicalOperator(dispatch; jpath + ".operator"))
      );

      def isBinaryLogicalExpr(dispatch; jpath): (
        assert(dispatch; type == "object"; "type == \"object\""; jpath) |
        assert(dispatch; length == 3; "length == 3"; jpath) |
        assert(dispatch; has("left"); "has(\"left\")"; jpath) |
        (.left | isLogicalOperand(dispatch; jpath + ".left")) |
        assert(dispatch; has("operator"); "has(\"operator\")"; jpath) |
        (.operator | isBinaryLogicalOperator(dispatch; jpath + ".operator")) |
        assert(dispatch; has("right"); "has(\"right\")"; jpath) |
        (.right | isLogicalOperand(dispatch; jpath + ".right"))
      );

      assert(dispatch; isUnaryLogicalExpr($DISPATCH.AND; jpath) or
        isBinaryLogicalExpr($DISPATCH.AND; jpath); "isUnaryLogicalExpr($DISPATCH.AND; jpath) or isBinaryLogicalExpr($DISPATCH.AND; jpath)"; jpath)
    );

    def isIf(dispatch; jpath): (
      def isElse(dispatch; jpath): (
        assert(dispatch; isIf($DISPATCH.AND; jpath) or
          isGroup($DISPATCH.AND; jpath); "isIf($DISPATCH.AND; jpath) or isGroup($DISPATCH.AND; jpath)"; jpath)
      );

      def isArrayOfElse(dispatch; jpath): (
        assert(dispatch; type == "array"; "type == \"array\""; jpath) |
        (to_entries | map(.value | isElse(dispatch; jpath + "[" + (.key | tostring) + "]")))
      );

      assert(dispatch; type == "object"; "type == \"object\""; jpath) |
      assert(dispatch; length == 3; "length == 3"; jpath) |
      assert(dispatch; has("if"); "has(\"if\")"; jpath) |
      (.["if"] | isLogicalExpr(dispatch; jpath + ".if")) |
      assert(dispatch; has("then"); "has(\"then\")"; jpath) |
      (.["then"] | isGroup(dispatch; jpath + ".then")) |
      assert(dispatch; has("else"); "has(\"else\")"; jpath) |
      (.["else"] | isArrayOfElse(dispatch; jpath + ".else"))
    );

    def isRange(dispatch; jpath): (
      assert(dispatch; type == "object"; "type == \"object\""; jpath) |
      assert(dispatch; length == 4; "length == 4"; jpath) |
      assert(dispatch; has("initial"); "has(\"initial\")"; jpath) |
      (.initial | isArithmeticExpr(dispatch; jpath + ".initial")) |
      assert(dispatch; has("conditional"); "has(\"conditional\")"; jpath) |
      (.conditional | isArithmeticExpr(dispatch; jpath + ".conditional")) |
      assert(dispatch; has("update"); "has(\"update\")"; jpath) |
      (.update | isArithmeticExpr(dispatch; jpath + ".update")) |
      assert(dispatch; has("do"); "has(\"do\")"; jpath) |
      (.do | isGroup(dispatch; jpath + ".do"))
    );

    def isIterator(dispatch; jpath): (
      assert(dispatch; type == "object"; "type == \"object\""; jpath) |
      assert(dispatch; length == 3; "length == 3"; jpath) |
      assert(dispatch; has("for"); "has(\"for\")"; jpath) |
      (.for | isIdentifier(dispatch; jpath + ".for")) |
      assert(dispatch; has("into"); "has(\"into\")"; jpath) |
      (.into | isDereferenced(dispatch; jpath + ".into")) |
      assert(dispatch; has("do"); "has(\"do\")"; jpath) |
      (.do | isGroup(dispatch; jpath + ".do"))
    );

    def isConditional(dispatch; jpath): (
      assert(dispatch; type == "object"; "type == \"object\""; jpath) |
      assert(dispatch; length == 2; "length == 2"; jpath) |
      assert(dispatch; has("while"); "has(\"while\")"; jpath) |
      (.["while"] | isLogicalExpr(dispatch; jpath + ".while")) |
      assert(dispatch; has("do"); "has(\"do\")"; jpath) |
      (.do | isGroup(dispatch; jpath + ".do"))
    );

    def isLoop(dispatch; jpath): (
      assert(dispatch; isRange($DISPATCH.AND; jpath) or
        isIterator($DISPATCH.AND; jpath) or
        isConditional($DISPATCH.AND; jpath); "isRange($DISPATCH.AND; jpath) or isIterator($DISPATCH.AND; jpath) or isConditional($DISPATCH.AND; jpath)"; jpath)
    );

    def is_Loop(dispatch; jpath): (
      assert(dispatch; type == "object"; "type == \"object\""; jpath) |
      assert(dispatch; length == 1; "length == 1"; jpath) |
      assert(dispatch; has("loop"); "has(\"loop\")"; jpath) |
      (.loop | isLoop(dispatch; jpath + ".loop"))
    );

    def isSubshell(dispatch; jpath): (
      assert(dispatch; isGroup($DISPATCH.AND; jpath) or
        isArithmeticExpr($DISPATCH.AND; jpath); "isGroup($DISPATCH.AND; jpath) or isArithmeticExpr($DISPATCH.AND; jpath)"; jpath)
    );

    def isRegister(dispatch; jpath): (
      assert(dispatch; type == "object"; "type == \"object\""; jpath) |
      assert(dispatch; length == 2; "length == 2"; jpath) |
      assert(dispatch; has("variable"); "has(\"variable\")"; jpath) |
      (.variable | isMutable(dispatch; jpath + ".variable")) |
      assert(dispatch; has("subshell"); "has(\"subshell\")"; jpath) |
      (.subshell | isSubshell(dispatch; jpath + ".subshell"))
    );

    def is_Register(dispatch; jpath): (
      assert(dispatch; type == "object"; "type == \"object\""; jpath) |
      assert(dispatch; length == 1; "length == 1"; jpath) |
      assert(dispatch; has("register"); "has(\"register\")"; jpath) |
      (.register | isRegister(dispatch; jpath + ".register"))
    );

    def isNonEmptyArrayOfCommand(dispatch; jpath): (
      def isCommand(dispatch; jpath): (
        def isCoproc(dispatch; jpath): (
          assert(dispatch; type == "object"; "type == \"object\""; jpath) |
          assert(dispatch; length == 2; "length == 2"; jpath) |
          assert(dispatch; has("name"); "has(\"name\")"; jpath) |
          (.name | isIdentifier(dispatch; jpath + ".name")) |
          assert(dispatch; has("commands"); "has(\"commands\")"; jpath) |
          (.commands | isNonEmptyArrayOfCommand(dispatch; jpath + ".commands"))
        );

        def is_Coproc(dispatch; jpath): (
          assert(dispatch; type == "object"; "type == \"object\""; jpath) |
          assert(dispatch; length == 1; "length == 1"; jpath) |
          assert(dispatch; has("coproc"); "has(\"coproc\")"; jpath) |
          (.coproc | isCoproc(dispatch; jpath + ".coproc"))
        );

        def isInternal(dispatch; jpath): (
          assert(dispatch; is_InternalCall($DISPATCH.AND; jpath) or
            is_Coproc($DISPATCH.AND; jpath); "is_InternalCall($DISPATCH.AND; jpath) or is_Coproc($DISPATCH.AND; jpath)"; jpath)
        );

        def is_Internal(dispatch; jpath): (
          assert(dispatch; type == "object"; "type == \"object\""; jpath) |
          assert(dispatch; length == 1; "length == 1"; jpath) |
          assert(dispatch; has("internal"); "has(\"internal\")"; jpath) |
          (.internal | isInternal(dispatch; jpath + ".internal"))
        );

        def isBranch(dispatch; jpath): (
          assert(dispatch; type == "object"; "type == \"object\""; jpath) |
          assert(dispatch; length == 2; "length == 2"; jpath) |
          assert(dispatch; has("pattern"); "has(\"pattern\")"; jpath) |
          (.pattern | isRegex(dispatch; jpath + ".pattern")) |
          assert(dispatch; has("commands"); "has(\"commands\")"; jpath) |
          (.commands | isNonEmptyArrayOfCommand(dispatch; jpath + ".commands"))
        );

        def isNonEmptyArrayOfBranch(dispatch; jpath): (
          assert(dispatch; type == "array"; "type == \"array\""; jpath) |
          assert(dispatch; length > 0; "length > 0"; jpath) |
          (to_entries | map(.value | isBranch(dispatch; jpath + "[" + (.key | tostring) + "]")))
        );

        def isSwitch(dispatch; jpath): (
          assert(dispatch; type == "object"; "type == \"object\""; jpath) |
          assert(dispatch; length == 2; "length == 2"; jpath) |
          assert(dispatch; has("evaluate"); "has(\"evaluate\")"; jpath) |
          (.evaluate | isSanitized(dispatch; jpath + ".evaluate")) |
          assert(dispatch; has("branches"); "has(\"branches\")"; jpath) |
          (.branches | isNonEmptyArrayOfBranch(dispatch; jpath + ".branches"))
        );

        def is_Switch(dispatch; jpath): (
          assert(dispatch; type == "object"; "type == \"object\""; jpath) |
          assert(dispatch; length == 1; "length == 1"; jpath) |
          assert(dispatch; has("switch"); "has(\"switch\")"; jpath) |
          (.switch | isSwitch(dispatch; jpath + ".switch"))
        );

        def isDefine(dispatch; jpath): (
          assert(dispatch; type == "object"; "type == \"object\""; jpath) |
          assert(dispatch; length == 2; "length == 2"; jpath) |
          assert(dispatch; has("name"); "has(\"name\")"; jpath) |
          (.name | isIdentifier(dispatch; jpath + ".name")) |
          assert(dispatch; has("body"); "has(\"body\")"; jpath) |
          (.body | isGroup(dispatch; jpath + ".body"))
        );

        def is_Define(dispatch; jpath): (
          assert(dispatch; type == "object"; "type == \"object\""; jpath) |
          assert(dispatch; length == 1; "length == 1"; jpath) |
          assert(dispatch; has("define"); "has(\"define\")"; jpath) |
          (.define | isDefine(dispatch; jpath + ".define"))
        );

        assert(dispatch; is_ArithmeticExpr($DISPATCH.AND; jpath) or
          is_Assign($DISPATCH.AND; jpath) or
          is_CaptureRestore($DISPATCH.AND; jpath) or
          is_Color($DISPATCH.AND; jpath) or
          is_Defer($DISPATCH.AND; jpath) or
          is_Define($DISPATCH.AND; jpath) or
          isGroup($DISPATCH.AND; jpath) or
          is_Harden($DISPATCH.AND; jpath) or
          isIf($DISPATCH.AND; jpath) or
          is_Internal($DISPATCH.AND; jpath) or
          is_Json($DISPATCH.AND; jpath) or
          is_Loop($DISPATCH.AND; jpath) or
          is_Mutate($DISPATCH.AND; jpath) or
          is_OnOff($DISPATCH.AND; jpath) or
          is_Parameters($DISPATCH.AND; jpath) or
          is_Print($DISPATCH.AND; jpath) or
          is_Readonly($DISPATCH.AND; jpath) or
          is_Register($DISPATCH.AND; jpath) or
          is_Return($DISPATCH.AND; jpath) or
          is_Skip($DISPATCH.AND; jpath) or
          is_Source($DISPATCH.AND; jpath) or
          is_Switch($DISPATCH.AND; jpath) or
          is_Call($DISPATCH.AND; jpath) or
          is_Module($DISPATCH.AND; jpath); "is_ArithmeticExpr($DISPATCH.AND; jpath) or is_Assign($DISPATCH.AND; jpath) or is_CaptureRestore($DISPATCH.AND; jpath) or is_Color($DISPATCH.AND; jpath) or is_Defer($DISPATCH.AND; jpath) or is_Define($DISPATCH.AND; jpath) or isGroup($DISPATCH.AND; jpath) or is_Harden($DISPATCH.AND; jpath) or isIf($DISPATCH.AND; jpath) or is_Internal($DISPATCH.AND; jpath) or is_Json($DISPATCH.AND; jpath) or is_Loop($DISPATCH.AND; jpath) or is_Mutate($DISPATCH.AND; jpath) or is_OnOff($DISPATCH.AND; jpath) or is_Parameters($DISPATCH.AND; jpath) or is_Print($DISPATCH.AND; jpath) or is_Readonly($DISPATCH.AND; jpath) or is_Register($DISPATCH.AND; jpath) or is_Return($DISPATCH.AND; jpath) or is_Skip($DISPATCH.AND; jpath) or is_Source($DISPATCH.AND; jpath) or is_Switch($DISPATCH.AND; jpath) or is_Call($DISPATCH.AND; jpath) or is_Module($DISPATCH.AND; jpath)"; jpath)
      );
      assert(dispatch; type == "array"; "type == \"array\""; jpath) |
      assert(dispatch; length > 0; "length > 0"; jpath) |
      (to_entries | map(.value | isCommand(dispatch; jpath + "[" + (.key | tostring) + "]")))
    );

    assert(dispatch; type == "object"; "type == \"object\""; jpath) |
    assert(dispatch; length == 2; "length == 2"; jpath) |
    assert(dispatch; has("redirections"); "has(\"redirections\")"; jpath) |
    assert(dispatch; has("commands"); "has(\"commands\")"; jpath) |
    (.redirections | isArrayOfRedirection(dispatch; jpath + ".redirections")) and
    (.commands | isNonEmptyArrayOfCommand(dispatch; jpath + ".commands"))
  );

  assert($DISPATCH.ASSERT; type == "object"; "type == \"object\""; ".") |
  assert($DISPATCH.ASSERT; length == 1; "length == 1"; ".") |
  assert($DISPATCH.ASSERT; has("routine"); "has(\"routine\")"; ".") |
  (.routine | isGroup($DISPATCH.ASSERT; ".routine"))
);
