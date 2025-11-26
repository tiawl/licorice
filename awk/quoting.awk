#! /usr/bin/env --split-string awk -f

function q(str) { return "\047" str "\047"; }
function dq(str) { return "\042" str "\042"; }
function edq(str) { return "\134" dq(str) "\134"; }
