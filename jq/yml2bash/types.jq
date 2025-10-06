#! /usr/bin/env --split-string gojq --from-file

def isFieldFromEnum(fields): (
  . as $input |
  (fields | type == "array") and
  (fields | length > 0) and
  (fields | map(type == "string") | all) and
  ($input | type == "string") and
  (fields | contains([$input]))
);

def isLiteral: (type == "string");

def isChar: (
  (type == "string") and
  (length == 1)
);

def isVariable: (
  (type == "string") and
  test("^[a-zA-Z_][a-zA-Z0-9_]*$")
);

def isInteger: (
  (type == "number") and
  (. == floor)
);

def isKey: (type == "string");

def isReference: (
  isInteger or
  isKey
);

def isArrayElement: (
  (type == "object") and
  has("name") and
  has("reference") and
  (length == 2) and
  (.name | isVariable) and
  (.reference | isReference)
);

def isParameter: (
  isInteger and
  (. >= 0)
);

def isSpecial: (
  isFieldFromEnum([
    "last",
    "FUNCNAME",
    "USER",
    "UID",
    "HOME",
    "RUNNER",
    "sep"
  ])
);

def isPath: (type == "string");
def isInternalLiteral: (type == "string");

def isSanitized: (
  isLiteral or
  isChar or
  isVariable or
  isArrayElement or
  isParameter or
  isSpecial or
  isPath or
  isInternalLiteral
);

def isArithmeticOperand: (
  isInteger or
  isParameter or
  isVariable or
  isArrayElement or
  isArithmeticExpr
);

def isBinaryArithmeticOperator: (
  isFieldFromEnum([
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

def isBinaryArithmeticExpr: (
  (type == "object") and
  has("left") and
  has("operator") and
  has("right") and
  (length == 3) and
  (.left | isArithmeticOperand) and
  (.operator | isBinaryArithmeticOperator) and
  (.right | isArithmeticOperand)
);

def isArithmeticExpr: (
  isBinaryArithmeticExpr
);

def is_ArithmeticExpr: (
  (type == "object") and
  has("arithmetic") and
  (length == 1) and
  (.arithmetic | isArithmeticExpr)
);

def isScope: (
  isFieldFromEnum([
    "Local",
    "Global"
  ])
);

def isType: (
  isFieldFromEnum([
    "String",
    "Associative",
    "Indexed",
    "Reference"
  ])
);

def isNotEmptySanitizedArray: (
  (type == "array") and
  (length > 0) and
  (map(isSanitized) | all)
);

def isAssign: (
  (type == "object") and
  has("scope") and
  has("type") and
  has("variables") and
  (length == 3) and
  (.scope | isScope) and
  (.type | isType) and
  (.variables | isNotEmptySanitizedArray)
);

def is_Assign: (
  (type == "object") and
  has("assign") and
  (length == 1) and
  (.assign | isAssign)
);

def is_Capture: (
  (type == "object") and
  has("capture") and
  (length == 1) and
  (.capture == "null")
);

def is_Restore: (
  (type == "object") and
  has("restore") and
  (length == 1) and
  (.restore == "null")
);

def is_CaptureRestore: (
  is_Capture or
  is_Restore
);

def isColor: (
  (type == "object") and
  has("index") and
  has("variable") and
  (length == 2) and
  (.index | isInteger) and
  (.variable | isSanitized)
);

def is_Color: (
  (type == "object") and
  has("color") and
  (length == 1) and
  (.color | isColor)
);

def is_Module: (
  # TODO
);

def is_Call: (
  # TODO
);

def is_Defer: (
  # TODO
);

def isDefine: (
  (type == "object") and
  has("name") and
  has("body") and
  (length == 2) and
  (.name | isVariable) and
  (.body | isGroup)
);

def is_Define: (
  (type == "object") and
  has("define") and
  (length == 1) and
  (.define | isDefine)
);

def is_Harden: (
  # TODO
);

def isIf: (
  # TODO
);

def is_Internal: (
  # TODO
);

def is_Json: (
  # TODO
);

def is_Loop: (
  # TODO
);

def is_Mutate: (
  # TODO
);

def is_OnOff: (
  # TODO
);

def is_Parameters: (
  # TODO
);

def is_Print: (
  # TODO
);

def is_Readonly: (
  # TODO
);

def is_Register: (
  # TODO
);

def is_Return: (
  # TODO
);

def is_Skip: (
  # TODO
);

def is_Source: (
  # TODO
);

def is_Switch: (
  # TODO
);

def isCommand: (
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

def isNotEmptyCommandArray: (
  (type == "array") and
  (length > 0) and
  (map(isCommand) | all)
);

def isInput: (
  isSanitized
);

def isFileDescriptor: (
  isInteger and
  (. > 0)
}

def isFile: (
  isPath or
  isFileDescriptor or
  isVariable or
  isArrayElement
}

def isOutput: (
  (type == "object") and
  has("left") and
  has("appending") and
  has("right") and
  (length == 3) and
  (.left | isFileDescriptor) and
  (.appending | type == "boolean") and
  (.right | isFile)
);

def isRedirection: (
  isInput or
  isOutput
);

def isRedirectionArray: (
  (type == "array") and
  (map(isRedirection) | all)
);

def isGroup: (
  (type == "object") and
  has("redirections") and
  has("commands") and
  (length == 2) and
  (.redirections | isRedirectionArray) and
  (.commands | isNotEmptyCommandArray)
);

def isRoutine: {
  (type == "object") and
  has("routine") and
  (length == 1) and
  (.routine | isGroup)
);

# type _Defer = {
#   defer: Defer;
# };
# type _Harden = {
#   harden: Harden;
# };
# type _Internal = {
#   internal: Internal;
# };
# type Internal = _InternalCall
#               | _Coproc
#               ;
# type _InternalCall = {
#   call: InternalCall;
# };
# type _Coproc = {
#   coproc: Coproc;
# };
# type _Json = {
#   json: Json;
# };
# type _Loop = {
#   loop: Loop;
# };
# type _Mutate = {
#   mutate: Mutate;
# };
# type _OnOff = _On
#             | _Off
#             ;
# type _On = {
#   on: OnOff;
# };
# type _Off = {
#   off: OnOff;
# };
# type _Parameters = {
#   parameters: Parameters;
# };
# type _Print = {
#   print: Print;
# };
# type _Readonly = {
#   readonly: Readonly;
# };
# type _Register = {
#   register: Register;
# };
# type _Return = {
#   return: Return;
# };
# type _Skip = {
#   skip: Skip;
# };
# type _Source = {
#   source: Source;
# };
# type _Switch = {
#   switch: Switch;
# };
# type _Call = {
#   call: Call;
# };
# type _Module = _ImageBuilderPrune
#              | _ImageTagDefined
#              | _ImageTagCreate
#              | _ImageTagCompute
#              | _ImageBuild
#              | _ImageMerge
#              | _ImagePrune
#              | _ImagePull
#              | _ImageRemove
#              | _ContainerResourceCopy
#              | _ContainerStatusGet
#              | _ContainerStatusCreated
#              | _ContainerStatusRunning
#              | _ContainerStatusHealthy
#              | _ContainerCreate
#              | _ContainerExec
#              | _ContainerStart
#              | _ContainerStop
#              | _NetworkIpGet
#              | _NetworkCreate
#              | _NetworkCreated
#              | _NetworkConnect
#              | _NetworkDisconnect
#              | _NetworkList
#              | _VolumeCreate
#              | _VolumeCreated
#              | _VolumeList
#              | _RoutineExec
#              ;
# type _ImageBuilderPrune = {
#   image.builder.prune: ImageBuilderPrune;
# };
# type _ImageTagDefined = {
#   image.tag.defined: ImageTagDefined;
# };
# type _ImageTagCreate = {
#   image.tag.create: ImageTagCreate;
# };
# type _ImageTagCompute = {
#   image.tag.compute: ImageTagCompute;
# };
# type _ImageBuild = {
#   image.build: ImageBuild;
# };
# type _ImageMerge = {
#   image.merge: ImageMerge;
# };
# type _ImagePrune = {
#   image.prune: ImagePrune;
# };
# type _ImagePull = {
#   image.pull: ImagePull;
# };
# type _ImageRemove = {
#   image.remove: ImageRemove;
# };
# type _ContainerResourceCopy = {
#   container.resource.copy: ContainerResourceCopy;
# };
# type _ContainerStatusGet = {
#   container.status.get: ContainerStatusGet;
# };
# type _ContainerStatusCreated = {
#   container.status.created: ContainerStatusCreated;
# };
# type _ContainerStatusRunning = {
#   container.status.running: ContainerStatusRunning;
# };
# type _ContainerStatusHealthy = {
#   container.status.healthy: ContainerStatusHealthy;
# };
# type _ContainerCreate = {
#   container.create: ContainerCreate;
# };
# type _ContainerExec = {
#   container.exec: ContainerExec;
# };
# type _ContainerStart = {
#   container.start: ContainerStart;
# };
# type _ContainerStop = {
#   container.stop: ContainerStop;
# };
# type _NetworkIpGet = {
#   network.ip.get: NetworkIpGet;
# };
# type _NetworkCreate = {
#   network.create: NetworkCreate;
# };
# type _NetworkCreated = {
#   network.created: NetworkCreated;
# };
# type _NetworkConnect = {
#   network.connect: NetworkConnect;
# };
# type _NetworkDisconnect = {
#   network.disconnect: NetworkDisconnect;
# };
# type _NetworkList = {
#   network.list: NetworkList;
# };
# type _VolumeCreate = {
#   volume.create: VolumeCreate;
# };
# type _VolumeCreated = {
#   volume.created: VolumeCreated;
# };
# type _VolumeList = {
#   volume.list: VolumeList;
# };
# type _RoutineExec = {
#   routine.exec: RoutineExec;
# };
# type Defer = _Module
#            | _Call
#            ;
# type ImageBuilderPrune = {};
# type ImageTagDefined = {
#   image: Sanitized;
#   tag: Sanitized;
# };
# type ImageTagCreate = {
#   from: Image;
#   to: Image;
# };
# type Image = {
#   image: Sanitized;
#   tag: Sanitized;
# };
# type ImageTagCompute = {
#   // TODO
# };
# type ImageBuild = {
#   // TODO
# };
# type ImageMerge = {
#   // TODO
# };
# type ImagePrune = {
#   // TODO
# };
# type ImagePull = {
#   // TODO
# };
# type ImageRemove = {
#   // TODO
# };
# type ContainerResourceCopy = {
#   // TODO
# };
# type ContainerStatusGet = {
#   // TODO
# };
# type ContainerStatusCreated = {
#   // TODO
# };
# type ContainerStatusRunning = {
#   // TODO
# };
# type ContainerStatusHealthy = {
#   // TODO
# };
# type ContainerCreate = {
#   // TODO
# };
# type ContainerExec = {
#   // TODO
# };
# type ContainerStart = {
#   // TODO
# };
# type ContainerStop = {
#   // TODO
# };
# type NetworkIpGet = {
#   // TODO
# };
# type NetworkCreate = {
#   // TODO
# };
# type NetworkCreated = {
#   // TODO
# };
# type NetworkConnect = {
#   // TODO
# };
# type NetworkDisconnect = {
#   // TODO
# };
# type NetworkList = {
#   // TODO
# };
# type VolumeCreate = {
#   // TODO
# };
# type VolumeCreated = {
#   // TODO
# };
# type VolumeList = {
#   // TODO
# };
# type RoutineExec = {
#   imported: Path;
#   args: Sanitized[];
# };
# type Call = {
#   command: Sanitized;
#   args: Sanitized[];
#   pipe?: Group;
# };
# type Harden = {
#   command: Sanitized;
#   as?: Sanitized;
# };
# type If = {
#   if: LogicalExpr;
#   then: Group;
#   else: Else[];
# };
# type Internal = InternalCall
#               | Coproc
#               ;
# type InternalCall = {
#   command: string;
#   args: Sanitized[];
#   pipe?: Group;
# };
# type Coproc = {
#   name: Variable;
#   commands: NotEmptyCommandArray;
# };
# type LogicalExpr = UnaryLogicalExpr
#                  | BinaryLogicalExpr
#                  ;
# type UnaryLogicalExpr = {
#   operand: LogicalOperand;
#   operator: BinaryLogicalOperator;
# };
# enum UnaryLogicalOperator {
#   Not,
# };
# type BinaryLogicalExpr = {
#   left: LogicalOperand;
#   operator: BinaryLogicalOperator;
#   right: LogicalOperand;
# };
# enum BinaryLogicalOperator {
#   And,
#   Or,
# };
# type LogicalOperand = LogicalExpr
#                     | Group
#                     ;
# type Else = If
#           | Group
#           ;
# type Json = NotEmptySanitizedArray;
# type Loop = Range
#           | Iterator
#           | Conditional
#           ;
# type Range = {
#   initial: ArithmeticExpr;
#   conditional: ArithmeticExpr;
#   update: ArithmeticExpr;
#   do: Group;
# };
# type Iterator = {
#   for: Variable;
#   into: Iterable;
#   do: Group;
# };
# type Iterable = {
#   name?: Variable; // If null => "${@}"
#   sub?: SubArray;
# };
# type SubArray = {
#   offset: Integer;
#   length?: Integer;
# };
# type Conditional = {
#   while: LogicalExpr;
#   do: Group;
# };
# type Mutate = {
#   name: Mutable;
#   variables: NotEmptySanitizedArray;
# };
# type Mutable = Variable
#              | ArrayElement
#              | Last
#              ;
# function Last(s: Special) void {
#   assert(s.valueOf() === Special.last.valueOf());
# }
# type OnOff = NotEmptyOptionArray;
# function NotEmptyOptionArray(a: Option[]) void {
#   assert(a.length > 0);
# }
# enum Option {
#   assoc_expand_once,
#   autocd,
#   cdable_vars,
#   cdspell,
#   checkhash,
#   checkjobs,
#   checkwinsize,
#   cmdhist,
#   compat31,
#   compat32,
#   compat40,
#   compat41,
#   compat42,
#   compat43,
#   compat44,
#   complete_fullquote,
#   direxpand,
#   dirspell,
#   dotglob,
#   execfail,
#   expand_aliases,
#   extdebug,
#   extglob,
#   extquote,
#   failglob,
#   force_fignore,
#   globasciiranges,
#   globstar,
#   gnu_errfmt,
#   histappend,
#   histreedit,
#   histverify,
#   hostcomplete,
#   huponexit,
#   inherit_errexit,
#   interactive_comments,
#   lastpipe,
#   lithist,
#   localvar_inherit,
#   localvar_unset,
#   login_shell,
#   mailwarn,
#   no_empty_cmd_completion,
#   nocaseglob,
#   nocasematch,
#   nullglob,
#   progcomp,
#   progcomp_alias,
#   promptvars,
#   restricted_shell,
#   shift_verbose,
#   sourcepath,
#   xpg_echo,
#   allexport,
#   braceexpand,
#   emacs,
#   errexit,
#   errtrace,
#   functrace,
#   hashall,
#   histexpand,
#   history,
#   ignoreeof,
#   keyword,
#   monitor,
#   noclobber,
#   noexec,
#   noglob,
#   nolog,
#   notify,
#   nounset,
#   onecmd,
#   physical,
#   pipefail,
#   posix,
#   privileged,
#   verbose,
#   vi,
#   xtrace
# };
# type Parameters = NotEmptySanitizedArray;
# type Print = {
#   variable?: Variable;
#   format: string;
#   args: Sanitized[];
# };
# type Readonly = NotEmptySanitizedArray;
# type Register = {
#   variable: Mutable;
#   subshell: Subshell;
# };
# type Subshell = Group
#               | ArithmeticExpr
#               ;
# type Return = Integer;
# type Skip = Sanitized;
# type Source = Sanitized
#             | Print
#             | Call
#             ;
# type Switch = {
#   evaluate: Sanitized;
#   branches: NotEmptyBranchArray;
# };
# function NotEmptyBranchArray(a: Branch[]) void {
#   assert(a.length > 0);
# }
# type Branch = {
#   pattern: Sanitized;
#   commands: NotEmptyCommandArray;
# };
