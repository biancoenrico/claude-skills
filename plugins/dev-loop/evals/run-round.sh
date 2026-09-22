#!/bin/sh
# Launches one round of the dev-loop eval suite against a target plugin root.
#
#     sh run-round.sh <target> <out-dir> [<case-name>...]
#
# <target> is the plugin root passed to `claude plugin eval`. <out-dir> is where each case
# writes its own <case-name>.json; a rerun of a case overwrites that file, nothing is merged
# across runs. With case names given, only those run, in the given order; with none, all five
# run in the fixed cost order, cheapest first, `plan-execution-two-batches` last.
#
# This script only builds one fixed command line per case and runs it. It does not read the
# JSON `claude plugin eval` writes, does not merge runs, and does not retry an infrastructure
# error — that rule (see the spec) is applied by whoever launches this script, reading
# `partial` and `error` in the JSON each case writes.
#
# `DEVLOOP_EVAL_REFERENCE`, when set, is the root of a plugin: before any case runs, the suite
# under it must checksum identically to the suite under <target>, or nothing runs at all.

set -eu

DEVLOOP_RUN_ROUND_DEFAULT_CASES="trigger-code-revision spec-revision-gap code-revision-planted-bug test-writing-mutation plan-execution-two-batches"

if [ $# -lt 2 ]; then
    printf '%s\n' "usage: run-round.sh <target> <out-dir> [<case-name>...]" >&2
    exit 2
fi

target=$1
out_dir=$2
shift 2

if [ $# -eq 0 ]; then
    # shellcheck disable=SC2086
    set -- $DEVLOOP_RUN_ROUND_DEFAULT_CASES
fi

if [ -n "${DEVLOOP_EVAL_REFERENCE:-}" ]; then
    ref_sums="${TMPDIR:-/tmp}/devloop-run-round-ref.$$"
    target_sums="${TMPDIR:-/tmp}/devloop-run-round-target.$$"
    trap 'rm -f "$ref_sums" "$target_sums"' EXIT

    (cd "$DEVLOOP_EVAL_REFERENCE" && find evals -type f ! -path '*/results/*' | sort | xargs sha256sum) > "$ref_sums"
    (cd "$target" && find evals -type f ! -path '*/results/*' | sort | xargs sha256sum) > "$target_sums"

    if ! cmp -s "$ref_sums" "$target_sums"; then
        printf 'run-round.sh: evals/ differs between %s and %s\n' "$DEVLOOP_EVAL_REFERENCE" "$target" >&2
        diff "$ref_sums" "$target_sums" >&2 || true
        exit 1
    fi
fi

mkdir -p "$out_dir"

for case_name in "$@"; do
    claude plugin eval "$target" --case "$case_name" --json "$out_dir/$case_name.json" --runs 1 \
        --scaffold --ablation none --trust-plugin --allow-tools Bash Write Edit \
        --model claude-opus-5 --judge-model claude-haiku-4-5-20251001
done
