# Tests for run.sh itself, limited to the one thing use does not verify on its own.
#
# The harness proves itself with every suite that passes through it: a broken assertion
# or a broken discovery turns the whole suite red at once. The filter does not work that
# way. A filter that matches nothing runs no test and has nothing to turn red, so the
# only thing standing between a mistyped filter and a green report is the guard below.

# A tiny suite in its own directory: one file, two tests, both passing.
runnerFixture() {
    _runner_dir=$(newTestDir "$1")
    cp "$DEVLOOP_TESTS_DIR/run.sh" "$DEVLOOP_TESTS_DIR/assert.sh" "$_runner_dir/"
    {
        echo 'test_alpha() { assertEquals 1 1; }'
        echo 'test_beta()  { assertEquals 2 2; }'
    } > "$_runner_dir/sample_test.sh"
    printf '%s' "$_runner_dir"
}

test_a_filter_that_matches_nothing_fails_instead_of_passing() {
    dir=$(runnerFixture emptyrun)
    DEVLOOP_TEST_FILTER='' sh "$dir/run.sh" no_such_test >/dev/null 2>&1
    assertEquals "a run that asserted nothing must not report success" "1" "$?"
}

test_a_filter_selects_a_subset_and_still_passes() {
    dir=$(runnerFixture subset)
    out=$(DEVLOOP_TEST_FILTER='' sh "$dir/run.sh" test_alpha 2>&1)
    status=$?
    assertEquals "selecting one test is a green run" "0" "$status"
    assertTrue "only the selected test ran" "case \"\$out\" in *'1 run, 0 failed'*) true ;; *) false ;; esac"
    assertTrue "the other test did not run" "case \"\$out\" in *test_beta*) false ;; *) true ;; esac"
}
