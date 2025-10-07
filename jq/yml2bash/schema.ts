// Schema file to describe formally types encountered into routine files
type Char = string & { __brand: 'SingleChar' };
type FileDescriptor = number & { __brand: 'PositiveInteger' };
type Identifier = string & { __brand: 'IdentifierString' };
type Integer = number & { __brand: 'Integer' };
type InternalLiteral = string;
type Key = string;
type Literal = string;
type NonEmptyArray<T> = T[] & { __brand: 'NonEmptyArray' };
type Parameter = number & { __brand: 'NonNegativeInteger' };
type Path = string;
enum SpecialString {
  last,
  FUNCNAME,
  USER,
  UID,
  HOME,
  ROUTINE
};
enum SpecialArray {
  sep
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
enum UnaryLogicalOperator {
  Not,
};
enum BinaryLogicalOperator {
  And,
  Or,
};
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
type Reference = Integer
               | Key
               ;
type ArrayElement = {
  "name": Identifier;
  "reference": Reference;
};
type SpecialArrayElement = {
  "name": SpecialArray;
  "reference": Reference;
};
type Sanitized = Literal
               | Char
               | Identifier
               | ArrayElement
               | Parameter
               | SpecialString
               | SpecialArrayElement
               | Path       // TODO: why ??
               | InternalLiteral
               ;
type Input = Sanitized;
type File = Path
          | FileDescriptor
          | Identifier
          | ArrayElement
          ;
type Output = {
  "left": FileDescriptor;
  "appending": boolean;
  "right": File;
};
type Redirection = Input
                 | Output
                 ;
type ImageBuilderPrune = {};
type ImageTagDefined = {
  "image": Sanitized;
  "tag": Sanitized;
};
type Image = {
  "image": Sanitized;
  "tag": Sanitized;
};
type ImageTagCreate = {
  "from": Image;
  "to": Image;
};
type BuildArg = {
  "name": Identifier;
  "value": Sanitized;
};
type Context = {
  "path": Sanitized;
  "args": BuildArg[];
};
type ImageTagCompute = {
  "input": NonEmptyArray<Context>;
};
type ImageBuild = {
  "image": Sanitized;
  "tag": Sanitized;
  "context": Context;
};
type ImageMerge = {
  "image": Sanitized;
  "tag": Sanitized;
  "base": Sanitized;
  "chain": NonEmptyArray<Context>;
};
type ImagePrune = {
  "pattern": Sanitized;
};
type ImagePull = {
  "registry": Sanitized;
  "library": Sanitized;
  "image": Sanitized;
  "tag": Sanitized;
};
type ImageRemove = {
  "image": Sanitized;
  "tag": Sanitized;
};
type ContainerResourceCopy = {
  "name": Sanitized;
  "source": Sanitized;
  "target": Sanitized;
};
type ContainerStatusGet = {
  "name": Sanitized;
};
type ContainerStatusCreated = {
  "name": Sanitized;
};
type ContainerStatusRunning = {
  "name": Sanitized;
};
type ContainerStatusHealthy = {
  "name": Sanitized;
};
type Volume = {
  "source": Sanitized;
  "target": Sanitized;
};
type ContainerCreate = {
  "name": Sanitized;
  "image": Sanitized;
  "hostname": Sanitized;
  "volumes": Volume[];
};
type ContainerExec = {
  "name": Sanitized;
  "detached": Sanitized;
  "user": Sanitized;
  "command": NonEmptyArray<Sanitized>;
};
type ContainerStart = {
  "name": Sanitized;
};
type ContainerStop = {
  "name": Sanitized;
};
type NetworkIpGet = {
  "container": Sanitized;
  "network": Sanitized;
};
type NetworkCreate = {
  "name": Sanitized;
  "isolated": Sanitized;
};
type NetworkCreated = {
  "name": Sanitized;
};
type NetworkConnect = {
  "container": Sanitized;
  "network": Sanitized;
};
type NetworkDisconnect = {
  "container": Sanitized;
  "network": Sanitized;
};
type NetworkList = {
  "pattern": Sanitized;
};
type VolumeCreate = {
  "name": Sanitized;
};
type VolumeCreated = {
  "name": Sanitized;
};
type VolumeList = {
  "pattern": Sanitized;
};
type RoutineExec = {
  "imported": Path;
  "args": Sanitized[];
};
type _ImageBuilderPrune = {
  "image.builder.prune": ImageBuilderPrune;
};
type _ImageTagDefined = {
  "image.tag.defined": ImageTagDefined;
};
type _ImageTagCreate = {
  "image.tag.create": ImageTagCreate;
};
type _ImageTagCompute = {
  "image.tag.compute": ImageTagCompute;
};
type _ImageBuild = {
  "image.build": ImageBuild;
};
type _ImageMerge = {
  "image.merge": ImageMerge;
};
type _ImagePrune = {
  "image.prune": ImagePrune;
};
type _ImagePull = {
  "image.pull": ImagePull;
};
type _ImageRemove = {
  "image.remove": ImageRemove;
};
type _ContainerResourceCopy = {
  "container.resource.copy": ContainerResourceCopy;
};
type _ContainerStatusGet = {
  "container.status.get": ContainerStatusGet;
};
type _ContainerStatusCreated = {
  "container.status.created": ContainerStatusCreated;
};
type _ContainerStatusRunning = {
  "container.status.running": ContainerStatusRunning;
};
type _ContainerStatusHealthy = {
  "container.status.healthy": ContainerStatusHealthy;
};
type _ContainerCreate = {
  "container.create": ContainerCreate;
};
type _ContainerExec = {
  "container.exec": ContainerExec;
};
type _ContainerStart = {
  "container.start": ContainerStart;
};
type _ContainerStop = {
  "container.stop": ContainerStop;
};
type _NetworkIpGet = {
  "network.ip.get": NetworkIpGet;
};
type _NetworkCreate = {
  "network.create": NetworkCreate;
};
type _NetworkCreated = {
  "network.created": NetworkCreated;
};
type _NetworkConnect = {
  "network.connect": NetworkConnect;
};
type _NetworkDisconnect = {
  "network.disconnect": NetworkDisconnect;
};
type _NetworkList = {
  "network.list": NetworkList;
};
type _VolumeCreate = {
  "volume.create": VolumeCreate;
};
type _VolumeCreated = {
  "volume.created": VolumeCreated;
};
type _VolumeList = {
  "volume.list": VolumeList;
};
type _RoutineExec = {
  "routine.exec": RoutineExec;
};
type _Module = _ImageBuilderPrune
             | _ImageTagDefined
             | _ImageTagCreate
             | _ImageTagCompute
             | _ImageBuild
             | _ImageMerge
             | _ImagePrune
             | _ImagePull
             | _ImageRemove
             | _ContainerResourceCopy
             | _ContainerStatusGet
             | _ContainerStatusCreated
             | _ContainerStatusRunning
             | _ContainerStatusHealthy
             | _ContainerCreate
             | _ContainerExec
             | _ContainerStart
             | _ContainerStop
             | _NetworkIpGet
             | _NetworkCreate
             | _NetworkCreated
             | _NetworkConnect
             | _NetworkDisconnect
             | _NetworkList
             | _VolumeCreate
             | _VolumeCreated
             | _VolumeList
             | _RoutineExec
             ;
type ArithmeticOperand = Integer
                       | Parameter
                       | Identifier
                       | ArrayElement
                       | ArithmeticExpr
                       ;
type BinaryArithmeticExpr = {
  "left": ArithmeticOperand;
  "operator": BinaryArithmeticOperator;
  "right": ArithmeticOperand;
};
type UnaryArithmeticExpr = {};
type ArithmeticExpr = UnaryArithmeticExpr
                    | BinaryArithmeticExpr
                    ;
type Assign = {
  "scope": Scope;
  "type": Type;
  "variables": NonEmptyArray<Sanitized>;
};
type Color = {
  "index": Integer;
  "variable": Sanitized;
};
type Harden = {
  "command": Sanitized;
  "as"?: Sanitized;
};
type Json = NonEmptyArray<Sanitized>;
type SubArray = {
  "offset": Integer;
  "length"?: Integer;
};
type Iterable = {
  "name"?: Identifier; // If null => "${@}"
  "sub"?: SubArray;
};
type Mutable = Identifier
             | ArrayElement
             | SpecialString.last
             ;
type Mutate = {
  "name": Mutable;
  "variables": NonEmptyArray<Sanitized>;
};
type Special = SpecialString
             | SpecialArray
             ;
type OnOff = NonEmptyArray<Option>;
type Parameters = NonEmptyArray<Sanitized>;
type Print = {
  "variable"?: Identifier;
  "format": string;
  "args": Sanitized[];
};
type Readonly = NonEmptyArray<Sanitized>;
type Return = Integer;
type Skip = Sanitized;
type _ArithmeticExpr = {
  "arithmetic": ArithmeticExpr;
};
type _Assign = {
  "assign": Assign;
};
type _Capture = {
  "capture": null;
};
type _Restore = {
  "restore": null;
};
type _CaptureRestore = _Capture
                     | _Restore
                     ;
type _Color = {
  "color": Color;
};
type _Harden = {
  "harden": Harden;
};
type _Json = {
  "json.encode": Json;
};
type _Mutate = {
  "mutate": Mutate;
};
type _On = {
  "on": OnOff;
};
type _Off = {
  "off": OnOff;
};
type _OnOff = _On
            | _Off
            ;
type _Parameters = {
  "parameters": Parameters;
};
type _Print = {
  "print": Print;
};
type _Readonly = {
  "readonly": Readonly;
};
type _Register = {
  "register": Register;
};
type _Return = {
  "return": Return;
};
type _Skip = {
  "skip": Skip;
};
type _Source = {
  "source": Source;
};
type _Switch = {
  "switch": Switch;
};
type Call = {
  "command": Sanitized;
  "args": Sanitized[];
  "pipe"?: Group;
};
type Source = Sanitized
            | Print
            | Call
            ;
type _Call = {
  "call": Call;
};
type Defer = _Module
           | _Call
           ;
type _Defer = {
  "defer": Defer;
};
type InternalCall = {
  "command": string;
  "args": Sanitized[];
  "pipe"?: Group;
};
type _InternalCall = {
  "call": InternalCall;
};
type LogicalOperand = LogicalExpr
                    | Group
                    ;
type UnaryLogicalExpr = {
  "operand": LogicalOperand;
  "operator": BinaryLogicalOperator;
};
type BinaryLogicalExpr = {
  "left": LogicalOperand;
  "operator": BinaryLogicalOperator;
  "right": LogicalOperand;
};
type LogicalExpr = UnaryLogicalExpr
                 | BinaryLogicalExpr
                 ;
type Else = If
          | Group
          ;
type If = {
  "if": LogicalExpr;
  "then": Group;
  "else": Else[];
};
type Range = {
  "initial": ArithmeticExpr;
  "conditional": ArithmeticExpr;
  "update": ArithmeticExpr;
  "do": Group;
};
type Iterator = {
  "for": Identifier;
  "into": Iterable;
  "do": Group;
};
type Conditional = {
  "while": LogicalExpr;
  "do": Group;
};
type Loop = Range
          | Iterator
          | Conditional
          ;
type _Loop = {
  "loop": Loop;
};
type Subshell = Group
              | ArithmeticExpr
              ;
type Register = {
  "variable": Mutable;
  "subshell": Subshell;
};
type Coproc = {
  "name": Identifier;
  "commands": NonEmptyArray<Command>;
};
type _Coproc = {
  "coproc": Coproc;
};
type Internal = _InternalCall
              | _Coproc
              ;
type _Internal = {
  "internal": Internal;
};
type Branch = {
  "pattern": Sanitized;
  "commands": NonEmptyArray<Command>;
};
type Switch = {
  "evaluate": Sanitized;
  "branches": NonEmptyArray<Branch>;
};
type Command = _ArithmeticExpr
             | _Assign
             | _CaptureRestore
             | _Color
             | _Defer
             | _Define
             | Group
             | _Harden
             | If
             | _Internal
             | _Json
             | _Loop
             | _Mutate
             | _OnOff
             | _Parameters
             | _Print
             | _Readonly
             | _Register
             | _Return
             | _Skip
             | _Source
             | _Switch
             | _Call
             | _Module
             ;
type Group = {
  "redirections": Redirection[];
  "commands": NonEmptyArray<Command>;
};
type Define = {
  "name": Identifier;
  "body": Group;
};
type _Define = {
  "define": Define;
};
type Routine = {
  "routine": Group;
};
