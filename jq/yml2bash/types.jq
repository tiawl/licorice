#! /usr/bin/env --split-string gojq --from-file

def isFieldFromEnum(fields): (
  . as $input |
  (fields | type == "array") and
  (fields | length > 0) and
  (fields | map(type == "string") | all) and
  ($input | type == "string") and
  (fields | contains([$input]))
);

def isNonEmptyArray(function): (
  (type == "array") and
  (length > 0) and
  (function | type == "boolean") and
  (map(function) | all)
);

def isLiteral: (type == "string");

def isChar: (
  (type == "string") and
  (length == 1)
);

def isIdentifier: (
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
  (.name | isIdentifier) and
  (.reference | isReference)
);

def isParameter: (
  isInteger and
  (. >= 0)
);

def isSpecialString: (
  isFieldFromEnum([
    "last",
    "FUNCNAME",
    "USER",
    "UID",
    "HOME",
    "ROUTINE"
  ])
);

def isSpecialArray: (
  isFieldFromEnum([
    "sep"
  ])
);

def isSpecialArrayElement: (
  (type == "object") and
  has("name") and
  has("reference") and
  (length == 2) and
  (.name | isSpecialArray) and
  (.reference | isReference)
);

def isPath: (type == "string");
def isInternalLiteral: (type == "string");

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

def isArithmeticOperand: (
  isInteger or
  isParameter or
  isIdentifier or
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

def isAssign: (
  (type == "object") and
  has("scope") and
  has("type") and
  has("variables") and
  (length == 3) and
  (.scope | isScope) and
  (.type | isType) and
  (.variables | isNonEmptyArray(Sanitized))
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
  (.name | isIdentifier) and
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
  isIdentifier or
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
  (.commands | isNonEmptyArray(Command))
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
#   input: NonEmptyArray(Context);
# };
# type Context = {
#   path: Sanitized;
#   args: BuildArg[];
# };
# type BuildArg = {
#   name: Identifier;
#   value: Sanitized;
# };
# type ImageBuild = {
#   image: Sanitized;
#   tag: Sanitized;
#   context: Context;
# };
# type ImageMerge = {
#   image: Sanitized;
#   tag: Sanitized;
#   base: Sanitized;
#   chain: NonEmptyArray(Context);
# };
# type ImagePrune = {
#   pattern: Sanitized;
# };
# type ImagePull = {
#   registry: Sanitized;
#   library: Sanitized;
#   image: Sanitized;
#   tag: Sanitized;
# };
# type ImageRemove = {
#   image: Sanitized;
#   tag: Sanitized;
# };
# type ContainerResourceCopy = {
#   name: Sanitized;
#   source: Sanitized;
#   target: Sanitized;
# };
# type ContainerStatusGet = {
#   name: Sanitized;
# };
# type ContainerStatusCreated = {
#   name: Sanitized;
# };
# type ContainerStatusRunning = {
#   name: Sanitized;
# };
# type ContainerStatusHealthy = {
#   name: Sanitized;
# };
# type ContainerCreate = {
#   name: Sanitized;
#   image: Sanitized;
#   hostname: Sanitized;
#   volumes: Volume[];
# };
# type Volume = {
#   source: Sanitized;
#   target: Sanitized;
# };
# type ContainerExec = {
#   name: Sanitized;
#   detached: Sanitized;
#   user: Sanitized;
#   command: NonEmptyArray(Sanitized);
# };
# type ContainerStart = {
#   name: Sanitized;
# };
# type ContainerStop = {
#   name: Sanitized;
# };
# type NetworkIpGet = {
#   container: Sanitized;
#   network: Sanitized;
# };
# type NetworkCreate = {
#   name: Sanitized;
#   isolated: Sanitized;
# };
# type NetworkCreated = {
#   name: Sanitized;
# };
# type NetworkConnect = {
#   container: Sanitized;
#   network: Sanitized;
# };
# type NetworkDisconnect = {
#   container: Sanitized;
#   network: Sanitized;
# };
# type NetworkList = {
#   pattern: Sanitized;
# };
# type VolumeCreate = {
#   name: Sanitized;
# };
# type VolumeCreated = {
#   name: Sanitized;
# };
# type VolumeList = {
#   pattern: Sanitized;
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
#   name: Identifier;
#   commands: NonEmptyArray(Command);
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
# type Json = NonEmptyArray(Sanitized);
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
#   for: Identifier;
#   into: Iterable;
#   do: Group;
# };
# type Iterable = {
#   name?: Identifier; // If null => "${@}"
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
#   variables: NonEmptyArray(Sanitized);
# };
# type Mutable = Identifier
#              | ArrayElement
#              | SpecialString.last
#              ;
# type Special = SpecialString
#              | SpecialArray
#              ;
# type OnOff = NonEmptyArray(Option);
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
# type Parameters = NonEmptyArray(Sanitized);
# type Print = {
#   variable?: Identifier;
#   format: string;
#   args: Sanitized[];
# };
# type Readonly = NonEmptyArray(Sanitized);
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
#   branches: NonEmptyArray(Branch);
# };
# type Branch = {
#   pattern: Sanitized;
#   commands: NonEmptyArray(Command);
# };
