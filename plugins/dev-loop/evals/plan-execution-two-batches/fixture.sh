#!/bin/sh
# A git repo holding a two-batch plan folder at docs/plans/sample-plan/. Batch 02's task
# sources lib.sh and calls add(), so it cannot pass without what batch 01 creates.
set -eu

git init -q
git config user.name "eval fixture"
git config user.email "eval-fixture@example.com"

mkdir -p docs/plans/sample-plan

cat > docs/plans/sample-plan/00-index.md <<'EOF'
# Index — sample two-batch plan

## 1. Order and dependencies

| batch | cannot start before | why |
|---|---|---|
| 01 add helper | — | first, no dependency |
| 02 use helper | 01 | sources and calls the function batch 01 creates |

## 2. Shared vocabulary and owners

| entry | owner | who calls it |
|---|---|---|
| `add()` in `lib.sh` | 01 | 02 |

## 3. End of a batch

Each batch closes when its own verification command, given in its own task, succeeds.
EOF

cat > docs/plans/sample-plan/01-add-helper.md <<'EOF'
# 01 — add helper

**Delivers:** `lib.sh`, with a shell function `add()` that echoes the sum of its two arguments.

**Inherits:** nothing, first batch.

**Leaves to the following batches:** the caller that sources `add()`, in batch 02.

**Starting material:**

## Tasks

### 01.1 — Create `lib.sh`

Create `lib.sh`:

    add() {
        echo $(( $1 + $2 ))
    }

Verification: `sh -c '. ./lib.sh && [ "$(add 2 3)" = "5" ]'` succeeds.

## Progress

## State

## Calibration
EOF

cat > docs/plans/sample-plan/02-use-helper.md <<'EOF'
# 02 — use helper

**Delivers:** `main.sh`, which sources `lib.sh` and prints the result of `add 2 3`.

**Inherits:** `add()` from `lib.sh` (batch 01).

**Leaves to the following batches:** nothing, last batch.

**Starting material:**

## Tasks

### 02.1 — Create `main.sh`

Create `main.sh`:

    #!/bin/sh
    . "$(dirname "$0")/lib.sh"
    add 2 3

Verification: `sh main.sh` prints `5`.

## Progress

## State

## Calibration
EOF

git add docs/plans/sample-plan
git commit -q -m "add sample two-batch plan"
