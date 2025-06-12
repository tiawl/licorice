#! /usr/bin/env bash

runner_dry () { #HELP <yaml_file>|Display the runner bash script without executing it
  shift

  local rainbow processed_inv
  rainbow=( '21' '27' '33' '39' '45' '51' '50' '49' '48' '47' '46' '82' '118' '154' '190' '226' '220' '214' '208' '202' '196' '197' '198' '199' '200' '201' '165' '129' '93' '57' )

  shuffle rainbow
  readonly rainbow

  local yml
  yml="${1}"
  if is not file "${yml}"
  then
    yml="${PWD:-"$(pwd)"}/${yml}"
  fi
  if is not file "${yml}"
  then
    error 'Can not find %s' "${1}"
  fi

  processed_inv="$(gojq --yaml-input --raw-output "${jq[yml2bash/common]}${jq[yml2bash/process_inventory]}" "${yml}")"
  readonly processed_inv

  local -A import
  source /proc/self/fd/0 <<< "$(gojq --yaml-input --raw-output '"import=( " + ([.import[] | "[" + . + "]=\"$(gojq --yaml-input --raw-output \".\" " + $ARGS.named.dir + "/" + . + ")\""] | join(" ")) + " )"' --arg dir "$(dirname "${yml}")" <<< "${processed_inv}")"
  assoc2json import
  readonly import

  gojq --raw-output "${jq[yml2bash/common]}${jq[yml2bash/write_script]}" --args "${rainbow[@]}" --arg env "$(declare -f init load_resources "${fns[@]}")" \
    <<< "$(gojq --null-input --raw-output "${processed_inv} + {import: (${import} | tostring | fromjson)}")"
}
