#!/bin/sh
# Minimal repo with one commit that introduces both files, so the review is of that
# commit's diff against the empty tree.
set -eu

git init -q
git config user.name "eval fixture"
git config user.email "eval-fixture@example.com"

cat > greeting.py <<'EOF'
def greet(name):
    return "Hello, " + name
EOF

cat > farewell.py <<'EOF'
def farewell(name):
    return "Goodbye, " + name
EOF

git add greeting.py farewell.py
git commit -q -m "add greeting and farewell helpers"
