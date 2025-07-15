#! /usr/bin/env bash

___ () { #HELP <image>|List tags referring to <image>
  ${namespace[core]}image list "${1}:*" | sed 's/^[^:]*://'
}
