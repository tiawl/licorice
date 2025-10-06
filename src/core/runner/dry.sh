#! /usr/bin/env bash

___ () { #HELP <yaml_file>|Display the runner bash script without executing it
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

    json="$(json::from::yaml '.' "${filepath}")"
    inv="$(json::program --slurpfile JSON <(print '%s' "${json}") --slurpfile INV <(print '%s' "${inv:-"{\"inventory\": {}}"}") "${jq[yml2bash/common]}"'
      (if ($JSON | type == "array") then $JSON[0] else $JSON end) as $JSON |
      (if ($INV | type == "array") then $INV[0] else $INV end) as $INV |
      $JSON |
      if (has("inventory")) then (
        if (.inventory | keys | any(IN($INV.inventory | keys[]))) then (
          "Conflicting inventories" | exit
        ) else (
          {inventory} * $INV
        ) end
      ) else (
        $INV
      ) end
    ')"
    json="$(json::program --slurpfile JSON <(print '%s' "${json}") --slurpfile INV <(print '%s' "${inv}") '
      (if ($JSON | type == "array") then $JSON[0] else $JSON end) as $JSON |
      (if ($INV | type == "array") then $INV[0] else $INV end) as $INV |
      $JSON * $INV | '"${jq[yml2bash/common]}${jq[yml2bash/replacer]}")"

    source /proc/self/fd/0 <<< "$(json::program --slurpfile JSON <(print '%s' "${json}") --slurpfile IMPORT <(print '{"import": %s}' "${import:-"{}"}") --arg ROOT "$(path::dir "${filepath}")/" "${jq[yml2bash/common]}"'
      (if ($JSON | type == "array") then $JSON[0] else $JSON end) as $JSON |
      (if ($IMPORT | type == "array") then $IMPORT[0] else $IMPORT end) as $IMPORT |
      $JSON |
      if (has("import")) then (
        {import: (.import | map({($ARGS.named.ROOT + .): null}) | add)} as $json_import |
        if (keys | any(IN($IMPORT.import | keys[]))) then (
          "Conflicting import" | exit
        ) else (
          ($json_import * $IMPORT)
        ) end
      ) else (
        $IMPORT
      ) end | ([.import | to_entries[] | select(.value == null) | .key | "if is not var \"raw_import[" + . + "]\"; then raw_import[" + . + "]=\"$(json::from::yaml \".group |= walk(if type == \\\"object\\\" then with_entries(if .key == \\\"imported\\\" then .value |= \\\"$(path::normalized \"$(path::dir " + . + ")\")/\\\" + (. | sub(\\\"^[.]/\\\"; \\\"\\\")) else . end) else . end)\" " + . + ")\"; fi"] | join(";"))
    ')"
    import="$(json::encode raw_import)"

    raw_visited["${filepath}"]='true'
    visited="$(json::encode raw_visited)"
    filepath="$(path::normalized "$(json::program --slurpfile IMPORT <(print '{"import": %s}' "${import}") --slurpfile VISITED <(print '%s' "${visited}") '
      (if ($VISITED | type == "array") then $VISITED[0] else $VISITED end) as $VISITED |
      (if ($IMPORT | type == "array") then $IMPORT[0] else $IMPORT end) as $IMPORT |
      [[$IMPORT.import, $VISITED][] | keys] | [.[0] - .[1], .[1] - .[0]] | add | unique[0] // empty')")"
  done

  readonly inv import

  json::filter "${jq[yml2bash/common]}${jq[yml2bash/types]}${jq[yml2bash/codegen]}${jq[yml2bash/writer]}" --arg NAMESPACE_SEP "${sep[namespace]}" --arg EXE "${exe}" --arg BACKEND "${backend}" --rawfile FUNCTIONS <(declare -f "${fns[@]}") --args -- "${rainbow[@]}" \
    <<< "$(json::from::yaml --arg ROOT "$(path::normalized "$(path::dir "${1}")")/" --slurpfile INV <(print '%s' "${inv}") --slurpfile IMPORT <(print '{"import": %s}' "${import}") '
            (if ($IMPORT | type == "array") then $IMPORT[0] else $IMPORT end) as $IMPORT |
            (if ($INV | type == "array") then $INV[0] else $INV end) as $INV |
            . * $IMPORT * $INV | '"${jq[yml2bash/common]}${jq[yml2bash/replacer]}"' |
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
