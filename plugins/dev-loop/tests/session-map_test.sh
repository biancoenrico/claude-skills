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
    # LC_ALL=C wc -c, not wc -m: characters depend on the locale of whoever runs the
    # suite, and a map with any non-ASCII character counts less under UTF-8 than under C.
    # The budget must mean the same thing everywhere, so it is measured in bytes.
    size=$(sh "$SESSION_MAP" "$REAL_LOOP" | LC_ALL=C wc -c | tr -d ' ')
    assertTrue "the session map must stay under 1200 bytes (C10), measured $size" "[ $size -lt 1200 ]"
    assertTrue "the shipped loop.md must actually yield a map, measured $size" "[ $size -gt 0 ]"
}

# Captures the standard error of the script for the file $1, discarding standard output.
sessionMapStderr() {
    sh "$SESSION_MAP" "$1" 2>&1 >/dev/null
}

# Echoes how many lines $1 holds. An empty string is zero lines; piping it through
# `printf '%s\n' | wc -l` counts it as one, which makes "exactly one line on stderr"
# hold just as well when there is no stderr at all.
countLines() {
    if [ -z "$1" ]; then
        echo 0
    else
        printf '%s\n' "$1" | wc -l | tr -d ' '
    fi
}

test_a_missing_file_is_reported_on_stderr() {
    dir=$(newTestDir missingreport)
    err=$(sessionMapStderr "$dir/absent.md")
    lines=$(countLines "$err")
    assertEquals "the caller learns which file could not be read" "1" "$lines"
    assertTrue "the line names the file" "case \"\$err\" in *absent.md*) true ;; *) false ;; esac"
}

test_missing_markers_are_reported_on_stderr() {
    dir=$(newTestDir nomarkersreport)
    printf 'a file with no markers at all\n' > "$dir/loop.md"
    err=$(sessionMapStderr "$dir/loop.md")
    lines=$(countLines "$err")
    assertEquals "a silent empty map would look like a map with nothing in it" "1" "$lines"
}

test_a_closing_marker_on_its_own_is_not_a_map() {
    dir=$(newTestDir loneclose)
    {
        echo "text that was never opened"
        echo "<!-- session-map:end -->"
    } > "$dir/loop.md"
    out=$(sh "$SESSION_MAP" "$dir/loop.md" 2>/dev/null)
    err=$(sessionMapStderr "$dir/loop.md")
    assertEquals "stdout stays empty" "" "$out"
    assertTrue "a lone closing marker is reported, not swallowed" "[ -n \"\$err\" ]"
}

test_an_empty_map_between_the_markers_is_silent() {
    dir=$(newTestDir emptymap)
    {
        echo "<!-- session-map:start -->"
        echo "<!-- session-map:end -->"
    } > "$dir/loop.md"
    out=$(sh "$SESSION_MAP" "$dir/loop.md" 2>/dev/null)
    err=$(sessionMapStderr "$dir/loop.md")
    assertEquals "stdout stays empty" "" "$out"
    assertEquals "a closed pair is a map, even an empty one: nothing to report" "" "$err"
}

test_an_unreadable_file_is_reported_like_a_missing_one() {
    dir=$(newTestDir unreadable)
    writeMarkedFile "$dir/loop.md" "a map nobody can open"
    chmod 000 "$dir/loop.md"
    out=$(sh "$SESSION_MAP" "$dir/loop.md" 2>/dev/null)
    err=$(sessionMapStderr "$dir/loop.md")
    chmod 644 "$dir/loop.md"
    assertEquals "stdout stays empty" "" "$out"
    assertEquals "one line, and it says the file could not be read" "1" "$(countLines "$err")"
    assertTrue "the cause is the file, not the markers" "case \"\$err\" in *'cannot read'*) true ;; *) false ;; esac"
}

test_a_marker_quoted_in_prose_does_not_open_the_map() {
    dir=$(newTestDir quoted)
    {
        echo "The map lives between <!-- session-map:start --> and its closing twin."
        echo "prose that belongs to the document, not to the map"
        echo "<!-- session-map:start -->"
        echo "the real map"
        echo "<!-- session-map:end -->"
    } > "$dir/loop.md"
    out=$(sh "$SESSION_MAP" "$dir/loop.md" 2>/dev/null)
    assertEquals "only a marker on a line of its own counts" "the real map" "$out"
}

test_only_the_first_closed_pair_is_printed() {
    dir=$(newTestDir twopairs)
    {
        echo "<!-- session-map:start -->"
        echo "the map"
        echo "<!-- session-map:end -->"
        echo "<!-- session-map:start -->"
        echo "a second pair nobody asked for"
        echo "<!-- session-map:end -->"
    } > "$dir/loop.md"
    out=$(sh "$SESSION_MAP" "$dir/loop.md" 2>/dev/null)
    assertEquals "a second pair does not extend the map" "the map" "$out"
}
