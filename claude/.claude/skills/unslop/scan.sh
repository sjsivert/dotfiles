#!/usr/bin/env bash
# Mechanical AI-tell scan for written artifacts. See SKILL.md for the judgment pass,
# which this script cannot do. Exit 0 always; the output is the report.
set -uo pipefail

if [ $# -eq 0 ]; then
	echo "usage: scan.sh <file-or-dir>..." >&2
	exit 2
fi

LIST=$(mktemp)
trap 'rm -f "$LIST"' EXIT
for target in "$@"; do
	if [ -d "$target" ]; then
		find "$target" -type f \( -name '*.md' -o -name '*.html' -o -name '*.txt' \) >>"$LIST"
	elif [ -f "$target" ]; then
		echo "$target" >>"$LIST"
	else
		echo "skipped, not found: $target" >&2
	fi
done

nfiles=$(wc -l <"$LIST" | tr -d ' ')
[ "$nfiles" -eq 0 ] && { echo "no files to scan"; exit 0; }
echo "scanned $nfiles file(s)"
printf '\n%6s %5s  %s\n' hits files tell

# report <regex> <label> [case]   case=i (default) or s for case-sensitive.
# Hit count and file count must use the same case sensitivity, or the report can
# claim more files than hits.
report() {
	local re="$1" label="$2" case="${3:-i}"
	local hflag fflag n f
	if [ "$case" = s ]; then hflag=-ohE; fflag=-lE; else hflag=-ohiE; fflag=-liE; fi
	n=$(xargs grep "$hflag" -- "$re" <"$LIST" 2>/dev/null | wc -l | tr -d ' ')
	f=$(xargs grep "$fflag" -- "$re" <"$LIST" 2>/dev/null | wc -l | tr -d ' ')
	[ "$n" -eq 0 ] && return
	printf '%6s %5s  %s\n' "$n" "$f" "$label"
}

report '^#{1,6} ([A-Z][a-z]+ ){2,}[A-Z][a-z]+[[:space:]]*$' 'Title Case heading -> sentence case' s
report '(✅|❌|🚀|⚠️|📊|💡|🎯|✨|🔧|🔥|📝|👉|🎉)' 'decorative emoji -> delete'
report '\bensur(e|es|ed|ing)\b' 'ensure -> name the actor and mechanism'
report '\b(additionally|furthermore|moreover)\b' 'additionally -> delete, start the sentence'
report ', (highlighting|ensuring|reflecting|showcasing|fostering|enabling|allowing|underscoring) ' '-ing tail clause -> own sentence or cut'
report '\b(serves as|stands as|acts as a|boasts)\b' 'fancy "is" -> is / has'
report '(API surface|\bsubstrate\b|\bwedge\b|\bscaffolding\b|north star|\bflywheel\b|\bbedrock\b|\bnexus\b)' 'abstract metaphor noun -> concrete word'
report '[‘’“”]' 'curly quote -> straight quote'
report '\b(crucial|delve|pivotal|tapestry|testament|underscore|showcase|garner|intricate|interplay)\b' 'AI vocabulary -> plain word'
report '\b(leverage|utilize|facilitate|seamless|holistic)\b' 'inflated verb/adj -> use / help / plain word'
report '\b(in order to|it is important to note|due to the fact that|in the event that)\b' 'filler phrase -> to / because / if'
report 'not just [^.]{1,45}, but' 'not just X, but Y -> state the point'
report '\b(kan potensielt|kan muligens|vil sannsynligvis kunne)\b' 'overhedging (no) -> kan'
report '\b(sømløs|kraftfull|helhetlig|muliggjør|nøkkelen til)' 'promo/puffery (no) -> plain word'
report '\bdet er viktig å (merke seg|påpeke|understreke|nevne)\b' 'filler (no) -> delete'

# No em-dash check on purpose. Measured against 74 plans and specs, every variant
# tried ran ~80% false positive: annotation separators (`file.cs:73 — note`) and
# heading separators (`## Phase 2 — run history`) are correct usage here. A check
# that noisy trains you to ignore the whole report. SKILL.md handles it as judgment.

printf '\nMechanical pass only. Now do the judgment pass in SKILL.md.\n'
