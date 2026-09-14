# Tests for hooks/session-map.sh.
#
# The script must print the slice of loop.md between the two session-map markers, and must
# never block a session: every failure mode ends in exit 0 with an empty stdout.

SESSION_MAP="$DEVLOOP_TESTS_DIR/../hooks/session-map.sh"
REAL_LOOP="$DEVLOOP_TESTS_DIR/../references/loop.md"

# Writes a loop.md-shaped file at $1, with the body $2 between the markers.
writeMarkedFile() {
    {
        echo "before the map"
        echo "<!-- session-map:start -->"
        printf '%s\n' "$2"
        echo "<!-- session-map:end -->"
        echo "after the map"
    } > "$1"
}

test_prints_the_text_between_the_markers() {
    dir=$(newTestDir extract)
    writeMarkedFile "$dir/loop.md" "the map itself"
    out=$(sh "$SESSION_MAP" "$dir/loop.md")
    assertEquals "only the text between the markers is printed" "the map itself" "$out"
}

test_missing_file_prints_nothing_and_exits_zero() {
    dir=$(newTestDir missing)
    out=$(sh "$SESSION_MAP" "$dir/absent.md" 2>/dev/null)
    status=$?
    assertEquals "stdout stays empty" "" "$out"
    assertEquals "the hook never blocks the session" "0" "$status"
}

test_missing_markers_print_nothing_and_exit_zero() {
    dir=$(newTestDir nomarkers)
    printf 'a file with no markers at all\n' > "$dir/loop.md"
    out=$(sh "$SESSION_MAP" "$dir/loop.md" 2>/dev/null)
    status=$?
    assertEquals "stdout stays empty" "" "$out"
    assertEquals "the hook never blocks the session" "0" "$status"
}

test_opening_marker_without_a_closing_one_prints_nothing() {
    dir=$(newTestDir unclosed)
    {
        echo "<!-- session-map:start -->"
        echo "a map nobody closed"
    } > "$dir/loop.md"
    out=$(sh "$SESSION_MAP" "$dir/loop.md" 2>/dev/null)
    status=$?
    assertEquals "half a map is not a map" "" "$out"
    assertEquals "the hook never blocks the session" "0" "$status"
}

test_without_an_argument_it_falls_back_to_the_plugin_root() {
    dir=$(newTestDir fallback)
    mkdir -p "$dir/references"
    writeMarkedFile "$dir/references/loop.md" "the fallback map"
    out=$(CLAUDE_PLUGIN_ROOT="$dir" sh "$SESSION_MAP")
    assertEquals "CLAUDE_PLUGIN_ROOT/references/loop.md is the fallback" "the fallback map" "$out"
}

test_the_shipped_session_map_fits_the_budget() {
    size=$(sh "$SESSION_MAP" "$REAL_LOOP" | wc -m | tr -d ' ')
    assertTrue "the session map must stay under 1200 characters (C10), measured $size" "[ $size -lt 1200 ]"
    assertTrue "the shipped loop.md must actually yield a map, measured $size" "[ $size -gt 0 ]"
}
