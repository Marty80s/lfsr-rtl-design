#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
variant="${1:-runtime}"
compiler="${2:-iverilog}"
runner="${3:-vvp}"
case "$variant" in
  fibonacci) top=tb_programmable_lfsr ;;
  galois) top=tb_galois_lfsr ;;
  runtime) top=tb_prog_galois_lfsr_rt ;;
  *) echo 'Choose fibonacci, galois, or runtime.' >&2; exit 2 ;;
esac
command -v "$compiler" >/dev/null || { echo "Missing simulator: $compiler" >&2; exit 127; }
mkdir -p build
"$compiler" -g2012 -s "$top" -o "build/$variant.vvp" "rtl/$variant/programmable_lfsr.v" "tb/tb_$variant.v"
"$runner" "build/$variant.vvp" | tee "build/$variant.log"
