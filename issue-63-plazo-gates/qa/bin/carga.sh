#!/usr/bin/env bash
# carga sintética de QA-037: 12 bucles de CPU y 6 de fork; deja su pgid en $1
echo "$(ps -o pgid= -p $$ | tr -d ' ')" > "$1"
for i in $(seq 12); do ( while :; do :; done ) & done; for i in $(seq 6); do ( while :; do /bin/true; done ) & done; wait
