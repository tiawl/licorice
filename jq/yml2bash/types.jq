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

def isCaptureRestore: (
  isFieldFromEnum([
    "Capture",
    "Restore"
  ])
);

def isColor: (
  (type == "object") and
  has("index") and
  has("variable") and
  (length == 2) and
  (.index | isInteger) and
  (.variable | isSanitized)
);

def isImage: (
  # TODO
);

def isContainer: (
  # TODO
);

def isNetwork: (
  # TODO
);

def isVolume: (
  # TODO
);

def isRunner: (
  # TODO
);

def isCore: (
  isImage or
  isContainer or
  isNetwork or
  isVolume or
  isRunner
);

def isCall: (
  # TODO
);

def isDefer: (
  isCore or
  isCall
);

def isDefine: (
  # TODO
);

def isGroup: (
  # TODO
);

def isHarden: (
  # TODO
);

def isIf: (
  # TODO
);

def isInternal: (
  # TODO
);

def isJson: (
  # TODO
);

def isLoop: (
  # TODO
);

def isMutate: (
  # TODO
);

def isOnOff: (
  # TODO
);

def isParameters: (
  # TODO
);

def isPrint: (
  # TODO
);

def isReadonly: (
  # TODO
);

def isRegister: (
  # TODO
);

def isReturn: (
  # TODO
);

def isRunner: (
  # TODO
);

def isSkip: (
  # TODO
);

def isSource: (
  # TODO
);

def isSplit: (
  # TODO
);

def isSwitch: (
  # TODO
);

def isCommand: (
  isArithmeticExpr or
  isAssign or
  isCapture or
  isColor or
  isCoproc or
  isDefer or
  isDefine or
  isGroup or
  isHarden or
  isIf or
  isInternal or
  isJson or
  isLoop or
  isMutate or
  isOnOff or
  isParameters or
  isPrint or
  isReadonly or
  isRegister or
  isRestore or
  isReturn or
  isRunner or
  isSkip or
  isSource or
  isSplit or
  isSwitch
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

def isDefine: (
  (type == "object") and
  has("name") and
  has("body") and
  (length == 2) and
  (.name | isVariable) and
  (.body | isGroup)
);

# type Core = Image
#           | Container
#           | Network
#           | Volume
#           | Runner
#           ;
# type Image = {}; type Container = {}; type Network = {}; type Volume = {};
# type Runner = {
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
#   conditional: LogicalExpr;
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
#   commands: Commands;
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
#   name: Variable;
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
#   conditional: LogicalExpr;
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
#   evaluated: Sanitized;
#   branches: NotEmptyBranchArray;
# };
# function NotEmptyBranchArray(a: Branch[]) void {
#   assert(a.length > 0);
# }
# type Branch = {
#   pattern: Sanitized;
#   commands: NotEmptyCommandArray;
# };
