#!/bin/sh
# usage: env_dump.sh <label>
mkdir -p "$HOME/rez/logs"
env | sort > "$HOME/rez/logs/env-$1.txt"
