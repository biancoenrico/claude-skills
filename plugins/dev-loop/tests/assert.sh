# Assertions and throwaway-directory helpers for the dev-loop test suite.
# Sourced by tests/run.sh before every test file; a test file may source it again
# when it is run on its own.
#
# The shape is borrowed from shunit2 without carrying the library: assertEquals and
# assertTrue behave the way a reader of shunit2 expects, and nothing else is provided.
#
# See the API block at the top of run.sh for how to write a test file.

# Number of failed assertions so far. run.sh reads it to decide whether a test passed.
ASSERT_FAILURES=0

# assertEquals [message] <expected> <actual>
assertEquals() {
    if [ $# -ge 3 ]; then
        _assert_msg=$1
        _assert_expected=$2
        _assert_actual=$3
    else
        _assert_msg=""
        _assert_expected=${1:-}
        _assert_actual=${2:-}
    fi
    if [ "$_assert_expected" = "$_assert_actual" ]; then
        return 0
    fi
    ASSERT_FAILURES=$((ASSERT_FAILURES + 1))
    if [ -n "$_assert_msg" ]; then
        echo "      $_assert_msg"
    fi
    echo "      expected <$_assert_expected> but was <$_assert_actual>"
    return 1
}

# assertTrue [message] <condition>
# The condition is a command line, evaluated in the current shell.
assertTrue() {
    if [ $# -ge 2 ]; then
        _assert_msg=$1
        _assert_cond=$2
    else
        _assert_msg=""
        _assert_cond=${1:-}
    fi
    if eval "$_assert_cond"; then
        return 0
    fi
    ASSERT_FAILURES=$((ASSERT_FAILURES + 1))
    if [ -n "$_assert_msg" ]; then
        echo "      $_assert_msg"
    fi
    echo "      condition was false: $_assert_cond"
    return 1
}

# The root under which every throwaway directory of this run lives.
# No mktemp: the shell PID makes the name unique, and cleanupTestDirs removes the lot.
testWorkRoot() {
    printf '%s/devloop-tests-%s' "${TMPDIR:-/tmp}" "$$"
}

# newTestDir <name> -> prints the path of a fresh, empty directory.
newTestDir() {
    # The name is what separates one test's directory from the run root: without it the
    # caller gets the root, and cleanup takes every other test with it.
    if [ -z "${1:-}" ]; then
        echo "      newTestDir needs a name" >&2
        return 1
    fi
    _test_dir="$(testWorkRoot)/$1"
    rm -rf "$_test_dir"
    mkdir -p "$_test_dir"
    printf '%s' "$_test_dir"
}

# newTestRepo <name> -> prints the path of a fresh directory holding an empty git repository.
newTestRepo() {
    _test_repo="$(newTestDir "$1")"
    (
        cd "$_test_repo" || exit 1
        git init -q
        git config user.email "tests@example.invalid"
        git config user.name "dev-loop tests"
    ) >/dev/null 2>&1
    printf '%s' "$_test_repo"
}

# Removes every throwaway directory of this run. run.sh traps it; a test file may call it.
cleanupTestDirs() {
    rm -rf "$(testWorkRoot)"
}
