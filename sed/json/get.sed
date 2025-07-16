#! /usr/bin/env --split-string sed --file

# Split the hold space between 2 lines: the first for the workflow stack (and potential variables) and the last for the final output
: init_hold_space
  x
  s/^/\n/
  x
  b json_value

# Dispatch the workflow depending of the token
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
  # From https://github.com/dominictarr/JSON.sh: At this point, the only valid single-character tokens are digits.
  /^[^0-9]$/ {
    b failure_invalid_single_char
  }
  # Check that the value does not contain a substring that can be potentially used during the negative indexes compute of JSON arrays
  /:[:0-9]*; case \\"\\\${1:-}\\" in / {
    z
    s/^/:[:0-9]*; case \\"\\${1:-}\\" in /
    b failure_forbidden_value
  }
  / ( '[0-9]\+'|'- ) / {
    z
    s/^/ ( '[0-9]+'|'- ) /
    b failure_forbidden_value
  }
  s/\\"/"/g
  s/'/'"'"'/g
  s/^"\?/GET='/
  s/"\?$/'/
  H
  x
  # Remove the new line character added by the 'H' command
  s/\n\([^\n]*\)$/\1/
  x
  z
  b return

# Deal with JSON objects
: json_object
  z
  x
  # If this is not the root JSON object, add a BASH `shift` into the final output
  /^[^\n]/ {
    s/$/shift; /
  }
  s/$/case \\"\\${1:-}\\" in/
  x
  n
  /^}$/ {
    b _json_object_loop_end
  }
  b _json_object_loop

  # Main loop for JSON object
  : _json_object_loop
    /^".\+"$/ {
      b _json_object_loop_1
    }
    b failure_expecting_json_string

    : _json_object_loop_1
      # Check that the JSON object current key does not contain a substring that can be potentially used during the negative indexes compute of JSON arrays
      /:[:0-9]*; case \\"\\\${1:-}\\" in / {
        z
        s/^/:[:0-9]*; case \\"\\${1:-}\\" in /
        b failure_forbidden_key
      }
      / ( '[0-9]\+'|'- ) / {
        z
        s/^/ ( '[0-9]+'|'- ) /
        b failure_forbidden_key
      }
      s/^"/ ( '/
      s/"$/' ) /
      H
      x
      # Remove the new line character added by the 'H' command
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
      # Before the JSON object current value treatment, add an unique ID in the workflow stack, to come back here when done
      s/^/O/
      x
      b json_value

    : _json_object_loop_3
      x
      s/$/ ;;/
      x
      n
      # Depending of the token, the loop continues or breaks
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
    s/$/ ( '' ) error 'Empty key' ;; ( * ) error 'Unknown key' ;; esac/
    x
    b return

# Deal with JSON arrays
: json_array
  z
  x
  # If this is not the root JSON array, it adds a BASH `shift` into the final output
  /^[^\n]/ {
    s/$/shift; /
  }
  # Add a ` :; ` marker to know that the current JSON array treatment is not finished: only useful for negative indexes treatment
  s/$/ :; case \\"\\${1:-}\\" in/
  # Add the length of the JSON array
  s/^/0/
  x
  n
  /^]$/ {
    b _json_array_positive_indexes_loop_end
  }
  b _json_array_positive_indexes_loop

  # Main loop for JSON array
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
      # 1) Before the JSON object current value treatment, add an unique ID in the workflow stack, to come back here when done
      # 2) Depending of the token, the loop continues or breaks
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
      # The marker is used as a stack of indexes where the incremented positive index is stored for each iteration. It will be used later for negative indexes
      s/^\([0-9]\+\)\(.* :\)\([:0-9]*\)\(; .*\)$/\1\2\1:\3\4/
      x
      n
      b _json_array_positive_indexes_loop

  : _json_array_positive_indexes_loop_end
    x
    # Append the last element in the stack
    s/^\([0-9]\+\)\(.* :\)\([:0-9]*\)\(; .*\)$/\2\1:\3\4/
    s/$/ ( '' ) error 'Empty index' ;; ( * ) error 'Unknown index' ;; esac/
    b _json_array_negative_indexes_loop

  # It iteratively empties the marker/stack to allow the user to use negative indexes for each element in JSON arrays
  : _json_array_negative_indexes_loop
    s/\(.*:\)\([0-9]\+\):\(; case \\"\\\${1:-}\\" in .*( '[0-9]\+'|'-\) ) /\1\3\2' ) /
    t _json_array_negative_indexes_loop
    # Remove the marker when the stack is empty
    s/\(.*\) \(:0\)\?:; \(case \\"\\\${1:-}\\" in \)/\1\3/
    x
    z
    b return

# Increments the index for JSON array
: incr_index
  x
  b _incr_index_nines2underscores

  # Replace trailing 9n with underscores
  : _incr_index_nines2underscores
    s/^\([EL][0-9]*\)9\(_*\)/\1_\2/
    t _incr_index_nines2underscores
    # Increment the last digit only
    s/^\([EL]\)\(_\+\)/\11\2/
    t _incr_index_underscores2zeroes
    s/^\([EL][0-9]*\)8\(_*\)/\19\2/
    t _incr_index_underscores2zeroes
    s/^\([EL][0-9]*\)7\(_*\)/\18\2/
    t _incr_index_underscores2zeroes
    s/^\([EL][0-9]*\)6\(_*\)/\17\2/
    t _incr_index_underscores2zeroes
    s/^\([EL][0-9]*\)5\(_*\)/\16\2/
    t _incr_index_underscores2zeroes
    s/^\([EL][0-9]*\)4\(_*\)/\15\2/
    t _incr_index_underscores2zeroes
    s/^\([EL][0-9]*\)3\(_*\)/\14\2/
    t _incr_index_underscores2zeroes
    s/^\([EL][0-9]*\)2\(_*\)/\13\2/
    t _incr_index_underscores2zeroes
    s/^\([EL][0-9]*\)1\(_*\)/\12\2/
    t _incr_index_underscores2zeroes
    s/^\([EL][0-9]*\)0\(_*\)/\11\2/
    b _incr_index_underscores2zeroes

  # Replace trailing underscores with 0s
  : _incr_index_underscores2zeroes
    s/^\([EL][0-9]*\)_/\10/
    t _incr_index_underscores2zeroes
    b _incr_index_end

  : _incr_index_end
    x
    b return

# Redirect the workflow depending of the first element in the workflow stack
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

# Success and known failure cases
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
: failure_forbidden_value
  s/.*/Error in json::parse SED script: A JSON value matched an internal regex: '\0'/w /dev/stderr
  Q 12
: failure_forbidden_key
  s/.*/Error in json::parse SED script: A JSON object key matched an internal regex: '\0'/w /dev/stderr
  Q 13
: success
  z
  x
  s/^\n//
