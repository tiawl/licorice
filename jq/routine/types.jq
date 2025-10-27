#! /usr/bin/env --split-string gojq --from-file

def isRoutine: (
  def isFromEnum(fields; assert; jpath): (
    . as $input |
    if (fields | type != "array") then unreachable("(fields | type != \"array\") case into isFromEnum") end |
    if (fields | length > 0) then unreachable("(fields | length > 0) case into inFromEnum") end |
    if (fields | map(type == "string") | all) then unreachable("(fields | map(type == \"string\") | all) case into inFromEnum") end |
    if ($input | type == "string") then unreachable("($input | type == \"string\") case into inFromEnum") end |
    assert(fields | contains([$input]); "fields | contains([$input])"; jpath)
  );

  def isArray(function; assert; jpath): (
    if (function | type != "boolean") then unreachable("isArray") end |
    assert(type == "array"; "type == \"array\""; jpath) |
    (to_entries | map(.value | function(assert; jpath + "[" + (.key | tostring) + "]")))
  );

  def isNonEmptyArray(function; assert; jpath): (
    assert(length > 0; "length > 0"; jpath) |
    (isArray(function; assert; jpath))
  );

  def isEmpty(assert; jpath): (
    assert(type == "object"; "type == \"object\""; jpath) |
    assert(length == 0; "length == 0"; jpath)
  );

  def isIdentifier(assert; jpath): (
    assert(type == "string"; "type == \"string\""; jpath) |
    assert(test("^[a-zA-Z_][a-zA-Z0-9_]*$"); "test(\"^[a-zA-Z_][a-zA-Z0-9_]*$\")"; jpath)
  );

  def isNoSpace(assert; jpath): (
    assert(type == "string"; "type == \"string\""; jpath) |
    assert(test("^[^[:space:]]*$"); "test(\"^[^[:space:]]*$\")"; jpath)
  );

  def isChar(assert; jpath): (
    isFromEnum([
      "asterisk",
      "tilde",
      "atsign",
      "newline"
    ]; assert; jpath)
  );

  def isInteger(assert; jpath): (
    assert(type == "number"; "type == \"number\""; jpath) |
    assert(. == floor; ". == floor"; jpath)
  );

  def isParameter(assert; jpath): (
    assert(isInteger(assert; jpath); "isInteger(assert; jpath)"; jpath) |
    assert(. >= 0; ". >= 0"; jpath)
  );

  def isFileDescriptor(assert; jpath): (
    assert(isInteger(assert; jpath); "isInteger(assert; jpath)"; jpath) |
    assert(. > 0; ". > 0"; jpath)
  );

  def isSpecial(assert; jpath): (
    isFromEnum([
      "last",
      "FUNCNAME",
      "USER",
      "UID",
      "HOME",
      "ROUTINE",
      "at_parameters",
      "sep"
    ]; assert; jpath)
  );

  def isBinaryArithmeticOperator(assert; jpath): (
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
    ]; assert; jpath)
  );

  def isScope(assert; jpath): (
    isFromEnum([
      "Local",
      "Global"
    ]; assert; jpath)
  );

  def isType(assert; jpath): (
    isFromEnum([
      "String",
      "Associative",
      "Indexed",
      "Reference"
    ]; assert; jpath)
  );

  def isUnaryLogicalOperator(assert; jpath): (
    isFromEnum([
      "Not"
    ]; assert; jpath)
  );

  def isBinaryLogicalOperator(assert; jpath): (
    isFromEnum([
      "And",
      "Or"
    ]; assert; jpath)
  );

  def isOption(assert; jpath): (
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
    ]; assert; jpath)
  );

  def isInternalLiteral(assert; jpath): (
    assert(type == "string"; "type == \"string\""; jpath)
  );

  def isKey(assert; jpath): (
    assert(type == "string"; "type == \"string\""; jpath)
  );

  def isLiteral(assert; jpath): (
    assert(type == "string"; "type == \"string\""; jpath)
  );

  def isPath(assert; jpath): (
    assert(type == "string"; "type == \"string\""; jpath)
  );

  def isRegex(assert; jpath): (
    assert(type == "string"; "type == \"string\""; jpath)
  );

  def isDefaultStringExpansion(assert; jpath): (
    assert(type == "object"; "type == \"object\""; jpath) |
    assert(length == 1; "length == 1"; jpath) |
    assert(has("default"); "has(\"default\")"; jpath) |
    assert(.default | type == "string"; "type == \"string\""; jpath + ".default")
  );

  def isAlternateStringExpansion(assert; jpath): (
    assert(type == "object"; "type == \"object\""; jpath) |
    assert(length == 1; "length == 1"; jpath) |
    assert(has("alternate"); "has(\"alternate\")"; jpath) |
    assert(.alternate | type == "string"; "type == \"string\""; jpath + ".alternate")
  );

  def isPromptStringExpansion(assert; jpath): (
    assert(type == "object"; "type == \"object\""; jpath) |
    assert(length == 1; "length == 1"; jpath) |
    assert(has("prompt"); "has(\"prompt\")"; jpath) |
    (.prompt | isEmpty(assert; jpath + ".prompt"))
  );

  def isRemoveStringExpansion(assert; jpath): (
    assert(type == "object"; "type == \"object\""; jpath) |
    assert(length == 3; "length == 3"; jpath) |
    assert(has("short"); "has(\"short\")"; jpath) |
    assert(.short | type == "boolean"; "type == \"boolean\""; jpath + ".short") |
    assert(has("from_start"); "has(\"from_start\")"; jpath) |
    assert(.from_start | type == "boolean"; "type == \"boolean\""; jpath + ".from_start") |
    assert(has("pattern"); "has(\"pattern\")"; jpath) |
    (.pattern | isRegex(assert; jpath + ".pattern"))
  );

  def is_RemoveStringExpansion(assert; jpath): (
    assert(type == "object"; "type == \"object\""; jpath) |
    assert(length == 1; "length == 1"; jpath) |
    assert(has("remove"); "has(\"remove\")"; jpath) |
    (.remove | isRemoveStringExpansion(assert; jpath + ".remove"))
  );

  def isReplaceStringExpansion(assert; jpath): (
    assert(type == "object"; "type == \"object\""; jpath) |
    assert(has("global"); "has(\"global\")"; jpath) |
    assert(.global | type == "boolean"; "type == \"boolean\""; jpath + ".global") |
    assert(has("match"); "has(\"match\")"; jpath) |
    (.match | isRegex(assert; jpath)) |
    if (length == 3) then (
      assert(has("with"); "has(\"with\")"; jpath) |
      assert(.with | type == "string"; "type == \"string\""; jpath + ".with")
    ) else (
      assert(length == 2; "length == 2"; jpath)
    ) end
  );

  def is_ReplaceStringExpansion(assert; jpath): (
    assert(type == "object"; "type == \"object\""; jpath) |
    assert(length == 1; "length == 1"; jpath) |
    assert(has("replace"); "has(\"replace\")"; jpath) |
    (.replace | isReplaceStringExpansion(assert; jpath + ".replace"))
  );

  def isStringExpansion(assert; jpath): (
    assert(isDefaultStringExpansion(AND; jpath) or
      isAlternateStringExpansion(AND; jpath) or
      isPromptStringExpansion(AND; jpath) or
      is_RemoveStringExpansion(AND; jpath) or
      is_ReplaceStringExpansion(AND; jpath); "isDefaultStringExpansion(AND; jpath) or isAlternateStringExpansion(AND; jpath) or isPromptStringExpansion(AND; jpath) or is_RemoveStringExpansion(AND; jpath) or is_ReplaceStringExpansion(AND; jpath)"; jpath)
  );

  def isArrayReference(assert; jpath): (
    assert(isInteger(AND; jpath) or
      isKey(AND; jpath); "isInteger(AND; jpath) or isKey(AND; jpath)"; jpath)
  );

  def isArrayIdentifier(assert; jpath): (
    assert(type == "object"; "type == \"object\""; jpath) |
    assert(length == 2; "length == 2"; jpath) |
    assert(has("name"); "has(\"name\")"; jpath) |
    assert(has("reference"); "has(\"reference\")"; jpath) |
    (.name | isIdentifier(assert; jpath + ".name")) |
    (.reference | isArrayReference(assert; jpath + ".reference"))
  );

  def isArrayExpansion(assert; jpath): (
    assert(type == "object"; "type == \"object\""; jpath) |
    assert(has("reference"); "has(\"reference\")"; jpath) |
    assert(has("offset"); "has(\"offset\")"; jpath) |
    (.reference | isArrayReference(assert; jpath + ".reference")) |
    (.offset | isInteger(assert; jpath + ".offset")) |
    if (length == 3) then (
      assert(has("length"); "has(\"length\")"; jpath) |
      (.length | isInteger(assert; jpath + ".length"))
    ) else (
      assert(length == 2; "length == 2"; jpath)
    ) end
  );

  def isDereferencedVariable(assert; jpath): (
    assert(type == "object"; "type == \"object\""; jpath) |
    assert(has("name"); "has(\"name\")"; jpath) |
    (.name | isIdentifier(assert; jpath + ".name")) |
    if (length == 3) then (
      assert(has("array_expansion"); "has(\"array_expansion\")"; jpath) |
      assert(has("string_expansion"); "has(\"string_expansion\")"; jpath) |
      (.array_expansion | isArrayExpansion(assert; jpath + ".array_expansion")) |
      (.string_expansion | isStringExpansion(assert; jpath + ".string_expansion"))
    ) elif (length == 2) then (
      if (has("array_expansion")) then (
        (.array_expansion | isArrayExpansion(assert; jpath + ".array_expansion"))
      ) else (
        assert(has("string_expansion"); "has(\"string_expansion\")"; jpath) |
        (.string_expansion | isStringExpansion(assert; jpath + ".string_expansion"))
      ) end
    ) else (
      assert(length == 1; "length == 1"; jpath) |
    )
  );

  def isDereferencedSpecial(assert; jpath): (
    assert(type == "object"; "type == \"object\""; jpath) |
    assert(has("special"); "has(\"special\")"; jpath) |
    (.special | isSpecial(assert; jpath + ".special")) |
    if (length == 3) then (
      assert(has("array_expansion"); "has(\"array_expansion\")"; jpath) |
      assert(has("string_expansion"); "has(\"string_expansion\")"; jpath) |
      (.array_expansion | isArrayExpansion(assert; jpath + ".array_expansion")) |
      (.string_expansion | isStringExpansion(assert; jpath + ".string_expansion"))
    ) elif (length == 2) then (
      if (has("array_expansion")) then (
        (.array_expansion | isArrayExpansion(assert; jpath + ".array_expansion"))
      ) else (
        assert(has("string_expansion"); "has(\"string_expansion\")"; jpath) |
        (.string_expansion | isStringExpansion(assert; jpath + ".string_expansion"))
      ) end
    ) else (
      assert(length == 1; "length == 1"; jpath) |
    )
  );

  def isDereferencedParameter(assert; jpath): (
    assert(type == "object"; "type == \"object\""; jpath) |
    assert(has("parameter"); "has(\"parameter\")"; jpath) |
    (.parameter | isParameter(assert; jpath + ".parameter")) |
    if (length == 2) then (
      assert(has("expansion"); "has(\"expansion\")"; jpath) |
      (.expansion | isStringExpansion(assert; jpath + ".expansion"))
    ) else (
      assert(length == 1; "length == 1"; jpath)
    ) end
  );

  def isDereferenced(assert; jpath): (
    assert(isDereferencedVariable(AND; jpath) or
      isDereferencedSpecial(AND; jpath) or
      isDereferencedParameter(AND; jpath); "isDereferencedVariable(AND; jpath) or isDereferencedSpecial(AND; jpath) or isDereferencedParameter(AND; jpath)"; jpath)
  );

  def isSanitized(assert; jpath): (
    assert(isLiteral(AND; jpath) or
      isChar(AND; jpath) or
      isDereferenced(AND; jpath) or
      isPath(AND; jpath) or
      isInternalLiteral(AND; jpath); "isLiteral(AND; jpath) or isChar(AND; jpath) or isDereferenced(AND; jpath) or isPath(AND; jpath) or isInternalLiteral(AND; jpath)"; jpath)
  );

  def isInput(assert; jpath): (
    isSanitized(assert; jpath)
  );

  def isFile(assert; jpath): (
    assert(isPath(AND; jpath) or
      isFileDescriptor(AND; jpath) or
      isDereferenced(AND; jpath); "isPath(AND; jpath) or isFileDescriptor(AND; jpath) or isDereferenced(AND; jpath)"; jpath)
  );

  def isOutput(assert; jpath): (
    assert(type == "object"; "type == \"object\""; jpath) |
    assert(length == 3; "length == 3"; jpath) |
    assert(has("left"); "has(\"left\")"; jpath) |
    (.left | isFileDescriptor(assert; jpath + ".left")) |
    assert(has("appending"); "has(\"appending\")"; jpath) |
    assert(.appending | type == "boolean"; "type == \"boolean\""; jpath + ".appending")
    assert(has("right"); "has(\"right\")"; jpath) |
    (.right | isFile(assert; jpath + ".right"))
  );

  def isRedirection(assert; jpath): (
    assert(isInput(AND; jpath) or
      isOutput(AND; jpath); "isInput(AND; jpath) or isOutput(AND; jpath)"; jpath)
  );

  def isImageBuilderPrune(assert; jpath): (
    isEmpty(assert; jpath)
  );

  def isImageTagDefined(assert; jpath): (
    assert(type == "object"; "type == \"object\""; jpath) |
    assert(length == 2; "length == 2"; jpath) |
    assert(has("image"); "has(\"image\")"; jpath) |
    (.image | isSanitized(assert; jpath + ".image")) |
    assert(has("tag"); "has(\"tag\")"; jpath) |
    (.tag | isSanitized(assert; jpath + ".tag"))
  );

  def isImage(assert; jpath): (
    assert(type == "object"; "type == \"object\""; jpath) |
    assert(length == 2; "length == 2"; jpath) |
    assert(has("image"); "has(\"image\")"; jpath) |
    (.image | isSanitized(assert; jpath + ".image")) |
    assert(has("tag"); "has(\"tag\")"; jpath) |
    (.tag | isSanitized(assert; jpath + ".tag"))
  );

  def isImageTagCreate(assert; jpath): (
    assert(type == "object"; "type == \"object\""; jpath) |
    assert(length == 2; "length == 2"; jpath) |
    assert(has("from"); "has(\"from\")"; jpath) |
    (.from | isImage(assert; jpath + ".from")) |
    assert(has("to"); "has(\"to\")"; jpath) |
    (.to | isImage(assert; jpath + ".to"))
  );

  def isBuildArg(assert; jpath): (
    assert(type == "object"; "type == \"object\""; jpath) |
    assert(length == 2; "length == 2"; jpath) |
    assert(has("name"); "has(\"name\")"; jpath) |
    (.name | isIdentifier(assert; jpath + ".name")) |
    assert(has("value"); "has(\"value\")"; jpath) |
    (.value | isSanitized(assert; jpath + ".value"))
  );

  def isContext(assert; jpath): (
    assert(type == "object"; "type == \"object\""; jpath) |
    assert(length == 2; "length == 2"; jpath) |
    assert(has("path"); "has(\"path\")"; jpath) |
    (.path | isSanitized(assert; jpath + ".path")) |
    assert(has("args"); "has(\"args\")"; jpath) |
    (.args | isArray(isBuildArg; assert; jpath + ".args"))
  );

  def isImageTagCompute(assert; jpath): (
    assert(type == "object"; "type == \"object\""; jpath) |
    assert(length == 1; "length == 1"; jpath) |
    assert(has("input"); "has(\"input\")"; jpath) |
    (.input | isNonEmptyArray(isContext; assert; jpath + ".input"))
  );

  def isImageBuild(assert; jpath): (
    assert(type == "object"; "type == \"object\""; jpath) |
    assert(length == 3; "length == 3"; jpath) |
    assert(has("image"); "has(\"image\")"; jpath) |
    (.image | isSanitized(assert; jpath + ".image")) |
    assert(has("tag"); "has(\"tag\")"; jpath) |
    (.tag | isSanitized(assert; jpath + ".tag")) |
    assert(has("context"); "has(\"context\")"; jpath) |
    (.context | isContext(assert; jpath + ".context"))
  );

  def isImageMerge(assert; jpath): (
    assert(type == "object"; "type == \"object\""; jpath) |
    assert(length == 4; "length == 4"; jpath) |
    assert(has("image"); "has(\"image\")"; jpath) |
    (.image | isSanitized(assert; jpath + ".image")) |
    assert(has("tag"); "has(\"tag\")"; jpath) |
    (.tag | isSanitized(assert; jpath + ".tag")) |
    assert(has("base"); "has(\"base\")"; jpath) |
    (.base | isSanitized(assert; jpath + ".base")) |
    assert(has("chain"); "has(\"chain\")"; jpath) |
    (.chain | isNonEmptyArray(isContext; assert; jpath + ".chain"))
  );

  def isImagePrune(assert; jpath): (
    assert(type == "object"; "type == \"object\""; jpath) |
    assert(length == 1; "length == 1"; jpath) |
    assert(has("pattern"); "has(\"pattern\")"; jpath) |
    (.pattern | isRegex(assert; jpath + ".pattern"))
  );

  def isImagePull(assert; jpath): (
    assert(type == "object"; "type == \"object\""; jpath) |
    assert(length == 4; "length == 4"; jpath) |
    assert(has("registry"); "has(\"registry\")"; jpath) |
    (.registry | isSanitized(assert; jpath + ".registry")) |
    assert(has("library"); "has(\"library\")"; jpath) |
    (.library | isSanitized(assert; jpath + ".library")) |
    assert(has("image"); "has(\"image\")"; jpath) |
    (.image | isSanitized(assert; jpath + ".image")) |
    assert(has("tag"); "has(\"tag\")"; jpath) |
    (.tag | isSanitized(assert; jpath + ".tag"))
  );

  def isImageRemove(assert; jpath): (
    assert(type == "object"; "type == \"object\""; jpath) |
    assert(length == 2; "length == 2"; jpath) |
    assert(has("image"); "has(\"image\")"; jpath) |
    (.image | isSanitized(assert; jpath + ".image")) |
    assert(has("tag"); "has(\"tag\")"; jpath) |
    (.tag | isSanitized(assert; jpath + ".tag"))
  );

  def isContainerResourceCopy(assert; jpath): (
    assert(type == "object"; "type == \"object\""; jpath) |
    assert(length == 3; "length == 3"; jpath) |
    assert(has("name"); "has(\"name\")"; jpath) |
    (.name | isSanitized(assert; jpath + ".name")) |
    assert(has("source"); "has(\"source\")"; jpath) |
    (.source | isSanitized(assert; jpath + ".source")) |
    assert(has("target"); "has(\"target\")"; jpath) |
    (.target | isSanitized(assert; jpath + ".target"))
  );

  def isContainerStatusGet(assert; jpath): (
    assert(type == "object"; "type == \"object\""; jpath) |
    assert(length == 1; "length == 1"; jpath) |
    assert(has("name"); "has(\"name\")"; jpath) |
    (.name | isSanitized(assert; jpath + ".name"))
  );

  def isContainerStatusCreated(assert; jpath): (
    assert(type == "object"; "type == \"object\""; jpath) |
    assert(length == 1; "length == 1"; jpath) |
    assert(has("name"); "has(\"name\")"; jpath) |
    (.name | isSanitized(assert; jpath + ".name"))
  );

  def isContainerStatusRunning(assert; jpath): (
    assert(type == "object"; "type == \"object\""; jpath) |
    assert(length == 1; "length == 1"; jpath) |
    assert(has("name"); "has(\"name\")"; jpath) |
    (.name | isSanitized(assert; jpath + ".name"))
  );

  def isContainerStatusHealthy(assert; jpath): (
    assert(type == "object"; "type == \"object\""; jpath) |
    assert(length == 1; "length == 1"; jpath) |
    assert(has("name"); "has(\"name\")"; jpath) |
    (.name | isSanitized(assert; jpath + ".name"))
  );

  def isVolume(assert; jpath): (
    assert(type == "object"; "type == \"object\""; jpath) |
    assert(length == 2; "length == 2"; jpath) |
    assert(has("source"); "has(\"source\")"; jpath) |
    (.source | isSanitized(assert; jpath + ".source")) |
    assert(has("target"); "has(\"target\")"; jpath) |
    (.target | isSanitized(assert; jpath + ".target"))
  );

  def isContainerCreate(assert; jpath): (
    assert(type == "object"; "type == \"object\""; jpath) |
    assert(length == 4; "length == 4"; jpath) |
    assert(has("name"); "has(\"name\")"; jpath) |
    (.name | isSanitized(assert; jpath + ".name")) |
    assert(has("image"); "has(\"image\")"; jpath) |
    (.image | isSanitized(assert; jpath + ".image")) |
    assert(has("hostname"); "has(\"hostname\")"; jpath) |
    (.hostname | isSanitized(assert; jpath + ".hostname")) |
    assert(has("volumes"); "has(\"volumes\")"; jpath) |
    (.volumes | isArray(isVolume; assert; jpath + ".volumes"))
  );

  def isContainerExec(assert; jpath): (
    assert(type == "object"; "type == \"object\""; jpath) |
    assert(length == 4; "length == 4"; jpath) |
    assert(has("name"); "has(\"name\")"; jpath) |
    (.name | isSanitized(assert; jpath + ".name")) |
    assert(has("detached"); "has(\"detached\")"; jpath) |
    (.detached | isSanitized(assert; jpath + ".detached")) |
    assert(has("user"); "has(\"user\")"; jpath) |
    (.user | isSanitized(assert; jpath + ".user")) |
    assert(has("command"); "has(\"command\")"; jpath) |
    (.command | isNonEmptyArray(isSanitized; assert; jpath + ".command"))
  );

  def isContainerStart(assert; jpath): (
    assert(type == "object"; "type == \"object\""; jpath) |
    assert(length == 1; "length == 1"; jpath) |
    assert(has("name"); "has(\"name\")"; jpath) |
    (.name | isSanitized(assert; jpath + ".name"))
  );

  def isContainerStop(assert; jpath): (
    assert(type == "object"; "type == \"object\""; jpath) |
    assert(length == 1; "length == 1"; jpath) |
    assert(has("name"); "has(\"name\")"; jpath) |
    (.name | isSanitized(assert; jpath + ".name"))
  );

  def isNetworkIpGet(assert; jpath): (
    assert(type == "object"; "type == \"object\""; jpath) |
    assert(length == 2; "length == 2"; jpath) |
    assert(has("container"); "has(\"container\")"; jpath) |
    (.container | isSanitized(assert; jpath + ".container")) |
    assert(has("network"); "has(\"network\")"; jpath) |
    (.network | isSanitized(assert; jpath + ".network"))
  );

  def isNetworkCreate(assert; jpath): (
    assert(type == "object"; "type == \"object\""; jpath) |
    assert(length == 2; "length == 2"; jpath) |
    assert(has("name"); "has(\"name\")"; jpath) |
    (.name | isSanitized(assert; jpath + ".name")) |
    assert(has("isolated"); "has(\"isolated\")"; jpath) |
    (.isolated | isSanitized(assert; jpath + ".isolated"))
  );

  def isNetworkCreated(assert; jpath): (
    assert(type == "object"; "type == \"object\""; jpath) |
    assert(length == 1; "length == 1"; jpath) |
    assert(has("name"); "has(\"name\")"; jpath) |
    (.name | isSanitized(assert; jpath + ".name"))
  );

  def isNetworkConnect(assert; jpath): (
    assert(type == "object"; "type == \"object\""; jpath) |
    assert(length == 2; "length == 2"; jpath) |
    assert(has("container"); "has(\"container\")"; jpath) |
    (.container | isSanitized(assert; jpath + ".container")) |
    assert(has("network"); "has(\"network\")"; jpath) |
    (.network | isSanitized(assert; jpath + ".network"))
  );

  def isNetworkDisconnect(assert; jpath): (
    assert(type == "object"; "type == \"object\""; jpath) |
    assert(length == 2; "length == 2"; jpath) |
    assert(has("container"); "has(\"container\")"; jpath) |
    (.container | isSanitized(assert; jpath + ".container")) |
    assert(has("network"); "has(\"network\")"; jpath) |
    (.network | isSanitized(assert; jpath + ".network"))
  );

  def isNetworkList(assert; jpath): (
    assert(type == "object"; "type == \"object\""; jpath) |
    assert(length == 1; "length == 1"; jpath) |
    assert(has("pattern"); "has(\"pattern\")"; jpath) |
    (.pattern | isRegex(assert; jpath + ".pattern"))
  );

  def isVolumeCreate(assert; jpath): (
    assert(type == "object"; "type == \"object\""; jpath) |
    assert(length == 1; "length == 1"; jpath) |
    assert(has("name"); "has(\"name\")"; jpath) |
    (.name | isSanitized(assert; jpath + ".name"))
  );

  def isVolumeCreated(assert; jpath): (
    assert(type == "object"; "type == \"object\""; jpath) |
    assert(length == 1; "length == 1"; jpath) |
    assert(has("name"); "has(\"name\")"; jpath) |
    (.name | isSanitized(assert; jpath + ".name"))
  );

  def isVolumeList(assert; jpath): (
    assert(type == "object"; "type == \"object\""; jpath) |
    assert(length == 1; "length == 1"; jpath) |
    assert(has("pattern"); "has(\"pattern\")"; jpath) |
    (.pattern | isRegex(assert; jpath + ".pattern"))
  );

  def isRoutineExec(assert; jpath): (
    assert(type == "object"; "type == \"object\""; jpath) |
    assert(length == 2; "length == 2"; jpath) |
    assert(has("imported"); "has(\"imported\")"; jpath) |
    assert(.imported | type == "string"; "type == \"string\""; jpath + ".imported") |
    assert(has("args"); "has(\"args\")"; jpath) |
    (.args | isArray(isSanitized; assert; jpath + ".args"))
  );

  def is_ImageBuilderPrune(assert; jpath): (
    assert(type == "object"; "type == \"object\""; jpath) |
    assert(length == 1; "length == 1"; jpath) |
    assert(has("image.builder.prune"); "has(\"image.builder.prune\")"; jpath) |
    (.["image.builder.prune"] | isImageBuilderPrune(assert; jpath + ".[\"image.builder.prune\"]"))
  );

  def is_ImageTagDefined(assert; jpath): (
    assert(type == "object"; "type == \"object\""; jpath) |
    assert(length == 1; "length == 1"; jpath) |
    assert(has("image.tag.defined"); "has(\"image.tag.defined\")"; jpath) |
    (.["image.tag.defined"] | isImageTagDefined(assert; jpath + ".[\"image.tag.defined\"]"))
  );

  def is_ImageTagCreate(assert; jpath): (
    assert(type == "object"; "type == \"object\""; jpath) |
    assert(length == 1; "length == 1"; jpath) |
    assert(has("image.tag.create"); "has(\"image.tag.create\")"; jpath) |
    (.["image.tag.create"] | isImageTagCreate(assert; jpath + ".[\"image.tag.create\"]"))
  );

  def is_ImageTagCompute(assert; jpath): (
    assert(type == "object"; "type == \"object\""; jpath) |
    assert(length == 1; "length == 1"; jpath) |
    assert(has("image.tag.compute"); "has(\"image.tag.compute\")"; jpath) |
    (.["image.tag.compute"] | isImageTagCompute(assert; jpath + ".[\"image.tag.compute\"]"))
  );

  def is_ImageBuild(assert; jpath): (
    assert(type == "object"; "type == \"object\""; jpath) |
    assert(length == 1; "length == 1"; jpath) |
    assert(has("image.build"); "has(\"image.build\")"; jpath) |
    (.["image.build"] | isImageBuild(assert; jpath + ".[\"image.build\"]"))
  );

  def is_ImageMerge(assert; jpath): (
    assert(type == "object"; "type == \"object\""; jpath) |
    assert(length == 1; "length == 1"; jpath) |
    assert(has("image.merge"); "has(\"image.merge\")"; jpath) |
    (.["image.merge"] | isImageMerge(assert; jpath + ".[\"image.merge\"]"))
  );

  def is_ImagePrune(assert; jpath): (
    assert(type == "object"; "type == \"object\""; jpath) |
    assert(length == 1; "length == 1"; jpath) |
    assert(has("image.prune"); "has(\"image.prune\")"; jpath) |
    (.["image.prune"] | isImagePrune(assert; jpath + ".[\"image.prune\"]"))
  );

  def is_ImagePull(assert; jpath): (
    assert(type == "object"; "type == \"object\""; jpath) |
    assert(length == 1; "length == 1"; jpath) |
    assert(has("image.pull"); "has(\"image.pull\")"; jpath) |
    (.["image.pull"] | isImagePull(assert; jpath + ".[\"image.pull\"]"))
  );

  def is_ImageRemove(assert; jpath): (
    assert(type == "object"; "type == \"object\""; jpath) |
    assert(length == 1; "length == 1"; jpath) |
    assert(has("image.remove"); "has(\"image.remove\")"; jpath) |
    (.["image.remove"] | isImageRemove(assert; jpath + ".[\"image.remove\"]"))
  );

  def is_ContainerResourceCopy(assert; jpath): (
    assert(type == "object"; "type == \"object\""; jpath) |
    assert(length == 1; "length == 1"; jpath) |
    assert(has("container.resource.copy"); "has(\"container.resource.copy\")"; jpath) |
    (.["container.resource.copy"] | isContainerResourceCopy(assert; jpath + ".[\"container.resource.copy\"]"))
  );

  def is_ContainerStatusGet(assert; jpath): (
    assert(type == "object"; "type == \"object\""; jpath) |
    assert(length == 1; "length == 1"; jpath) |
    assert(has("container.status.get"); "has(\"container.status.get\")"; jpath) |
    (.["container.status.get"] | isContainerStatusGet(assert; jpath + ".[\"container.status.get\"]"))
  );

  def is_ContainerStatusCreated(assert; jpath): (
    assert(type == "object"; "type == \"object\""; jpath) |
    assert(length == 1; "length == 1"; jpath) |
    assert(has("container.status.created"); "has(\"container.status.created\")"; jpath) |
    (.["container.status.created"] | isContainerStatusCreated(assert; jpath + ".[\"container.status.created\"]"))
  );

  def is_ContainerStatusRunning(assert; jpath): (
    assert(type == "object"; "type == \"object\""; jpath) |
    assert(length == 1; "length == 1"; jpath) |
    assert(has("container.status.running"); "has(\"container.status.running\")"; jpath) |
    (.["container.status.running"] | isContainerStatusRunning(assert; jpath + ".[\"container.status.running\"]"))
  );

  def is_ContainerStatusHealthy(assert; jpath): (
    assert(type == "object"; "type == \"object\""; jpath) |
    assert(length == 1; "length == 1"; jpath) |
    assert(has("container.status.healthy"); "has(\"container.status.healthy\")"; jpath) |
    (.["container.status.healthy"] | isContainerStatusHealthy(assert; jpath + ".[\"container.status.healthy\"]"))
  );

  def is_ContainerCreate(assert; jpath): (
    assert(type == "object"; "type == \"object\""; jpath) |
    assert(length == 1; "length == 1"; jpath) |
    assert(has("container.create"); "has(\"container.create\")"; jpath) |
    (.["container.create"] | isContainerCreate(assert; jpath + ".[\"container.create\"]"))
  );

  def is_ContainerExec(assert; jpath): (
    assert(type == "object"; "type == \"object\""; jpath) |
    assert(length == 1; "length == 1"; jpath) |
    assert(has("container.exec"); "has(\"container.exec\")"; jpath) |
    (.["container.exec"] | isContainerExec(assert; jpath + ".[\"container.exec\"]"))
  );

  def is_ContainerStart(assert; jpath): (
    assert(type == "object"; "type == \"object\""; jpath) |
    assert(length == 1; "length == 1"; jpath) |
    assert(has("container.start"); "has(\"container.start\")"; jpath) |
    (.["container.start"] | isContainerStart(assert; jpath + ".[\"container.start\"]"))
  );

  def is_ContainerStop(assert; jpath): (
    assert(type == "object"; "type == \"object\""; jpath) |
    assert(length == 1; "length == 1"; jpath) |
    assert(has("container.stop"); "has(\"container.stop\")"; jpath) |
    (.["container.stop"] | isContainerStop(assert; jpath + ".[\"container.stop\"]"))
  );

  def is_NetworkIpGet(assert; jpath): (
    assert(type == "object"; "type == \"object\""; jpath) |
    assert(length == 1; "length == 1"; jpath) |
    assert(has("network.ip.get"); "has(\"network.ip.get\")"; jpath) |
    (.["network.ip.get"] | isNetworkIpGet(assert; jpath + ".[\"network.ip.get\"]"))
  );

  def is_NetworkCreate(assert; jpath): (
    assert(type == "object"; "type == \"object\""; jpath) |
    assert(length == 1; "length == 1"; jpath) |
    assert(has("network.create"); "has(\"network.create\")"; jpath) |
    (.["network.create"] | isNetworkCreate(assert; jpath + ".[\"network.create\"]"))
  );

  def is_NetworkCreated(assert; jpath): (
    assert(type == "object"; "type == \"object\""; jpath) |
    assert(length == 1; "length == 1"; jpath) |
    assert(has("network.created"); "has(\"network.created\")"; jpath) |
    (.["network.created"] | isNetworkCreated(assert; jpath + ".[\"network.created\"]"))
  );

  def is_NetworkConnect(assert; jpath): (
    assert(type == "object"; "type == \"object\""; jpath) |
    assert(length == 1; "length == 1"; jpath) |
    assert(has("network.connect"); "has(\"network.connect\")"; jpath) |
    (.["network.connect"] | isNetworkConnect(assert; jpath + ".[\"network.connect\"]"))
  );

  def is_NetworkDisconnect(assert; jpath): (
    assert(type == "object"; "type == \"object\""; jpath) |
    assert(length == 1; "length == 1"; jpath) |
    assert(has("network.disconnect"); "has(\"network.disconnect\")"; jpath) |
    (.["network.disconnect"] | isNetworkDisconnect(assert; jpath + ".[\"network.disconnect\"]"))
  );

  def is_NetworkList(assert; jpath): (
    assert(type == "object"; "type == \"object\""; jpath) |
    assert(length == 1; "length == 1"; jpath) |
    assert(has("network.list"); "has(\"network.list\")"; jpath) |
    (.["network.list"] | isNetworkList(assert; jpath + ".[\"network.list\"]"))
  );

  def is_VolumeCreate(assert; jpath): (
    assert(type == "object"; "type == \"object\""; jpath) |
    assert(length == 1; "length == 1"; jpath) |
    assert(has("volume.create"); "has(\"volume.create\")"; jpath) |
    (.["volume.create"] | isVolumeCreate(assert; jpath + ".[\"volume.create\"]"))
  );

  def is_VolumeCreated(assert; jpath): (
    assert(type == "object"; "type == \"object\""; jpath) |
    assert(length == 1; "length == 1"; jpath) |
    assert(has("volume.created"); "has(\"volume.created\")"; jpath) |
    (.["volume.created"] | isVolumeCreated(assert; jpath + ".[\"volume.created\"]"))
  );

  def is_VolumeList(assert; jpath): (
    assert(type == "object"; "type == \"object\""; jpath) |
    assert(length == 1; "length == 1"; jpath) |
    assert(has("volume.list"); "has(\"volume.list\")"; jpath) |
    (.["volume.list"] | isVolumeList(assert; jpath + ".[\"volume.list\"]"))
  );

  def is_RoutineExec(assert; jpath): (
    assert(type == "object"; "type == \"object\""; jpath) |
    assert(length == 1; "length == 1"; jpath) |
    assert(has("routine.exec"); "has(\"routine.exec\")"; jpath) |
    (.["routine.exec"] | isRoutineExec(assert; jpath + ".[\"routine.exec\"]"))
  );

  def is_Module(assert; jpath): (
    assert(is_ImageBuilderPrune(AND; jpath) or
      is_ImageTagDefined(AND; jpath) or
      is_ImageTagCreate(AND; jpath) or
      is_ImageTagCompute(AND; jpath) or
      is_ImageBuild(AND; jpath) or
      is_ImageMerge(AND; jpath) or
      is_ImagePrune(AND; jpath) or
      is_ImagePull(AND; jpath) or
      is_ImageRemove(AND; jpath) or
      is_ContainerResourceCopy(AND; jpath) or
      is_ContainerStatusGet(AND; jpath) or
      is_ContainerStatusCreated(AND; jpath) or
      is_ContainerStatusRunning(AND; jpath) or
      is_ContainerStatusHealthy(AND; jpath) or
      is_ContainerCreate(AND; jpath) or
      is_ContainerExec(AND; jpath) or
      is_ContainerStart(AND; jpath) or
      is_ContainerStop(AND; jpath) or
      is_NetworkIpGet(AND; jpath) or
      is_NetworkCreate(AND; jpath) or
      is_NetworkCreated(AND; jpath) or
      is_NetworkConnect(AND; jpath) or
      is_NetworkDisconnect(AND; jpath) or
      is_NetworkList(AND; jpath) or
      is_VolumeCreate(AND; jpath) or
      is_VolumeCreated(AND; jpath) or
      is_VolumeList(AND; jpath) or
      is_RoutineExec(AND; jpath); "is_ImageBuilderPrune(AND; jpath) or is_ImageTagDefined(AND; jpath) or is_ImageTagCreate(AND; jpath) or is_ImageTagCompute(AND; jpath) or is_ImageBuild(AND; jpath) or is_ImageMerge(AND; jpath) or is_ImagePrune(AND; jpath) or is_ImagePull(AND; jpath) or is_ImageRemove(AND; jpath) or is_ContainerResourceCopy(AND; jpath) or is_ContainerStatusGet(AND; jpath) or is_ContainerStatusCreated(AND; jpath) or is_ContainerStatusRunning(AND; jpath) or is_ContainerStatusHealthy(AND; jpath) or is_ContainerCreate(AND; jpath) or is_ContainerExec(AND; jpath) or is_ContainerStart(AND; jpath) or is_ContainerStop(AND; jpath) or is_NetworkIpGet(AND; jpath) or is_NetworkCreate(AND; jpath) or is_NetworkCreated(AND; jpath) or is_NetworkConnect(AND; jpath) or is_NetworkDisconnect(AND; jpath) or is_NetworkList(AND; jpath) or is_VolumeCreate(AND; jpath) or is_VolumeCreated(AND; jpath) or is_VolumeList(AND; jpath) or is_RoutineExec(AND; jpath)"; jpath)
  );

  def isArithmeticExpr(assert; jpath): (
    def isArithmeticOperand(assert; jpath): (
      assert(isInteger(AND; jpath) or
        isIdentifier(AND; jpath) or
        isDereferenced(AND; jpath) or
        isArithmeticExpr(AND; jpath); "isInteger(AND; jpath) or isIdentifier(AND; jpath) or isDereferenced(AND; jpath) or isArithmeticExpr(AND; jpath)"; jpath)
    );

    def isBinaryArithmeticExpr(assert; jpath): (
      assert(type == "object"; "type == \"object\""; jpath) |
      assert(length == 3; "length == 3"; jpath) |
      assert(has("left"); "has(\"left\")"; jpath) |
      (.left | isArithmeticOperand(assert; jpath + ".left")) |
      assert(has("operator"); "has(\"operator\")"; jpath) |
      (.operator | isBinaryArithmeticOperator(assert; jpath + ".operator")) |
      assert(has("right"); "has(\"right\")"; jpath) |
      (.right | isArithmeticOperand(assert; jpath + ".right"))
    );

    isBinaryArithmeticExpr(assert; jpath)
  );

  def isAssign(assert; jpath): (
    (type == "object") and
    (has("scope")) and
    (.scope | isScope) and
    (has("variables")) and
    (.variables | isNonEmptyArray(isSanitized)) and
    (
      (
        (length == 3) and
        (has("type")) and
        (.type | isType)
      ) or (
        (length == 2)
      )
    )
  );

  def isColor(assert; jpath): (
    (type == "object") and
    (length == 2) and
    (has("index")) and
    (.index | isInteger) and
    (has("variable")) and
    (.variable | isSanitized)
  );

  def isHarden(assert; jpath): (
    (type == "object") and
    (has("command")) and
    (.command | isSanitized) and
    (
      (
        (length == 2) and
        (has("as")) and
        (.as | isType)
      ) or (
        (length == 1)
      )
    )
  );

  def isJson(assert; jpath): (
    isNonEmptyArray(isSanitized)
  );

  def isMutable(assert; jpath): (
    isIdentifier or
    isArrayIdentifier or
    (. == "last")
  );

  def isMutate(assert; jpath): (
    (type == "object") and
    (length == 3) and
    (has("name")) and
    (.name | isMutable) and
    (has("value")) and
    (.value | isNonEmptyArray(isSanitized)) and
    (
      (
        (length == 3) and
        (has("type")) and
        (.type | isType)
      ) or (
        (length == 2)
      )
    )
  );

  def isOnOff(assert; jpath): (
    isNonEmptyArray(isOption)
  );

  def isParameters(assert; jpath): (
    isNonEmptyArray(isSanitized)
  );

  def isPrint(assert; jpath): (
    (type == "object") and
    (has("format")) and
    (.format | type == "string") and
    (has("args")) and
    (.args | isArray(isSanitized)) and
    (
      (
        (length == 3) and
        (has("variable")) and
        (.variable | isIdentifier)
      ) or (
        (length == 2)
      )
    )
  );

  def isReadonly(assert; jpath): (
    isNonEmptyArray(isSanitized)
  );

  def isReturn(assert; jpath): (
    isInteger
  );

  def isSkip(assert; jpath): (
    isSanitized
  );

  def is_ArithmeticExpr(assert; jpath): (
    (type == "object") and
    (length == 1) and
    (has("arithmetic")) and
    (.arithmetic | isArithmeticExpr)
  );

  def is_Assign(assert; jpath): (
    (type == "object") and
    (length == 1) and
    (has("assign")) and
    (.assign | isAssign)
  );

  def is_Capture(assert; jpath): (
    (type == "object") and
    (length == 1) and
    (has("capture")) and
    (.capture | type == "null")
  );

  def is_Restore(assert; jpath): (
    (type == "object") and
    (length == 1) and
    (has("restore")) and
    (.restore | type == "null")
  );

  def is_CaptureRestore(assert; jpath): (
    is_Capture or
    is_Restore
  );

  def is_Color(assert; jpath): (
    (type == "object") and
    (length == 1) and
    (has("color")) and
    (.color | isColor)
  );

  def is_Harden(assert; jpath): (
    (type == "object") and
    (length == 1) and
    (has("harden")) and
    (.harden | isHarden)
  );

  def is_Json(assert; jpath): (
    (type == "object") and
    (length == 1) and
    (has("json.encode")) and
    (.["json.encode"] | isJson)
  );

  def is_Mutate(assert; jpath): (
    (type == "object") and
    (length == 1) and
    (has("mutate")) and
    (.mutate | isMutate)
  );

  def is_On(assert; jpath): (
    (type == "object") and
    (length == 1) and
    (has("on")) and
    (.on | isOnOff)
  );

  def is_Off(assert; jpath): (
    (type == "object") and
    (length == 1) and
    (has("off")) and
    (.off | isOnOff)
  );

  def is_OnOff(assert; jpath): (
    is_On or
    is_Off
  );

  def is_Parameters(assert; jpath): (
    (type == "object") and
    (length == 1) and
    (has("parameters")) and
    (.parameters | isParameters)
  );

  def is_Print(assert; jpath): (
    (type == "object") and
    (length == 1) and
    (has("print")) and
    (.print | isPrint)
  );

  def is_Readonly(assert; jpath): (
    (type == "object") and
    (length == 1) and
    (has("readonly")) and
    (.readonly | isReadonly)
  );

  def is_Return(assert; jpath): (
    (type == "object") and
    (length == 1) and
    (has("return")) and
    (.return | isInteger)
  );

  def is_Skip(assert; jpath): (
    (type == "object") and
    (length == 1) and
    (has("skip")) and
    (.skip | isSanitized)
  );

  def isGroup(assert; jpath): (
    def isCall(assert; jpath): (
      (type == "object") and
      (has("command")) and
      (.command | isSanitized) and
      (has("args")) and
      (.args | isArray(isSanitized)) and
      (
        (
          (length == 3) and
          (has("pipe")) and
          (.pipe | isGroup)
        ) or (
          (length == 2)
        )
      )
    );

    def isSourceable(assert; jpath): (
      isPrint or
      isCall
    );

    def isSource(assert; jpath): (
      isNonEmptyArray(isSanitized) or
      isNonEmptyArray(isSourceable)
    );

    def is_Source(assert; jpath): (
      (type == "object") and
      (length == 1) and
      (has("source")) and
      (.source | isSource)
    );

    def is_Call(assert; jpath): (
      (type == "object") and
      (length == 1) and
      (has("call")) and
      (.call | isCall)
    );

    def isDefer(assert; jpath): (
      is_Module or
      is_Call
    );

    def is_Defer(assert; jpath): (
      (type == "object") and
      (length == 1) and
      (has("defer")) and
      (.defer | isDefer)
    );

    def isInternalCall(assert; jpath): (
      (type == "object") and
      (length == 3) and
      (has("command")) and
      (.command | isNoSpace) and
      (has("args")) and
      (.args | isArray(isSanitized)) and
      (
        (
          (length == 3) and
          (has("pipe")) and
          (.pipe | isGroup)
        ) or (
          (length == 2)
        )
      )
    );

    def is_InternalCall(assert; jpath): (
      (type == "object") and
      (length == 1) and
      (has("call")) and
      (.call | isInternalCall)
    );

    def isLogicalExpr(assert; jpath): (
      def isLogicalOperand(assert; jpath): (
        isLogicalExpr or
        isGroup
      );

      def isUnaryLogicalExpr(assert; jpath): (
        (type == "object") and
        (length == 2) and
        (has("operand")) and
        (.operand | isLogicalOperand) and
        (has("operator")) and
        (.operator | isBinaryLogicalOperator)
      );

      def isBinaryLogicalExpr(assert; jpath): (
        (type == "object") and
        (length == 3) and
        (has("left")) and
        (.left | isLogicalOperand) and
        (has("operator")) and
        (.operator | isBinaryLogicalOperator) and
        (has("right")) and
        (.right | isLogicalOperand)
      );

      isUnaryLogicalExpr or
      isBinaryLogicalExpr
    );

    def isIf(assert; jpath): (
      def isElse(assert; jpath): (
        isIf or
        isGroup
      );

      (type == "object") and
      (length == 3) and
      (has("if")) and
      (.if | isLogicalExpr) and
      (has("then")) and
      (.then | isGroup) and
      (has("else")) and
      (.else | isArray(isElse))
    );

    def isRange(assert; jpath): (
      (type == "object") and
      (length == 4) and
      (has("initial")) and
      (.initial | isArithmeticExpr) and
      (has("conditional")) and
      (.conditional | isArithmeticExpr) and
      (has("update")) and
      (.update | isArithmeticExpr) and
      (has("do")) and
      (.do | isGroup)
    );

    def isIterator(assert; jpath): (
      (type == "object") and
      (length == 3) and
      (has("for")) and
      (.for | isIdentifier) and
      (has("into")) and
      (.into | isDereferenced) and
      (has("do")) and
      (.do | isGroup)
    );

    def isConditional(assert; jpath): (
      (type == "object") and
      (length == 2) and
      (has("while")) and
      (.while | isLogicalExpr) and
      (has("do")) and
      (.do | isGroup)
    );

    def isLoop(assert; jpath): (
      isRange or
      isIterator or
      isConditional
    );

    def is_Loop(assert; jpath): (
      (type == "object") and
      (length == 1) and
      (has("loop")) and
      (.loop | isLoop)
    );

    def isSubshell(assert; jpath): (
      isGroup or
      isArithmeticExpr
    );

    def isRegister(assert; jpath): (
      (type == "object") and
      (length == 2) and
      (has("variable")) and
      (.variable | isMutable) and
      (has("subshell")) and
      (.subshell | isSubshell)
    );

    def is_Register(assert; jpath): (
      (type == "object") and
      (length == 1) and
      (has("register")) and
      (.register | isRegister)
    );

    def isCommand(assert; jpath): (
      def isCoproc(assert; jpath): (
        (type == "object") and
        (length == 2) and
        (has("name")) and
        (.name | isIdentifier) and
        (has("commands")) and
        (.commands | isNonEmptyArray(isCommand))
      );

      def is_Coproc(assert; jpath): (
        (type == "object") and
        (length == 1) and
        (has("coproc")) and
        (.coproc | isCoproc)
      );

      def isInternal(assert; jpath): (
        is_InternalCall or
        is_Coproc
      );

      def is_Internal(assert; jpath): (
        (type == "object") and
        (length == 1) and
        (has("internal")) and
        (.internal | isInternal)
      );

      def isBranch(assert; jpath): (
        (type == "object") and
        (length == 2) and
        (has("pattern")) and
        (.pattern | isRegex) and
        (has("commands")) and
        (.commands | isNonEmptyArray(isCommand))
      );

      def isSwitch(assert; jpath): (
        (type == "object") and
        (length == 2) and
        (has("evaluate")) and
        (.evaluate | isSanitized) and
        (has("branches")) and
        (.branches | isNonEmptyArray(isBranch))
      );

      def is_Switch(assert; jpath): (
        (type == "object") and
        (length == 1) and
        (has("switch")) and
        (.switch | isSwitch)
      );

      def isDefine(assert; jpath): (
        (type == "object") and
        (length == 2) and
        (has("name")) and
        (.name | isIdentifier) and
        (has("body")) and
        (.body | isGroup)
      );

      def is_Define(assert; jpath): (
        (type == "object") and
        (length == 1) and
        (has("define")) and
        (.define | isDefine)
      );

      is_ArithmeticExpr or
      is_Assign or
      is_CaptureRestore or
      is_Color or
      is_Defer or
      is_Define or
      isGroup or
      is_Harden or
      isIf or
      is_Internal or
      is_Json or
      is_Loop or
      is_Mutate or
      is_OnOff or
      is_Parameters or
      is_Print or
      is_Readonly or
      is_Register or
      is_Return or
      is_Skip or
      is_Source or
      is_Switch or
      is_Call or
      is_Module
    );

    assert(type == "object"; "type == \"object\""; jpath) |
    assert(length == 2; "length == 2"; jpath) |
    assert(has("redirections"); "has(\"redirections\")"; jpath) |
    assert(has("commands"); "has("commands")"; jpath) |
    (.redirections | isArray(isRedirection; assert; jpath + ".redirections")) and
    (.commands | isNonEmptyArray(isCommand; assert; jpath + ".commands"))
  );

  ASSERT(type == "object"; "type == \"object\""; ".") |
  ASSERT(length == 1; "length == 1"; ".") |
  ASSERT(has("routine"); "has(\"routine\")"; ".") |
  (.routine | isGroup(ASSERT; ".routine"))
);
