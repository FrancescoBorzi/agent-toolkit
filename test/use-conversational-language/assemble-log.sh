#!/usr/bin/env bash
# Assembles a LANGUAGE-TEST run log from a run dir (see LANGUAGE-TEST.md, "Run log").
# Usage: ./assemble-log.sh <run-dir> <output.md>
# Expects in <run-dir>: header.md, scenarios.tsv (id, judge context, brief),
# iter<N>/texts/<id>.txt, iter<N>/verdicts/<id>.<model>.txt, triage-iter<N>.md (optional per
# iteration), outcome.md. Iterations, scenario order and panel come from what's on disk.
set -euo pipefail
RUN="${1:?usage: assemble-log.sh <run-dir> <output.md>}"
LOG="${2:?usage: assemble-log.sh <run-dir> <output.md>}"

# A text may itself contain a ``` block, so fence it with one backtick more than its longest run.
fence_for() {
  local longest
  longest="$( { grep -o '`\{1,\}' "$1" || true; } | awk '{ if (length($0) > m) m = length($0) }
    END { print m + 0 }')"
  if [ "$longest" -lt 3 ]; then longest=3; else longest=$((longest + 1)); fi
  printf '%*s' "$longest" '' | tr ' ' '`'
}

{
  cat "$RUN/header.md"
  echo
  echo "## Scenarios"
  echo
  while IFS=$'\t' read -r id ctx brief || [ -n "$id" ]; do
    echo "- **\`$id\`** — \"$ctx\""
    printf '%s\n' "$brief" | fold -s -w 98 | sed 's/^/  /; s/[[:space:]]*$//'
  done < "$RUN/scenarios.tsv"
  echo

  for iter in "$RUN"/iter*/; do
    [ -d "$iter" ] || continue
    n="$(basename "$iter" | sed 's/^iter//')"
    echo "## Iteration $n"
    echo
    while IFS=$'\t' read -r id ctx brief || [ -n "$id" ]; do
      [ -f "$iter/texts/$id.txt" ] || continue
      fence="$(fence_for "$iter/texts/$id.txt")"
      echo "### $id"
      echo
      echo "$fence"
      cat "$iter/texts/$id.txt"
      echo
      echo "$fence"
      echo
      for vf in "$iter/verdicts/$id".*.txt; do
        [ -f "$vf" ] || continue
        m="$(basename "$vf" .txt)"
        m="${m#"$id".}"
        verdict="$(head -1 "$vf" | tr -d '\r')"
        echo "**$m: $verdict**"
        echo
        tail -n +2 "$vf" | sed '/./,$!d' | fold -s -w 100 | sed 's/[[:space:]]*$//'
        echo
      done
    done < "$RUN/scenarios.tsv"
    if [ -f "$RUN/triage-iter$n.md" ]; then
      cat "$RUN/triage-iter$n.md"
      echo
    fi
  done

  echo "## Outcome"
  echo
  cat "$RUN/outcome.md"
} > "$LOG"
echo "written: $LOG"
wc -l "$LOG"
