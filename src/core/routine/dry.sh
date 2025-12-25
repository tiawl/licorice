#! /usr/bin/env bash

___::merge::inventory () {
  if json::object::has "${1}" '."inventory"'
  then
    json::kind::error "${1}" '."inventory"' 'object' "${FUNCNAME[1]}.${FUNCNAME[0]}"

    local -n keysref
    keysref="JSONKEYS_${1}"

    word splitting $'\n'
    on noglob
    if not unique ${keysref['."inventory"']} ${JSONKEYS_inventory['.']}
    then
      off noglob
      word splitting reset
      error 'Conflict: inventories must contain keys not already used by an other inventory'
    fi
    off noglob
    word splitting reset

    json::object::merge 'inventory' '.' "${1}" '."inventory"'
    json::object::delete "${1}" '."inventory"'
  fi
}

# The goal of these 2 functions is to resolve inventory recursively.
# Into 'inventory' object, while there are keys that ends with
# '."inventory"', the loop:
# a) replaces these keys with the content of inventory variables
# b) sends error if a cycle is detected
___::resolve::inventory::into::inventory::rec () {
  word splitting reset
  json::kind::error 'inventory' "${1}" 'string' "${FUNCNAME[0]}"
  json::object::set 'inventory' "${2}" 'inventory' '.'"${3}"
  "${FUNCNAME[0]%::rec}" "${@:4}" "${3}"
}

___::resolve::inventory::into::inventory () {
  if not unique "${@}"
  then
    error 'Inventory cycle detected'
  fi

  # This loop fully relies on lastpipe and pipefail shell options.
  word splitting $'\n'
  {
    match '\."inventory"$' \
      | awk "${awk[quoting]}${awk[routine/inventory/resolve/inventory]}" \
      | source /proc/self/fd/0
  } <<< "${!JSONKIND_inventory[@]}" || :
  word splitting reset
}

___::resolve::inventory () {
  while gt "${#}" '0'
  do
    local -n kindref
    kindref="JSONKIND_${1}"

    word splitting $'\n'
    # 1) This loop fully relies on lastpipe and pipefail shell options.
    # 2) The goal of this loop is to resolve inventory into 'file' object,
    #    while there are keys that ends with '."inventory"', the loop
    #    replaces these keys with the content of inventory variables
    while { {
      match '\."inventory"$' \
        | awk -v "HEX=${1}" "${awk[quoting]}${awk[routine/inventory/resolve/file]}" \
        | source /proc/self/fd/0
    } <<< "${!kindref[@]}"; } do :; done
    word splitting reset

    shift
    unset -n kindref
  done
}

___::merge::import () {
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

    on noglob
    if not unique ${valref['."import"']}
    then
      off noglob
      error 'Duplicated imported file into: %s' "${2}"
    fi
    off noglob

    # This loop fully relies on lastpipe shell option
    awk -v "LENGTH=${lenref['."import"']}" -v "ROOT=${root}" -v "HEX=${1}" "${awk[quoting]}${awk[repeat]}${awk[routine/import/map-array-to-object]}" \
       | source /proc/self/fd/0

    word splitting $'\n'
    on noglob
    if not unique ${keysref['."import"']} ${JSONKEYS_import['.']}
    then
      off noglob
      word splitting reset
      error 'Conflict: import arrays must not contain files already used by an other import arrays'
    fi
    off noglob
    word splitting reset

    json::object::merge 'import' '.' "${1}" '."import"'
    json::object::delete "${1}" '."import"'
  fi
}

___::resolve::import () {
  : TODO
  # local -n kindref
  # kinfref="JSONKIND_${1}"

  # word splitting $'\n'
  # while { {
  #   match '\."imported"$' \
  #     | awk "${awk[quoting]}${awk[routine/import/resolve]}" \
  #     | source /proc/self/fd/0
  # } <<< "${!kindref[@]}"; } do
  #   word splitting reset
  #   if not unique "${resolved[@]}"
  #   then
  #     error 'Import cycle detected'
  #   fi
  # done
  # word splitting reset
}

___::resolve () {
  local filepath
  local -A hex
  filepath="$(path::normalized "${1}")"
  json::parse 'inventory' <<< '{}'
  json::parse 'import' <<< '{}'

  while str not empty "${filepath}"
  do
    if is not file "${filepath}" && is not pipe "${filepath}"
    then
      error 'Can not find %s' "${filepath}"
    fi

    # This loop fully relies on lastpipe shell option
    {
      awk -v "KEY=${filepath}" "${awk[quoting]}${awk[str2hex]}" \
        | source /proc/self/fd/0
    } <<< "${filepath}"

    json::parse "${filepath}" "${hex["${filepath}"]}"
    "${FUNCNAME[0]%::resolve}"::merge::inventory "${hex["${filepath}"]}"
    "${FUNCNAME[0]%::resolve}"::merge::import "${hex["${filepath}"]}" "${filepath}"

    if json::object::has 'import' ".\"${filepath}\""
    then
      JSONGET_import[".\"${filepath}\""]='true'
      JSONVALUES_import['.']="${JSONVALUES_import[".\"${filepath}\""]/false/true}"
    fi

    # It keeps the first unvisited imported filepath (if there are not, it's an empty string)
    filepath="$(
      word splitting $'\n'
      awk '{IMPORTS[(NR-1)]=$0} END {for (i = NR/2; i <= NR; i++) {if (IMPORTS[i] == "false") {print IMPORTS[(i - (NR/2))]; exit}}}' \
        <<< "${JSONKEYS_import['.']}" "${JSONVALUES_import['.']}"
    )"
  done

  "${FUNCNAME[0]}"::inventory::into::inventory
  "${FUNCNAME[0]}"::inventory "${hex[@]}"
  "${FUNCNAME[0]}"::import
}

___ () { #HELP <yaml_file>|Display the routine bash script without executing it
  local -a rainbow
  rainbow=( '21' '27' '33' '39' '45' '51' '50' '49' '48' '47' '46' '82' '118' '154' '190' '226' '220' '214' '208' '202' '196' '197' '198' '199' '200' '201' '165' '129' '93' '57' )
  shuffle rainbow
  readonly rainbow

  "${FUNCNAME[0]}"::resolve "${1}"
  # TODO: check routine JSON schema
  # TODO: codegen
}
