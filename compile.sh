#!/bin/bash
# Compile only the .tex files whose output is stale: the .pdf is missing or
# older than the .tex. Uses xelatex (Unicode-compliant).
# Pass filenames to force-compile specific files regardless of staleness.

set -euo pipefail

# .tex files to never auto-compile (e.g. dated archives). One per line.
IGNORE=(
    "ritesh_cv_Jun2724.tex"
)

is_ignored() {
    local f=$1
    for ig in "${IGNORE[@]}"; do
        [ "$f" = "$ig" ] && return 0
    done
    return 1
}

files=()

if [ "$#" -gt 0 ]; then
    files=("$@")
else
    # Rebuild any .tex whose .pdf is missing or older than the .tex.
    for f in *.tex; do
        [ -f "$f" ] || continue          # no matches -> literal '*.tex'
        is_ignored "$f" && continue
        pdf="${f%.tex}.pdf"
        if [ ! -f "$pdf" ] || [ "$f" -nt "$pdf" ]; then
            files+=("$f")
        fi
    done
fi

if [ "${#files[@]}" -eq 0 ]; then
    echo "Nothing to compile: all PDFs are up to date."
    exit 0
fi

for f in "${files[@]}"; do
    [ -f "$f" ] || continue
    echo "==> Compiling $f"
    xelatex -interaction=nonstopmode "$f"
done
