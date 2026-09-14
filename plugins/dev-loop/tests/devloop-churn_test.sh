# Tests for scripts/devloop-churn.
#
# One history serves almost every case: a file touched four times and then deleted, one
# touched three times, two tied on two touches, one touched once, one that only moves
# outside the default 12-month window, and one outside the zone.
#
# Commit dates are pinned rather than left to the clock. They are counted backwards from
# the instant the repository is built, not written as absolute timestamps: git refuses a
# relative string in GIT_AUTHOR_DATE, and an absolute one would drift out of the sliding
# 12-month default window as the months pass, turning a green suite red with nothing
# changed. `git rev-parse --since=now` gives the reference instant without reaching for
# `date`, which the plugin does not use.

DEVLOOP_CHURN_BIN=$(CDPATH='' cd -- "${DEVLOOP_SCRIPT_DIR:-plugins/dev-loop/scripts}" && pwd)/devloop-churn

CHURN_TAB=$(printf '\t')

# The shared history, built once per shell by setUp.
CHURN_REPO=''

# Reference instant of the repository being built, in seconds since the epoch.
CHURN_NOW=0

# Commits whatever is in the working tree, dated $1 days before CHURN_NOW, with the
# message $2. Runs with the test repository as the current directory.
churnCommitDaysAgo() {
    churn_stamp=$((CHURN_NOW - $1 * 86400))
    git add -A
    GIT_AUTHOR_DATE="$churn_stamp +0000" GIT_COMMITTER_DATE="$churn_stamp +0000" \
        git commit -q -m "$2"
}

# Builds the shared history in a throwaway repository named $1 and prints its path.
churnBuildRepo() {
    churn_build_repo=$(newTestRepo "$1")
    CHURN_NOW=$(git -C "$churn_build_repo" rev-parse --since=now)
    CHURN_NOW=${CHURN_NOW#--max-age=}
    (
        cd "$churn_build_repo" || exit 1
        mkdir -p src docs

        # Outside the default window: src/old.txt only ever moves here.
        echo 1 > src/old.txt
        echo 1 > docs/out.txt
        churnCommitDaysAgo 400 'old one'
        echo 2 >> src/old.txt
        churnCommitDaysAgo 390 'old two'

        # Four touches, the last of which removes the file.
        echo 1 > src/gone.txt
        churnCommitDaysAgo 50 'gone one'
        echo 2 >> src/gone.txt
        churnCommitDaysAgo 49 'gone two'
        echo 3 >> src/gone.txt
        churnCommitDaysAgo 48 'gone three'
        rm src/gone.txt
        churnCommitDaysAgo 47 'gone four'

        echo 1 > src/hot.txt
        churnCommitDaysAgo 40 'hot one'
        echo 2 >> src/hot.txt
        churnCommitDaysAgo 39 'hot two'
        echo 3 >> src/hot.txt
        churnCommitDaysAgo 38 'hot three'

        # The tie. tie-b moves last, so the newest-first order of git log offers it
        # first: only the alphabetical rule can put tie-a above it.
        echo 1 > src/tie-a.txt
        churnCommitDaysAgo 30 'tie-a one'
        echo 2 >> src/tie-a.txt
        churnCommitDaysAgo 29 'tie-a two'
        echo 1 > src/tie-b.txt
        churnCommitDaysAgo 28 'tie-b one'
        echo 2 >> src/tie-b.txt
        churnCommitDaysAgo 27 'tie-b two'

        echo 1 > src/cold.txt
        echo 2 >> docs/out.txt
        churnCommitDaysAgo 26 'cold one'
    ) >/dev/null 2>&1
    printf '%s' "$churn_build_repo"
}

setUp() {
    if [ -z "$CHURN_REPO" ]; then
        CHURN_REPO=$(churnBuildRepo churnhistory)
    fi
}

# Runs the script in the shared repository and prints its standard output.
churnRun() {
    ( cd "$CHURN_REPO" && sh "$DEVLOOP_CHURN_BIN" "$@" 2>/dev/null )
}

# Runs the script in the directory $1 and prints its exit code, output discarded.
churnStatusIn() {
    churn_status_dir=$1
    shift
    ( cd "$churn_status_dir" && sh "$DEVLOOP_CHURN_BIN" "$@" >/dev/null 2>&1 )
    echo $?
}

# Counts the lines of $1. An empty string is zero lines, not one.
churnCountLines() {
    if [ -z "$1" ]; then
        echo 0
    else
        printf '%s\n' "$1" | wc -l | awk '{ print $1 }'
    fi
}

test_the_zone_is_ranked_by_count_descending() {
    churn_expected=$(printf '4\t%s\n3\t%s\n2\t%s\n2\t%s\n1\t%s' \
        'src/gone.txt (deleted)' 'src/hot.txt' 'src/tie-a.txt' 'src/tie-b.txt' 'src/cold.txt')
    assertEquals "the whole default listing" "$churn_expected" "$(churnRun src)"
}

test_a_tie_on_count_is_broken_alphabetically() {
    # Restricted to the two tied files, so nothing else can carry the assertion.
    churn_expected=$(printf '2\t%s\n2\t%s' 'src/tie-a.txt' 'src/tie-b.txt')
    assertEquals "tie-a comes first although tie-b moved last" \
        "$churn_expected" "$(churnRun 'src/tie-*.txt')"
}

test_the_two_fields_are_separated_by_a_real_tab() {
    churn_first=$(churnRun src --top 1)
    assertEquals "count, one tab, path" "4${CHURN_TAB}src/gone.txt (deleted)" "$churn_first"
}

test_a_file_that_no_longer_exists_is_marked_deleted() {
    churn_out=$(churnRun src)
    assertTrue "the deleted file carries the marker" \
        "case \"\$churn_out\" in *'src/gone.txt (deleted)'*) true ;; *) false ;; esac"
    assertTrue "a file still on disk carries no marker" \
        "case \"\$churn_out\" in *'src/hot.txt (deleted)'*) false ;; *) true ;; esac"
}

test_top_cuts_the_listing() {
    assertEquals "--top 1 leaves one line" "1" "$(churnCountLines "$(churnRun src --top 1)")"
    assertEquals "--top 3 leaves three lines" "3" "$(churnCountLines "$(churnRun src --top 3)")"
    assertEquals "the default keeps all five" "5" "$(churnCountLines "$(churnRun src)")"
}

test_since_excludes_the_older_commits() {
    churn_default=$(churnRun src)
    assertTrue "the default 12 months leave out a file last touched 390 days ago" \
        "case \"\$churn_default\" in *src/old.txt*) false ;; *) true ;; esac"
    churn_expected=$(printf '4\t%s\n3\t%s\n2\t%s\n2\t%s\n2\t%s\n1\t%s' \
        'src/gone.txt (deleted)' 'src/hot.txt' 'src/old.txt' 'src/tie-a.txt' 'src/tie-b.txt' 'src/cold.txt')
    assertEquals "a wider window brings it back, in its place among the ties" \
        "$churn_expected" "$(churnRun src --since '3 years ago')"
}

test_a_zone_given_as_a_directory_restricts_the_listing() {
    churn_src=$(churnRun src)
    assertTrue "the src zone says nothing about docs" \
        "case \"\$churn_src\" in *docs/*) false ;; *) true ;; esac"
    assertEquals "the docs zone says nothing about src" \
        "1${CHURN_TAB}docs/out.txt" "$(churnRun docs)"
}

test_a_zone_given_as_a_glob_restricts_the_listing() {
    churn_glob=$(churnRun 'src/tie-*.txt')
    assertEquals "only the two files the glob names" "2" "$(churnCountLines "$churn_glob")"
    assertTrue "the most touched file of src is not among them" \
        "case \"\$churn_glob\" in *hot.txt*) false ;; *) true ;; esac"
}

test_a_missing_zone_is_a_bad_argument() {
    assertEquals "no zone, no guess" "2" "$(churnStatusIn "$CHURN_REPO")"
    assertEquals "nothing reaches stdout" "" "$(churnRun)"
}

test_a_top_that_is_not_a_number_is_a_bad_argument() {
    assertEquals "--top abc" "2" "$(churnStatusIn "$CHURN_REPO" src --top abc)"
    assertEquals "nothing reaches stdout" "" "$(churnRun src --top abc)"
}

test_a_top_of_zero_is_a_bad_argument() {
    assertEquals "a listing of zero files is not a listing" \
        "2" "$(churnStatusIn "$CHURN_REPO" src --top 0)"
}

test_a_since_git_cannot_read_is_a_bad_argument() {
    # The case the validation exists for: git's approxidate turns an unreadable date
    # into "now", and the empty listing that follows reads as "nothing changed here".
    assertEquals "--since pippo" "2" "$(churnStatusIn "$CHURN_REPO" src --since pippo)"
    assertEquals "and no empty listing to mistake for an answer" "" "$(churnRun src --since pippo)"
}

test_a_since_git_can_read_is_accepted() {
    assertEquals "a plain date goes through" "0" "$(churnStatusIn "$CHURN_REPO" src --since 2001-01-01)"
    assertEquals "so does an approxidate" "0" "$(churnStatusIn "$CHURN_REPO" src --since '3 years ago')"
}

test_an_unknown_option_is_a_bad_argument() {
    assertEquals "--bogus" "2" "$(churnStatusIn "$CHURN_REPO" src --bogus)"
}

test_outside_a_git_repository_it_refuses() {
    churn_plain=$(newTestDir churnnorepo)
    assertEquals "no repository, no churn" "3" "$(churnStatusIn "$churn_plain" src)"
    assertEquals "stdout stays empty" "" "$( cd "$churn_plain" && sh "$DEVLOOP_CHURN_BIN" src 2>/dev/null )"
}

test_a_truncated_history_is_warned_about_on_stderr() {
    churn_shallow=$(newTestRepo churnshallow)
    (
        cd "$churn_shallow" || exit 1
        mkdir -p src
        echo 1 > src/a.txt
        git add -A
        git commit -q -m 'only one'
        # What a partial clone leaves behind: the boundary commit list git reads to
        # know the history stops here.
        git rev-parse HEAD > .git/shallow
    ) >/dev/null 2>&1
    churn_out=$( cd "$churn_shallow" && sh "$DEVLOOP_CHURN_BIN" src 2>/dev/null )
    churn_err=$( cd "$churn_shallow" && sh "$DEVLOOP_CHURN_BIN" src 2>&1 >/dev/null )
    assertTrue "the warning says the history is truncated" \
        "case \"\$churn_err\" in *shallow*) true ;; *) false ;; esac"
    assertEquals "and it stays out of the listing" "1${CHURN_TAB}src/a.txt" "$churn_out"
}
