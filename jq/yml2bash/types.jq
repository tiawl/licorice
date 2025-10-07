#! /usr/bin/env --split-string gojq --from-file

def isFromEnum(fields): (
  . as $input |
  (fields | type == "array") and
  (fields | length > 0) and
  (fields | map(type == "string") | all) and
  ($input | type == "string") and
  (fields | contains([$input]))
);

def isArray(function): (
  (type == "array") and
  (function | type == "boolean") and
  (map(function) | all)
);

def isNonEmptyArray(function): (
  (isArray(function)) and
  (length > 0)
);

def isIdentifier: (
  (type == "string") and
  test("^[a-zA-Z_][a-zA-Z0-9_]*$")
);

def isChar: (
  (type == "string") and
  (length == 1)
);

def isInteger: (
  (type == "number") and
  (. == floor)
);

def isParameter: (
  isInteger and
  (. >= 0)
);

def isFileDescriptor: (
  isInteger and
  (. > 0)
);

def isSpecialString: (
  isFromEnum([
    "last",
    "FUNCNAME",
    "USER",
    "UID",
    "HOME",
    "ROUTINE"
  ])
);

def isSpecialArray: (
  isFromEnum([
    "sep"
  ])
);

def isBinaryArithmeticOperator: (
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
  ])
);

def isScope: (
  isFromEnum([
    "Local",
    "Global"
  ])
);

def isType: (
  isFromEnum([
    "String",
    "Associative",
    "Indexed",
    "Reference"
  ])
);

def isUnaryLogicalOperator: (
  isFromEnum([
    "Not"
  ])
);

def isBinaryLogicalOperator: (
  isFromEnum([
    "And",
    "Or"
  ])
);

def isOption: (
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
  ])
);

def isInternalLiteral: (
  (type == "string")
);

def isKey: (
  (type == "string")
);

def isLiteral: (
  (type == "string")
);

def isPath: (
  (type == "string")
);

def isReference: (
  isInteger or
  isKey
);

def isArrayElement: (
  (type == "object") and
  (length == 2) and
  has("name") and
  (.name | isIdentifier) and
  has("reference") and
  (.reference | isReference)
);

def isSpecialArrayElement: (
  (type == "object") and
  (length == 2) and
  has("name") and
  (.name | isSpecialArray) and
  has("reference") and
  (.reference | isReference)
);

def isSanitized: (
  isLiteral or
  isChar or
  isIdentifier or
  isArrayElement or
  isParameter or
  isSpecialString or
  isSpecialArrayElement or
  isPath or
  isInternalLiteral
);

def isInput: (
  isSanitized
);

def isFile: (
  isPath or
  isFileDescriptor or
  isIdentifier or
  isArrayElement
);

def isOutput: (
  (type == "object") and
  (length == 3) and
  has("left") and
  (.left | isFileDescriptor) and
  has("appending") and
  (.appending | type == "boolean") and
  has("right") and
  (.right | isFile)
);

def isRedirection: (
  isInput or
  isOutput
);

def isImageBuilderPrune: (
  (type == "object") and
  (length == 0)
);

def isImageTagDefined: (
  (type == "object") and
  (length == 2) and
  has("image") and
  (.image | isSanitized) and
  has("tag") and
  (.tag | isSanitized)
);

def isImage: (
  (type == "object") and
  (length == 2) and
  has("image") and
  (.image | isSanitized) and
  has("tag") and
  (.tag | isSanitized)
);

def isImageTagCreate: (
  (type == "object") and
  (length == 2) and
  has("from") and
  (.from | isImage) and
  has("to") and
  (.to | isImage)
);

def isBuildArg: (
  (type == "object") and
  (length == 2) and
  has("name") and
  (.name | isIdentifier) and
  has("value") and
  (.value | isSanitized)
);

def isContext: (
  (type == "object") and
  (length == 2) and
  has("path") and
  (.path | isSanitized) and
  has("args") and
  (.args | isArray(isBuildArg))
);

def isImageTagCompute: (
  (type == "object") and
  (length == 1) and
  has("input") and
  (.input | isNonEmptyArray(isContext))
);

def isImageBuild: (
  (type == "object") and
  (length == 3) and
  has("image") and
  (.image | isSanitized) and
  has("tag") and
  (.tag | isSanitized) and
  has("context") and
  (.context | isContext)
);

def isImageMerge: (
  (type == "object") and
  (length == 4) and
  has("image") and
  (.image | isSanitized) and
  has("tag") and
  (.tag | isSanitized) and
  has("base") and
  (.base | isSanitized) and
  has("chain") and
  (.chain | isNonEmptyArray(isContext))
);

def isImagePrune: (
  (type == "object") and
  (length == 1) and
  has("pattern") and
  (.pattern | isSanitized)
);

def isImagePull: (
  (type == "object") and
  (length == 4) and
  has("registry") and
  (.registry | isSanitized) and
  has("library") and
  (.library | isSanitized) and
  has("image") and
  (.image | isSanitized) and
  has("tag") and
  (.tag | isSanitized)
);

def isImageRemove: (
  (type == "object") and
  (length == 2) and
  has("image") and
  (.image | isSanitized) and
  has("tag") and
  (.tag | isSanitized)
);

def isContainerResourceCopy: (
  (type == "object") and
  (length == 3) and
  has("name") and
  (.name | isSanitized) and
  has("source") and
  (.source | isSanitized) and
  has("target") and
  (.target | isSanitized)
);

def isContainerStatusGet: (
  (type == "object") and
  (length == 1) and
  has("name") and
  (.name | isSanitized)
);

def isContainerStatusCreated: (
  (type == "object") and
  (length == 1) and
  has("name") and
  (.name | isSanitized)
);

def isContainerStatusRunning: (
  (type == "object") and
  (length == 1) and
  has("name") and
  (.name | isSanitized)
);

def isContainerStatusHealthy: (
  (type == "object") and
  (length == 1) and
  has("name") and
  (.name | isSanitized)
);

def isVolume: (
  (type == "object") and
  (length == 2) and
  has("source") and
  (.source | isSanitized) and
  has("target") and
  (.target | isSanitized)
);

def isContainerCreate: (
  (type == "object") and
  (length == 4) and
  has("name") and
  (.name | isSanitized) and
  has("image") and
  (.image | isSanitized) and
  has("hostname") and
  (.hostname | isSanitized) and
  has("volumes") and
  (.volumes | isArray(isVolume))
);

def isContainerExec: (
  (type == "object") and
  (length == 4) and
  has("name") and
  (.name | isSanitized) and
  has("detached") and
  (.detached | isSanitized) and
  has("user") and
  (.user | isSanitized) and
  has("command") and
  (.command | isNonEmptyArray(isSanitized))
);

def isContainerStart: (
  (type == "object") and
  (length == 1) and
  has("name") and
  (.name | isSanitized)
);

def isContainerStop: (
  (type == "object") and
  (length == 1) and
  has("name") and
  (.name | isSanitized)
);

def isNetworkIpGet: (
  (type == "object") and
  (length == 2) and
  has("container") and
  (.container | isSanitized) and
  has("network") and
  (.network | isSanitized)
);

def isNetworkCreate: (
  (type == "object") and
  (length == 2) and
  has("name") and
  (.name | isSanitized) and
  has("isolated") and
  (.isolated | isSanitized)
);

def isNetworkCreated: (
  (type == "object") and
  (length == 1) and
  has("name") and
  (.name | isSanitized)
);

def isNetworkConnect: (
  (type == "object") and
  (length == 2) and
  has("container") and
  (.container | isSanitized) and
  has("network") and
  (.network | isSanitized)
);

def isNetworkDisconnect: (
  (type == "object") and
  (length == 2) and
  has("container") and
  (.container | isSanitized) and
  has("network") and
  (.network | isSanitized)
);

def isNetworkList: (
  (type == "object") and
  (length == 1) and
  has("pattern") and
  (.pattern | isSanitized)
);

def isVolumeCreate: (
  (type == "object") and
  (length == 1) and
  has("name") and
  (.name | isSanitized)
);

def isVolumeCreated: (
  (type == "object") and
  (length == 1) and
  has("name") and
  (.name | isSanitized)
);

def isVolumeList: (
  (type == "object") and
  (length == 1) and
  has("pattern") and
  (.pattern | isSanitized)
);

def isRoutineExec: (
  (type == "object") and
  (length == 2) and
  has("imported") and
  (.imported | type == "string") and
  has("args") and
  (.args | isArray(isSanitized))
);

def is_ImageBuilderPrune: (
  (type == "object") and
  (length == 1) and
  has("image.builder.prune") and
  (.image.builder.prune | isImageBuilderPrune)
);

def is_ImageTagDefined: (
  (type == "object") and
  (length == 1) and
  has("image.tag.defined") and
  (.image.tag.defined | isImageTagDefined)
);

def is_ImageTagCreate: (
  (type == "object") and
  (length == 1) and
  has("image.tag.create") and
  (.image.tag.create | isImageTagCreate)
);

def is_ImageTagCompute: (
  (type == "object") and
  (length == 1) and
  has("image.tag.compute") and
  (.image.tag.compute | isImageTagCompute)
);

def is_ImageBuild: (
  (type == "object") and
  (length == 1) and
  has("image.build") and
  (.image.build | isImageBuild)
);

def is_ImageMerge: (
  (type == "object") and
  (length == 1) and
  has("image.merge") and
  (.image.merge | isImageMerge)
);

def is_ImagePrune: (
  (type == "object") and
  (length == 1) and
  has("image.prune") and
  (.image.prune | isImagePrune)
);

def is_ImagePull: (
  (type == "object") and
  (length == 1) and
  has("image.pull") and
  (.image.pull | isImagePull)
);

def is_ImageRemove: (
  (type == "object") and
  (length == 1) and
  has("image.remove") and
  (.image.remove | isImageRemove)
);

def is_ContainerResourceCopy: (
  (type == "object") and
  (length == 1) and
  has("container.resource.copy") and
  (.container.resource.copy | isContainerResourceCopy)
);

def is_ContainerStatusGet: (
  (type == "object") and
  (length == 1) and
  has("container.status.get") and
  (.container.status.get | isContainerStatusGet)
);

def is_ContainerStatusCreated: (
  (type == "object") and
  (length == 1) and
  has("container.status.created") and
  (.container.status.created | isContainerStatusCreated)
);

def is_ContainerStatusRunning: (
  (type == "object") and
  (length == 1) and
  has("container.status.running") and
  (.container.status.running | isContainerStatusRunning)
);

def is_ContainerStatusHealthy: (
  (type == "object") and
  (length == 1) and
  has("container.status.healthy") and
  (.container.status.healthy | isContainerStatusHealthy)
);

def is_ContainerCreate: (
  (type == "object") and
  (length == 1) and
  has("container.create") and
  (.container.create | isContainerCreate)
);

def is_ContainerExec: (
  (type == "object") and
  (length == 1) and
  has("container.exec") and
  (.container.exec | isContainerExec)
);

def is_ContainerStart: (
  (type == "object") and
  (length == 1) and
  has("container.start") and
  (.container.start | isContainerStart)
);

def is_ContainerStop: (
  (type == "object") and
  (length == 1) and
  has("container.stop") and
  (.container.stop | isContainerStop)
);

def is_NetworkIpGet: (
  (type == "object") and
  (length == 1) and
  has("network.ip.get") and
  (.network.ip.get | isNetworkIpGet)
);

def is_NetworkCreate: (
  (type == "object") and
  (length == 1) and
  has("network.create") and
  (.network.create | isNetworkCreate)
);

def is_NetworkCreated: (
  (type == "object") and
  (length == 1) and
  has("network.created") and
  (.network.created | isNetworkCreated)
);

def is_NetworkConnect: (
  (type == "object") and
  (length == 1) and
  has("network.connect") and
  (.network.connect | isNetworkConnect)
);

def is_NetworkDisconnect: (
  (type == "object") and
  (length == 1) and
  has("network.disconnect") and
  (.network.disconnect | isNetworkDisconnect)
);

def is_NetworkList: (
  (type == "object") and
  (length == 1) and
  has("network.list") and
  (.network.list | isNetworkList)
);

def is_VolumeCreate: (
  (type == "object") and
  (length == 1) and
  has("volume.create") and
  (.volume.create | isVolumeCreate)
);

def is_VolumeCreated: (
  (type == "object") and
  (length == 1) and
  has("volume.created") and
  (.volume.created | isVolumeCreated)
);

def is_VolumeList: (
  (type == "object") and
  (length == 1) and
  has("volume.list") and
  (.volume.list | isVolumeList)
);

def is_RoutineExec: (
  (type == "object") and
  (length == 1) and
  has("routine.exec") and
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

def isUnaryArithmeticExpr: (
  (type == "object") and
  (length == 0)
);

def isArithmeticExpr: (
  def isArithmeticOperand: (
    isInteger or
    isParameter or
    isIdentifier or
    isArrayElement or
    isArithmeticExpr
  );

  def isBinaryArithmeticExpr: (
    (type == "object") and
    (length == 3) and
    has("left") and
    (.left | isArithmeticOperand) and
    has("operator") and
    (.operator | isBinaryArithmeticOperator) and
    has("right") and
    (.right | isArithmeticOperand)
  );

  isUnaryArithmeticExpr or
  isBinaryArithmeticExpr
);

def isAssign: (
  (type == "object") and
  (length == 3) and
  has("scope") and
  (.scope | isScope) and
  has("type") and
  (.type | isType) and
  has("variables") and
  (.variables | isNonEmptyArray(isSanitized))
);

def isColor: (
  (type == "object") and
  (length == 2) and
  has("index") and
  (.index | isInteger) and
  has("variable") and
  (.variable | isSanitized)
);

def isHarden: (
  (type == "object") and
  (length == 2) and
  has("command") and
  (.command | isSanitized) and
  has("as") and
  (.as | isSanitized)
);

def isJson: (
  isNonEmptyArray(isSanitized)
);

def isSubArray: (
  (type == "object") and
  (length == 2) and
  has("offset") and
  (.offset | isInteger) and
  has("length") and
  (.length | isInteger)
);

def isIterable: (
  (type == "object") and
  (length == 2) and
  has("name") and
  (.name | isIdentifier) and
  has("sub") and
  (.sub | isSubArray)
);

def isMutable: (
  isIdentifier or
  isArrayElement or
  isSpecialString.last
);

def isMutate: (
  (type == "object") and
  (length == 2) and
  has("name") and
  (.name | isMutable) and
  has("variables") and
  (.variables | isNonEmptyArray(isSanitized))
);

def isSpecial: (
  isSpecialString or
  isSpecialArray
);

def isOnOff: (
  isNonEmptyArray(isOption)
);

def isParameters: (
  isNonEmptyArray(isSanitized)
);

def isPrint: (
  (type == "object") and
  (length == 3) and
  has("variable") and
  (.variable | isIdentifier) and
  has("format") and
  (.format | type == "string") and
  has("args") and
  (.args | isArray(isSanitized))
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
  has("arithmetic") and
  (.arithmetic | isArithmeticExpr)
);

def is_Assign: (
  (type == "object") and
  (length == 1) and
  has("assign") and
  (.assign | isAssign)
);

def is_Capture: (
  (type == "object") and
  (length == 1) and
  has("capture") and
  (.capture | type == "null")
);

def is_Restore: (
  (type == "object") and
  (length == 1) and
  has("restore") and
  (.restore | type == "null")
);

def is_CaptureRestore: (
  is_Capture or
  is_Restore
);

def is_Color: (
  (type == "object") and
  (length == 1) and
  has("color") and
  (.color | isColor)
);

def is_Harden: (
  (type == "object") and
  (length == 1) and
  has("harden") and
  (.harden | isHarden)
);

def is_Json: (
  (type == "object") and
  (length == 1) and
  has("json.encode") and
  (.json.encode | isJson)
);

def is_Mutate: (
  (type == "object") and
  (length == 1) and
  has("mutate") and
  (.mutate | isMutate)
);

def is_On: (
  (type == "object") and
  (length == 1) and
  has("on") and
  (.on | isOnOff)
);

def is_Off: (
  (type == "object") and
  (length == 1) and
  has("off") and
  (.off | isOnOff)
);

def is_OnOff: (
  is_On or
  is_Off
);

def is_Parameters: (
  (type == "object") and
  (length == 1) and
  has("parameters") and
  (.parameters | isParameters)
);

def is_Print: (
  (type == "object") and
  (length == 1) and
  has("print") and
  (.print | isPrint)
);

def is_Readonly: (
  (type == "object") and
  (length == 1) and
  has("readonly") and
  (.readonly | isReadonly)
);

def is_Return: (
  (type == "object") and
  (length == 1) and
  has("return") and
  (.return | isInteger)
);

def is_Skip: (
  (type == "object") and
  (length == 1) and
  has("skip") and
  (.skip | isSanitized)
);

def isGroup: (
  def isCall: (
    (type == "object") and
    (length == 3) and
    has("command") and
    (.command | isSanitized) and
    has("args") and
    (.args | isArray(isSanitized)) and
    has("pipe") and
    (.pipe | isGroup)
  );

  def isSource: (
    isSanitized or
    isPrint or
    isCall
  );

  def is_Source: (
    (type == "object") and
    (length == 1) and
    has("source") and
    (.source | isSource)
  );

  def is_Call: (
    (type == "object") and
    (length == 1) and
    has("call") and
    (.call | isCall)
  );

  def isDefer: (
    is_Module or
    is_Call
  );

  def is_Defer: (
    (type == "object") and
    (length == 1) and
    has("defer") and
    (.defer | isDefer)
  );

  def isInternalCall: (
    (type == "object") and
    (length == 3) and
    has("command") and
    (.command | type == "string") and
    has("args") and
    (.args | isArray(isSanitized)) and
    has("pipe") and
    (.pipe | isGroup)
  );

  def is_InternalCall: (
    (type == "object") and
    (length == 1) and
    has("call") and
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
      has("operand") and
      (.operand | isLogicalOperand) and
      has("operator") and
      (.operator | isBinaryLogicalOperator)
    );

    def isBinaryLogicalExpr: (
      (type == "object") and
      (length == 3) and
      has("left") and
      (.left | isLogicalOperand) and
      has("operator") and
      (.operator | isBinaryLogicalOperator) and
      has("right") and
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
    has("if") and
    (.if | isLogicalExpr) and
    has("then") and
    (.then | isGroup) and
    has("else") and
    (.else | isArray(isElse))
  );

  def isRange: (
    (type == "object") and
    (length == 4) and
    has("initial") and
    (.initial | isArithmeticExpr) and
    has("conditional") and
    (.conditional | isArithmeticExpr) and
    has("update") and
    (.update | isArithmeticExpr) and
    has("do") and
    (.do | isGroup)
  );

  def isIterator: (
    (type == "object") and
    (length == 3) and
    has("for") and
    (.for | isIdentifier) and
    has("into") and
    (.into | isIterable) and
    has("do") and
    (.do | isGroup)
  );

  def isConditional: (
    (type == "object") and
    (length == 2) and
    has("while") and
    (.while | isLogicalExpr) and
    has("do") and
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
    has("loop") and
    (.loop | isLoop)
  );

  def isSubshell: (
    isGroup or
    isArithmeticExpr
  );

  def isRegister: (
    (type == "object") and
    (length == 2) and
    has("variable") and
    (.variable | isMutable) and
    has("subshell") and
    (.subshell | isSubshell)
  );

  def is_Register: (
    (type == "object") and
    (length == 1) and
    has("register") and
    (.register | isRegister)
  );

  def isCommand: (
    def isCoproc: (
      (type == "object") and
      (length == 2) and
      has("name") and
      (.name | isIdentifier) and
      has("commands") and
      (.commands | isNonEmptyArray(isCommand))
    );

    def is_Coproc: (
      (type == "object") and
      (length == 1) and
      has("coproc") and
      (.coproc | isCoproc)
    );

    def isInternal: (
      is_InternalCall or
      is_Coproc
    );

    def is_Internal: (
      (type == "object") and
      (length == 1) and
      has("internal") and
      (.internal | isInternal)
    );

    def isBranch: (
      (type == "object") and
      (length == 2) and
      has("pattern") and
      (.pattern | isSanitized) and
      has("commands") and
      (.commands | isNonEmptyArray(isCommand))
    );

    def isSwitch: (
      (type == "object") and
      (length == 2) and
      has("evaluate") and
      (.evaluate | isSanitized) and
      has("branches") and
      (.branches | isNonEmptyArray(isBranch))
    );

    def is_Switch: (
      (type == "object") and
      (length == 1) and
      has("switch") and
      (.switch | isSwitch)
    );

    def isDefine: (
      (type == "object") and
      (length == 2) and
      has("name") and
      (.name | isIdentifier) and
      has("body") and
      (.body | isGroup)
    );

    def is_Define: (
      (type == "object") and
      (length == 1) and
      has("define") and
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

  (type == "object") and
  (length == 2) and
  has("redirections") and
  (.redirections | isArray(isRedirection)) and
  has("commands") and
  (.commands | isNonEmptyArray(isCommand))
);

def isRoutine: (
  (type == "object") and
  (length == 1) and
  has("routine") and
  (.routine | isGroup)
);
