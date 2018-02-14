#!/bin/sh
set -ex

gccvers=(
#    '4.9.4'
#    '5.5.0'
    '6.4.0'
    '7.2.0'
)

targets=(
  'x86_64-linux-gnu'
)

for gccver in "${gccvers[@]}"; do
  for target in "${targets[@]}"; do
      PATH="$(pwd)/tools/bin:$PATH" bash .travis.yml.script "${target}" "${gccver}"
  done
done

