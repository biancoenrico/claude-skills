# Tests for scripts/devloop-mutate.
#
# The script mutates one tracked file, runs a command against the mutated tree and puts
# the file back. What is worth testing is therefore not only the verdict it returns but
# the state it leaves behind: a right exit code on a dirty tree is worth nothing, so the
# two are asserted together wherever both matter.
#
# The script under test comes from DEVLOOP_SCRIPT_DIR, resolved once and absolutely:
# the mutation pass points that variable at a copy outside the tree, and nothing here
# may assume the plugin path.

DEVLOOP_MUTATE_BIN=$(CDPATH='' cd -- "${DEVLOOP_SCRIPT_DIR:-plugins/dev-loop/scripts}" && pwd)/devloop-mutate

# A literal newline, for the <find> that crosses a line end.
DMT_NEWLINE='
'

# ---------------------------------------------------------------------------
# Helpers. Every test file is sourced into the same shell, so all of these carry the
# dmt prefix.
# ---------------------------------------------------------------------------

# dmtNewRepo <name> -> prints the path of a repository holding sample.txt and other.txt,
# both committed.
dmtNewRepo() {
    dmt_repo=$(newTestRepo "$1")
    printf 'alpha\nbeta\ngamma\n' > "$dmt_repo/sample.txt"
    printf 'untouched\n' > "$dmt_repo/other.txt"
    dmtGit "$dmt_repo" add sample.txt other.txt
    dmtGit "$dmt_repo" commit -q -m "sample files"
    printf '%s' "$dmt_repo"
}

# dmtGit <repo> <arguments...> - git inside the repository, quietly.
dmtGit() {
    dmt_git_repo=$1
    shift
    (cd "$dmt_git_repo" && git "$@") >/dev/null 2>&1
}

# dmtWriteScript <path> <body> - a throwaway target command, run as `sh <path>`.
dmtWriteScript() {
    printf '%s\n' "$2" > "$1"
}

# dmtRun <repo> <arguments...> - runs the script from inside the repository.
# Leaves the combined output in DMT_OUT and the exit code in DMT_STATUS.
#
# The redirection wraps the whole group rather than the script alone: the cases that end
# in a SIGKILL make dash announce "Killed" on the standard error in force at that point,
# and an announcement like that in the middle of a passing suite reads as a failure.
dmtRun() {
    dmt_run_repo=$1
    shift
    DMT_OUT=$( { cd "$dmt_run_repo" && sh "$DEVLOOP_MUTATE_BIN" "$@"; } 2>&1 )
    DMT_STATUS=$?
}

# dmtRunStdout <repo> <arguments...> - the same, with standard error thrown away, for
# the cases that must prove stdout stayed empty.
dmtRunStdout() {
    dmt_run_repo=$1
    shift
    DMT_OUT=$( { cd "$dmt_run_repo" && sh "$DEVLOOP_MUTATE_BIN" "$@"; } 2>/dev/null )
    DMT_STATUS=$?
}

# dmtContains <haystack> <needle> -> prints yes or no.
dmtContains() {
    case "$1" in
        *"$2"*) printf 'yes' ;;
        *)      printf 'no' ;;
    esac
}

# dmtIsClean <repo> -> prints yes when the working tree matches HEAD.
dmtIsClean() {
    if (cd "$1" && git diff --quiet HEAD) >/dev/null 2>&1; then
        printf 'yes'
    else
        printf 'no'
    fi
}

# dmtLeftovers <repo> -> prints the names of the lock and the marker still sitting under
# <git-dir>/devloop-mutate, or nothing when the run cleaned up after itself.
dmtLeftovers() {
    dmt_left=''
    if [ -d "$1/.git/devloop-mutate/lock" ]; then
        dmt_left="$dmt_left lock"
    fi
    if [ -f "$1/.git/devloop-mutate/marker" ]; then
        dmt_left="$dmt_left marker"
    fi
    printf '%s' "$dmt_left"
}

# dmtDeadPid -> prints the pid of a process that has already exited.
dmtDeadPid() {
    sh -c 'exit 0' &
    dmt_dead=$!
    wait "$dmt_dead" 2>/dev/null
    printf '%s' "$dmt_dead"
}

# dmtPlantLock <repo> <pid> - writes a lock directory owned by <pid>.
dmtPlantLock() {
    mkdir -p "$1/.git/devloop-mutate/lock"
    printf '%s\n' "$2" > "$1/.git/devloop-mutate/lock/pid"
}

# dmtOrphan <repo> <file> - leaves behind what a run killed mid-flight leaves behind:
# the file mutated, the marker complete, the lock stale. The target command kills its
# own parent with SIGKILL, which is the one signal no trap can catch.
dmtOrphan() {
    dmtWriteScript "$1/killer.sh" 'kill -s KILL "$PPID"
sleep 1'
    dmtRun "$1" "$2" alpha ALPHA -- sh ./killer.sh
}

# ---------------------------------------------------------------------------
# Arguments
# ---------------------------------------------------------------------------

test_without_arguments_it_is_a_usage_error() {
    dir=$(newTestDir mutate-noargs)
    dmtRunStdout "$dir"
    assertEquals "no arguments at all is a wrong call" "2" "$DMT_STATUS"
    assertEquals "the usage goes to stderr, never to stdout" "" "$DMT_OUT"
}

test_a_missing_separator_is_a_usage_error() {
    dir=$(newTestDir mutate-nosep)
    dmtRunStdout "$dir" sample.txt alpha ALPHA true
    assertEquals "-- is mandatory" "2" "$DMT_STATUS"
    assertEquals "nothing on stdout" "" "$DMT_OUT"
}

test_an_empty_command_is_a_usage_error() {
    dir=$(newTestDir mutate-nocmd)
    dmtRunStdout "$dir" sample.txt alpha ALPHA --
    assertEquals "-- must be followed by a command" "2" "$DMT_STATUS"
    assertEquals "nothing on stdout" "" "$DMT_OUT"
}

test_too_many_arguments_before_the_separator_are_a_usage_error() {
    dir=$(newTestDir mutate-extra)
    dmtRunStdout "$dir" sample.txt alpha ALPHA spare -- true
    assertEquals "a fourth argument before -- is a wrong call" "2" "$DMT_STATUS"
    assertEquals "nothing on stdout" "" "$DMT_OUT"
}

test_a_find_equal_to_the_replace_is_a_usage_error() {
    dir=$(newTestDir mutate-same)
    dmtRunStdout "$dir" sample.txt alpha alpha -- true
    assertEquals "a mutation that changes nothing is a wrong call" "2" "$DMT_STATUS"
    assertEquals "nothing on stdout" "" "$DMT_OUT"
}

test_a_find_that_crosses_a_line_end_is_a_usage_error() {
    dir=$(newTestDir mutate-multiline)
    dmtRunStdout "$dir" sample.txt "alpha${DMT_NEWLINE}beta" X -- true
    assertEquals "the substitution works one line at a time" "2" "$DMT_STATUS"
    assertEquals "nothing on stdout" "" "$DMT_OUT"
}

# ---------------------------------------------------------------------------
# Internal error
#
# run.sh runs every file under dash and under bash, which is what this case needs: a
# `trap ... ERR` mechanism would be caught by bash and ignored by dash, and the dash
# half would come back 0.
# ---------------------------------------------------------------------------

test_an_internal_failure_exits_one() {
    repo=$(dmtNewRepo mutate-internal)
    # A regular file where the script needs its own directory: mkdir -p fails, no
    # deliberate exit was taken, and the EXIT trap has to call that an internal error.
    printf 'in the way\n' > "$repo/.git/devloop-mutate"
    dmtRun "$repo" sample.txt alpha ALPHA -- true
    assertEquals "a step that fails with no verdict of ours is an internal error" "1" "$DMT_STATUS"
}

# ---------------------------------------------------------------------------
# Verdicts
# ---------------------------------------------------------------------------

test_a_failing_command_says_the_mutation_was_caught() {
    repo=$(dmtNewRepo mutate-caught)
    dmtWriteScript "$repo/cmd.sh" 'exit 1'
    dmtRun "$repo" sample.txt alpha ALPHA -- sh ./cmd.sh
    assertEquals "a command that fails killed the mutant" "10" "$DMT_STATUS"
}

test_a_passing_command_says_the_mutation_survived() {
    repo=$(dmtNewRepo mutate-survived)
    dmtWriteScript "$repo/cmd.sh" 'exit 0'
    dmtRun "$repo" sample.txt alpha ALPHA -- sh ./cmd.sh
    assertEquals "a command that passes let the mutant through" "11" "$DMT_STATUS"
}

test_a_command_that_does_not_exist_gives_no_verdict() {
    repo=$(dmtNewRepo mutate-notfound)
    dmtRun "$repo" sample.txt alpha ALPHA -- devloop-no-such-command
    assertEquals "127 is not a verdict about the mutation" "12" "$DMT_STATUS"
}

test_a_command_that_cannot_be_executed_gives_no_verdict() {
    repo=$(dmtNewRepo mutate-noexec)
    # Written without the executable bit, so running it is a 126.
    dmtWriteScript "$repo/cmd.sh" 'exit 0'
    dmtRun "$repo" sample.txt alpha ALPHA -- "$repo/cmd.sh"
    assertEquals "126 is not a verdict about the mutation" "12" "$DMT_STATUS"
}

test_a_command_killed_by_a_signal_gives_no_verdict() {
    repo=$(dmtNewRepo mutate-signalled)
    dmtWriteScript "$repo/cmd.sh" 'kill -s KILL "$$"'
    dmtRun "$repo" sample.txt alpha ALPHA -- sh ./cmd.sh
    assertEquals "a command killed by a signal never said anything" "12" "$DMT_STATUS"
}

# ---------------------------------------------------------------------------
# The mutation itself, and what the run leaves behind
# ---------------------------------------------------------------------------

test_the_command_sees_the_mutated_file() {
    repo=$(dmtNewRepo mutate-sees)
    dmtWriteScript "$repo/cmd.sh" 'cat "$1" > "$2"'
    dmtRun "$repo" sample.txt alpha ALPHA -- sh ./cmd.sh "$repo/sample.txt" "$repo/seen.txt"
    seen=$(cat "$repo/seen.txt")
    assertEquals "the command runs against the substituted text" "ALPHA
beta
gamma" "$seen"
}

test_the_file_comes_back_and_nothing_is_left_behind() {
    repo=$(dmtNewRepo mutate-restored)
    dmtWriteScript "$repo/cmd.sh" 'exit 1'
    dmtRun "$repo" sample.txt alpha ALPHA -- sh ./cmd.sh
    assertEquals "the working tree is back on HEAD" "yes" "$(dmtIsClean "$repo")"
    assertEquals "neither the lock nor the marker survives a finished run" "" "$(dmtLeftovers "$repo")"
}

test_the_command_output_reaches_the_caller() {
    repo=$(dmtNewRepo mutate-tail)
    dmtWriteScript "$repo/cmd.sh" 'echo "the assertion of the target test failed"
exit 1'
    dmtRun "$repo" sample.txt alpha ALPHA -- sh ./cmd.sh
    assertEquals "the tail of the output tells an assertion from a build error" \
        "yes" "$(dmtContains "$DMT_OUT" "the assertion of the target test failed")"
}

test_a_file_without_a_final_newline_does_not_gain_one() {
    repo=$(dmtNewRepo mutate-nonewline)
    printf 'alpha beta' > "$repo/nonl.txt"
    dmtGit "$repo" add nonl.txt
    dmtGit "$repo" commit -q -m "a file with no final newline"
    dmtWriteScript "$repo/cmd.sh" 'cat "$1" > "$2"'
    dmtRun "$repo" nonl.txt alpha ALPHA -- sh ./cmd.sh "$repo/nonl.txt" "$repo/seen.txt"

    # The mutated file must differ from the original in the substitution and in nothing
    # else. A newline added here is the natural mistake of awk, and a style test tripping
    # over it would report a killed mutant that nobody wrote.
    printf 'ALPHA beta' > "$repo/expected-mutated"
    assertTrue "the mutated file gains no final newline" \
        "cmp -s \"\$repo/seen.txt\" \"\$repo/expected-mutated\""

    (cd "$repo" && git show "HEAD:./nonl.txt" > "$repo/expected-head") >/dev/null 2>&1
    assertTrue "the restored file matches HEAD byte for byte" \
        "cmp -s \"\$repo/nonl.txt\" \"\$repo/expected-head\""
}

test_what_the_command_changed_is_reported_and_left_alone() {
    repo=$(dmtNewRepo mutate-status)
    dmtWriteScript "$repo/cmd.sh" 'printf "rewritten by the command\n" > "$1"'
    dmtRun "$repo" sample.txt alpha ALPHA -- sh ./cmd.sh "$repo/other.txt"
    assertEquals "what the command left behind is named" "yes" "$(dmtContains "$DMT_OUT" "other.txt")"
    assertEquals "our own mutation is not blamed on the command" "no" "$(dmtContains "$DMT_OUT" "sample.txt")"
    other=$(cat "$repo/other.txt")
    assertEquals "the change is reported, not undone" "rewritten by the command" "$other"
}

test_a_command_that_rewrites_the_mutated_file_stops_the_restore() {
    repo=$(dmtNewRepo mutate-rewritten)
    dmtWriteScript "$repo/cmd.sh" 'printf "a formatter got here first\n" > "$1"'
    dmtRun "$repo" sample.txt alpha ALPHA -- sh ./cmd.sh "$repo/sample.txt"
    assertEquals "the restore is impossible and says so" "4" "$DMT_STATUS"
    content=$(cat "$repo/sample.txt")
    assertEquals "nothing is overwritten in silence" "a formatter got here first" "$content"
    assertTrue "the original copy is kept for whoever sorts it out" "[ -f \"\$repo/.git/devloop-mutate/original\" ]"
    assertTrue "so is the mutated copy" "[ -f \"\$repo/.git/devloop-mutate/mutated\" ]"
    assertEquals "the paths of the copies are printed" "yes" "$(dmtContains "$DMT_OUT" "devloop-mutate/original")"
}

# ---------------------------------------------------------------------------
# Interruption
# ---------------------------------------------------------------------------

test_a_term_while_the_command_runs_restores_and_gives_no_verdict() {
    repo=$(dmtNewRepo mutate-term)
    # The child records the pid of the script that started it, so the signal reaches the
    # script itself and not the shell around it, then stays alive long enough to be
    # interrupted. The file is already mutated by the time the child exists at all.
    dmtWriteScript "$repo/sleeper.sh" 'printf "%s\n" "$PPID" > "$1"
sleep 1'
    (cd "$repo" && sh "$DEVLOOP_MUTATE_BIN" sample.txt alpha ALPHA -- \
        sh ./sleeper.sh "$repo/parent.pid") >/dev/null 2>&1 &
    waited=$!

    tries=0
    while [ ! -s "$repo/parent.pid" ] && [ "$tries" -lt 200 ]; do
        tries=$((tries + 1))
        sleep 0.05 2>/dev/null || sleep 1
    done
    target=''
    read -r target < "$repo/parent.pid" || target=''
    kill -TERM "$target" 2>/dev/null
    wait "$waited"
    status=$?

    assertEquals "an interrupted run gave no verdict about the mutation" "12" "$status"
    assertEquals "and it still put the file back" "yes" "$(dmtIsClean "$repo")"
    assertEquals "nothing of ours survives the interruption" "" "$(dmtLeftovers "$repo")"
}

# ---------------------------------------------------------------------------
# The order of the mutation: copy, marker, trap, substitution
# ---------------------------------------------------------------------------

test_a_killed_run_leaves_the_file_mutated_and_a_complete_marker() {
    repo=$(dmtNewRepo mutate-killed)
    dmtOrphan "$repo" sample.txt
    content=$(cat "$repo/sample.txt")
    assertEquals "the file stays mutated: nobody was left to restore it" "ALPHA
beta
gamma" "$content"
    # Complete means all three paths: the file and the two copies. Written before the
    # substitution, so a mutated file can always be attributed to us.
    lines=$(awk 'END { print NR }' "$repo/.git/devloop-mutate/marker")
    assertEquals "the marker names the file and both copies" "3" "$lines"
    assertTrue "the original copy was taken first of all" "[ -f \"\$repo/.git/devloop-mutate/original\" ]"
    assertTrue "the mutated copy is there too" "[ -f \"\$repo/.git/devloop-mutate/mutated\" ]"
}

test_the_next_run_restores_the_orphan_marker() {
    repo=$(dmtNewRepo mutate-orphan)
    dmtOrphan "$repo" sample.txt
    dmtWriteScript "$repo/cmd.sh" 'exit 0'
    dmtRun "$repo" sample.txt beta BETA -- sh ./cmd.sh
    assertEquals "an orphan mutation is restored and the new one does not start" "5" "$DMT_STATUS"
    assertEquals "the working tree is back on HEAD" "yes" "$(dmtIsClean "$repo")"
    assertEquals "the marker and the stale lock are gone" "" "$(dmtLeftovers "$repo")"
}

test_an_orphan_marker_whose_file_changed_is_left_alone() {
    repo=$(dmtNewRepo mutate-orphan-changed)
    dmtOrphan "$repo" sample.txt
    printf 'somebody fixed this by hand\n' > "$repo/sample.txt"
    dmtWriteScript "$repo/cmd.sh" 'exit 0'
    dmtRun "$repo" sample.txt beta BETA -- sh ./cmd.sh
    assertEquals "a file that moved since is not overwritten" "4" "$DMT_STATUS"
    content=$(cat "$repo/sample.txt")
    assertEquals "the hand-written fix survives" "somebody fixed this by hand" "$content"
    assertTrue "the marker is left for whoever sorts it out" "[ -f \"\$repo/.git/devloop-mutate/marker\" ]"
    assertTrue "and so are the copies" "[ -f \"\$repo/.git/devloop-mutate/original\" ]"
    assertEquals "the paths are printed" "yes" "$(dmtContains "$DMT_OUT" "devloop-mutate/mutated")"
}

test_the_marker_decides_even_when_it_names_another_file() {
    repo=$(dmtNewRepo mutate-orphan-otherfile)
    dmtOrphan "$repo" sample.txt
    dmtWriteScript "$repo/cmd.sh" 'exit 0'
    # The request is about other.txt; the comparison is about the file the marker records.
    dmtRun "$repo" other.txt untouched TOUCHED -- sh ./cmd.sh
    assertEquals "the marker decides, whatever was asked for" "5" "$DMT_STATUS"
    sample=$(cat "$repo/sample.txt")
    assertEquals "the file the marker named is the one restored" "alpha
beta
gamma" "$sample"
}

# ---------------------------------------------------------------------------
# The four startup checks, and their fixed order
# ---------------------------------------------------------------------------

test_a_lock_held_by_a_live_process_is_refused() {
    repo=$(dmtNewRepo mutate-lock-live)
    dmtPlantLock "$repo" "$$"
    dmtWriteScript "$repo/cmd.sh" 'exit 0'
    dmtRun "$repo" sample.txt alpha ALPHA -- sh ./cmd.sh
    assertEquals "somebody else is mutating this repository" "3" "$DMT_STATUS"
    owner=''
    read -r owner < "$repo/.git/devloop-mutate/lock/pid" || owner=''
    assertEquals "a refused run does not take somebody else's lock away" "$$" "$owner"
}

test_a_stale_lock_is_taken_over() {
    repo=$(dmtNewRepo mutate-lock-stale)
    dmtPlantLock "$repo" "$(dmtDeadPid)"
    dmtWriteScript "$repo/cmd.sh" 'exit 0'
    dmtRun "$repo" sample.txt alpha ALPHA -- sh ./cmd.sh
    assertEquals "a lock whose owner is gone is no lock at all" "11" "$DMT_STATUS"
    assertEquals "and it is released like any other" "" "$(dmtLeftovers "$repo")"
}

test_an_untracked_file_is_refused() {
    repo=$(dmtNewRepo mutate-untracked)
    printf 'alpha\n' > "$repo/fresh.txt"
    dmtRun "$repo" fresh.txt alpha ALPHA -- true
    assertEquals "git is the only way back" "3" "$DMT_STATUS"
}

test_a_file_that_differs_from_head_is_refused() {
    repo=$(dmtNewRepo mutate-dirty)
    printf 'alpha\nbeta\ngamma\ndelta\n' > "$repo/sample.txt"
    dmtRun "$repo" sample.txt alpha ALPHA -- true
    assertEquals "a dirty file has changes of somebody else's to lose" "3" "$DMT_STATUS"
}

test_a_find_that_is_absent_is_refused() {
    repo=$(dmtNewRepo mutate-absent)
    dmtRun "$repo" sample.txt "no such text" X -- true
    assertEquals "nothing to mutate" "3" "$DMT_STATUS"
    assertEquals "the working tree is untouched" "yes" "$(dmtIsClean "$repo")"
}

test_a_find_repeated_on_one_line_is_refused() {
    repo=$(dmtNewRepo mutate-repeated)
    # Occurrences, not lines: these two sit on the same line and are still two.
    printf 'aa bb aa\n' > "$repo/twice.txt"
    dmtGit "$repo" add twice.txt
    dmtGit "$repo" commit -q -m "twice on one line"
    dmtRun "$repo" twice.txt aa ZZ -- true
    assertEquals "two on one line are two occurrences" "3" "$DMT_STATUS"
}

test_outside_a_git_repository_it_is_refused() {
    dir=$(newTestDir mutate-norepo)
    printf 'alpha\n' > "$dir/sample.txt"
    dmtRun "$dir" sample.txt alpha ALPHA -- true
    assertEquals "with no git there is no way back" "3" "$DMT_STATUS"
}

test_a_live_lock_wins_over_an_orphan_marker() {
    repo=$(dmtNewRepo mutate-order-lock)
    dmtOrphan "$repo" sample.txt
    dmtPlantLock "$repo" "$$"
    dmtWriteScript "$repo/cmd.sh" 'exit 0'
    dmtRun "$repo" sample.txt beta BETA -- sh ./cmd.sh
    assertEquals "the lock is checked first" "3" "$DMT_STATUS"
    assertTrue "the orphan marker is somebody else's business now" \
        "[ -f \"\$repo/.git/devloop-mutate/marker\" ]"
}

test_the_orphan_marker_wins_over_a_missing_find() {
    repo=$(dmtNewRepo mutate-order-marker)
    dmtOrphan "$repo" sample.txt
    dmtWriteScript "$repo/cmd.sh" 'exit 0'
    dmtRun "$repo" sample.txt "no such text" X -- sh ./cmd.sh
    assertEquals "the marker is checked before the file and the find" "5" "$DMT_STATUS"
    assertEquals "the working tree is back on HEAD" "yes" "$(dmtIsClean "$repo")"
}
