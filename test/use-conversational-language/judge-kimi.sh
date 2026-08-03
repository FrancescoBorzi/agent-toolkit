#!/usr/bin/env bash
# Kimi-panel variant of judge.sh: runs blind judge calls through headless `kimi -p` instead of
# `claude -p`. Same interface and output layout: [PANEL="model ..."] ./judge-kimi.sh <run-dir>
# <iteration-number>. Model aliases may contain "/" (e.g. kimi-code/k3); "/" and ":" become "-"
# in verdict filenames (kimi-code/k3 -> kimi-code-k3). Dead calls and verdicts still malformed
# after the rerun land in verdicts/_failures.log (truncated per invocation) and make the script
# exit non-zero.
set -u
RUN="${1:?usage: judge-kimi.sh <run-dir> <iteration-number>}"
N="${2:?usage: judge-kimi.sh <run-dir> <iteration-number>}"
TEXTS="$RUN/iter$N/texts"
OUT="$RUN/iter$N/verdicts"
SCEN="$RUN/scenarios.tsv"
PANEL="${PANEL:-kimi-code/k3 kimi-code/kimi-for-coding}"

shopt -s nullglob
texts=("$TEXTS"/*.txt)
shopt -u nullglob
if [ ${#texts[@]} -eq 0 ]; then
  echo "judge-kimi.sh: no .txt files in $TEXTS" >&2
  exit 1
fi
if [ ! -f "$SCEN" ]; then
  echo "judge-kimi.sh: no scenario file at $SCEN" >&2
  exit 1
fi

# An id with no scenarios.tsv row would be judged with an empty Context, which is not comparable
# to the rest of the panel.
missing=""
for f in "${texts[@]}"; do
  id="$(basename "$f" .txt)"
  awk -F'\t' -v id="$id" '$1 == id { found = 1; exit } END { exit !found }' "$SCEN" ||
    missing="$missing $id"
done
if [ -n "$missing" ]; then
  echo "judge-kimi.sh: no row in $SCEN for:$missing" >&2
  exit 1
fi

mkdir -p "$OUT"
FAILURES="$OUT/_failures.log"
: > "$FAILURES"

safe_name() { printf '%s' "$1" | tr '/:' '--'; }

judge_once() {
  local id="$1" model="$2" text ctx prompt d rc
  text="$(cat "$TEXTS/$id.txt")"
  ctx="$(awk -F'\t' -v id="$id" '$1 == id { print $2; exit }' "$SCEN")"
  prompt="Guess whether this text has been written by a human or is AI generated.
First line of your reply: exactly HUMAN or AI. Then briefly explain why.
Judge from the text alone.

Context: $ctx

Input text:

$text"
  d="$(mktemp -d)"
  mkdir "$d/skills"
  # stream-json: one JSON object per line; the verdict is the last assistant message. Blind call:
  # fresh temp cwd, empty skills dir, so no project/user config or skill text reaches the judge.
  (cd "$d" && kimi --output-format stream-json --model "$model" --skills-dir "$d/skills" \
    --prompt "$prompt") > "$OUT/$id.$(safe_name "$model").raw.jsonl" \
    2> "$OUT/$id.$(safe_name "$model").err"
  rc=$?
  if [ "$rc" -eq 0 ]; then
    jq -rs '[.[] | select(.role == "assistant") | .content] | last // empty' \
      "$OUT/$id.$(safe_name "$model").raw.jsonl" > "$OUT/$id.$(safe_name "$model").txt"
    [ -s "$OUT/$id.$(safe_name "$model").txt" ] || rc=1
  fi
  rm -rf "$d"
  return "$rc"
}

verdict_ok() {
  local first
  first="$(head -1 "$OUT/$1.$(safe_name "$2").txt" | tr -d '\r')"
  [ "$first" = "HUMAN" ] || [ "$first" = "AI" ]
}

judge() {
  local id="$1" model="$2"
  judge_once "$id" "$model" || { echo "CALL-FAILED $id $(safe_name "$model")" >> "$FAILURES"; return; }
  verdict_ok "$id" "$model" && return 0
  # malformed verdict (first line not HUMAN/AI): rerun once, per the harness
  judge_once "$id" "$model" || { echo "CALL-FAILED-RERUN $id $(safe_name "$model")" >> "$FAILURES"; return; }
  verdict_ok "$id" "$model" || echo "MALFORMED $id $(safe_name "$model")" >> "$FAILURES"
}
export -f judge judge_once verdict_ok safe_name
export TEXTS OUT SCEN FAILURES

for f in "${texts[@]}"; do
  id="$(basename "$f" .txt)"
  for m in $PANEL; do
    echo "$id $m"
  done
done | xargs -P 10 -n 2 bash -c 'judge "$0" "$1"'

failed="$(wc -l < "$FAILURES" | tr -d '[:space:]')"
if [ "$failed" -gt 0 ]; then
  echo "FAILED: $failed judge call(s) dead or unusable, see $FAILURES" >&2
  exit 1
fi

echo "ALL DONE"
