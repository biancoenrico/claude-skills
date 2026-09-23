#!/bin/sh
# First commit: a small function with a boundary at running_total.py line 4
# (`while i < n:`). Second commit: widens that same line to `while i <= n:`, an
# off-by-one that reads items[n] out of range.
set -eu

git init -q
git config user.name "eval fixture"
git config user.email "eval-fixture@example.com"

cat > running_total.py <<'EOF'
def sum_first_n(items, n):
    total = 0
    i = 0
    while i < n:
        total += items[i]
        i += 1
    return total
EOF

git add running_total.py
git commit -q -m "add sum_first_n helper"

sed -i 's/while i < n:/while i <= n:/' running_total.py
git add running_total.py
git commit -q -m "widen sum_first_n loop bound"
