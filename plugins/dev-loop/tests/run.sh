# The dev-loop test runner. One command runs everything:
#
#     sh plugins/dev-loop/tests/run.sh
#
# It relaunches itself under dash and under bash, because half of criterion C7 is proving
# the scripts survive both. A shell that is not installed is reported and skipped: a
# missing environment is not a red test, and this plugin is public and cannot demand dash.
#
# ---------------------------------------------------------------------------
# How to write a test file
#
#   * One file per script under test, named <script>_test.sh, in this directory.
#     run.sh discovers it; nothing here needs editing.
#   * Inside it, every function whose name starts with test_ is a test. The name must
#     be at the start of a line, in the form:  test_something() {
#   * Assertions come from assert.sh, which run.sh has already sourced:
#         assertEquals "message" "expected" "actual"
#         assertTrue   "message" "[ -f some/file ]"
#     Both take the message as an optional first argument.
#   * Throwaway directories come from assert.sh too, and never from mktemp (forbidden):
#         dir=$(newTestDir mycase)        # empty directory
#         repo=$(newTestRepo mycase)      # empty git repository
#     run.sh removes all of them on exit, however it exits.
#   * setUp and tearDown are optional. Define either and it runs around every test of
#     that file; they are reset to no-ops before each file.
#   * A test fails when one of its assertions fails. Nothing else is inspected, so a test
#     that asserts nothing passes.
#
# Environment: POSIX shell only. DEVLOOP_TESTS_DIR holds this directory.
# ---------------------------------------------------------------------------

set -u

tests_dir=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)
DEVLOOP_TESTS_DIR=$tests_dir
export DEVLOOP_TESTS_DIR

# ---------------------------------------------------------------------------
# Driver pass: pick the shells and relaunch this same file under each of them.
# ---------------------------------------------------------------------------
if [ -z "${DEVLOOP_TEST_SHELL:-}" ]; then
    driver_status=0
    shells_run=''
    for candidate in dash bash; do
        if command -v "$candidate" >/dev/null 2>&1; then
            echo "=== $candidate ==="
            DEVLOOP_TEST_SHELL="$candidate" "$candidate" "$tests_dir/run.sh" || driver_status=1
            shells_run="$shells_run $candidate"
        else
            echo "!!! $candidate is not installed: the $candidate half of the shell"
            echo "!!! portability check DID NOT RUN. This is not a failure, but the"
            echo "!!! suite proved less than it claims to."
        fi
    done
    if [ -z "$shells_run" ]; then
        echo "=== sh (fallback: neither dash nor bash was found) ==="
        DEVLOOP_TEST_SHELL="sh" sh "$tests_dir/run.sh" || driver_status=1
    fi
    exit "$driver_status"
fi

# ---------------------------------------------------------------------------
# Worker pass: one shell, every test file.
# ---------------------------------------------------------------------------
. "$tests_dir/assert.sh"

trap 'cleanupTestDirs' EXIT
trap 'cleanupTestDirs; exit 1' HUP INT TERM

tests_total=0
tests_failed=0
files_seen=0

for test_file in "$tests_dir"/*_test.sh; do
    [ -f "$test_file" ] || continue
    files_seen=$((files_seen + 1))
    echo "  $(basename "$test_file")"

    # Fresh no-op hooks, so a previous file's setUp cannot leak into this one.
    setUp() { :; }
    tearDown() { :; }

    # shellcheck source=/dev/null
    . "$test_file"

    test_names=$(sed -n 's/^\(test_[A-Za-z0-9_]*\)[ 	]*()[ 	]*{.*/\1/p' "$test_file")
    for test_name in $test_names; do
        tests_total=$((tests_total + 1))
        failures_before=$ASSERT_FAILURES
        setUp
        "$test_name"
        tearDown
        if [ "$ASSERT_FAILURES" -gt "$failures_before" ]; then
            tests_failed=$((tests_failed + 1))
            echo "    FAIL $test_name"
        else
            echo "    ok   $test_name"
        fi
    done
done

if [ "$files_seen" -eq 0 ]; then
    echo "  no *_test.sh file found in $tests_dir"
fi

echo "  $DEVLOOP_TEST_SHELL: $tests_total run, $tests_failed failed"
if [ "$tests_failed" -gt 0 ]; then
    echo "  FAILED under $DEVLOOP_TEST_SHELL"
    exit 1
fi
exit 0
