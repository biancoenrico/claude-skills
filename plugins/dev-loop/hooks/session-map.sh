# Prints the session map: the slice of loop.md between the two session-map markers.
#
# Reads the file given as the first argument. ${CLAUDE_PLUGIN_ROOT}/references/loop.md is
# only the fallback, because nothing guarantees that variable reaches a child process.
#
# It never blocks a session: a missing file, missing markers or an unclosed opening marker
# all end in exit 0 with an empty stdout and at most one line on stderr.

set -u

map_file=${1:-}
if [ -z "$map_file" ]; then
    map_file="${CLAUDE_PLUGIN_ROOT:-}/references/loop.md"
fi

if [ ! -f "$map_file" ]; then
    echo "session-map: cannot read $map_file" >&2
    exit 0
fi

awk '
/<!-- session-map:start -->/ { collecting = 1; next }
/<!-- session-map:end -->/   { if (collecting) { closed = 1; collecting = 0 } next }
collecting                   { buffer = buffer $0 "\n" }
END {
    if (closed != 1) { exit 1 }
    printf "%s", buffer
}
' "$map_file" || echo "session-map: no closed session-map markers in $map_file" >&2

exit 0
