#! /usr/bin/env bash

shebangless () {
  sed '/^#\s*!/{:loop;N;s/.*\n$//;t loop;s/^\n\+//}' "${@}"
}

compile () {
  on errexit inherit_errexit errtrace functrace noclobber nounset pipefail lastpipe extglob

  bash_setup

  harden base64
  harden cat
  harden git
  harden mkdir
  harden rm
  harden sed

  local name len_cmd src cmd desc
  local -a help split
  name='placid'
  namespace[root]="${name}${sep[namespace]}"
  namespace[internal]="${namespace[root]}internal${sep[namespace]}"
  namespace[core]="${namespace[root]}core${sep[namespace]}"
  version["${name}"]="$(git -C "${SDIR}" describe --match *.*.* --tags --abbrev=9)"
  version["${name}"]="${version["${name}"]%-*}"
  version["${name}"]="${version["${name}"]%\.*}.${version["${name}"]##*[-.]}"

  on globstar
  for src in "${SDIR}/src/core"/**/*.sh
  do
    if is file "${src}"
    then
      cmd="${src#"${SDIR}/src/core/"}"
      cmd="${cmd%.sh}"
      desc="$(sed -n 's/^\s*___\s*()\s*{\s*#HELP/'"${cmd//\// }"'/p' "${src}")"
      if str not empty "${desc:-}"
      then
        help+=( "${desc}" )
      fi
    fi
  done
  off globstar

  len_cmd='0'
  for desc in "${help[@]}"
  do
    mapfile -t -d '|' split <<< "${desc}"
    len_cmd="$(( ${#split[0]} > ${len_cmd} ? ${#split[0]} : ${len_cmd} ))"
  done

  readonly name help len_cmd

  rm -rf "${SDIR}/bin"
  mkdir -p "${SDIR}/bin"
  off noclobber
  cat <<EOF > "${SDIR}/bin/${name}"
#! /usr/bin/env bash

$(exec -c bash --noprofile --norc -O extglob -c '
    source "${1}"/src/utils.sh
    on globstar
    for src in "${1}"/src/core/**/*.sh
    do
      if is file "${src}"
      then
        source "${src}"
        def="$(declare -f ___)"
        funcname="${src#"${1}/src/core/"}"
        funcname="${funcname%.sh}"
        source /proc/self/fd/0 <<< "${2}${funcname//\//"${3}"}${def#___}"
        unset -f ___
      fi
    done
    declare -f
  ' -- "${SDIR}" "${namespace[core]}" "${sep[namespace]}")

${namespace[root]}version () {
  printf '${name} ${version["${name}"]}\n' >&2
}

${namespace[root]}help () {
  cut_line () {
    local cols
    cols="\${COLUMNS}"
    if ge "\${#1}" "\${COLUMNS}"
    then
      set -- "\${1}" "\${1:0:\${COLUMNS}}"
      set -- "\${1}" "\${2% *}"
      if gt "\${#2}" "\$(( ${len_cmd} + 9 ))" && lt "\${#2}" "\${COLUMNS}"
      then
        cols="\$(( \${#2} + 1 ))"
      fi
    fi
    printf '%s\\n' "\${_buf:0:\${cols}}"
    _buf="\${_buf:\${cols}}"
  }

  on checkwinsize

  # (:;:) is a micro sleep to ensure the variables are exported immediately.
  (:;:)

  local desc _buf
  local -a split

  ${namespace[root]}version

  printf '\nCOMMANDS:\n' >&2
  ${help[@]@A}
  for desc in "\${help[@]}"
  do
    mapfile -t -d '|' split <<< "\${desc}"
    if gt "\${COLUMNS}" "\$(( ${len_cmd} + 9 ))"
    then
      printf -v _buf -- '        %-${len_cmd}s %s' "\${split[0]}" "\${split[1]%$'\n'}"
      cut_line "\${_buf}"
      while gt "\${#_buf}" '0'
      do
        printf -v _buf '        %${len_cmd}s %s' '' "\${_buf}"
        cut_line "\${_buf}"
      done
    else
      printf '\t%s\t%s' "\${split[0]}" "\${split[1]}"
    fi
  done >&2

  off checkwinsize
  unset -f cut_line
}

${namespace[internal]}load_resources () {
  global -A sed jq buf
  global -a fns
$(on globstar
  for dir in sed jq
  do
    for entry in "${SDIR}/${dir}"/**/*
    do
      if is file "${entry}"
      then
        key="${entry#"${SDIR}/${dir}/"}"
        key="${key%".${dir}"}"
        printf '  %s[%s]=%s\n' "${dir}" "${key}" "'$(shebangless "${entry}" | sed "s/'/'\"'\"'/g")'"
      fi
    done
  done
  for entry in "${SDIR}/buf/vendor"/**/*
  do
    if is file "${SDIR}/buf/descriptor_sets/$(basename "${entry}")"
    then
      printf '  buf[descriptor_set_%s]=%s\n' "$(basename "${entry}" '.proto')" "'$(base64 --wrap 0 "${SDIR}/buf/descriptor_sets/$(basename "${entry}")")'"
      printf '  buf[vendor_%s]=%s\n' "$(basename "${entry}" '.proto')" "'$(sed "s/'/'\"'\"'/g" "${entry}")'"
    fi
  done)

  fns=( $(exec -c bash --noprofile --norc -c "source ${SDIR}/src/utils.sh; compgen -A function") \$(compgen -A function -X '!(${namespace[core]}*|${namespace[internal]}*)') )
  namespace=(${namespace[@]@K})
  version=(${version[@]@K})
  readonly sed jq buf fns
}

${name} () {
  if is not var '${name^^}_REEXEC_WITH_EMPTY_ENV'
  then
    \\command exec -c env --ignore-environment BASH="\${BASH:-}" ${name^^}_REEXEC_WITH_EMPTY_ENV='yes' bash --norc --noprofile "\${BASH_SOURCE[0]}" "\${@}" || \\command exit 1
  fi

  on errexit inherit_errexit errtrace functrace noclobber nounset pipefail lastpipe extglob

  bash_setup

  ${namespace[internal]}load_resources

  ${namespace[core]}init

  case "\${1:-}" in
  ( help|version ) "${namespace[root]}\${1}" "\${@:2}" ;;
  ( image|container|network|volume|runner ) "${namespace[core]}\${1}" "\${@:2}" ;;
  ( * ) ${namespace[root]}help ;;
  esac
}

${name} "\${@}"
EOF
  chmod 0700 "${SDIR}/bin/${name}"
}

compile "${@}"
