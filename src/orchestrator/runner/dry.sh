#! /usr/bin/env bash

runner_dry () { #HELP <yaml_file>|Display the runner bash script without executing it
  shift

  local rainbow filepath json inv import visited
  local -A raw_import raw_visited
  rainbow=( '21' '27' '33' '39' '45' '51' '50' '49' '48' '47' '46' '82' '118' '154' '190' '226' '220' '214' '208' '202' '196' '197' '198' '199' '200' '201' '165' '129' '93' '57' )

  shuffle rainbow
  readonly rainbow

  filepath="$(normalizedpath "${1}")"

  while is not var "raw_visited[${filepath}]"
  do
    if is not file "${filepath}"
    then
      error 'Can not find %s' "${filepath}"
    fi

    json="$(gojq --yaml-input --raw-output --monochrome-output --compact-output '.' "${filepath}")"
    inv="$(gojq --null-input --raw-output --monochrome-output --compact-output --slurpfile JSON <(printf '%s' "${json}") --slurpfile INV <(printf '%s' "${inv:-"{\"inventory\": {}}"}") "${jq[yml2bash/common]}"'
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
    json="$(gojq --null-input --raw-output --monochrome-output --compact-output --slurpfile JSON <(printf '%s' "${json}") --slurpfile INV <(printf '%s' "${inv}") '
      (if ($JSON | type == "array") then $JSON[0] else $JSON end) as $JSON |
      (if ($INV | type == "array") then $INV[0] else $INV end) as $INV |
      $JSON * $INV | '"${jq[yml2bash/common]}${jq[yml2bash/process_inventory]}")"

    source /proc/self/fd/0 <<< "$(gojq --null-input --raw-output --monochrome-output --compact-output --slurpfile JSON <(printf '%s' "${json}") --slurpfile IMPORT <(printf '{"import": %s}' "${import:-"{}"}") --arg ROOT "$(dirname "${filepath}")/" "${jq[yml2bash/common]}"'
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
      ) end | ([.import | to_entries[] | select(.value == null) | .key | "if is not var \"raw_import[" + . + "]\"; then raw_import[" + . + "]=\"$(gojq --yaml-input --raw-output --monochrome-output --compact-output \".group |= walk(if type == \\\"object\\\" then with_entries(if .key == \\\"imported\\\" then .value |= \\\"$(normalizedpath \"$(dirname " + . + ")\")/\\\" + (. | sub(\\\"^[.]/\\\"; \\\"\\\")) else . end) else . end)\" " + . + ")\"; fi"] | join(";"))
    ')"
    import="$(json encode raw_import)"

    raw_visited["${filepath}"]='true'
    visited="$(json encode raw_visited)"
    filepath="$(normalizedpath "$(gojq --null-input --raw-output --monochrome-output --compact-output --slurpfile IMPORT <(printf '{"import": %s}' "${import}") --slurpfile VISITED <(printf '%s' "${visited}") '
      (if ($VISITED | type == "array") then $VISITED[0] else $VISITED end) as $VISITED |
      (if ($IMPORT | type == "array") then $IMPORT[0] else $IMPORT end) as $IMPORT |
      [[$IMPORT.import, $VISITED][] | keys] | [.[0] - .[1], .[1] - .[0]] | add | unique[0] // empty')")"
  done

  readonly inv import

  gojq --raw-output "${jq[yml2bash/common]}${jq[yml2bash/write_script]}" --rawfile env <(declare -f init load_resources "${fns[@]}") --args -- "${rainbow[@]}" \
    <<< "$(gojq --yaml-input --raw-output --monochrome-output --compact-output --arg ROOT "$(normalizedpath "$(dirname "${1}")")/" --slurpfile INV <(printf '%s' "${inv}") --slurpfile IMPORT <(printf '{"import": %s}' "${import}") '
            (if ($IMPORT | type == "array") then $IMPORT[0] else $IMPORT end) as $IMPORT |
            (if ($INV | type == "array") then $INV[0] else $INV end) as $INV |
            . * $IMPORT * $INV | '"${jq[yml2bash/common]}${jq[yml2bash/process_inventory]}"' |
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
