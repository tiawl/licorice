#! /usr/bin/env bash

___ () { #HELP <yaml_file>|Display the routine bash script without executing it
  inventory::merge () {
    if json::object::has "${1}" '."inventory"'
    then
      json::kind::error "${1}" '."inventory"' 'object' "${FUNCNAME[1]}.${FUNCNAME[0]}"

      local old_ifs
      old_ifs="${IFS}"
      readonly old_ifs

      local -n keysref
      keysref="JSONKEYS_${1}"

      IFS=$'\n'
      set -f
      if not unique ${keysref['."inventory"']} ${JSONKEYS_inventory['."inventory"']}
      then
        set +f
        IFS="${old_ifs}"
        error 'Conflict: inventories must contain keys not already used by an other inventory'
      fi
      set +f
      IFS="${old_ifs}"

      json::object::merge 'inventory' '."inventory"' "${1}" '."inventory"'
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
    json::object::delete "${1}" '."inventory"'

    local -n kindref
    kindref="JSONKIND_${1}"

    while :
    do
      # 1) This loop fully relies on lastpipe and pipefail shell options.
      # 2) The goal of this loop is to resolve inventory into 'file' object,
      #    while there are keys that ends with '."inventory"', the loop
      #    replaces these keys with the content of inventory variables
      if print '%s\n' "${!kindref[@]}" | match '.\."inventory"$' \
        | awk -v "HEX=${1}" "${awk[quoting]}${awk[routine/import/resolve/file]}" \
        | source /proc/self/fd/0
      then
        continue
      fi
      break
    done
  }

  import::merge () {
    if json::object::has "${1}" '."import"'
    then
      json::kind::error "${1}" '."import"' 'array' "${FUNCNAME[1]}.${FUNCNAME[0]}"

      local -n lenref valref keysref
      lenref="JSONLENGTH_${1}"
      valref="JSONVALUES_${1}"
      keysref="JSONKEYS_${1}"

      local root i
      for (( i = 0; i < lenref['."import"']; i++ ))
      do
        json::kind::error "${1}" ".\"import\".${i}" 'string' "${FUNCNAME[1]}.${FUNCNAME[0]}"
      done

      root="$(path::dir "${2}")"

      set -f
      if not unique ${valref['."import"']}
      then
        set +f
        error 'Duplicated imported file into: %s' "${2}"
      fi
      set +f

      # This loop fully relies on lastpipe shell option
      awk -v "LENGTH=${lenref['."import"']}" -v "ROOT=${root}" -v "HEX=${1}" "${awk[quoting]}${awk[repeat]}${awk[routine/import/map-array-to-object]}" \
         | source /proc/self/fd/0

      IFS=$'\n'
      set -f
      if not unique ${keysref['."import"']} ${JSONKEYS_import['."import"']}
      then
        set +f
        IFS="${old_ifs}"
        error 'Conflict: import arrays must not contain files already used by an other import arrays'
      fi
      set +f
      IFS="${old_ifs}"

      json::object::merge 'import' '."import"' "${1}" '."import"'
    fi
  }

  local filepath
  local -a rainbow
  local -A hex
  rainbow=( '21' '27' '33' '39' '45' '51' '50' '49' '48' '47' '46' '82' '118' '154' '190' '226' '220' '214' '208' '202' '196' '197' '198' '199' '200' '201' '165' '129' '93' '57' )
  shuffle rainbow
  readonly rainbow

  filepath="$(path::normalized "${1}")"
  print '{"inventory": {}}' | json::parse 'inventory'
  print '{"import": {}}' | json::parse 'import'

  while str not empty "${filepath}"
  do
    if is not file "${filepath}"
    then
      error 'Can not find %s' "${filepath}"
    fi

    str hex "${filepath}"
    json::from::yaml '.' "${filepath}" | json::parse "${hex["${filepath}"]}"
    inventory::merge "${hex["${filepath}"]}"
    import::merge "${hex["${filepath}"]}" "${filepath}"

    if json::object::has 'import' ".\"import\".\"${filepath}\""
    then
      JSONGET_import[".\"import\".\"${filepath}\""]="$(< "${filepath}")"
      JSONKIND_import[".\"import\".\"${filepath}\""]='string'
      # TODO: how to change JSONVALUES_import here ?
      # (declare -a t; i=2; VALUES=$'ww\nee\nrr\ntt'; IFS=$'\n'; t=( $VALUES ); t[$i]=vbvb; echo "${t[*]}")
    fi

    # It keeps the first unvisited imported filepath (if there are not, it's an empty string)
    filepath="$(
      set -f
      IFS=$'\n'
      printf '%s\n' ${JSONKEYS_import['."import"']} ${JSONVALUES_import['."import"']} \
        | awk '{IMPORTS[(NR-1)]=$0} END {for (i = NR/2; i <= NR; i++) {if (IMPORTS[i] == "null") {print IMPORTS[(i - (NR/2))]; exit}}}'
    )"
  done

  inventory::resolve::recursively
  # TODO: inventory::resolve::imports
  # TODO: import::resolve::main
  inventory::resolve::main # inventory::resolve::file "${hex}" ??

  # TODO: check routine JSON schema
  # TODO: codegen
}
