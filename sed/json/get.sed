#! /usr/bin/env --split-string sed --file

: init_hold_space
  x
  s/^/\n/
  x
  b json_value

: json_value
  /^{$/ {
    b json_object
  }
  /^\[$/ {
    b json_array
  }
  /^$/ {
    b failure_empty_json_value
  }
  /^[^0-9]$/ {
    b failure_invalid_single_char
  }
  s/\\"/"/g
  s/'/'"'"'/g
  s/^"\?/printf '%s\\n' '/
  s/"\?$/'/
  H
  x
  s/\n\([^\n]*\)$/\1/
  x
  z
  b return

: json_object
  z
  x
  /^[^\n]/ {
    s/$/shift; /
  }
  s/$/case "${1}" in/
  x
  n
  /^}$/ {
    b _json_object_loop_end
  }
  b _json_object_loop

  : _json_object_loop
    /^".\+"$/ {
      b _json_object_loop_1
    }
    b failure_expecting_json_string

    : _json_object_loop_1
      s/^"/ ( '/
      s/"$/' ) /
      H
      x
      s/\n\([^\n]*\)$/\1/
      x
      n
      /^:$/ {
        b _json_object_loop_2
      }
      b failure_expecting_colon

    : _json_object_loop_2
      n
      x
      s/^/O/
      x
      b json_value

    : _json_object_loop_3
      x
      s/$/ ;;/
      x
      n
      /^}$/ {
        b _json_object_loop_end
      }
      /^,$/ {
        b _json_object_loop_4
      }
      b failure_expecting_comma_or_closing_brace

    : _json_object_loop_4
      n
      b _json_object_loop

  : _json_object_loop_end
    z
    x
    s/$/ ( * ) return 1 ;; esac/
    x
    b return

: json_array
  z
  x
  /^[^\n]/ {
    s/$/shift; /
  }
  s/$/ :; case "${1}" in/
  s/^/0/
  x
  n
  /^]$/ {
    b _json_array_positive_indexes_loop_end
  }
  b _json_array_positive_indexes_loop

  : _json_array_positive_indexes_loop
    x
    s/^\([0-9]\+\).*/A\0 ( '\1'|'- ) /
    x
    b json_value

    : _json_array_positive_indexes_loop_1
      x
      s/$/ ;;/
      x
      n
      /^]$/ {
        x
        s/^/E/
        x
        b incr_index
      }
      /^,$/ {
        x
        s/^/L/
        x
        b incr_index
      }
      b failure_expecting_comma_or_closing_bracket

    : _json_array_positive_indexes_loop_2
      x
      s/^\([0-9]\+\)\(.* :\)\([:0-9]*\)\(; .*\)$/\1\2\1:\3\4/
      x
      n
      b _json_array_positive_indexes_loop

  : _json_array_positive_indexes_loop_end
    x
    s/^\([0-9]\+\)\(.* :\)\([:0-9]*\)\(; .*\)$/\2\1:\3\4/
    s/$/ ( * ) return 1 ;; esac/
    b _json_array_negative_indexes_loop

  : _json_array_negative_indexes_loop
    s/\(.*:\)\([0-9]\+\):\(; case "\${1}" in .*( '[0-9]\+'|'-\) )/\1\3\2' )/
    t _json_array_negative_indexes_loop
    s/\(.*\) :; \(case "\${1}" in \)/\1\2/
    x
    z
    b return

: incr_index
  x
  b nines2underscores

  : nines2underscores
    s/^\([EL][0-9]*\)9\(_*\)/\1_\2/
    t nines2underscores
    s/^\([EL]\)\(_\+\)/\11\2/
    t underscores2zeroes
    s/^\([EL][0-9]*\)8\(_*\)/\19\2/
    t underscores2zeroes
    s/^\([EL][0-9]*\)7\(_*\)/\18\2/
    t underscores2zeroes
    s/^\([EL][0-9]*\)6\(_*\)/\17\2/
    t underscores2zeroes
    s/^\([EL][0-9]*\)5\(_*\)/\16\2/
    t underscores2zeroes
    s/^\([EL][0-9]*\)4\(_*\)/\15\2/
    t underscores2zeroes
    s/^\([EL][0-9]*\)3\(_*\)/\14\2/
    t underscores2zeroes
    s/^\([EL][0-9]*\)2\(_*\)/\13\2/
    t underscores2zeroes
    s/^\([EL][0-9]*\)1\(_*\)/\12\2/
    t underscores2zeroes
    s/^\([EL][0-9]*\)0\(_*\)/\11\2/
    b underscores2zeroes

  : underscores2zeroes
    s/^\([EL][0-9]*\)_/\10/
    t underscores2zeroes
    b _incr_index_end

  : _incr_index_end
    x
    b return

: return
  x
  /^\n/ {
    x
    b success
  }
  /^O/ {
    s/^O//
    x
    b _json_object_loop_3
  }
  /^A/ {
    s/^A//
    x
    b _json_array_positive_indexes_loop_1
  }
  /^E/ {
    s/^E//
    x
    b _json_array_positive_indexes_loop_end
  }
  /^L/ {
    s/^L//
    x
    b _json_array_positive_indexes_loop_2
  }
  x
  b failure_unknown_return_code

: failure_unknown_return_code
  x
  s/^\([^\n]*\).*/Error in json::parse SED script: Unknown return code. Flow stack from SED Hold Space: "\1" /w /dev/stderr
  Q 5
: failure_invalid_single_char
  z
  s/^/Error in json::parse SED script: Invalid single character token/w /dev/stderr
  Q 6
: failure_empty_json_value
  z
  s/^/Error in json::parse SED script: Empty JSON value/w /dev/stderr
  Q 7
: failure_expecting_json_string
  z
  s/^/Error in json::parse SED script: Expecting JSON string/w /dev/stderr
  Q 8
: failure_expecting_colon
  z
  s/^/Error in json::parse SED script: Expecting colon character/w /dev/stderr
  Q 9
: failure_expecting_comma_or_closing_brace
  z
  s/^/Error in json::parse SED script: Expecting comma or closing brace character/w /dev/stderr
  Q 10
: failure_expecting_comma_or_closing_bracket
  z
  s/^/Error in json::parse SED script: Expecting comma or closing bracket character/w /dev/stderr
  Q 11
: success
  z
  x
  s/^\n//
  p
