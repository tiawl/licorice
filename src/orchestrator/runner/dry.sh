#! /usr/bin/env bash

runner_dry () { #HELP <yaml_file>|Display the runner bash script without executing it
  shift

  local rainbow filepath json inv import
  local -A visited
  rainbow=( '21' '27' '33' '39' '45' '51' '50' '49' '48' '47' '46' '82' '118' '154' '190' '226' '220' '214' '208' '202' '196' '197' '198' '199' '200' '201' '165' '129' '93' '57' )

  shuffle rainbow
  readonly rainbow

  filepath="$(normalizedpath "${1}")"

  while is not var "visited[${filepath}]"
  do
    if is not file "${filepath}"
    then
      error 'Can not find %s' "${filepath}"
    fi

    json="$(gojq --yaml-input --raw-output --monochrome-output --compact-output '.' "${filepath}")"
    inv="$(gojq --null-input --raw-output --monochrome-output --compact-output --argjson JSON "${json}" --argjson INV "${inv:-"{\"inventory\": {}}"}" '
      $JSON |
      if (has("inventory")) then (
        if (.inventory | keys | any(IN($INV.inventory | keys[]))) then (
          "Conflicting inventories\n" | halt_error(1)
        ) else (
          {inventory} * $INV
        ) end
      ) else (
        $INV
      ) end
    ')"
    json="$(gojq --null-input --raw-output --monochrome-output --compact-output --argjson JSON "${json}" --argjson INV "${inv}" '$JSON * $INV | '"${jq[yml2bash/common]}${jq[yml2bash/process_inventory]}")"

    local -A import
    source /proc/self/fd/0 <<< "$(gojq --null-input --raw-output --monochrome-output --compact-output --argjson JSON "${json}" --argjson IMPORT "{\"import\": ${import:-"{}"}}" --arg ROOT "$(dirname "${filepath}")/" '
      $JSON |
      if (has("import")) then (
        {import: (.import | map({($ARGS.named.ROOT + .): null}) | add)} |
        if (keys | any(IN($IMPORT.import | keys[]))) then (
          "Conflicting import\n" | halt_error(1)
        ) else (
          . * $IMPORT
        ) end
      ) else (
        $IMPORT
      ) end | "import=( " + ([.import | keys[] | "[" + . + "]=\"$(gojq --yaml-input --raw-output --monochrome-output --compact-output \"walk(if type == \\\"object\\\" then with_entries(if .key == \\\"imported\\\" then .value |= \\\"" + $ARGS.named.ROOT + "\\\" + (. | sub(\\\"^[.]/\\\"; \\\"\\\")) else . end) else . end)\" " + . + ")\""] | join(" ")) + " )"
    ')"
    assoc2json import

    visited["${filepath}"]='true'
    assoc2json visited
    filepath="$(normalizedpath "$(gojq --null-input --raw-output --monochrome-output --compact-output --argjson IMPORT "{\"import\": ${import}}" --argjson VISITED "${visited}" '[[$IMPORT.import, $VISITED][] | keys] | [.[0] - .[1], .[1] - .[0]] | add | unique[0] // empty')")"
  done

  readonly inv import

  gojq --raw-output "${jq[yml2bash/common]}${jq[yml2bash/write_script]}" --args "${rainbow[@]}" --arg env "$(declare -f init load_resources "${fns[@]}")" \
    <<< "$(gojq --yaml-input --raw-output --monochrome-output --compact-output --arg ROOT "$(normalizedpath "$(dirname "${1}")")/" --argjson INV "${inv}" --argjson IMPORT "{\"import\": ${import}}" '. * $IMPORT * $INV | '"${jq[yml2bash/common]}${jq[yml2bash/process_inventory]}"' | .group |= walk(if type == "object" then with_entries(if .key == "imported" then .value |= $ARGS.named.ROOT + (. | sub("^[.]/"; "")) else . end) else . end)' "${1}")"
}
