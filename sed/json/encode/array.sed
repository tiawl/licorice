#! /usr/bin/env --split-string sed --file

: loop
  # Keep the current array element into the hold space
  H

  # Init a workflow stack into the hold space
  x
  s/^/\n/
  x

  # JSON grammar in McKeeman Form:
  ### json
  ###    element
  : json_validator
    b json_validator___element

  ### value
  ###    object
  ###    array
  ###    string
  ###    number
  ###    "true"
  ###    "false"
  ###    "null"

  ### object
  ###     '{' ws '}'
  ###     '{' members '}'

  ### members
  ###     member
  ###     member ',' members

  ### member
  ###     ws string ws ':' element

  ### array
  ###     '[' ws ']'
  ###     '[' elements ']'

  ### elements
  ###     element
  ###     element ',' elements

  ### element
  ###     ws value ws
  : json_validator___element
    x
    s/^/e1e2e3/
    x
    b json_validator___ws
    : json_validator___element_1
      b json_validator___value
    : json_validator___element_2
      b json_validator___ws
    : json_validator___element_3
      b json_validator___return

  ### string
  ### '"' characters '"'

  ### characters
  ###     ""
  ###     character characters

  ### character
  ###     '0020' . '10FFFF' - '"' - '\'
  ### '\' escape

  ### escape
  ###     '"'
  ###     '\'
  ###     '/'
  ###     'b'
  ###     'f'
  ###     'n'
  ###     'r'
  ###     't'
  ###     'u' hex hex hex hex

  ### hex
  ###     digit
  ###     'A' . 'F'
  ###     'a' . 'f'

  ### number
  ###     integer fraction exponent

  ### integer
  ###     digit
  ###     onenine digits
  ###     '-' digit
  ###     '-' onenine digits

  ### digits
  ###     digit
  ###     digit digits

  ### digit
  ###     '0'
  ###     onenine

  ### onenine
  ###     '1' . '9'

  ### fraction
  ###     ""
  ###     '.' digits

  ### exponent
  ###     ""
  ###     'E' sign digits
  ###     'e' sign digits

  ### sign
  ###     ""
  ###     '+'
  ###     '-'

  ### ws
  ###     ""
  ###     '0020' ws
  ###     '000A' ws
  ###     '000D' ws
  ###     '0009' ws
  : json_validator___ws
    /^$/ {
      b json_validator___ws_1
    }
    /^[\x20\x0a\x0d\x09]/ {
      s/^.//
      b json_validator___ws
    }
    b json_validator___FAILURE
    : json_validator___ws_1
      b json_validator___return

  # Redirect the workflow depending of the first element in the workflow stack
  : json_validator___return
    x
    /^e1/ {
      s/^e1//
      x
      b json_validator___element_1
    }
    /^e2/ {
      s/^e2//
      x
      b json_validator___element_2
    }
    /^e3/ {
      s/^e3//
      x
      b json_validator___element_3
    }
    /^\n/ {
      x
      b json_validator___SUCCESS
    }
    x
    b json_validator___ERROR

  : json_validator___ERROR
    s/.*/Error in sed\/json\/encode\/array.sed script: Unknown return code/w /dev/stderr
    Q 5

  : json_validator___SUCCESS
    g
    # Reset the pattern space with the current element of the array stored into the hold space
    s/^.*\n//
    x
    # Remove workflow stack and the backed-up element of the array from the hold space: if the json_validator succeed, the workflow stack is empty => reset the hold space is easier than in a failure case
    s/^\n//
    s/\n.*$//
    x
    b end_loop

  : json_validator___FAILURE
    g
    # Reset the pattern space with the current element of the array stored into the hold space
    s/^.*\n//
    x
    # Remove the backed-up element of the array then the workflow stack from the hold space: if the json_validator failed, the workflow stack is not empty => we can not reset the hold space the same way we could do it in a success case
    s/\n\(.*\)$/\1/
    s/^.*\n//
    x
    # Map the current element of the array as a JSON string
    s/\\/\\\\/g
    s/"/\\"/g
    s/^/"/
    s/$/"/
    b end_loop

  : end_loop
    H
    x
    s/\n//
    h

    n
    x
    s/$/,/
    x

    b loop
