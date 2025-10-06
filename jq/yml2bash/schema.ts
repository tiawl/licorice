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
function NotEmptyCommandArray(A: Commands[]) void {
  assert(A.length > 0);
}
type Redirection = Variable
                 | Output
                 ;
type Output = {
  left: FileDescriptor;
  appending: boolean;
  right: File;
};
function FileDescriptor(i: Integer) void {
  assert(i > 0);
}
function Integer(n: number) void {
  assert(n.isInteger());
}
type File = Path
          | FileDescriptor
          | Variable
          ;
type Path = string;
type Command = ArithmeticExpr
             | Assign
             | Capture
             | Color
             | Coproc
             | Defer
             | Define
             | Group
             | Harden
             | If
             | Json
             | Loop
             | Mutate
             | On
             | Off
             | Parameters
             | Print
             | Raw
             | Readonly
             | Register
             | Restore
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
                       | ArithmeticExpr
                       ;
function Parameter(i: Integer) void {
  assert(i >= 0);
}
type Assign = {
  scope: Scope;
  type: Type;
  variables: NotEmptySanitizedArray;
};
function NotEmptySanitizedArray(A: Sanitized[]) void {
  assert(A.length > 0);
}
type Sanitized = Literal
               | Char
               | Variable
               | Parameter
               | Special
               | Path       // TODO: why ??
               | Group      // TODO: why ??
               ;
type Literal = string;
function Char(s: string) void {
  assert(s.length == 1);
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
type OnOff = On
           | Off
           ;
type On = {
  options: NotEmptyOptionArray;
};
type Off = {
  options: NotEmptyOptionArray;
};
function NotEmptyOptionArray(A: Option[]) void {
  assert(A.length > 0);
}
enum Option {
  AssocExpandOnce,
  Autocd,
  CdableVars,
  Cdspell,
  Checkhash,
  Checkjobs,
  Checkwinsize,
  Cmdhist,
  Compat31,
  Compat32,
  Compat40,
  Compat41,
  Compat42,
  Compat43,
  Compat44,
  CompleteFullquote,
  Direxpand,
  Dirspell,
  Dotglob,
  Execfail,
  ExpandAliases,
  Extdebug,
  Extglob,
  Extquote,
  Failglob,
  ForceFignore,
  Globasciiranges,
  Globstar,
  GnuErrfmt,
  Histappend,
  Histreedit,
  Histverify,
  Hostcomplete,
  Huponexit,
  InheritErrexit,
  InteractiveComments,
  Lastpipe,
  Lithist,
  LocalvarInherit,
  LocalvarUnset,
  LoginShell,
  Mailwarn,
  NoEmptyCmdCompletion,
  Nocaseglob,
  Nocasematch,
  Nullglob,
  Progcomp,
  ProgcompAlias,
  Promptvars,
  RestrictedShell,
  ShiftVerbose,
  Sourcepath,
  XpgEcho,
  Allexport,
  Braceexpand,
  Emacs,
  Errexit,
  Errtrace,
  Functrace,
  Hashall,
  Histexpand,
  History,
  Ignoreeof,
  Keyword,
  Monitor,
  Noclobber,
  Noexec,
  Noglob,
  Nolog,
  Notify,
  Nounset,
  Onecmd,
  Physical,
  Pipefail,
  Posix,
  Privileged,
  Verbose,
  Vi,
  Xtrace
};
type Coproc = {
  name: Variable;
  commands: Commands;
};
type Defer = Core
           | Call
           ;
type Core = Image
          | Container
          | Network
          | Volume
          ;
type Image = {}; type Container = {}; type Network = {}; type Volume = {};
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
  conditional: BooleanExpr;
  then: Group;
  else: Else[];
};
type BooleanExpr = UnaryBooleanExpr
                 | BinaryBooleanExpr
                 ;
type UnaryBooleanExpr = {
  operand: BooleanOperand;
  operator: BinaryBooleanOperator;
};
enum UnaryBooleanOperator {
  Not,
};
type BinaryBooleanExpr = {
  left: BooleanOperand;
  operator: BinaryBooleanOperator;
  right: BooleanOperand;
};
enum BinaryBooleanOperator {
  And,
  Or,
};
type BooleanOperand = BooleanExpr
                    | Group
                    ;
type Else = If
          | Group
          ;
type Json =;
type Loop =;
type Mutate =;
type Parameters =;
type Print =;
type Raw =;
type Readonly =;
type Register =;
type Return =;
type Runner =;
type Skip =;
type Source =;
type Split =;
type Switch =;
