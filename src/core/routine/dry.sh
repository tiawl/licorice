#! /usr/bin/env bash

___ () { #HELP <yaml_file>|Display the routine bash script without executing it
  local rainbow filepath json inv import visited
  local -A raw_import raw_visited
  rainbow=( '21' '27' '33' '39' '45' '51' '50' '49' '48' '47' '46' '82' '118' '154' '190' '226' '220' '214' '208' '202' '196' '197' '198' '199' '200' '201' '165' '129' '93' '57' )

  shuffle rainbow
  readonly rainbow

  filepath="$(path::normalized "${1}")"

  while is not var "raw_visited[${filepath}]"
  do
    if is not file "${filepath}"
    then
      error 'Can not find %s' "${filepath}"
    fi

    # TODO: refactore and gather slurpfiles
    json="$(json::from::yaml '.' "${filepath}")"
    inv="$(json::program --slurpfile ROUTINE_JSON <(print '%s' "${json}") --slurpfile ROUTINE_INV <(print '%s' "${inv:-"{\"inventory\": {}}"}") "${jq[routine/common]}"'
      (if ($ROUTINE_JSON | type == "array") then $ROUTINE_JSON[0] else $ROUTINE_JSON end) as $ROUTINE_JSON |
      (if ($ROUTINE_INV | type == "array") then $ROUTINE_INV[0] else $ROUTINE_INV end) as $ROUTINE_INV |
      $ROUTINE_JSON |
      if (has("inventory")) then (
        if (.inventory | keys | any(IN($ROUTINE_INV.inventory | keys[]))) then (
          "Conflicting inventories" | exit
        ) else (
          {inventory} * $ROUTINE_INV
        ) end
      ) else (
        $ROUTINE_INV
      ) end
    ')"
    json="$(json::program --slurpfile ROUTINE_JSON <(print '%s' "${json}") --slurpfile ROUTINE_INV <(print '%s' "${inv}") '
      (if ($ROUTINE_JSON | type == "array") then $ROUTINE_JSON[0] else $ROUTINE_JSON end) as $ROUTINE_JSON |
      (if ($ROUTINE_INV | type == "array") then $ROUTINE_INV[0] else $ROUTINE_INV end) as $ROUTINE_INV |
      $ROUTINE_JSON * $ROUTINE_INV | '"${jq[routine/common]}${jq[routine/replacer]}")"

    source /proc/self/fd/0 <<< "$(json::program --slurpfile ROUTINE_JSON <(print '%s' "${json}") --slurpfile ROUTINE_IMPORT <(print '{"import": %s}' "${import:-"{}"}") --arg ROOT "$(path::dir "${filepath}")/" "${jq[routine/common]}"'
      (if ($ROUTINE_JSON | type == "array") then $ROUTINE_JSON[0] else $ROUTINE_JSON end) as $ROUTINE_JSON |
      (if ($ROUTINE_IMPORT | type == "array") then $ROUTINE_IMPORT[0] else $ROUTINE_IMPORT end) as $ROUTINE_IMPORT |
      $ROUTINE_JSON |
      if (has("import")) then (
        {import: (.import | map({($ARGS.named.ROOT + .): null}) | add)} as $json_import |
        if (keys | any(IN($ROUTINE_IMPORT.import | keys[]))) then (
          "Conflicting import" | exit
        ) else (
          ($json_import * $ROUTINE_IMPORT)
        ) end
      ) else (
        $ROUTINE_IMPORT
      ) end | ([.import | to_entries[] | select(.value == null) | .key | "if is not var \"raw_import[" + . + "]\"; then raw_import[" + . + "]=\"$(json::from::yaml \".group |= walk(if type == \\\"object\\\" then with_entries(if .key == \\\"imported\\\" then .value |= \\\"$(path::normalized \"$(path::dir " + . + ")\")/\\\" + (. | sub(\\\"^[.]/\\\"; \\\"\\\")) else . end) else . end)\" " + . + ")\"; fi"] | join(";"))
    ')"
    import="$(json::encode raw_import)"

    raw_visited["${filepath}"]='true'
    visited="$(json::encode raw_visited)"
    filepath="$(path::normalized "$(json::program --slurpfile ROUTINE_IMPORT <(print '{"import": %s}' "${import}") --slurpfile ROUTINE_VISITED <(print '%s' "${visited}") '
      (if ($ROUTINE_VISITED | type == "array") then $ROUTINE_VISITED[0] else $ROUTINE_VISITED end) as $ROUTINE_VISITED |
      (if ($ROUTINE_IMPORT | type == "array") then $ROUTINE_IMPORT[0] else $ROUTINE_IMPORT end) as $ROUTINE_IMPORT |
      [[$ROUTINE_IMPORT.import, $ROUTINE_VISITED][] | keys] | [.[0] - .[1], .[1] - .[0]] | add | unique[0] // empty')")"
  done

  readonly inv import

  json::filter "${jq[routine/common]}${jq[routine/types]}${jq[routine/codegen]}${jq[routine/writer]}" --arg NAMESPACE_SEP "${sep[namespace]}" --arg EXE "${exe}" --arg BACKEND "${backend}" --rawfile FUNCTIONS <(declare -f "${fns[@]}") --args -- "${rainbow[@]}" \
    <<< "$(json::from::yaml --arg ROOT "$(path::normalized "$(path::dir "${1}")")/" --slurpfile ROUTINE_INV <(print '%s' "${inv}") --slurpfile ROUTINE_IMPORT <(print '{"import": %s}' "${import}") '
            (if ($ROUTINE_IMPORT | type == "array") then $ROUTINE_IMPORT[0] else $ROUTINE_IMPORT end) as $ROUTINE_IMPORT |
            (if ($ROUTINE_INV | type == "array") then $ROUTINE_INV[0] else $ROUTINE_INV end) as $ROUTINE_INV |
            . * $ROUTINE_IMPORT * $ROUTINE_INV | '"${jq[routine/common]}${jq[routine/replacer]}"' |
            .group |= walk(
              if (type == "object") then (
                with_entries(
                  if (.key == "imported") then (
                    .value |= $ARGS.named.ROOT + (. | sub("^[.]/"; ""))
                  ) else . end
                )
              ) else . end
            )' "${1}")"
}
