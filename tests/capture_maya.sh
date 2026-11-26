#!/bin/sh
# usage: capture_maya.sh <label>   (run by hand while Maya is open)
P=$(pgrep -n -x maya.bin || pgrep -n -f '/maya\.bin') || { echo "no maya.bin process" >&2; exit 1; }
tr '\0' '\n' < "/proc/$P/environ" | sort > "$HOME/rez/logs/env-maya-$1.txt"
# argv without argv[0], with a count line, in the same format as args-stub.txt
{ printf 'count=%s\n' "$(( $(tr -cd '\0' < "/proc/$P/cmdline" | wc -c) - 1 ))"
  tr '\0' '\n' < "/proc/$P/cmdline" | tail -n +2; } > "$HOME/rez/logs/args-maya-$1.txt"
