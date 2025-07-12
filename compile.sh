#! /usr/bin/env bash

shebangless () {
  sed '/^#\s*!/{:loop;N;s/.*\n$//;t loop;s/^\n\+//}' "${@}"
}

compile () {
  on errexit inherit_errexit errtrace functrace noclobber nounset pipefail lastpipe extglob

  harden base64
  harden cat
  harden git
  harden mkdir
  harden rm
  harden sed

  local exe len_cmd src cmd desc
  local -a help split
  local -A sep path namespace version

  exe='placid'
  sep[namespace]='::'
  sep[image]='/'
  sep[tag]=':'
  sep[container]='-'
  sep[network]='-'
  sep[volume]='_'
  path[docker_socket]='/var/run/docker.sock'
  namespace[root]="${exe}${sep[namespace]}"
  namespace[core]="${namespace[root]}core${sep[namespace]}"
  namespace[containerd]="${namespace[root]}containerd${sep[namespace]}"
  namespace[docker]="${namespace[root]}docker${sep[namespace]}"
  namespace[podman]="${namespace[root]}podman${sep[namespace]}"
  version[docker_api]='v1.51'
  version["${exe}"]="$(git -C "${SDIR}" describe --match *.*.* --tags --abbrev=9)"
  version["${exe}"]="${version["${exe}"]%-*}"
  version["${exe}"]="${version["${exe}"]%\.*}.${version["${exe}"]##*[-.]}"

  readonly sep

  on globstar
  for src in "${SDIR}/src/docker"/**/*.sh
  do
    if is file "${src}"
    then
      cmd="${src#"${SDIR}/src/docker/"}"
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

  readonly exe help len_cmd

  rm -rf "${SDIR}/bin"
  mkdir -p "${SDIR}/bin"
  off noclobber
  cat <<EOF > "${SDIR}/bin/${exe}"
#! /usr/bin/env bash

$(exec -c bash --noprofile --norc -c "
    source \"${SDIR}/src/index.sh\"
    declare -A namespace
    namespace=(${namespace[@]@K})
    for key in core docker podman containerd
    do
      on globstar
      for src in \"${SDIR}/src/\${key}\"/**/*.sh
      do
        if is file \"\${src}\"
        then
          source \"\${src}\"
          def=\"\$(declare -f ___)\"
          funcname=\"\${src#\"${SDIR}/src/\${key}/\"}\"
          funcname=\"\${funcname%.sh}\"
          source /proc/self/fd/0 <<< \"\${namespace[\"\${key}\"]}\${funcname//\//\"${sep[namespace]}\"}\${def#___}\"
          unset -f ___
        fi
      done
      off globstar
    done
    declare -f
  ")

${namespace[core]}version () {
  printf '${exe} ${version["${exe}"]}\n' >&2
}

${namespace[core]}help () {
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

  ${namespace[core]}version

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

${namespace[core]}init () {
  global -A sed jq buf sep version namespace path

  sep=(${sep[@]@K})
  namespace=(${namespace[@]@K})
  version=(${version[@]@K})
  path=(${path[@]@K})

  readonly sep

  harden base64
  #harden bc
  harden cat
  harden curl
  harden env
  harden gojq
  harden json_pp
  #harden mktemp
  harden protoc
  harden rg || harden egrep
  harden sed
  harden sha256sum
  #harden shuf
  harden tar
  #harden tee

  global backend exe
  exe='${exe}'
  if is socket '/var/run/containerd/containerd.sock'
  then
    backend='containerd'
  elif is socket "\${path[docker_socket]}"
  then
    backend='docker'
  elif is socket "/run/user/\${UID}/podman/podman.sock"
  then
    backend='podman'
  else
    error 'No available backend'
  fi

  # TODO: remove this later
  backend='docker'
  readonly backend

  # TODO: manage DOCKERD_HOST, BUILDKITD_HOST, CONTAINERD_HOST env vars

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

  fns=( $(exec -c bash --noprofile --norc -c "source ${SDIR}/src/index.sh; compgen -A function") \$(compgen -A function -X "!(\${namespace[core]}*|\${namespace["\${backend}"]}*)") )
  readonly sed jq buf fns
}

${exe} () {
  if is not var '${exe^^}_REEXEC_WITH_EMPTY_ENV'
  then
    \\command exec -c env --ignore-environment BASH="\${BASH:-}" ${exe^^}_REEXEC_WITH_EMPTY_ENV='yes' bash --norc --noprofile "\${BASH_SOURCE[0]}" "\${@}" || \\command exit 1
  fi

  on errexit inherit_errexit errtrace functrace noclobber nounset pipefail lastpipe extglob

  ${namespace[core]}init

  case "\${1:-}" in
  ( image|container|network|volume|runner|version|help ) "${namespace[core]}\${1}" "\${@:2}" ;;
  ( * ) ${namespace[core]}help ;;
  esac
}

${exe} "\${@}"
EOF
  chmod 0700 "${SDIR}/bin/${exe}"
}

compile "${@}"
