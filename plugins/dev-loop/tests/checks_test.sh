# Tests for checks.sh.
#
# A checks.sh that prints green whatever it is given is indistinguishable from one that
# works, and from this batch on it is a closing criterion of every batch. So each of its
# seven checks gets a case built to make it red, and the empty tree gets a case of its
# own: an absent input has to be declared and stay green, never mistaken for a pass.
#
# Every fixture is a small plugin tree of its own, built under a throwaway directory, so
# nothing here depends on what the real plugin happens to contain today.

# The line of Italian prose the C6 fixture plants. It lives here, once, inside the
# exemption markers, because the file that plants a marker is scanned by C6 like any
# other file under the plugin.
# c6-exempt:start
checks_italian_line='Questa riga deve essere scritta in italiano.'
# c6-exempt:end

# The private term the C6 fixture plants. Invented on purpose: a real one would have to
# be written here, and this file is published.
checks_private_term='examplecorp'

# The heading the C5 fixture shares between a references/ file and a consultation file.
checks_shared_heading='A heading long enough to be guarded'

# checks_write_skill <path> <description> <when_to_use>
checks_write_skill() {
    cat > "$1" <<EOF
---
name: sample
description: $2
when_to_use: $3
---

# Sample skill

Body.
EOF
}

# checks_write_agent <path> <description>
checks_write_agent() {
    cat > "$1" <<EOF
---
description: $2
model: inherit
effort: high
---

Body.
EOF
}

# checks_write_script <path> - a script that passes every shell check, carrying both
# anchors of the mutation sequence.
checks_write_script() {
    cat > "$1" <<'EOF'
#!/bin/sh
set -eu
dm_quit() {
    exit "$1"
}
git status --porcelain > "$DM_DIR/status-before"
cp "$DM_FILE_ABS" "$DM_RESTORE_ORIG"
cp "$DM_RESTORE_MUT" "$DM_FILE_ABS"
"$@" > "$DM_DIR/output" 2>&1 || DM_CHILD_STATUS=$?
cp "$DM_RESTORE_ORIG" "$DM_FILE_ABS"
dm_quit "$DM_EXIT_CODE"
EOF
}

# checks_repeat <count> <string> - prints the string that many times, no newline.
checks_repeat() {
    awk -v n="$1" -v s="$2" 'BEGIN { for (i = 0; i < n + 0; i++) printf "%s", s }'
}

# checks_new_fixture <name> -> prints the plugin root of a tree that passes everything.
# The private-terms list sits beside the plugin root, one level up, where checks.sh
# climbs to look for it.
checks_new_fixture() {
    _cf_base=$(newTestDir "$1")
    _cf_root="$_cf_base/plugin"
    mkdir -p "$_cf_root/references" "$_cf_root/agents" "$_cf_root/skills/sample" \
        "$_cf_root/scripts" "$_cf_root/hooks" "$_cf_base/docs"
    printf '%s\n' "# $checks_shared_heading" "" "Shared prose." \
        > "$_cf_root/references/shared.md"
    printf '%s\n' "# Declared numbers" "" \
        '- **Searchable form:** `9 sample units`' "- **Value:** 9" \
        > "$_cf_root/references/limits.md"
    checks_write_skill "$_cf_root/skills/sample/SKILL.md" \
        "A sample skill." "When a sample is needed."
    checks_write_agent "$_cf_root/agents/sample.md" \
        "A sample agent launched by the dev-loop skills."
    checks_write_script "$_cf_root/scripts/devloop-mutate"
    printf '%s\n' "# sample list" "$checks_private_term" \
        > "$_cf_base/docs/dev-loop-private-terms.txt"
    printf '%s' "$_cf_root"
}

# checks_run <plugin-root> - runs checks.sh and keeps its output and exit status.
checks_run() {
    checks_out=$(sh "$DEVLOOP_TESTS_DIR/checks.sh" "$1" 2>&1)
    checks_status=$?
    return 0
}

# checks_saw <substring> - true when the last run printed it.
checks_saw() {
    printf '%s\n' "$checks_out" | grep -q -- "$1"
}

# ---------------------------------------------------------------------------

test_a_clean_fixture_passes_every_check() {
    _root=$(checks_new_fixture clean)
    checks_run "$_root"
    assertEquals "a clean tree must pass: $checks_out" "0" "$checks_status"
    assertTrue "the run must say so" 'checks_saw "all checks passed"'
}

test_an_empty_tree_is_green_and_declares_what_it_could_not_measure() {
    _root=$(newTestDir empty)
    checks_run "$_root"
    assertEquals "an empty tree is green: $checks_out" "0" "$checks_status"
    assertTrue "C1 says there is nothing to measure" 'checks_saw "C1 no SKILL.md"'
    assertTrue "shell says there is nothing to read" 'checks_saw "shell no script to read"'
}

test_c1_catches_a_skill_file_over_the_character_cap() {
    _root=$(checks_new_fixture c1)
    checks_repeat 18000 x >> "$_root/skills/sample/SKILL.md"
    checks_run "$_root"
    assertEquals "an oversized skill must fail" "1" "$checks_status"
    assertTrue "C1 must name it: $checks_out" 'checks_saw "! C1 skills/sample/SKILL.md"'
}

test_c2_catches_a_skill_file_over_the_line_cap() {
    _root=$(checks_new_fixture c2)
    checks_repeat 520 'x
' >> "$_root/skills/sample/SKILL.md"
    checks_run "$_root"
    assertEquals "a skill with too many lines must fail" "1" "$checks_status"
    assertTrue "C2 must name it: $checks_out" 'checks_saw "! C2 skills/sample/SKILL.md"'
}

test_c3_catches_an_agent_description_one_character_over_the_cap() {
    _root=$(checks_new_fixture c3agent)
    checks_write_agent "$_root/agents/sample.md" "$(checks_repeat 201 d)"
    checks_run "$_root"
    assertEquals "201 characters must fail" "1" "$checks_status"
    assertTrue "C3 must name the agent: $checks_out" 'checks_saw "! C3 agents/sample.md"'

    # The cap itself, to prove the check measures rather than always complaining.
    checks_write_agent "$_root/agents/sample.md" "$(checks_repeat 200 d)"
    checks_run "$_root"
    assertEquals "200 characters must pass: $checks_out" "0" "$checks_status"
}

test_c3_catches_a_skill_over_its_description_budget() {
    _root=$(checks_new_fixture c3skill)
    checks_write_skill "$_root/skills/sample/SKILL.md" \
        "$(checks_repeat 400 d)" "$(checks_repeat 201 w)"
    checks_run "$_root"
    assertEquals "601 characters must fail" "1" "$checks_status"
    assertTrue "C3 must name the skill: $checks_out" \
        'checks_saw "! C3 skills/sample/SKILL.md"'
}

test_c5_catches_a_reference_heading_repeated_in_a_consultation_file() {
    _root=$(checks_new_fixture c5heading)
    printf '%s\n' "# Criteria" "" "## $checks_shared_heading" \
        > "$_root/skills/sample/criteria.md"
    checks_run "$_root"
    assertEquals "a copied heading must fail" "1" "$checks_status"
    assertTrue "C5 must name the consultation file: $checks_out" \
        'checks_saw "! C5 skills/sample/criteria.md"'
}

test_c5_leaves_a_short_generic_heading_alone() {
    _root=$(checks_new_fixture c5short)
    printf '%s\n' "# Tasks" "" "Body." >> "$_root/references/shared.md"
    printf '%s\n' "# Criteria" "" "## Tasks" > "$_root/skills/sample/criteria.md"
    checks_run "$_root"
    assertEquals "a generic heading is not a copied block: $checks_out" "0" "$checks_status"
}

test_c5_catches_a_twin_marker() {
    _root=$(checks_new_fixture c5twin)
    printf '%s\n' "Body with a GEM""ELLA marker." >> "$_root/skills/sample/SKILL.md"
    checks_run "$_root"
    assertEquals "a twin marker must fail" "1" "$checks_status"
    assertTrue "C5 must name the file: $checks_out" 'checks_saw "! C5 skills/sample/SKILL.md"'
}

test_c6_catches_a_private_term_outside_the_exempt_region() {
    _root=$(checks_new_fixture c6term)
    printf '%s\n' "Written by $checks_private_term." >> "$_root/skills/sample/SKILL.md"
    checks_run "$_root"
    assertEquals "a private term must fail" "1" "$checks_status"
    assertTrue "C6 must name it: $checks_out" 'checks_saw "! C6 skills/sample/SKILL.md"'
}

test_c6_leaves_a_private_term_inside_the_exempt_region_alone() {
    _root=$(checks_new_fixture c6exempt)
    printf '%s\n' "# c6-exempt:start" "Written by $checks_private_term." \
        "# c6-exempt:end" >> "$_root/skills/sample/SKILL.md"
    checks_run "$_root"
    assertEquals "the exemption is by position: $checks_out" "0" "$checks_status"
}

test_c6_catches_italian_prose() {
    _root=$(checks_new_fixture c6prose)
    printf '%s\n' "$checks_italian_line" >> "$_root/skills/sample/SKILL.md"
    checks_run "$_root"
    assertEquals "Italian prose must fail" "1" "$checks_status"
    assertTrue "C6 must name it: $checks_out" 'checks_saw "! C6 skills/sample/SKILL.md"'
}

test_c6_declares_the_terms_list_absent_and_stays_green() {
    _root=$(checks_new_fixture c6nodocs)
    rm -rf "$(dirname -- "$_root")/docs"
    checks_run "$_root"
    assertEquals "a plugin without docs/ is still green: $checks_out" "0" "$checks_status"
    assertTrue "and says what it could not search" \
        'checks_saw "private-terms list is absent"'
}

test_limits_catches_a_declared_number_written_into_a_skill() {
    _root=$(checks_new_fixture limits)
    printf '%s\n' "Stop after 9 sample units of work." >> "$_root/skills/sample/SKILL.md"
    checks_run "$_root"
    assertEquals "a rewritten number must fail" "1" "$checks_status"
    assertTrue "limits must name the skill: $checks_out" \
        'checks_saw "! limits skills/sample/SKILL.md"'
}

test_limits_says_so_when_no_searchable_form_is_declared() {
    _root=$(checks_new_fixture limitsempty)
    printf '%s\n' "# Declared numbers" "" "Nothing declared here." \
        > "$_root/references/limits.md"
    checks_run "$_root"
    assertEquals "an undeclared form is a note, not a failure: $checks_out" "0" "$checks_status"
    assertTrue "and the note says what to fix" 'checks_saw "declares no searchable form"'
}

test_shell_catches_a_banned_token() {
    _root=$(checks_new_fixture shelltoken)
    printf '%s\n' 'work=$(mktemp -d)' >> "$_root/scripts/devloop-mutate"
    checks_run "$_root"
    assertEquals "a banned token must fail" "1" "$checks_status"
    assertTrue "shell must name it: $checks_out" 'checks_saw "uses mktemp"'
}

test_shell_catches_a_command_run_through_another_shell() {
    _root=$(checks_new_fixture shellsubshell)
    printf '%s\n' 'sh -c "$1"' >> "$_root/scripts/devloop-mutate"
    checks_run "$_root"
    assertEquals "sh -c must fail" "1" "$checks_status"
    assertTrue "shell must name it: $checks_out" 'checks_saw "uses sh -c"'
}

test_shell_catches_the_mutation_sequence_inside_a_subshell() {
    _root=$(checks_new_fixture shellparens)
    cat > "$_root/scripts/devloop-mutate" <<'EOF'
#!/bin/sh
set -eu
dm_quit() {
    exit "$1"
}
(
cp "$DM_FILE_ABS" "$DM_RESTORE_ORIG"
cp "$DM_RESTORE_MUT" "$DM_FILE_ABS"
)
dm_quit "$DM_EXIT_CODE"
EOF
    checks_run "$_root"
    assertEquals "a subshell around the mutation must fail" "1" "$checks_status"
    assertTrue "shell must say which line: $checks_out" 'checks_saw "closes a subshell"'
}

test_shell_catches_a_tool_outside_the_allowed_list() {
    _root=$(checks_new_fixture shelltool)
    printf '%s\n' 'curl -s "$1"' >> "$_root/scripts/devloop-mutate"
    checks_run "$_root"
    assertEquals "an unlisted tool must fail" "1" "$checks_status"
    assertTrue "shell must name it: $checks_out" 'checks_saw "calls curl"'
}

test_shell_says_so_when_the_mutation_anchors_are_gone() {
    _root=$(checks_new_fixture shellanchors)
    printf '%s\n' "#!/bin/sh" "set -eu" "git status" > "$_root/scripts/devloop-mutate"
    checks_run "$_root"
    assertEquals "an unrecognisable sequence must fail" "1" "$checks_status"
    assertTrue "and say that the anchors are what went missing: $checks_out" \
        'checks_saw "neither of its anchors"'
}
