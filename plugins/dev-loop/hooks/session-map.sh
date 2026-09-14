# Prints the session map: the slice of loop.md between the two session-map markers.
#
# Reads the file given as the first argument. ${CLAUDE_PLUGIN_ROOT}/references/loop.md is
# only the fallback, because nothing guarantees that variable reaches a child process.
#
# It never blocks a session: a missing file, an unreadable one, missing markers or an
# unclosed opening marker all end in exit 0 with an empty stdout and one line on stderr.

set -u

map_file=${1:-}
if [ -z "$map_file" ]; then
    map_file="${CLAUDE_PLUGIN_ROOT:-}/references/loop.md"
fi

if [ ! -f "$map_file" ] || [ ! -r "$map_file" ]; then
    echo "session-map: cannot read $map_file" >&2
    exit 0
fi

# The markers are anchored and only the first closed pair is printed: loop.md is allowed
# to quote its own markers in prose without silently growing the map.
# awk writes the map straight to stdout, so the bytes come out as they went in; its own
# diagnostics are dropped, because the exit status below tells the cause more precisely.
awk '
/^<!-- session-map:start -->[[:space:]]*$/ { if (!closed && !collecting) { collecting = 1 } next }
/^<!-- session-map:end -->[[:space:]]*$/   { if (collecting) { closed = 1; collecting = 0 } next }
collecting                                 { buffer = buffer $0 "\n" }
END {
    if (closed != 1) { exit 1 }
    printf "%s", buffer
}
' "$map_file" 2>/dev/null
status=$?

if [ "$status" -eq 1 ]; then
    echo "session-map: no closed session-map markers in $map_file" >&2
elif [ "$status" -ne 0 ]; then
    echo "session-map: could not read the map from $map_file" >&2
fi

exit 0
