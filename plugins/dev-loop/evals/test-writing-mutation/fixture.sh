#!/bin/sh
# One commit: a small function with exactly two branches (even/odd), no further edge cases.
set -eu

git init -q
git config user.name "eval fixture"
git config user.email "eval-fixture@example.com"

cat > classify.py <<'EOF'
def classify(n):
    if n % 2 == 0:
        return "even"
    else:
        return "odd"
EOF

git add classify.py
git commit -q -m "add classify helper"
