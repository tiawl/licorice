#! /usr/bin/env --split-string gojq --from-file

# TODO: minimal SPEC
# TODO:
# - more checks
# - op:
#   - and
#   - or
#   - [[ ]]
# - async/wait

{
  var: {
    user: "__"
  },
  fn: {
    internal: ("runner" + $ARGS.named.NAMESPACE_SEP),
    user: ("user" + $ARGS.named.NAMESPACE_SEP)
  },
  sep: $ARGS.named.NAMESPACE_SEP
} as $NAMESPACE |
{
  internal: -1,
  quiet: 0,
  user: 1
} as $MODE |
-2 as $NOINDENT |
.import as $IMPORT |
.name as $RUNNER |
$ARGS.named.EXE as $EXE |
$ARGS.named.BACKEND as $BACKEND |
$ARGS.named.FUNCTIONS as $FUNCTIONS |

def incr_indent_level(i): (
  if (. == $NOINDENT) then $NOINDENT else (. + i) end
);

def indent(level): (
  ((" " * ((level | incr_indent_level(1)) * 4)) // "") + .
);

def is_legit_varname: (
  test("^[a-zA-Z_][a-zA-Z0-9_]*$")
);

def bad_varname: (
  "Bad variable name: \"" + . + "\"" | exit
);

def among(k): (
  . as $input |
    reduce k[] as $item (0; . + ($input | if has($item) then 1 else 0 end))
);

def is_unique_key_object: (
  if (type != "object") then (
    "Expected an object: " + (. | tostring) | exit
  ) end |

  if (keys | length > 1) then (
    "This object must contain a unique key: " + (. | tostring) | exit
  ) end
);


def xtrace(mode): (
  (.before // []) + (
    if (mode == $MODE.user) then (
      [
        $NAMESPACE.fn.internal + "xtrace \"$(echo " + .xtrace + ")\"",
        .program
      ]
    ) else (
      [
        .program
      ]
    ) end
  )
);

def default_type: (
  if ((.type == "") or (.type == null)) then (
    .type = "string"
  ) end
);

def check_type_coherence: (
  if ((has("key")) and (.type != "string")) then (
    "Values into associative or indexed array must be string typed" | exit
  ) end |
  if ((has("key")) and (has("value")) and (.value | length > 1)) then (
    "You can not attribute several values to a single key" | exit
  ) end |
  if ((.type == "string") and (has("value")) and (.value | length > 1)) then (
    "You can not attribute several values to a string variable" | exit
  ) end
);

def return(level): (
  ("return " + (.return | tostring)) | indent(level)
);

def capture_restore(level): (
  if (.capture or .restore) then (keys[0] | indent(level)) else "" end
);

def define(level; mode; nested_register; user_defined): (
  def group(level; mode; multilined; indent_first; nested_register): (
    def sanitize(mode; quoted): (
      def expansion(mode): (
        if (among(["default", "alternate", "replace", "prompt"]) == 2) then (
          "You can only use one of \"default\", \"alternate\", \"replace\" or \"prompt\" fields for a same variable" | exit
        ) end |
        if (has("default")) then (
          ":-" + (.default | sanitize(mode; true))
        ) elif (has("alternate")) then (
          ":+" + (.alternate | sanitize(mode; true))
        ) elif (has("prompt") and .prompt) then (
          "@P"
        ) elif (has("replace")) then (
          .replace |
            if (has("all")) then (
              "//" + (.all | sanitize(mode; true)) + (if (has("with")) then ("/" + (.with | sanitize(mode; true))) else "" end)
            ) elif (has("first")) then (
              "/" + (.first | sanitize(mode; true)) + (if (has("with")) then ("/" + (.with | sanitize(mode; true))) else "" end)
            ) elif (has("start") and (.match == "shortest")) then (
              "#" + (.start | sanitize(mode; true))
            ) elif (has("start") and (.match == "longest")) then (
              "##" + (.start | sanitize(mode; true))
            ) elif (has("end") and (.match == "shortest")) then (
              "%" + (.end | sanitize(mode; true))
            ) elif (has("end") and (.match == "longest")) then (
              "%%" + (.end | sanitize(mode; true))
            ) else (
              "Unknown field into \"replace\": " + (. | tostring) | exit
            ) end
        ) else "" end
      );

      def variable(name; mode; quoted): (
        (if (quoted) then "\"" else "" end) + "${" + name + (
          if (has("key")) then (
            "[" + (.key | sanitize(mode; false)) + "]"
          ) elif (has("index")) then (
            "[" + (
              if (.index | type == "number") then (
                .index | tostring
              ) else (
                "The .var.index must be number typed" | exit
              ) end
            ) + "]"
          ) else "" end
        ) + expansion(mode) + "}" + (if (quoted) then "\"" else "" end)
      );

      map(
        . as $input |
        if (has("literal")) then (
          (if (quoted) then "'" else "" end) + (.literal | tostring) + (if (quoted) then "'" else "" end)
        ) elif (has("number")) then (
          if (.number | type != "number") then (
            (.number | tostring) + " is not number typed" | exit
          ) end |
          (if (quoted) then "\"" else "" end) + (.number | tostring) + (if (quoted) then "\"" else "" end)
        ) elif (has("char")) then (
          if (.char == "asterisk") then (
            "*"
          ) elif (.char == "tilde") then (
            "~"
          ) elif (.char == "atsign") then (
            "@"
          ) elif (.char == "newline") then (
            "$'\\n'"
          ) else (
            "Unknown char: \"" + .char + "\"" | exit
          ) end
        ) elif (has("var")) then (
          if (.var | is_legit_varname) then (
            variable(if (mode != $MODE.internal) then $NAMESPACE.var.user else "" end + .var; mode; quoted)
          ) else (
            $input.var | bad_varname
          ) end
        ) elif (has("parameter")) then (
          if (.parameter | type == "number") then (
            variable(.parameter | tostring; mode; quoted)
          ) else (
            "Positional parameter must be number typed" | exit
          ) end
        ) elif (has("special")) then (
          variable(
            if (.special == "last") then "_"
            elif ((.special == "FUNCNAME") or (.special == "USER") or (.special == "UID") or (.special == "HOME") or (.special == "RUNNER") or (.special == "sep")) then .special
            else (
              "Unknown special variable: \"" + .special + "\"" | exit
            ) end
          ; mode; quoted)
        ) elif (has("file")) then (
          (if (quoted) then "\"" else "" end) + "$(< " + (.file | sanitize(mode; true)) + ")" + (if (quoted) then "\"" else "" end)
        ) elif (has("input")) then (
          "<(" + ({group: .input} | group($NOINDENT; mode; false; false; false)) + ")"
        ) elif (has("unsafe")) then (
          if (mode != $MODE.internal) then (
            "\"unsafe\" can only be used as internal user" | exit
          ) end |
          .unsafe
        ) else (
          "Unknown field object passing through sanitize(): \"" + keys[0] + "\"" | exit
        ) end
      ) | join("")
    );

    def harden(level; mode): (
      (
        .harden |
        "harden " + (.command | sanitize(mode; true)) + (
          if (has("as") and (.as | length > 0)) then (
            " " + (
              if (mode != $MODE.internal) then (
                $NAMESPACE.fn.user
              ) else "" end
            ) + (.as | sanitize(mode; true))
          ) elif (mode != $MODE.internal) then (
            " '" + $NAMESPACE.fn.user + "'" + (.command | sanitize(mode; true)) | gsub("''"; "")
          ) else "" end
        )
      ) | indent(level)
    );

    def mutate(level; mode; value_mode): (
      .mutate | default_type | check_type_coherence | . as $input |
      if (has("value") | not) then (
        "You forgot the .mutate.value mandatory field into: " + tostring | exit
      ) end |
      if (has("scope")) then (
        "Use assign instead of mutate to attribute a scope for this variable: " + tostring | exit
      ) end |
      if ((.name | has("var") | not) and (.name | has("special") | not)) then (
        "In .mutate.name you can only use var or special: " + tostring | exit
      ) end |
      if ((.name | has("var")) and (.name.var | is_legit_varname | not)) then (
        .name | bad_varname
      ) end |
      (
        if ((.name | has("special")) and (.name.special == "last")) then (
          ": "
        ) else (
          if (mode != $MODE.internal) then $NAMESPACE.var.user else "" end + .name.var + (
            if (has("key")) then (
              "[" + (.key | sanitize(mode; true)) + "]"
            ) elif (has("index")) then (
              if (.index | type != "number") then (
                "mutate: index field must be number typed" | exit
              ) end |
              "[" + (.index | tostring) + "]"
            ) else "" end
          ) + "="
        ) end + (
          if (($input.type == "indexed") or ($input.type == "associative")) then (
            ("(" + (.value | map(sanitize(value_mode; true)) | join(" ")) + ")")
          ) else (
            .value[0] | sanitize(mode; true)
          ) end
        )
      ) | indent(level)
    );

    def assign(level; mode): (
      .assign | default_type | check_type_coherence |
      if (has("scope") | not) then (
        "You forgot the .assign.scope mandatory field into: " + tostring | exit
      ) end |
      if (has("value")) then (
        "Use mutate instead of assign to change value of this variable: " + tostring | exit
      ) end |
      (
        (
          if (.scope == "global") then (
            "global "
          ) elif (.scope == "local") then (
            "local "
          ) else (
            "Unknown .assign.scope: \"" + .type + "\"" | exit
          ) end
        ) + (
          if (.type == "string") then (
            ""
          ) elif (.type == "associative") then (
            "-A "
          ) elif (.type == "indexed") then (
            "-a "
          ) elif (.type == "reference") then (
            "-n "
          ) else (
            "Unknown .assign.type: \"" + .type + "\"" | exit
          ) end
        ) + (.vars | map(if (mode != $MODE.internal) then $NAMESPACE.var.user else "" end + (. | sanitize(mode; true))) | join(" "))
      ) | indent(level)
    );

    def core(mode): {
      image: {
        builder: {
          prune: (try (
            .image.builder.prune as $prune |
              if $prune then "image builder prune" else null end
          ) catch null)
        },
        tag: {
          defined: (try (
            .image.tag.defined as $defined |
              if $defined then (
                "image tag defined " +
                  ($defined.image | sanitize(mode; true)) + " " +
                  ($defined.tag | sanitize(mode; true))
              ) else null end
          ) catch null),
          create: (try (
            .image.tag.create as $create |
              if $create then (
                "image tag create " +
                  ($create.from.image | sanitize(mode; true)) + " " +
                  ($create.from.tag | sanitize(mode; true)) + " " +
                  ($create.to.image | sanitize(mode; true)) + " " +
                  ($create.to.tag | sanitize(mode; true))
              ) else null end
          ) catch null),
          compute: (try (
            .image.tag.compute as $compute |
              if $compute then (
                "image tag compute " +
                  ([range($compute | length) as $i | $compute[$i] | "context " + (.context | sanitize(mode; true)) + " string " + ([{var: ("assoc" + ($i | tostring))}] | sanitize($MODE.internal; true))] | join(" "))
              ) else null end
          ) catch null)
        },
        pull: (try (
          .image.pull as $pull |
            if $pull then (
              "image pull " +
                ($pull.registry | sanitize(mode; true)) + " " +
                ($pull.library | sanitize(mode; true)) + " " +
                ($pull.image | sanitize(mode; true)) + " " +
                ($pull.tag | sanitize(mode; true))
            ) else null end
        ) catch null),
        remove: (try (
          .image.remove as $remove |
            if $remove then (
              "image remove " +
                ($remove.image | sanitize(mode; true)) + " " +
                ($remove.tag | sanitize(mode; true))
            ) else null end
        ) catch null),
        prune: (try (
          .image.prune as $prune |
            if $prune then (
              "image prune " +
                ($prune | sanitize(mode; true))
            ) else null end
        ) catch null),
        build: (try (
          .image.build as $build |
            if $build then (
              "image build " +
                ($build.image | sanitize(mode; true)) + " " +
                ($build.tag | sanitize(mode; true)) + " " +
                ($build.context | sanitize(mode; true)) + " " +
                ([{var: "assoc"}] | sanitize($MODE.internal; true))
            ) else null end
        ) catch null),
        merge: (try (
          .image.merge as $merge |
            if $merge then (
              "image merge " +
                ($merge.image | sanitize(mode; true)) + " " +
                ($merge.tag | sanitize(mode; true)) + " " +
                ($merge.base | sanitize(mode; true)) + " " +
                ([range($merge.chain | length) | ($merge.chain[.].context | sanitize(mode; true)) + " " + ([{var: ("assoc" + tostring)}] | sanitize($MODE.internal; true))] | join(" "))
            ) else null end
        ) catch null)
      },
      container: {
        resource: {
          copy: (try (
            .container.resource.copy as $copy |
              if $copy then (
                "container resource copy " +
                  ($copy.name | sanitize(mode; true)) + " " +
                  ($copy.src | sanitize(mode; true)) + " " +
                  ($copy.dest | sanitize(mode; true))
              ) else null end
          ) catch null)
        },
        status: {
          get: (try (
            .container.status.get as $get |
              if $get then (
                "container status get " +
                  ($get | sanitize(mode; true))
              ) else null end
          ) catch null),
          created: (try (
            .container.status.created as $created |
              if $created then (
                "container status created " +
                  ($created | sanitize(mode; true))
              ) else null end
          ) catch null),
          running: (try (
            .container.status.running as $running |
              if $running then (
                "container status running " +
                  ($running | sanitize(mode; true))
              ) else null end
          ) catch null),
          healthy: (try (
            .container.status.healthy as $healthy |
              if $healthy then (
                "container status healthy " +
                  ($healthy | sanitize(mode; true))
              ) else null end
          ) catch null)
        },
        create: (try (
          .container.create as $create |
            if $create then (
              "container create " +
                ($create.name | sanitize(mode; true)) + " " +
                ($create.image | sanitize(mode; true)) + " " +
                ($create.hostname | sanitize(mode; true)) + " " +
                ([{var: "idx"}] | sanitize($MODE.internal; true))
            ) else null end
        ) catch null),
        start: (try (
          .container.start as $start |
            if $start then (
              "container start " +
                ($start.name | sanitize(mode; true))
            ) else null end
        ) catch null),
        stop: (try (
          .container.stop as $stop |
            if $stop then (
              "container stop " +
                ($stop.name | sanitize(mode; true))
            ) else null end
        ) catch null),
        exec: (try (
          .container.exec as $exec |
            if $exec then (
              "container exec " +
                ($exec.name | sanitize(mode; true)) + " " +
                ($exec.detached | sanitize(mode; true)) + " " +
                ($exec.user | sanitize(mode; true)) + " " +
                ([{var: "idx"}] | sanitize($MODE.internal; true))
            ) else null end
        ) catch null)
      },
      network: {
        ip: {
          get: (try (
            .network.ip.get as $get |
              if $get then (
                "network ip get " +
                  ($get.container | sanitize(mode; true)) + " " +
                  ($get.network | sanitize(mode; true))
              ) else null end
          ) catch null)
        },
        create: (try (
          .network.create as $create |
            if $create then (
              if ($create.isolated | type != "boolean") then (
                "network.create.isolated must be a boolean" | exit
              ) else null end |
              "network create " +
                ($create.name | sanitize(mode; true)) + " " +
                ($create.isolated | tostring)
            ) else null end
        ) catch null),
        connect: (try (
          .network.connect as $connect |
            if $connect then (
              "network connect " +
                ($connect.network | sanitize(mode; true)) + " " +
                ($connect.container | sanitize(mode; true))
            ) else null end
        ) catch null),
        disconnect: (try (
          .network.disconnect as $disconnect |
            if $disconnect then (
              "network disconnect " +
                ($disconnect.network | sanitize(mode; true)) + " " +
                ($disconnect.container | sanitize(mode; true))
            ) else null end
        ) catch null),
        list: (try (
          .network.list as $list |
            if $list then (
              "network list " +
                ($list.pattern | sanitize(mode; true))
            ) else null end
        ) catch null),
        created: (try (
          .network.created as $created |
            if $created then (
              "network created " +
                ($created.name | sanitize(mode; true))
            ) else null end
        ) catch null)
      },
      volume: {
        create: (try (
          .volume.create as $create |
            if $create then (
              "volume create " +
                ($create.name | sanitize(mode; true))
            ) else null end
        ) catch null),
        list: (try (
          .volume.list as $list |
            if $list then (
              "volume list " +
                ($list.pattern | sanitize(mode; true))
            ) else null end
        ) catch null),
        created: (try (
          .volume.created as $created |
            if $created then (
              "volume created " +
                ($created.name | sanitize(mode; true))
            ) else null end
        ) catch null)
      }
    };

    def readonly(level; mode): (
      ("readonly -- " + (.readonly | map(if (mode != $MODE.internal) then $NAMESPACE.var.user else "" end + (. | sanitize(mode; true))) | join(" "))) | indent(level)
    );

    def print(level; mode): (
      (
        .print |
        "print " + (
          if (has("var")) then (
            if (.var | is_legit_varname) then (
              "-v " + (if (mode != $MODE.internal) then $NAMESPACE.var.user else "" end) + .var + " "
            ) else (
              .var | bad_varname
            ) end
          ) else "" end
        ) + "-- '" + .format + "'" + (if (.args | length > 0) then " " else "" end) + (.args | map(sanitize(mode; true)) | join(" "))
      ) | indent(level)
    );

    def skip(level; mode): (
      (": " + (.skip | map(sanitize(mode; true)) | join(" "))) | indent(level)
    );

    def json(level; mode): (
      (
        "json" + $NAMESPACE.sep + (.json |
          if (has("encode")) then (
            "encode " + (.encode[] | sanitize(mode; true))
          ) else (
            "Unknown json op" | exit
          ) end
        )
      ) | indent(level)
    );

    def color(level; mode): (
      (.color | $NAMESPACE.fn.internal + "color " + (.index | sanitize(mode; true)) + " " + ((if (mode != $MODE.internal) then $NAMESPACE.var.user else "" end) + (.ref | sanitize(mode; true)))) | indent(level)
    );

    def on_off(level; mode): (
      ((keys[0]) + " " + (values[] | map(sanitize(mode; true)) | join(" "))) | indent(level)
    );

    def parameters(level; mode): (
      ("set -- " + (.parameters | map(sanitize(mode; true)) | join(" "))) | indent(level)
    );

    def arithmetic_operator(mode): (
      def arithmetic_side(mode): (
        if (has("parameter") or has("var")) then (
          [.] | sanitize(mode; true)
        ) elif (has("literal")) then (
          if (.literal | type == "string") then (
            .literal
          ) else (
            ".literal arithmetic side must be string typed" | exit
          ) end
        ) elif (has("number")) then (
          is_unique_key_object |
          if (.number | type == "number") then (
            .number | tostring
          ) else (
            ".number arithmetic side must be number typed" | exit
          ) end
        ) elif (has("arithmetic")) then (
          is_unique_key_object |
            "( " + (.arithmetic | arithmetic_operator(mode)) + " )"
        ) else (
          "Unknown arithmetic side: " + (. | tostring) | exit
        ) end
      );

      if (has("addition")) then (
        .addition | ((.left | arithmetic_side(mode)) + " + " + (.right | arithmetic_side(mode)))
      ) elif (has("substraction")) then (
        .substraction | ((.left | arithmetic_side(mode)) + " - " + (.right | arithmetic_side(mode)))
      ) elif (has("remainder")) then (
        .remainder | ((.left | arithmetic_side(mode)) + " % " + (.right | arithmetic_side(mode)))
      ) elif (has("gt")) then (
        .gt | ((.left | arithmetic_side(mode)) + " > " + (.right | arithmetic_side(mode)))
      ) elif (has("lt")) then (
        .lt | ((.left | arithmetic_side(mode)) + " < " + (.right | arithmetic_side(mode)))
      ) elif (has("ge")) then (
        .ge | ((.left | arithmetic_side(mode)) + " >= " + (.right | arithmetic_side(mode)))
      ) elif (has("le")) then (
        .le | ((.left | arithmetic_side(mode)) + " <= " + (.right | arithmetic_side(mode)))
      ) elif (has("eq")) then (
        .eq | ((.left | arithmetic_side(mode)) + " == " + (.right | arithmetic_side(mode)))
      ) elif (has("ne")) then (
        .ne | ((.left | arithmetic_side(mode)) + " != " + (.right | arithmetic_side(mode)))
      ) elif (has("assignment")) then (
        .assignment | ((.left | arithmetic_side(mode)) + " = " + (.right | arithmetic_side(mode)))
      ) elif (has("increment")) then (
        .increment | ((.left | arithmetic_side(mode)) + " += " + (.right | arithmetic_side(mode)))
      ) else (
        "Unknown arithmetic operand: " + tostring | exit
      ) end
    );

    def arithmetic(level; mode): (
      ("(( " + (.arithmetic | arithmetic_operator(mode)) + " ))") | indent(level)
    );

    def command(level; mode; multilined; nested_register): (
      def switch(level; mode; nested_register): (
        .switch as $input | .switch |
          ("case " + (.evaluate | sanitize(mode; true)) + " in\n") | indent(level) + (
            $input.branches | map(
              . as $branch |
              ("( " + ($branch.pattern | sanitize(mode; true)) + " ) ") | indent(level) +
              ($branch | group(level; mode; true; false; nested_register)) + " ;;\n"
            ) | join("")
          ) + ("esac" | indent(level))
      );

      def raw(level; mode; nested_register): (
        .raw |
          if (mode != $MODE.internal) then (
            "\"raw\" can only be used as internal user" | exit
          ) end |
          if (.command | tostring | test("\\s")) then (
            ".raw.command must not contain space characters" | exit
          ) end |
          ((.command | tostring) + (if (.args | length > 0) then " " else "" end) + (.args | map(sanitize(mode; true)) | join(" ")) + (
            if (has("pipe")) then (
              " | " + (.pipe | group($NOINDENT; mode; false; false; nested_register))
            ) else "" end
          )) | indent(level)
      );

      def coproc(level; mode; nested_register): (
        .coproc |
          if (mode != $MODE.internal) then (
            "\"coproc\" can only be used as internal user" | exit
          ) end |
          (group(level; mode; true; false; nested_register)) as $group |
          if (.name | test("^[A-Z_][A-Z0-9_]*$") | not) then (
            "Bad coproc name: \"" + . + "\"" | exit
          ) end |
          (("coproc " + .name + " ") | indent(level)) + $group
      );

      def call(mode; nested_register): (
        .call |
          if (.command | sanitize(mode; true) | test("\\s")) then (
            ".call.command must not contain space characters" | exit
          ) end |
          $NAMESPACE.fn.internal + "call \"$(echo '" + $NAMESPACE.fn.user + "'" + (.command | sanitize(mode; true)) + (if (.args | length > 0) then " " else "" end) + (.args | map(sanitize(mode; true)) | join(" ")) + ")" + (
            if (has("pipe")) then (
              " | " + (.pipe | group($NOINDENT; mode; false; false; nested_register))
            ) else "" end
          ) + "\""
      );

      def runner_exec(level; mode; nested_register): (
        .runner.exec as $exec |
        $exec.args // [] as $exec_args |
        ("exec" + $NAMESPACE.sep + $exec.imported) as $fn_name |
          {
            define: {
              name: $fn_name,
              group: $IMPORT[$exec.imported].group
            }
          } | define(level; mode; nested_register; false) + (
            {
              program: ($NAMESPACE.fn.internal + $fn_name + (if ($exec_args | length > 0) then " " else "" end) + ($exec_args | map(sanitize(mode; true)) | join(" "))),
              xtrace: ("runner exec " + $exec.imported + (if ($exec_args | length > 0) then " " else "" end) + ($exec_args | map(sanitize(mode; true)) | join(" ")))
            } | xtrace(mode) | map(indent(level)) | join("\n")
          )
      );

      def sourceable(mode; nested_register): (
        if (has("call")) then call(mode; nested_register)
        elif (has("print")) then print(-1; mode)
        else ("Authorized tasks into source.from JSON array are \"call\" and \"print\"" | exit)
        end
      );

      def source(level; mode; nested_register): (
        .source |
          if (has("string")) then (
            ("source /proc/self/fd/0 <<< " + (.string | map(sanitize(mode; true)) | join(" "))) | indent(level)
          ) elif (has("from")) then (
            (if (mode != $MODE.internal) then $MODE.quiet else mode end) as $mode |
              ("source <(\n" | indent(level)) +
              (.from | map(sourceable($mode; nested_register) | indent(level | incr_indent_level(1))) | join("\n")) + "\n" +
              (")" | indent(level))
            ) else (
            "Authorized fields into source JSON object are \"string\" and \"from\"" | exit
          ) end
      );

      def register(level; mode; nested): (
        .register as $input | .register | (
          if (mode == $MODE.internal) then 0 else 1 end
        ) as $offset |
          if (has("into") | not) then (
            ".register used without .register.into" | exit
          ) end |
          if (among(["group", "arithmetic", "split"]) == 2) then (
            "You can only use one of \"group\", \"arithmetic\" or \"split\" fields into register" | exit
          ) end |
          if (has("group")) then (
            if (mode == $MODE.internal) then (
              group(level | incr_indent_level($offset); mode; true; false; nested) as $group |
              {
                mutate: {
                  name: $input.into,
                  value: [[{unsafe: ("\"$(" + $group + ")\"")}]]
                }
              } | mutate(level | incr_indent_level($offset); $MODE.internal; mode)
            ) else (
              if ((.into | has("var")) and (.into.var | is_legit_varname | not)) then (
                .into | bad_varname
              ) end |
              (group($NOINDENT; mode; false; false; true) | gsub("'"; "'\"'\"'")) as $group |
              if (.into | has("var")) then (
                $NAMESPACE.fn.internal + "register '" + $NAMESPACE.var.user + $input.into.var + "' '" + $group + "'"
              ) elif ((.into | has("special")) and (.into.special == "last")) then (
                ": \"$(" + $group + ")\""
              ) else (
                "In .register.into you can only use var or special \"last\": " + tostring | exit
              ) end | indent(level)
            ) end
          ) elif (has("arithmetic")) then (
            if ((.into | has("var")) and (.into.var | is_legit_varname | not)) then (
              .into | bad_varname
            ) end |
            arithmetic(-1; mode) as $arith |
            if (.into | has("var")) then (
              (if (mode != $MODE.internal) then $NAMESPACE.var.user else "" end) + $input.into.var + "=\"$" + $arith + "\""
            ) elif ((.into | has("special")) and (.into.special == "last")) then (
              ": \"$" + $arith + "\""
            ) else (
              "In .register.into you can only use var or special \"last\": " + tostring | exit
            ) end | indent(level)
          ) elif (has("split")) then (
            ("mapfile -t " + ($input.split | if (has("delimiter")) then ("-d " + (.delimiter | sanitize(mode; true))) else "" end) + " " + ($input.into | sanitize(mode; true)) + " <<< " + ($input.split.string | sanitize(mode; true))) | indent(level | incr_indent_level($offset))
          ) else (
            "Authorized fields into register are: arithmetic and group" | exit
          ) end
      );

      def before_core(level; mode): {
        image: {
          tag: {
            compute: (try (
              .image.tag.compute as $compute |
                if $compute then ([
                  {assign: {vars: [range($compute | length) | [{literal: ("raw_assoc" + tostring)}]], type: "associative", scope: "local"}} | assign($NOINDENT; $MODE.internal)
                ] + [
                  {assign: {vars: [range($compute | length) | [{literal: ("assoc" + tostring)}]], scope: "local"}} | assign($NOINDENT; $MODE.internal)
                ] + (
                  [
                    range($compute | length) |
                    [
                      ({mutate: {name: {var: ("raw_assoc" + tostring)}, type: "associative", value: ($compute[.].args // [])}} | mutate($NOINDENT; $MODE.internal; mode)),
                      ({
                        register: {
                          group: {commands: [{json: {encode: [[{literal: ("raw_assoc" + tostring)}]]}}]},
                          into: {var: ("assoc" + tostring)}
                        }
                      } | register(-1; $MODE.internal; nested_register) | split("\n")[])
                    ]
                  ] | add)
                ) else null end
            ) catch null)
          },
          build: (try (
            .image.build as $build |
              if $build then [
                ({assign: {vars: [[{literal: "raw_assoc"}]], type: "associative", scope: "local"}} | assign($NOINDENT; $MODE.internal)),
                ({assign: {vars: [[{literal: "assoc"}]], scope: "local"}} | assign($NOINDENT; $MODE.internal)),
                ({mutate: {name: {var: "raw_assoc"}, type: "associative", value: $build.args}} | mutate($NOINDENT; $MODE.internal; mode)),
                ({
                  register: {
                    group: {commands: [{json: {encode: [[{literal: "raw_assoc"}]]}}]},
                    into: {var: "assoc"}
                  }
                } | register($NOINDENT; $MODE.internal; nested_register))
              ] else null end
          ) catch null),
          merge: (try (
            .image.merge as $merge |
              if $merge then ([
                {assign: {vars: [range($merge.chain | length) | [{literal: ("raw_assoc" + tostring)}]], type: "associative", scope: "local"}} | assign($NOINDENT; $MODE.internal)
              ] + [
                {assign: {vars: [range($merge.chain | length) | [{literal: ("assoc" + tostring)}]], scope: "local"}} | assign($NOINDENT; $MODE.internal)
              ] + (
                [
                  range($merge.chain | length) |
                  [
                    ({mutate: {name: {var: ("raw_assoc" + tostring)}, type: "associative", value: ($merge.chain[.].args // [])}} | mutate($NOINDENT; $MODE.internal; mode)),
                    ({
                      register: {
                        group: {commands: [{json: {encode: [[{literal: ("raw_assoc" + tostring)}]]}}]},
                        into: {var: ("assoc" + tostring)}
                      }
                    } | register(-1; $MODE.internal; nested_register) | split("\n")[])
                  ]
                ] | add)
              ) else null end
          ) catch null)
        },
        container: {
          create: (try (
            .container.create as $create |
            if $create then (
              [
                {assign: {vars: [range($create.volumes | length) | [{literal: ("raw_assoc" + tostring)}]], type: "associative", scope: "local"}} | assign($NOINDENT; $MODE.internal)
              ] + [
                {assign: {vars: [range($create.volumes | length) | [{literal: ("assoc" + tostring)}]], scope: "local"}} | assign($NOINDENT; $MODE.internal)
              ] + (
                [
                  range($create.volumes | length) | [
                    ({mutate: {name: {var: ("raw_assoc" + tostring)}, type: "associative", value: ($create.volumes[.] | [
                        {
                          key: [{literal: "Source"}],
                          value: .source
                        },{
                          key: [{literal: "Target"}],
                          value: .target
                        },{
                          key: [{literal: "Type"}],
                          value: [{literal: "volume"}]
                        }
                      ] // [])}} | mutate($NOINDENT; $MODE.internal; mode)),
                    ({
                      register: {
                        group: {commands: [{json: {encode: [[{literal: ("raw_assoc" + tostring)}]]}}]},
                        into: {var: ("assoc" + tostring)}
                      }
                    } | register(-1; $MODE.internal; nested_register) | split("\n")[])
                  ]
                ] | add
              ) + [
                ({assign: {vars: [[{literal: "raw_idx"}]], type: "indexed", scope: "local"}} | assign($NOINDENT; $MODE.internal)),
                ({assign: {vars: [[{literal: "idx"}]], scope: "local"}} | assign($NOINDENT; $MODE.internal)),
                ({mutate: {name: {var: "raw_idx"}, type: "indexed", value: ([[[range($create.volumes | length) | {var: ("assoc" + tostring)}]]] // [])}} | mutate($NOINDENT; $MODE.internal; $MODE.internal)),
                ({
                  register: {
                    group: {commands: [{json: {encode: [[{literal: "raw_idx"}]]}}]},
                    into: {var: "idx"}
                  }
                } | register(-1; $MODE.internal; nested_register) | split("\n")[])
              ]
            ) else null end
          ) catch null),
          exec: (try (
            .container.exec as $exec |
            if $exec then (
              [
                ({assign: {vars: [[{literal: "raw_idx"}]], type: "indexed", scope: "local"}} | assign($NOINDENT; $MODE.internal)),
                ({assign: {vars: [[{literal: "idx"}]], scope: "local"}} | assign($NOINDENT; $MODE.internal)),
                ({mutate: {name: {var: "raw_idx"}, type: "indexed", value: [$exec.command]}} | mutate($NOINDENT; $MODE.internal; mode)),
                ({
                  register: {
                    group: {commands: [{json: {encode: [[{literal: "raw_idx"}]]}}]},
                    into: {var: "idx"}
                  }
                } | register(-1; $MODE.internal; nested_register) | split("\n")[])
              ]
            ) else null end
          ) catch null)
        }
      };

      def traceable(level; mode; nested_register): (
        if (isempty(.[])) then (
          []
        ) else (
          def filter_core(expected_type): (
            walk(
              if (type == "object") then (
                with_entries(select((.value != null) and (.value | (type == "object" and length == 0) | not)))
              ) end
            ) | .. | select(type == expected_type)
          );

          . as $input |
          ((core(mode) | filter_core("string")) // null) as $program |
          if ($program | type == "string") then (
            {
              before: ((before_core(level; mode) | filter_core("array")) // []),
              program: ($EXE + $NAMESPACE.sep + "core" + $NAMESPACE.sep + $program),
              xtrace: $program
            }
          ) elif ($input | has("call")) then (
            {
              program: ($input | call(mode; nested_register)),
              xtrace: (($input.call.command | sanitize(mode; true)) + " " + ($input.call.args | map(sanitize(mode; true)) | join(" ")))
            }
          ) else (
            "Unknown traceable type: \"" + ($input | tostring) + "\"" | exit
          ) end | xtrace(mode) | map(indent(level))
        ) end
      );

      def deferrable(level; mode; nested_register): (
        traceable(level; mode; nested_register)
      );

      def defer(level; mode; nested_register): (
        .defer |
        deferrable(-1; mode; nested_register) | map(
          "defer '" + gsub("'"; "'\"'\"'") + "'" | indent(level)
        ) | join("\n")
      );

      def conditionable(level; mode; nested_register): (
        traceable(level; mode; nested_register)
      );

      def boolean_op(mode; nested_register): (
        if (has("not")) then (
          "{ ! " + (.not | boolean_op(mode; nested_register)) + "; }"
        ) else (
          group($NOINDENT; mode; false; false; nested_register)
        ) end
      );

      def conditional(level; mode; nested_register): (
        .if |
        if (has("then") | not) then (
          ".if used without .if.then" | exit
        ) elif (has("conditional") | not) then (
          ".if used without .if.conditional" | exit
        ) end | (
          ("if " + (.conditional | boolean_op(mode; nested_register)) + "; then ") | indent(level)
        ) + (.then | group(level; mode; true; false; nested_register)) + (
          if (has("else") and (.else | length > 0)) then (
            .else | map(
              (
                if (has("conditional") and (.conditional | length > 0)) then (
                  " elif " + (.conditional | boolean_op(mode; nested_register)) + "; then "
                ) else (
                  " else "
                ) end
              ) + (.then | group(level; mode; true; false; nested_register))
            ) | join("")
          ) else "" end
        ) + " fi"
      );

      def loop(level; mode; nested_register): (
        def loop_range(level; mode): (
          .range |
          if (has("initial") | not) then (
            ".loop.range used without .loop.range.initial" | exit
          ) elif (has("conditional") | not) then (
            ".loop.range used without .loop.range.conditional" | exit
          ) elif (has("update") | not) then (
            ".loop.range used without .loop.range.update" | exit
          ) end | (
            ("for (( " + (.initial.arithmetic | arithmetic_operator(mode)) + "; " + (.conditional.arithmetic | arithmetic_operator(mode)) + "; " + (.update.arithmetic | arithmetic_operator(mode)) + " )); do ") | indent(level)
          )
        );

        def loop_iterator(level; mode): (
          .iterator |
          if (has("name") | not) then (
            ".loop.iterator used without .loop.iterator.name" | exit
          ) elif (has("into") | not) then (
            ".loop.iterator used without .loop.iterator.into" | exit
          ) elif ((.into | has("var") | not) or (.into | has("parameter") | not) or (.into | has("last") | not)) then (
            ".loop.iterator.into should be var, parameter or special" | exit
          ) end | (
            ("for " + .name + " in " + (.into | sanitize(mode; true)) + "; do ") | indent(level)
          )
        );

        def loop_conditional(level; mode; nested_register): (
          (
            "while " + (
              .conditional | boolean_op(mode; nested_register)
            ) + "; do "
          ) | indent(level)
        );

        .loop |
        if (has("do") | not) then (
          ".loop used without .loop.do" | exit
        ) elif (.do | has("group") | not) then (
          ".loop.do used without .loop.do.group" | exit
        ) end |
        if (has("range")) then (
          loop_range(level; mode)
        ) elif (has("iterator")) then (
          loop_iterator(level; mode)
        ) elif (has("conditional")) then (
          loop_conditional(level; mode; nested_register)
        ) else (
          ".loop used without .loop.range, .loop.conditional or .loop.iterator" | exit
        ) end + (.do | group(level; mode; true; false; nested_register)) + " done"
      );

      is_unique_key_object |

      if (has("harden")) then (
        harden(level; mode)
      ) elif (has("assign")) then (
        assign(level; mode)
      ) elif (has("mutate")) then (
        mutate(level; mode; mode)
      ) elif (has("define")) then (
        define(level; mode; nested_register; true)
      ) elif (has("readonly")) then (
        readonly(level; mode)
      ) elif (has("if")) then (
        conditional(level; mode; nested_register)
      ) elif (has("loop")) then (
        loop(level; mode; nested_register)
      ) elif (has("switch")) then (
        switch(level; mode; nested_register)
      ) elif (has("defer")) then (
        defer(level; mode; nested_register)
      ) elif (has("register")) then (
        register(level; mode; nested_register)
      ) elif (has("parameters")) then (
        parameters(level; mode)
      ) elif (has("capture") or has("restore")) then (
        capture_restore(level)
      ) elif (has("on") or has("off")) then (
        on_off(level; mode)
      ) elif (has("json")) then (
        json(level; mode)
      ) elif (has("color")) then (
        color(level; mode)
      ) elif (has("source")) then (
        source(level; mode; nested_register)
      ) elif (has("arithmetic")) then (
        arithmetic(level; mode)
      ) elif (has("print")) then (
        print(level; mode)
      ) elif (has("return")) then (
        return(level)
      ) elif (has("skip")) then (
        skip(level; mode)
      ) elif (has("split")) then (
        split(level)
      ) elif (has("runner")) then (
        runner_exec(level; mode; nested_register)
      ) elif (has("group")) then (
        group(level; mode; multilined; true; nested_register)
      ) elif (has("raw")) then (
        raw(level; mode; nested_register)
      ) elif (has("coproc")) then (
        coproc(level; mode; nested_register)
      ) elif (has("initialized")) then (
        $MODE.user
      ) else (
        traceable(level; mode; nested_register) | join(if (multilined) then "\n" else "; " end)
      ) end
    );

    def redirections(mode): (
      .redirections | map(
        is_unique_key_object |
        if (has("input")) then (
          .input | "<" + (
            if (has("var")) then (
              if (.var | is_legit_varname) then ("&" + ([.] | sanitize(mode; true))) else (.var | bad_varname) end
            ) else (
              "Unknown input redirection: \"" + tostring + "\"" | exit
            ) end
          )
        ) elif (has("output")) then (
          .output |
            (.left.fd | tostring) + (
              if (.appending) then ">>" else ">" end
            ) + (
              .right |
              if (has("fd")) then (
                "&" + (.fd | tostring)
              ) elif (has("file")) then (
                " " + .file
              ) elif (has("var")) then (
                if (.var | is_legit_varname) then ("&" + ([.] | sanitize(mode; true))) else (.var | bad_varname) end
              ) else (
                "Unknown right output redirection: \"" + tostring + "\"" | exit
              ) end
            )
        ) else (
          "Unknown redirection: \"" + tostring + "\"" | exit
        ) end
      ) | join(" ")
    );

    (
      if (multilined and (nested_register | not)) then (
        {
          first: "\n",
          between: "\n",
          last: "\n"
        }
      ) else (
        {
          first: " ",
          between: "; ",
          last: "; "
        }
      ) end
    ) as $sep |

    .group as $input |
    (
      ("{" + $sep.first) | if (indent_first) then (indent(level)) end
    ) + (
      reduce .group.commands[] as $item (
        {
          mode: mode,
          output: []
        };
        . as $reduce_input |
        ($item | command(level | incr_indent_level(1); $reduce_input.mode; multilined; nested_register)) as $output |
        if ($output | type == "string") then (
          {
            mode: $reduce_input.mode,
            output: ($reduce_input.output + (if ($output | length == 0) then [] else [$output] end))
          }
        ) elif ($output | type == "number") then (
          {
            mode: $output,
            output: $reduce_input.output
          }
        ) end
      ) | .output | join($sep.between)
    ) + $sep.last + (
      (
        "}" + (
          if (.group | has("redirections")) then (
            " " + (.group | redirections(mode))
          ) else "" end
        )
      ) | indent(level)
    )
  );

  .define |
    (group(level; mode; true; true; nested_register)) as $group |
    if (user_defined and (.name | is_legit_varname | not)) then (
      bad_varname
    ) end | (
      ((if (user_defined) then $NAMESPACE.fn.user else $NAMESPACE.fn.internal end) + .name + " ()\n") | indent(level)
    ) + $group + "\n"
);
