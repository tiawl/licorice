#! /usr/bin/env --split-string awk -f

function repeat(str, num,
                remain, result) {
  if (num < 2) {
    remain = (num == 1)
  } else {
    remain = (num % 2 == 1)
    result = repeat(str, (num - remain) / 2)
  }
  return result result (remain ? str : "")
}
