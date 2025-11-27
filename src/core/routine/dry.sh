#! /usr/bin/env bash

___ () { #HELP <yaml_file>|Display the routine bash script without executing it
  inventory::merge () {
    local old_ifs
    old_ifs="${IFS}"
    readonly old_ifs

    json::from::yaml '.' "${1}" | json::parse 'file'
    if json::object::has 'file' '."inventory"'
    then
      json::kind::assert 'file' '."inventory"' 'object' "${FUNCNAME[1]}.${FUNCNAME[0]}"

      IFS=$'\n'
      set -f
      if not unique ${JSONKEYS_file['."inventory"']} ${JSONKEYS_inventory['."inventory"']}
      then
        set +f
        IFS="${old_ifs}"
        error 'Conflict: inventories must contain keys not already used by an other inventory'
      fi
      set +f
      IFS="${old_ifs}"

      json::object::merge 'inventory' '."inventory"' 'file' '."inventory"'
    fi
  }

  inventory::resolve::recursively () {
    local -a resolved

    while :
    do
      # 1) This loop fully relies on lastpipe and pipefail shell options.
      # 2) The goal of this loop is to resolve inventory recursively. Into
      #    'inventory' object, while there are keys that ends with
      #    '."inventory"', the loop:
      #    a) replaces these keys with the content of inventory variables
      #    b) sends error if a cycle is detected
      if print '%s\n' "${!JSONKIND_inventory[@]}" | match '.\."inventory"$' \
        | awk "${awk[quoting]}${awk[routine/inventory/resolve/recursively]}" \
        | source /proc/self/fd/0
      then
        if not unique "${resolved[@]}"
        then
          error 'Inventory cycle detected'
        fi
        continue
      fi
      break
    done
  }

  inventory::resolve::file () {
    json::object::delete 'file' '."inventory"'

    while :
    do
      # 1) This loop fully relies on lastpipe and pipefail shell options.
      # 2) The goal of this loop is to resolve inventory into 'file' object,
      #    while there are keys that ends with '."inventory"', the loop
      #    replaces these keys with the content of inventory variables
      if print '%s\n' "${!JSONKIND_file[@]}" | match '.\."inventory"$' \
        | awk "${awk[quoting]}${awk[routine/import/resolve/file]}" \
        | source /proc/self/fd/0
      then
        continue
      fi
      break
    done
  }

  import::merge () {
    if json::object::has 'file' '."import"'
    then
      json::kind::assert 'file' '."import"' 'array' "${FUNCNAME[1]}.${FUNCNAME[0]}"

      local root i
      root="$(path::dir "${1}")"

      set -f
      if not unique ${JSONVALUES_file['."import"']}
      then
        set +f
        error 'Duplicated imported file into: %s' "${1}"
      fi
      set +f

      awk -v "LENGTH=${JSONLENGTH_file['."import"']}" -v "ROOT=${root}" "${awk[quoting]}${awk[repeat]}${awk[routine/import/map-array-to-object]}" \
         | source /proc/self/fd/0

      IFS=$'\n'
      set -f
      if not unique ${JSONKEYS_file['."import"']} ${JSONKEYS_import['."import"']}
      then
        set +f
        IFS="${old_ifs}"
        error 'Conflict: import arrays must not contain files already used by an other import arrays'
      fi
      set +f
      IFS="${old_ifs}"

      json::object::merge 'import' '."import"' 'file' '."import"'

      # TODO: JSONVALUES
      # TODO: JSONLENGTH
    fi
  }

  import::resolve () {
    # TODO:
    # 2. On traverse les imports déjà résolus:
    #   1. On selectionne les imports qui viennent d'être mergés
    #   2. On parse et conserve leur contenu tout en remplaçant la valeur des clés "imported" par le chemin absolu des fichiers auquels elles correspondent
  }

  local rainbow filepath import visited
  rainbow=( '21' '27' '33' '39' '45' '51' '50' '49' '48' '47' '46' '82' '118' '154' '190' '226' '220' '214' '208' '202' '196' '197' '198' '199' '200' '201' '165' '129' '93' '57' )
  shuffle rainbow
  readonly rainbow

  local -A raw_import raw_visited # remove it later

  filepath="$(path::normalized "${1}")"
  print '{"inventory": {}}' | json::parse 'inventory'
  print '{"import": {}}' | json::parse 'import'

  while is not var "raw_visited[${filepath}]"
  do
    if is not file "${filepath}"
    then
      error 'Can not find %s' "${filepath}"
    fi

    inventory::merge "${filepath}"
    inventory::resolve::recursively
    inventory::resolve::file
    import::merge "${filepath}"
    import::resolve

    # TODO: remove jq code here

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
      ) end | ([
        .import | to_entries[] | select(.value == null) | .key |
          "if is not var \"raw_import[" + . + "]\";
           then
             raw_import[" + . + "]=\"$(
               json::from::yaml \".group |= walk(
                 if type == \\\"object\\\" then
                   with_entries(
                     if .key == \\\"imported\\\" then
                       .value |= \\\"$(path::normalized \"$(path::dir " + . + ")\")/\\\" + (. | sub(\\\"^[.]/\\\"; \\\"\\\"))
                     else . end
                   )
                 else . end
               )\" " + . + "
             )\";
           fi"
      ] | join(";"))
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

  # TODO: check routine JSON schema here

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
