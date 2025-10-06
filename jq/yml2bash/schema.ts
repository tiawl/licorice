type Define = {
  name: Variable;
  body: Group;
};
function Variable(s: string) void {
  assert(s.match("/[a-zA-Z_][a-zA-Z0-9_]*/"));
}
type Group = {
  redirections: Redirection[];
  commands: NotEmptyCommandArray;
};
function NotEmptyCommandArray(a: Commands[]) void {
  assert(a.length > 0);
}
type Redirection = Input
                 | Output
                 ;
type Input = Sanitized;
type Sanitized = Literal
               | Char
               | Variable
               | ArrayElement
               | Parameter
               | Special
               | Path       // TODO: why ??
               | InternalLiteral
               ;
type Literal = string;
function Char(s: string) void {
  assert(s.length == 1);
}
type ArrayElement = {
  name: Variable;
  reference: Reference;
};
type Reference = Integer
               | Key
               ;
function Integer(n: number) void {
  assert(n.isInteger());
}
type Key = string;
function Parameter(i: Integer) void {
  assert(i >= 0);
}
enum Special {
  last,
  FUNCNAME,
  USER,
  UID,
  HOME,
  RUNNER,
  sep
};
type Path = string;
type InternalLiteral = string;
type Output = {
  left: FileDescriptor;
  appending: boolean;
  right: File;
};
function FileDescriptor(i: Integer) void {
  assert(i > 0);
}
type File = Path
          | FileDescriptor
          | Variable
          | ArrayElement
          ;
type Command = ArithmeticExpr
             | Assign
             | CaptureRestore
             | Color
             | Defer
             | Define
             | Group
             | Harden
             | If
             | Internal
             | Json
             | Loop
             | Mutate
             | OnOff
             | Parameters
             | Print
             | Readonly
             | Register
             | Return
             | Runner
             | Skip
             | Source
             | Split
             | Switch
             ;
type ArithmeticExpr = BinaryArithmeticExpr;
type BinaryArithmeticExpr = {
  left: ArithmeticOperand;
  operator: BinaryArithmeticOperator;
  right: ArithmeticOperand;
};
// TODO: more arithmetic operators
enum BinaryArithmeticOperator {
  Addition,
  Substraction,
  Remainder,
  Gt,
  Lt,
  Ge,
  Le,
  Eq,
  Ne,
  Assignment,
  Increment
};
type ArithmeticOperand = Integer
                       | Parameter
                       | Variable
                       | ArrayElement
                       | ArithmeticExpr
                       ;
type Assign = {
  scope: Scope;
  type: Type;
  variables: NotEmptySanitizedArray;
};
function NotEmptySanitizedArray(a: Sanitized[]) void {
  assert(a.length > 0);
}
enum Scope {
  Local,
  Global
};
enum Type {
  String,
  Associative,
  Indexed,
  Reference
};
enum CaptureRestore {
  Capture,
  Restore
}
type Color = {
  index: Integer;
  variable: Sanitized;
};
type Defer = Core
           | Call
           ;
type Core = Image
          | Container
          | Network
          | Volume
          | Runner
          ;
type Image = {}; type Container = {}; type Network = {}; type Volume = {};
type Runner = {
  imported: Path;
  args: Sanitized[];
};
type Call = {
  command: Sanitized;
  args: Sanitized[];
  pipe?: Group;
};
type Harden = {
  command: Sanitized;
  as?: Sanitized;
};
type If = {
  conditional: LogicalExpr;
  then: Group;
  else: Else[];
};
type Internal = InternalCall
              | Coproc
              ;
type InternalCall = {
  command: string;
  args: Sanitized[];
  pipe?: Group;
};
type Coproc = {
  name: Variable;
  commands: Commands;
};
type LogicalExpr = UnaryLogicalExpr
                 | BinaryLogicalExpr
                 ;
type UnaryLogicalExpr = {
  operand: LogicalOperand;
  operator: BinaryLogicalOperator;
};
enum UnaryLogicalOperator {
  Not,
};
type BinaryLogicalExpr = {
  left: LogicalOperand;
  operator: BinaryLogicalOperator;
  right: LogicalOperand;
};
enum BinaryLogicalOperator {
  And,
  Or,
};
type LogicalOperand = LogicalExpr
                    | Group
                    ;
type Else = If
          | Group
          ;
type Json = NotEmptySanitizedArray;
type Loop = Range
          | Iterator
          | Conditional
          ;
type Range = {
  initial: ArithmeticExpr;
  conditional: ArithmeticExpr;
  update: ArithmeticExpr;
  do: Group;
};
type Iterator = {
  name: Variable;
  into: Iterable;
  do: Group;
};
type Iterable = {
  name?: Variable; // If null => "${@}"
  sub?: SubArray;
};
type SubArray = {
  offset: Integer;
  length?: Integer;
};
type Conditional = {
  conditional: LogicalExpr;
  do: Group;
};
type Mutate = {
  name: Mutable;
  variables: NotEmptySanitizedArray;
};
type Mutable = Variable
             | ArrayElement
             | Last
             ;
function Last(s: Special) void {
  assert(s.valueOf() === Special.last.valueOf());
}
type OnOff = NotEmptyOptionArray;
function NotEmptyOptionArray(a: Option[]) void {
  assert(a.length > 0);
}
enum Option {
  assoc_expand_once,
  autocd,
  cdable_vars,
  cdspell,
  checkhash,
  checkjobs,
  checkwinsize,
  cmdhist,
  compat31,
  compat32,
  compat40,
  compat41,
  compat42,
  compat43,
  compat44,
  complete_fullquote,
  direxpand,
  dirspell,
  dotglob,
  execfail,
  expand_aliases,
  extdebug,
  extglob,
  extquote,
  failglob,
  force_fignore,
  globasciiranges,
  globstar,
  gnu_errfmt,
  histappend,
  histreedit,
  histverify,
  hostcomplete,
  huponexit,
  inherit_errexit,
  interactive_comments,
  lastpipe,
  lithist,
  localvar_inherit,
  localvar_unset,
  login_shell,
  mailwarn,
  no_empty_cmd_completion,
  nocaseglob,
  nocasematch,
  nullglob,
  progcomp,
  progcomp_alias,
  promptvars,
  restricted_shell,
  shift_verbose,
  sourcepath,
  xpg_echo,
  allexport,
  braceexpand,
  emacs,
  errexit,
  errtrace,
  functrace,
  hashall,
  histexpand,
  history,
  ignoreeof,
  keyword,
  monitor,
  noclobber,
  noexec,
  noglob,
  nolog,
  notify,
  nounset,
  onecmd,
  physical,
  pipefail,
  posix,
  privileged,
  verbose,
  vi,
  xtrace
};
type Parameters = NotEmptySanitizedArray;
type Print = {
  variable?: Variable;
  format: string;
  args: Sanitized[];
};
type Readonly = NotEmptySanitizedArray;
type Register = {
  variable: Mutable;
  subshell: Subshell;
};
type Subshell = Group
              | ArithmeticExpr
              ;
type Return = Integer;
type Skip = Sanitized;
type Source = Sanitized
            | Print
            | Call
            ;
type Switch = {
  evaluated: Sanitized;
  branches: NotEmptyBranchArray;
};
function NotEmptyBranchArray(a: Branch[]) void {
  assert(a.length > 0);
}
type Branch = {
  pattern: Sanitized;
  commands: NotEmptyCommandArray;
};
