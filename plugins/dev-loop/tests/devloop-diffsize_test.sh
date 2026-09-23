# Tests for scripts/devloop-diffsize.
#
# The script prints one number, and that number decides whether a batch counts as small.
# So every count is asserted as the whole of stdout, and every refusal as an exit code
# with nothing on stdout: a caller that reads a silent zero takes the small-batch path.
#
# The script under test comes from DEVLOOP_SCRIPT_DIR, resolved once and absolutely,
# because every run happens from inside a throwaway repository.

DEVLOOP_DIFFSIZE_BIN=$(CDPATH='' cd -- "${DEVLOOP_SCRIPT_DIR:-plugins/dev-loop/scripts}" && pwd)/devloop-diffsize

# ---------------------------------------------------------------------------
# Helpers. Every test file is sourced into the same shell, so all of these carry the
# dds prefix.
# ---------------------------------------------------------------------------

# ddsGit <repo> <arguments...> - git inside the repository, quietly.
ddsGit() {
    dds_git_repo=$1
    shift
    (cd "$dds_git_repo" && git "$@") >/dev/null 2>&1
}

# ddsLines <file> <n> - writes n distinct text lines, creating the parent directories.
ddsLines() {
    mkdir -p "$(dirname "$1")"
    : > "$1"
    dds_i=0
    while [ "$dds_i" -lt "$2" ]; do
        dds_i=$((dds_i + 1))
        printf 'line %s\n' "$dds_i" >> "$1"
    done
}

# ddsBinary <file> - writes a file git reads as binary.
ddsBinary() {
    mkdir -p "$(dirname "$1")"
    printf 'bin\000ary\001\002\n' > "$1"
}

# ddsCommit <repo> <message> - commits everything in the working tree.
ddsCommit() {
    ddsGit "$1" add -A
    ddsGit "$1" commit -q --allow-empty -m "$2"
}

# ddsNewRepo <name> -> prints the path of a repository with one empty commit.
ddsNewRepo() {
    dds_repo=$(newTestRepo "$1")
    ddsCommit "$dds_repo" base
    printf '%s' "$dds_repo"
}

# ddsRun <repo> <arguments...> - runs the script from inside the repository.
# Leaves stdout alone in DDS_OUT, stderr thrown away, and the exit code in DDS_STATUS.
ddsRun() {
    dds_run_repo=$1
    shift
    DDS_OUT=$(cd "$dds_run_repo" && sh "$DEVLOOP_DIFFSIZE_BIN" "$@" 2>/dev/null)
    DDS_STATUS=$?
}

# ddsCandidate <name> <path> [arguments...] - one commit adding keep.txt (1 line) and
# <path> (2 lines), counted over that commit. 1 means <path> was taken for a test file,
# 3 means it was counted.
ddsCandidate() {
    dds_cand_repo=$(ddsNewRepo "$1")
    ddsLines "$dds_cand_repo/keep.txt" 1
    ddsLines "$dds_cand_repo/$2" 2
    ddsCommit "$dds_cand_repo" candidate
    shift 2
    ddsRun "$dds_cand_repo" "$@" HEAD~1..HEAD
}

# ---------------------------------------------------------------------------
# Ranges
# ---------------------------------------------------------------------------

test_a_range_counts_added_plus_removed_lines() {
    repo=$(ddsNewRepo diffsize-range)
    ddsLines "$repo/a.txt" 4
    ddsCommit "$repo" four
    printf 'line 1\nchanged\nline 3\n' > "$repo/a.txt"
    ddsCommit "$repo" edit
    ddsRun "$repo" HEAD~1..HEAD
    assertEquals "one line changed and one removed: 2 removed, 1 added" "3" "$DDS_OUT"
    assertEquals "0" "$DDS_STATUS"
}

test_several_ranges_are_summed() {
    repo=$(ddsNewRepo diffsize-ranges)
    ddsLines "$repo/a.txt" 2
    ddsCommit "$repo" first
    ddsLines "$repo/b.txt" 3
    ddsCommit "$repo" second
    ddsRun "$repo" HEAD~2..HEAD~1 HEAD~1..HEAD
    assertEquals "2 lines in the first range plus 3 in the second" "5" "$DDS_OUT"
}

test_a_moved_file_counts_as_removed_and_added() {
    repo=$(ddsNewRepo diffsize-rename)
    ddsLines "$repo/src/a.txt" 3
    ddsCommit "$repo" add
    mkdir -p "$repo/tests"
    ddsGit "$repo" mv src/a.txt tests/a.txt
    ddsCommit "$repo" move
    ddsRun "$repo" HEAD~1..HEAD
    assertEquals "the 3 lines leaving src count; the 3 landing in tests do not" "3" "$DDS_OUT"
}

# ---------------------------------------------------------------------------
# Working tree
# ---------------------------------------------------------------------------

test_without_a_range_it_counts_the_working_tree_against_head() {
    repo=$(ddsNewRepo diffsize-worktree)
    ddsLines "$repo/staged.txt" 2
    ddsLines "$repo/unstaged.txt" 2
    printf 'ignored.txt\n' > "$repo/.gitignore"
    ddsCommit "$repo" tracked
    printf 'line 1\nstaged\n' > "$repo/staged.txt"
    ddsGit "$repo" add staged.txt
    printf 'line 1\nunstaged\n' > "$repo/unstaged.txt"
    ddsLines "$repo/new notes.txt" 3
    ddsLines "$repo/ignored.txt" 50
    ddsRun "$repo"
    assertEquals "2 staged + 2 unstaged + 3 untracked, the ignored file left out" "7" "$DDS_OUT"
    assertEquals "0" "$DDS_STATUS"
}

test_an_untracked_file_in_a_test_directory_is_excluded() {
    repo=$(ddsNewRepo diffsize-untracked-test)
    ddsLines "$repo/keep.txt" 1
    ddsLines "$repo/tests/a.txt" 5
    ddsRun "$repo"
    assertEquals "only keep.txt" "1" "$DDS_OUT"
}

test_non_ascii_paths_are_counted_and_classified() {
    repo=$(ddsNewRepo diffsize-nonascii)
    ddsLines "$repo/caffè.txt" 2
    ddsRun "$repo"
    assertEquals "an untracked caffè.txt counts in full" "2" "$DDS_OUT"
    ddsLines "$repo/tests/caffè.txt" 5
    ddsCommit "$repo" add
    ddsRun "$repo" HEAD~1..HEAD
    assertEquals "in a range, tests/caffè.txt is still a test file" "2" "$DDS_OUT"
}

test_from_a_subdirectory_the_whole_working_tree_is_counted() {
    repo=$(ddsNewRepo diffsize-subdir)
    ddsLines "$repo/top.txt" 2
    ddsLines "$repo/sub/inner.txt" 1
    ddsRun "$repo/sub"
    assertEquals "the untracked top.txt counts from sub too" "3" "$DDS_OUT"
    ddsLines "$repo/tests/a.txt" 5
    ddsRun "$repo/tests"
    assertEquals "from inside tests/, tests/a.txt is still a test file" "3" "$DDS_OUT"
}

test_an_untracked_file_git_cannot_read_is_an_error() {
    repo=$(ddsNewRepo diffsize-quoted)
    ddsLines "$repo/tab$(printf '\t')name.txt" 1
    ddsRun "$repo"
    assertEquals "a quoted name is not a count of zero" "3" "$DDS_STATUS"
    assertEquals "nothing on stdout" "" "$DDS_OUT"
}

test_without_a_range_a_repository_with_no_commit_is_an_error() {
    repo=$(newTestRepo diffsize-nohead)
    ddsLines "$repo/a.txt" 2
    ddsRun "$repo"
    assertEquals "no HEAD to diff against is not a count of zero" "3" "$DDS_STATUS"
    assertEquals "nothing on stdout" "" "$DDS_OUT"
}

# ---------------------------------------------------------------------------
# -- <path>
# ---------------------------------------------------------------------------

test_paths_scope_a_range() {
    repo=$(ddsNewRepo diffsize-scope-range)
    ddsLines "$repo/a.txt" 1
    ddsLines "$repo/b.txt" 10
    ddsLines "$repo/c.txt" 2
    ddsCommit "$repo" three
    ddsRun "$repo" HEAD~1..HEAD -- a.txt c.txt
    assertEquals "a and c only" "3" "$DDS_OUT"
}

test_paths_scope_the_working_tree() {
    repo=$(ddsNewRepo diffsize-scope-worktree)
    ddsLines "$repo/in/tracked.txt" 1
    ddsLines "$repo/out/tracked.txt" 1
    ddsCommit "$repo" tracked
    printf 'changed\n' > "$repo/in/tracked.txt"
    printf 'changed\n' > "$repo/out/tracked.txt"
    ddsLines "$repo/in/new.txt" 3
    ddsLines "$repo/out/new.txt" 30
    ddsLines "$repo/other.txt" 300
    ddsRun "$repo" -- in other.txt
    assertEquals "2 tracked + 3 untracked under in, 300 in other.txt, nothing under out" "305" "$DDS_OUT"
}

# ---------------------------------------------------------------------------
# Binary files
# ---------------------------------------------------------------------------

test_a_tracked_binary_file_counts_zero() {
    repo=$(ddsNewRepo diffsize-binary-tracked)
    ddsBinary "$repo/blob.bin"
    ddsLines "$repo/a.txt" 2
    ddsCommit "$repo" binary
    ddsRun "$repo" HEAD~1..HEAD
    assertEquals "only the text lines" "2" "$DDS_OUT"
    assertEquals "0" "$DDS_STATUS"
}

test_an_untracked_binary_file_counts_zero() {
    repo=$(ddsNewRepo diffsize-binary-untracked)
    ddsBinary "$repo/blob.bin"
    ddsLines "$repo/a.txt" 2
    ddsRun "$repo"
    assertEquals "only the text lines" "2" "$DDS_OUT"
    assertEquals "0" "$DDS_STATUS"
}

# ---------------------------------------------------------------------------
# Test files
# ---------------------------------------------------------------------------

test_a_test_directory_segment_excludes_the_file() {
    for dds_path in test/a.txt src/tests/a.txt src/__tests__/a.txt src/spec/a.txt src/specs/a.txt; do
        ddsCandidate diffsize-segment "$dds_path"
        assertEquals "$dds_path is a test file" "1" "$DDS_OUT"
    done
}

test_a_segment_that_only_contains_test_does_not_exclude() {
    ddsCandidate diffsize-testdata src/testdata/a.txt
    assertEquals "testdata is not the segment test" "3" "$DDS_OUT"
}

test_a_test_name_form_excludes_the_file() {
    for dds_path in foo_test.py foo.test.js foo.spec.ts test_foo.py; do
        ddsCandidate diffsize-name "$dds_path"
        assertEquals "$dds_path is a test file" "1" "$DDS_OUT"
    done
}

test_segments_and_name_forms_ignore_case() {
    for dds_path in src/TESTS/a.txt FOO_TEST.py; do
        ddsCandidate diffsize-case "$dds_path"
        assertEquals "$dds_path is a test file" "1" "$DDS_OUT"
    done
}

test_test_suffixes_exclude_only_with_a_capital_t() {
    for dds_path in FooTest.py FooTests.py; do
        ddsCandidate diffsize-capital "$dds_path"
        assertEquals "$dds_path is a test file" "1" "$DDS_OUT"
    done
    ddsCandidate diffsize-lower footest.py
    assertEquals "footest.py is counted" "3" "$DDS_OUT"
}

test_words_ending_in_test_are_counted() {
    for dds_path in latest.js contest.py; do
        ddsCandidate diffsize-word "$dds_path"
        assertEquals "$dds_path is counted" "3" "$DDS_OUT"
    done
}

test_with_tests_counts_test_files_too() {
    ddsCandidate diffsize-withtests src/tests/a.txt --with-tests
    assertEquals "the test file's 2 lines are back in" "3" "$DDS_OUT"
}

# ---------------------------------------------------------------------------
# Refusals: an exit code and nothing on stdout
# ---------------------------------------------------------------------------

test_a_three_dot_range_is_a_usage_error() {
    repo=$(ddsNewRepo diffsize-threedot)
    ddsLines "$repo/a.txt" 2
    ddsCommit "$repo" add
    ddsRun "$repo" HEAD~1...HEAD
    assertEquals "2" "$DDS_STATUS"
    assertEquals "nothing on stdout" "" "$DDS_OUT"
}

test_a_ref_that_does_not_exist_is_an_error() {
    repo=$(ddsNewRepo diffsize-noref)
    ddsRun "$repo" nosuchref..HEAD
    assertEquals "git refused the range" "3" "$DDS_STATUS"
    assertEquals "nothing on stdout" "" "$DDS_OUT"
}

test_an_argument_that_is_not_a_range_is_a_usage_error() {
    repo=$(ddsNewRepo diffsize-badarg)
    ddsRun "$repo" HEAD
    assertEquals "2" "$DDS_STATUS"
    assertEquals "nothing on stdout" "" "$DDS_OUT"
}
