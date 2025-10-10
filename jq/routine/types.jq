#! /usr/bin/env --split-string gojq --from-file

def isRoutine: (
  def isFromEnum(fields; jpath): (
    . as $input |
    if (fields | type != "array") then unreachable("(fields | type != \"array\") case into isFromEnum") end |
    if (fields | length > 0) then unreachable("(fields | length > 0) case into inFromEnum") end |
    if (fields | map(type == "string") | all) then unreachable("(fields | map(type == \"string\") | all) case into inFromEnum") end |
    if ($input | type == "string") then unreachable("($input | type == \"string\") case into inFromEnum") end |
    assert(fields | contains([$input]); "fields | contains([$input])"; jpath)
  );

  def isArray(function; jpath): (
    if (function | type != "boolean") then unreachable("isArray") end |
    assert(type == "array"; "type == \"array\""; jpath) |
    (to_entries | map(.value | function(jpath + "[" + (.key | tostring) + "]")) | all)
  );

  def isNonEmptyArray(function; jpath): (
    assert(length > 0; "length > 0"; jpath) |
    (isArray(function; jpath))
  );

  def isEmpty(jpath): (
    assert(type == "object"; "type == \"object\""; jpath) |
    assert(length == 0; "length == 0"; jpath)
  );

  def isIdentifier(jpath): (
    assert(type == "string"; "type == \"string\""; jpath) |
    assert(test("^[a-zA-Z_][a-zA-Z0-9_]*$"); "test(\"^[a-zA-Z_][a-zA-Z0-9_]*$\")"; jpath)
  );

  def isNoSpace(jpath): (
    assert(type == "string"; "type == \"string\""; jpath) |
    assert(test("^[^[:space:]]*$"); "test(\"^[^[:space:]]*$\")"; jpath)
  );

  def isChar(jpath): (
    isFromEnum([
      "asterisk",
      "tilde",
      "atsign",
      "newline"
    ]; jpath)
  );

  def isInteger(jpath): (
    assert(type == "number"; "type == \"number\""; jpath) |
    assert(. == floor; ". == floor"; jpath)
  );

  def isParameter(jpath): (
    assert(isInteger; "isInteger"; jpath) |
    assert(. >= 0; ". >= 0"; jpath)
  );

  def isFileDescriptor(jpath): (
    assert(isInteger; "isInteger"; jpath) |
    assert(. > 0; ". > 0"; jpath)
  );

  def isSpecial(jpath): (
    isFromEnum([
      "last",
      "FUNCNAME",
      "USER",
      "UID",
      "HOME",
      "ROUTINE",
      "at_parameters",
      "sep"
    ]; jpath)
  );

  def isBinaryArithmeticOperator(jpath): (
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
    ]; jpath)
  );

  def isScope(jpath): (
    isFromEnum([
      "Local",
      "Global"
    ]; jpath)
  );

  def isType(jpath): (
    isFromEnum([
      "String",
      "Associative",
      "Indexed",
      "Reference"
    ]; jpath)
  );

  def isUnaryLogicalOperator(jpath): (
    isFromEnum([
      "Not"
    ]; jpath)
  );

  def isBinaryLogicalOperator(jpath): (
    isFromEnum([
      "And",
      "Or"
    ]; jpath)
  );

  def isOption(jpath): (
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
    ]; jpath)
  );

  def isInternalLiteral(jpath): (
    assert(type == "string"; "type == \"string\""; jpath)
  );

  def isKey(jpath): (
    assert(type == "string"; "type == \"string\""; jpath)
  );

  def isLiteral(jpath): (
    assert(type == "string"; "type == \"string\""; jpath)
  );

  def isPath(jpath): (
    assert(type == "string"; "type == \"string\""; jpath)
  );

  def isRegex(jpath): (
    assert(type == "string"; "type == \"string\""; jpath)
  );

  def isDefaultStringExpansion(jpath): (
    assert(type == "object"; "type == \"object\""; jpath) |
    assert(length == 1; "length == 1"; jpath) |
    assert(has("default"); "has(\"default\")"; jpath) |
    assert(.default | type == "string"; "type == \"string\""; jpath + ".default")
  );

  def isAlternateStringExpansion(jpath): (
    assert(type == "object"; "type == \"object\""; jpath) |
    assert(length == 1; "length == 1"; jpath) |
    assert(has("alternate"); "has(\"alternate\")"; jpath) |
    assert(.alternate | type == "string"; "type == \"string\""; jpath + ".alternate")
  );

  def isPromptStringExpansion(jpath): (
    assert(type == "object"; "type == \"object\""; jpath) |
    assert(length == 1; "length == 1"; jpath) |
    assert(has("prompt"); "has(\"prompt\")"; jpath) |
    (.prompt | isEmpty(jpath + ".prompt"))
  );

  def isRemoveStringExpansion(jpath): (
    assert(type == "object"; "type == \"object\""; jpath) |
    assert(length == 3; "length == 3"; jpath) |
    assert(has("short"); "has(\"short\")"; jpath) |
    assert(.short | type == "boolean"; ".short | type == \"boolean\""; jpath) |
    assert(has("from_start"); "has(\"from_start\")"; jpath) |
    assert(.from_start | type == "boolean"; ".from_start | type == \"boolean\""; jpath) |
    assert(has("pattern"); "has(\"pattern\")"; jpath) |
    (.pattern | isRegex(jpath + ".pattern"))
  );

  def is_RemoveStringExpansion(jpath): (
    assert(type == "object"; "type == \"object\""; jpath) |
    assert(length == 1; "length == 1"; jpath) |
    assert(has("remove"); "has(\"remove\")"; jpath) |
    (.remove | isRemoveStringExpansion(jpath + ".remove"))
  );

  def isReplaceStringExpansion(jpath): (
    assert(type == "object"; "type == \"object\""; jpath) |
    assert(has("global"); "has(\"global\")"; jpath) |
    assert(.global | type == "boolean"; ".global | type == \"boolean\""; jpath) |
    assert(has("match"); "has(\"match\")"; jpath) |
    (.match | isRegex(jpath)) |
    if (length == 3) then (
      assert(has("with"); "has(\"with\")"; jpath) |
      assert(.with | type == "string"; ".with | type == \"string\""; jpath)
    ) end |
    assert(length == 2; "length == 2"; jpath)
  );

  def is_ReplaceStringExpansion: (
    (type == "object") and
    (length == 1) and
    (has("replace")) and
    (.replace | isReplaceStringExpansion)
  );

  def isStringExpansion: (
    isDefaultStringExpansion or
    isAlternateStringExpansion or
    isPromptStringExpansion or
    is_RemoveStringExpansion or
    is_ReplaceStringExpansion
  );

  def isArrayReference: (
    isInteger or
    isKey
  );

  def isArrayIdentifier: (
    (type == "object") and
    (length == 2) and
    (has("name")) and
    (.name | isIdentifier) and
    (has("reference")) and
    (.reference | isArrayReference)
  );

  def isArrayExpansion: (
    (type == "object") and
    (has("reference")) and
    (.reference | isArrayReference) and
    (has("offset")) and
    (.offset | isInteger) and
    (
      (
        (length == 3) and
        (has("length")) and
        (.length | isInteger)
      ) or (
        (length == 2)
      )
    )
  );

  def isDereferencedVariable: (
    (type == "object") and
    (has("name")) and
    (.name | isIdentifier) and
    (
      (
        (length == 3) and
        (has("array_expansion")) and
        (.array_expansion | isArrayExpansion) and
        (has("string_expansion")) and
        (.string_expansion | isStringExpansion)
      ) or (
        (length == 2) and
        (has("array_expansion")) and
        (.array_expansion | isArrayExpansion)
      ) or (
        (length == 2) and
        (has("string_expansion")) and
        (.string_expansion | isStringExpansion)
      ) or (
        (length == 1)
      )
    )
  );

  def isDereferencedSpecial: (
    (type == "object") and
    (has("special")) and
    (.special | isSpecial) and
    (
      (
        (length == 3) and
        (has("array_expansion")) and
        (.array_expansion | isArrayExpansion) and
        (has("string_expansion")) and
        (.string_expansion | isStringExpansion)
      ) or (
        (length == 2) and
        (has("array_expansion")) and
        (.array_expansion | isArrayExpansion)
      ) or (
        (length == 2) and
        (has("string_expansion")) and
        (.string_expansion | isStringExpansion)
      ) or (
        (length == 1)
      )
    )
  );

  def isDereferencedParameter: (
    (type == "object") and
    (has("parameter")) and
    (.parameter | isParameter) and
    (
      (
        (length == 2) and
        (has("expansion")) and
        (.expansion | isStringExpansion)
      ) or (
        (length == 1)
      )
    )
  );

  def isDereferenced: (
    isDereferencedVariable or
    isDereferencedSpecial or
    isDereferencedParameter
  );

  def isSanitized: (
    isLiteral or
    isChar or
    isDereferenced or
    isPath or
    isInternalLiteral
  );

  def isInput: (
    isSanitized
  );

  def isFile: (
    isPath or
    isFileDescriptor or
    isDereferenced
  );

  def isOutput: (
    (type == "object") and
    (length == 3) and
    (has("left")) and
    (.left | isFileDescriptor) and
    (has("appending")) and
    (.appending | type == "boolean") and
    (has("right")) and
    (.right | isFile)
  );

  def isRedirection: (
    isInput or
    isOutput
  );

  def isImageBuilderPrune: (
    isEmpty
  );

  def isImageTagDefined: (
    (type == "object") and
    (length == 2) and
    (has("image")) and
    (.image | isSanitized) and
    (has("tag")) and
    (.tag | isSanitized)
  );

  def isImage: (
    (type == "object") and
    (length == 2) and
    (has("image")) and
    (.image | isSanitized) and
    (has("tag")) and
    (.tag | isSanitized)
  );

  def isImageTagCreate: (
    (type == "object") and
    (length == 2) and
    (has("from")) and
    (.from | isImage) and
    (has("to")) and
    (.to | isImage)
  );

  def isBuildArg: (
    (type == "object") and
    (length == 2) and
    (has("name")) and
    (.name | isIdentifier) and
    (has("value")) and
    (.value | isSanitized)
  );

  def isContext: (
    (type == "object") and
    (length == 2) and
    (has("path")) and
    (.path | isSanitized) and
    (has("args")) and
    (.args | isArray(isBuildArg))
  );

  def isImageTagCompute: (
    (type == "object") and
    (length == 1) and
    (has("input")) and
    (.input | isNonEmptyArray(isContext))
  );

  def isImageBuild: (
    (type == "object") and
    (length == 3) and
    (has("image")) and
    (.image | isSanitized) and
    (has("tag")) and
    (.tag | isSanitized) and
    (has("context")) and
    (.context | isContext)
  );

  def isImageMerge: (
    (type == "object") and
    (length == 4) and
    (has("image")) and
    (.image | isSanitized) and
    (has("tag")) and
    (.tag | isSanitized) and
    (has("base")) and
    (.base | isSanitized) and
    (has("chain")) and
    (.chain | isNonEmptyArray(isContext))
  );

  def isImagePrune: (
    (type == "object") and
    (length == 1) and
    (has("pattern")) and
    (.pattern | isRegex)
  );

  def isImagePull: (
    (type == "object") and
    (length == 4) and
    (has("registry")) and
    (.registry | isSanitized) and
    (has("library")) and
    (.library | isSanitized) and
    (has("image")) and
    (.image | isSanitized) and
    (has("tag")) and
    (.tag | isSanitized)
  );

  def isImageRemove: (
    (type == "object") and
    (length == 2) and
    (has("image")) and
    (.image | isSanitized) and
    (has("tag")) and
    (.tag | isSanitized)
  );

  def isContainerResourceCopy: (
    (type == "object") and
    (length == 3) and
    (has("name")) and
    (.name | isSanitized) and
    (has("source")) and
    (.source | isSanitized) and
    (has("target")) and
    (.target | isSanitized)
  );

  def isContainerStatusGet: (
    (type == "object") and
    (length == 1) and
    (has("name")) and
    (.name | isSanitized)
  );

  def isContainerStatusCreated: (
    (type == "object") and
    (length == 1) and
    (has("name")) and
    (.name | isSanitized)
  );

  def isContainerStatusRunning: (
    (type == "object") and
    (length == 1) and
    (has("name")) and
    (.name | isSanitized)
  );

  def isContainerStatusHealthy: (
    (type == "object") and
    (length == 1) and
    (has("name")) and
    (.name | isSanitized)
  );

  def isVolume: (
    (type == "object") and
    (length == 2) and
    (has("source")) and
    (.source | isSanitized) and
    (has("target")) and
    (.target | isSanitized)
  );

  def isContainerCreate: (
    (type == "object") and
    (length == 4) and
    (has("name")) and
    (.name | isSanitized) and
    (has("image")) and
    (.image | isSanitized) and
    (has("hostname")) and
    (.hostname | isSanitized) and
    (has("volumes")) and
    (.volumes | isArray(isVolume))
  );

  def isContainerExec: (
    (type == "object") and
    (length == 4) and
    (has("name")) and
    (.name | isSanitized) and
    (has("detached")) and
    (.detached | isSanitized) and
    (has("user")) and
    (.user | isSanitized) and
    (has("command")) and
    (.command | isNonEmptyArray(isSanitized))
  );

  def isContainerStart: (
    (type == "object") and
    (length == 1) and
    (has("name")) and
    (.name | isSanitized)
  );

  def isContainerStop: (
    (type == "object") and
    (length == 1) and
    (has("name")) and
    (.name | isSanitized)
  );

  def isNetworkIpGet: (
    (type == "object") and
    (length == 2) and
    (has("container")) and
    (.container | isSanitized) and
    (has("network")) and
    (.network | isSanitized)
  );

  def isNetworkCreate: (
    (type == "object") and
    (length == 2) and
    (has("name")) and
    (.name | isSanitized) and
    (has("isolated")) and
    (.isolated | isSanitized)
  );

  def isNetworkCreated: (
    (type == "object") and
    (length == 1) and
    (has("name")) and
    (.name | isSanitized)
  );

  def isNetworkConnect: (
    (type == "object") and
    (length == 2) and
    (has("container")) and
    (.container | isSanitized) and
    (has("network")) and
    (.network | isSanitized)
  );

  def isNetworkDisconnect: (
    (type == "object") and
    (length == 2) and
    (has("container")) and
    (.container | isSanitized) and
    (has("network")) and
    (.network | isSanitized)
  );

  def isNetworkList: (
    (type == "object") and
    (length == 1) and
    (has("pattern")) and
    (.pattern | isRegex)
  );

  def isVolumeCreate: (
    (type == "object") and
    (length == 1) and
    (has("name")) and
    (.name | isSanitized)
  );

  def isVolumeCreated: (
    (type == "object") and
    (length == 1) and
    (has("name")) and
    (.name | isSanitized)
  );

  def isVolumeList: (
    (type == "object") and
    (length == 1) and
    (has("pattern")) and
    (.pattern | isRegex)
  );

  def isRoutineExec: (
    (type == "object") and
    (length == 2) and
    (has("imported")) and
    (.imported | type == "string") and
    (has("args")) and
    (.args | isArray(isSanitized))
  );

  def is_ImageBuilderPrune: (
    (type == "object") and
    (length == 1) and
    (has("image.builder.prune")) and
    (.image.builder.prune | isImageBuilderPrune)
  );

  def is_ImageTagDefined: (
    (type == "object") and
    (length == 1) and
    (has("image.tag.defined")) and
    (.image.tag.defined | isImageTagDefined)
  );

  def is_ImageTagCreate: (
    (type == "object") and
    (length == 1) and
    (has("image.tag.create")) and
    (.image.tag.create | isImageTagCreate)
  );

  def is_ImageTagCompute: (
    (type == "object") and
    (length == 1) and
    (has("image.tag.compute")) and
    (.image.tag.compute | isImageTagCompute)
  );

  def is_ImageBuild: (
    (type == "object") and
    (length == 1) and
    (has("image.build")) and
    (.image.build | isImageBuild)
  );

  def is_ImageMerge: (
    (type == "object") and
    (length == 1) and
    (has("image.merge")) and
    (.image.merge | isImageMerge)
  );

  def is_ImagePrune: (
    (type == "object") and
    (length == 1) and
    (has("image.prune")) and
    (.image.prune | isImagePrune)
  );

  def is_ImagePull: (
    (type == "object") and
    (length == 1) and
    (has("image.pull")) and
    (.image.pull | isImagePull)
  );

  def is_ImageRemove: (
    (type == "object") and
    (length == 1) and
    (has("image.remove")) and
    (.image.remove | isImageRemove)
  );

  def is_ContainerResourceCopy: (
    (type == "object") and
    (length == 1) and
    (has("container.resource.copy")) and
    (.container.resource.copy | isContainerResourceCopy)
  );

  def is_ContainerStatusGet: (
    (type == "object") and
    (length == 1) and
    (has("container.status.get")) and
    (.container.status.get | isContainerStatusGet)
  );

  def is_ContainerStatusCreated: (
    (type == "object") and
    (length == 1) and
    (has("container.status.created")) and
    (.container.status.created | isContainerStatusCreated)
  );

  def is_ContainerStatusRunning: (
    (type == "object") and
    (length == 1) and
    (has("container.status.running")) and
    (.container.status.running | isContainerStatusRunning)
  );

  def is_ContainerStatusHealthy: (
    (type == "object") and
    (length == 1) and
    (has("container.status.healthy")) and
    (.container.status.healthy | isContainerStatusHealthy)
  );

  def is_ContainerCreate: (
    (type == "object") and
    (length == 1) and
    (has("container.create")) and
    (.container.create | isContainerCreate)
  );

  def is_ContainerExec: (
    (type == "object") and
    (length == 1) and
    (has("container.exec")) and
    (.container.exec | isContainerExec)
  );

  def is_ContainerStart: (
    (type == "object") and
    (length == 1) and
    (has("container.start")) and
    (.container.start | isContainerStart)
  );

  def is_ContainerStop: (
    (type == "object") and
    (length == 1) and
    (has("container.stop")) and
    (.container.stop | isContainerStop)
  );

  def is_NetworkIpGet: (
    (type == "object") and
    (length == 1) and
    (has("network.ip.get")) and
    (.network.ip.get | isNetworkIpGet)
  );

  def is_NetworkCreate: (
    (type == "object") and
    (length == 1) and
    (has("network.create")) and
    (.network.create | isNetworkCreate)
  );

  def is_NetworkCreated: (
    (type == "object") and
    (length == 1) and
    (has("network.created")) and
    (.network.created | isNetworkCreated)
  );

  def is_NetworkConnect: (
    (type == "object") and
    (length == 1) and
    (has("network.connect")) and
    (.network.connect | isNetworkConnect)
  );

  def is_NetworkDisconnect: (
    (type == "object") and
    (length == 1) and
    (has("network.disconnect")) and
    (.network.disconnect | isNetworkDisconnect)
  );

  def is_NetworkList: (
    (type == "object") and
    (length == 1) and
    (has("network.list")) and
    (.network.list | isNetworkList)
  );

  def is_VolumeCreate: (
    (type == "object") and
    (length == 1) and
    (has("volume.create")) and
    (.volume.create | isVolumeCreate)
  );

  def is_VolumeCreated: (
    (type == "object") and
    (length == 1) and
    (has("volume.created")) and
    (.volume.created | isVolumeCreated)
  );

  def is_VolumeList: (
    (type == "object") and
    (length == 1) and
    (has("volume.list")) and
    (.volume.list | isVolumeList)
  );

  def is_RoutineExec: (
    (type == "object") and
    (length == 1) and
    (has("routine.exec")) and
    (.routine.exec | isRoutineExec)
  );

  def is_Module: (
    is_ImageBuilderPrune or
    is_ImageTagDefined or
    is_ImageTagCreate or
    is_ImageTagCompute or
    is_ImageBuild or
    is_ImageMerge or
    is_ImagePrune or
    is_ImagePull or
    is_ImageRemove or
    is_ContainerResourceCopy or
    is_ContainerStatusGet or
    is_ContainerStatusCreated or
    is_ContainerStatusRunning or
    is_ContainerStatusHealthy or
    is_ContainerCreate or
    is_ContainerExec or
    is_ContainerStart or
    is_ContainerStop or
    is_NetworkIpGet or
    is_NetworkCreate or
    is_NetworkCreated or
    is_NetworkConnect or
    is_NetworkDisconnect or
    is_NetworkList or
    is_VolumeCreate or
    is_VolumeCreated or
    is_VolumeList or
    is_RoutineExec
  );

  def isArithmeticExpr: (
    def isArithmeticOperand: (
      isInteger or
      isIdentifier or
      isDereferenced or
      isArithmeticExpr
    );

    def isBinaryArithmeticExpr: (
      (type == "object") and
      (length == 3) and
      (has("left")) and
      (.left | isArithmeticOperand) and
      (has("operator")) and
      (.operator | isBinaryArithmeticOperator) and
      (has("right")) and
      (.right | isArithmeticOperand)
    );

    isBinaryArithmeticExpr
  );

  def isAssign: (
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

  def isColor: (
    (type == "object") and
    (length == 2) and
    (has("index")) and
    (.index | isInteger) and
    (has("variable")) and
    (.variable | isSanitized)
  );

  def isHarden: (
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

  def isJson: (
    isNonEmptyArray(isSanitized)
  );

  def isMutable: (
    isIdentifier or
    isArrayIdentifier or
    (. == "last")
  );

  def isMutate: (
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

  def isOnOff: (
    isNonEmptyArray(isOption)
  );

  def isParameters: (
    isNonEmptyArray(isSanitized)
  );

  def isPrint: (
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

  def isReadonly: (
    isNonEmptyArray(isSanitized)
  );

  def isReturn: (
    isInteger
  );

  def isSkip: (
    isSanitized
  );

  def is_ArithmeticExpr: (
    (type == "object") and
    (length == 1) and
    (has("arithmetic")) and
    (.arithmetic | isArithmeticExpr)
  );

  def is_Assign: (
    (type == "object") and
    (length == 1) and
    (has("assign")) and
    (.assign | isAssign)
  );

  def is_Capture: (
    (type == "object") and
    (length == 1) and
    (has("capture")) and
    (.capture | type == "null")
  );

  def is_Restore: (
    (type == "object") and
    (length == 1) and
    (has("restore")) and
    (.restore | type == "null")
  );

  def is_CaptureRestore: (
    is_Capture or
    is_Restore
  );

  def is_Color: (
    (type == "object") and
    (length == 1) and
    (has("color")) and
    (.color | isColor)
  );

  def is_Harden: (
    (type == "object") and
    (length == 1) and
    (has("harden")) and
    (.harden | isHarden)
  );

  def is_Json: (
    (type == "object") and
    (length == 1) and
    (has("json.encode")) and
    (.json.encode | isJson)
  );

  def is_Mutate: (
    (type == "object") and
    (length == 1) and
    (has("mutate")) and
    (.mutate | isMutate)
  );

  def is_On: (
    (type == "object") and
    (length == 1) and
    (has("on")) and
    (.on | isOnOff)
  );

  def is_Off: (
    (type == "object") and
    (length == 1) and
    (has("off")) and
    (.off | isOnOff)
  );

  def is_OnOff: (
    is_On or
    is_Off
  );

  def is_Parameters: (
    (type == "object") and
    (length == 1) and
    (has("parameters")) and
    (.parameters | isParameters)
  );

  def is_Print: (
    (type == "object") and
    (length == 1) and
    (has("print")) and
    (.print | isPrint)
  );

  def is_Readonly: (
    (type == "object") and
    (length == 1) and
    (has("readonly")) and
    (.readonly | isReadonly)
  );

  def is_Return: (
    (type == "object") and
    (length == 1) and
    (has("return")) and
    (.return | isInteger)
  );

  def is_Skip: (
    (type == "object") and
    (length == 1) and
    (has("skip")) and
    (.skip | isSanitized)
  );

  def isGroup(jpath): (
    def isCall: (
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

    def isSourceable: (
      isPrint or
      isCall
    );

    def isSource: (
      isNonEmptyArray(isSanitized) or
      isNonEmptyArray(isSourceable)
    );

    def is_Source: (
      (type == "object") and
      (length == 1) and
      (has("source")) and
      (.source | isSource)
    );

    def is_Call: (
      (type == "object") and
      (length == 1) and
      (has("call")) and
      (.call | isCall)
    );

    def isDefer: (
      is_Module or
      is_Call
    );

    def is_Defer: (
      (type == "object") and
      (length == 1) and
      (has("defer")) and
      (.defer | isDefer)
    );

    def isInternalCall: (
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

    def is_InternalCall: (
      (type == "object") and
      (length == 1) and
      (has("call")) and
      (.call | isInternalCall)
    );

    def isLogicalExpr: (
      def isLogicalOperand: (
        isLogicalExpr or
        isGroup
      );

      def isUnaryLogicalExpr: (
        (type == "object") and
        (length == 2) and
        (has("operand")) and
        (.operand | isLogicalOperand) and
        (has("operator")) and
        (.operator | isBinaryLogicalOperator)
      );

      def isBinaryLogicalExpr: (
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

    def isIf: (
      def isElse: (
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

    def isRange: (
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

    def isIterator: (
      (type == "object") and
      (length == 3) and
      (has("for")) and
      (.for | isIdentifier) and
      (has("into")) and
      (.into | isDereferenced) and
      (has("do")) and
      (.do | isGroup)
    );

    def isConditional: (
      (type == "object") and
      (length == 2) and
      (has("while")) and
      (.while | isLogicalExpr) and
      (has("do")) and
      (.do | isGroup)
    );

    def isLoop: (
      isRange or
      isIterator or
      isConditional
    );

    def is_Loop: (
      (type == "object") and
      (length == 1) and
      (has("loop")) and
      (.loop | isLoop)
    );

    def isSubshell: (
      isGroup or
      isArithmeticExpr
    );

    def isRegister: (
      (type == "object") and
      (length == 2) and
      (has("variable")) and
      (.variable | isMutable) and
      (has("subshell")) and
      (.subshell | isSubshell)
    );

    def is_Register: (
      (type == "object") and
      (length == 1) and
      (has("register")) and
      (.register | isRegister)
    );

    def isCommand: (
      def isCoproc: (
        (type == "object") and
        (length == 2) and
        (has("name")) and
        (.name | isIdentifier) and
        (has("commands")) and
        (.commands | isNonEmptyArray(isCommand))
      );

      def is_Coproc: (
        (type == "object") and
        (length == 1) and
        (has("coproc")) and
        (.coproc | isCoproc)
      );

      def isInternal: (
        is_InternalCall or
        is_Coproc
      );

      def is_Internal: (
        (type == "object") and
        (length == 1) and
        (has("internal")) and
        (.internal | isInternal)
      );

      def isBranch: (
        (type == "object") and
        (length == 2) and
        (has("pattern")) and
        (.pattern | isRegex) and
        (has("commands")) and
        (.commands | isNonEmptyArray(isCommand))
      );

      def isSwitch: (
        (type == "object") and
        (length == 2) and
        (has("evaluate")) and
        (.evaluate | isSanitized) and
        (has("branches")) and
        (.branches | isNonEmptyArray(isBranch))
      );

      def is_Switch: (
        (type == "object") and
        (length == 1) and
        (has("switch")) and
        (.switch | isSwitch)
      );

      def isDefine: (
        (type == "object") and
        (length == 2) and
        (has("name")) and
        (.name | isIdentifier) and
        (has("body")) and
        (.body | isGroup)
      );

      def is_Define: (
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
    (.redirections | isArray(isRedirection; jpath + ".redirections")) and
    (.commands | isNonEmptyArray(isCommand; jpath + ".commands"))
  );

  assert(type == "object"; "type == \"object\""; ".") |
  assert(length == 1; "length == 1"; ".") |
  assert(has("routine"); "has(\"routine\")"; ".") |
  (.routine | isGroup(".routine"))
);
