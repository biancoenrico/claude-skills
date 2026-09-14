# Tests for scripts/devloop-comment-gates.
#
# The script reads comments and prints findings as file:line:check:text, and the split
# rule of that line is the first thing tested: a comment of its own may carry colons.
# Every case works in a throwaway directory, never in this repository.

# The script under test, resolved once, as an absolute path: the test runs after a cd
# into a throwaway directory, and DEVLOOP_SCRIPT_DIR lets a mutation pass point the
# suite at a copy of the script without touching either the tests or the plugin.
DEVLOOP_GATES_BIN=$(CDPATH='' cd -- "${DEVLOOP_SCRIPT_DIR:-plugins/dev-loop/scripts}" && pwd)/devloop-comment-gates

# gatesWrite <file> <line>... - writes the lines to the file, one per line.
gatesWrite() {
    gates_target=$1
    shift
    : > "$gates_target"
    for gates_line in "$@"; do
        printf '%s\n' "$gates_line" >> "$gates_target"
    done
}

# gatesCountLines <text> - an empty text is zero lines, not one.
gatesCountLines() {
    if [ -z "$1" ]; then
        echo 0
    else
        printf '%s\n' "$1" | awk 'END { print NR }'
    fi
}

# The three splits of a finding, in the order the header of the script fixes them.
gatesField1() { printf '%s' "${1%%:*}"; }
gatesField2() { gates_rest=${1#*:}; printf '%s' "${gates_rest%%:*}"; }
gatesField3() { gates_rest=${1#*:}; gates_rest=${gates_rest#*:}; printf '%s' "${gates_rest%%:*}"; }
gatesText()   { gates_rest=${1#*:}; gates_rest=${gates_rest#*:}; printf '%s' "${gates_rest#*:}"; }

test_a_colon_in_the_comment_text_survives_the_split() {
    dir=$(newTestDir gatescolon)
    gatesWrite "$dir/a.js" "// TODO: this waits for batch 3"
    out=$(cd "$dir" && sh "$DEVLOOP_GATES_BIN" a.js 2>/dev/null)
    assertEquals "one comment, one finding" "1" "$(gatesCountLines "$out")"
    assertEquals "the check is the third field" "process-ref" "$(gatesField3 "$out")"
    assertEquals "everything after the third colon is the text" \
        "TODO: this waits for batch 3" "$(gatesText "$out")"
    assertEquals "the file is the first field" "a.js" "$(gatesField1 "$out")"
    assertEquals "the line is the second field" "1" "$(gatesField2 "$out")"
}

test_process_ref_fires_on_the_base_list() {
    dir=$(newTestDir gatesprocess)
    gatesWrite "$dir/a.js" "// batch 3 will finish this"
    out=$(cd "$dir" && sh "$DEVLOOP_GATES_BIN" a.js 2>/dev/null)
    assertEquals "only process-ref fires" "1" "$(gatesCountLines "$out")"
    assertEquals "the base list holds batch N" "process-ref" "$(gatesField3 "$out")"
}

test_line_ref_fires_on_a_quoted_line_number() {
    dir=$(newTestDir gateslineref)
    gatesWrite "$dir/a.js" "// see parser.js:42 for the rest"
    out=$(cd "$dir" && sh "$DEVLOOP_GATES_BIN" a.js 2>/dev/null)
    assertEquals "only line-ref fires" "1" "$(gatesCountLines "$out")"
    assertEquals "a quoted line number is a line-ref" "line-ref" "$(gatesField3 "$out")"
}

test_tense_fires_on_a_past_form() {
    dir=$(newTestDir gatestense)
    gatesWrite "$dir/a.js" "// this was needed by the caller"
    out=$(cd "$dir" && sh "$DEVLOOP_GATES_BIN" a.js 2>/dev/null)
    assertEquals "only tense fires" "1" "$(gatesCountLines "$out")"
    assertEquals "a past form is a tense finding" "tense" "$(gatesField3 "$out")"
}

test_a_block_comment_is_reported_once() {
    dir=$(newTestDir gatesblock)
    gatesWrite "$dir/a.js" \
        "/*" \
        " * batch 3 owns this." \
        " * batch 4 owns that." \
        " */" \
        "var x = 1;"
    out=$(cd "$dir" && sh "$DEVLOOP_GATES_BIN" a.js 2>/dev/null)
    assertEquals "the block is one unit, whatever it repeats" "1" "$(gatesCountLines "$out")"
    assertEquals "the line is the one the block opens on" "1" "$(gatesField2 "$out")"
}

test_an_unknown_extension_is_skipped_and_listed() {
    dir=$(newTestDir gatesunknown)
    gatesWrite "$dir/notes.xyz" "# batch 3 owns this"
    out=$(cd "$dir" && sh "$DEVLOOP_GATES_BIN" notes.xyz 2>/dev/null)
    status=$?
    err=$(cd "$dir" && sh "$DEVLOOP_GATES_BIN" notes.xyz 2>&1 >/dev/null)
    assertEquals "a file nobody can read is no finding" "" "$out"
    assertEquals "skipping a file is not a failure" "0" "$status"
    assertTrue "the skipped file is named on stderr" \
        "case \"\$err\" in *notes.xyz*) true ;; *) false ;; esac"
}

test_a_term_from_the_terms_file_fires_process_ref() {
    dir=$(newTestDir gatesterms)
    gatesWrite "$dir/a.js" "// frobnicate this later"
    gatesWrite "$dir/terms.txt" "frobnicate"
    out=$(cd "$dir" && sh "$DEVLOOP_GATES_BIN" --terms terms.txt a.js 2>/dev/null)
    assertEquals "the added term fires process-ref" "process-ref" "$(gatesField3 "$out")"
    bare=$(cd "$dir" && sh "$DEVLOOP_GATES_BIN" a.js 2>/dev/null)
    assertEquals "and fires nothing without the file" "" "$bare"
}

test_an_unreadable_terms_file_is_a_bad_argument() {
    dir=$(newTestDir gatesnoterms)
    gatesWrite "$dir/a.js" "// a plain comment"
    out=$(cd "$dir" && sh "$DEVLOOP_GATES_BIN" --terms absent.txt a.js 2>/dev/null)
    status=$?
    assertEquals "a terms file that is not there is a bad argument" "2" "$status"
    assertEquals "stdout stays empty" "" "$out"
}

# c6-exempt:start
# The fixture of the next case has to be written in the language it tests, which is why
# it sits in the region that tests/checks.sh cuts out before it forbids non-English
# prose in the plugin.
GATES_IT_FIXTURE="// questo era necessario"
# c6-exempt:end

test_the_italian_patterns_need_lang_it() {
    dir=$(newTestDir gateslangit)
    gatesWrite "$dir/a.js" "$GATES_IT_FIXTURE"
    out=$(cd "$dir" && sh "$DEVLOOP_GATES_BIN" --lang it a.js 2>/dev/null)
    assertEquals "the italian past form fires tense" "tense" "$(gatesField3 "$out")"
    en=$(cd "$dir" && sh "$DEVLOOP_GATES_BIN" --lang en a.js 2>/dev/null)
    assertEquals "the english patterns do not read italian" "" "$en"
}

test_an_unknown_language_skips_the_tense_check() {
    dir=$(newTestDir gateslangde)
    gatesWrite "$dir/a.js" "// this was needed by the caller"
    out=$(cd "$dir" && sh "$DEVLOOP_GATES_BIN" --lang de a.js 2>/dev/null)
    status=$?
    err=$(cd "$dir" && sh "$DEVLOOP_GATES_BIN" --lang de a.js 2>&1 >/dev/null)
    assertEquals "a language nobody wrote patterns for finds nothing" "" "$out"
    assertEquals "a skipped check is still a complete run" "0" "$status"
    assertTrue "the skipped check is named on stderr" \
        "case \"\$err\" in *tense*) true ;; *) false ;; esac"
}

test_a_tracked_name_is_not_missing() {
    repo=$(newTestRepo gatestracked)
    gatesWrite "$repo/doc.js" "// the helper \`ghostHelper\` does the work"
    gatesWrite "$repo/lib.js" "function ghostHelper() { return 1; }"
    (cd "$repo" && git add doc.js lib.js && git commit -qm one) >/dev/null 2>&1
    out=$(cd "$repo" && sh "$DEVLOOP_GATES_BIN" doc.js 2>/dev/null)
    assertEquals "a name the repository carries is no finding" "" "$out"
}

test_a_name_only_in_an_untracked_file_is_missing() {
    repo=$(newTestRepo gatesuntracked)
    gatesWrite "$repo/doc.js" "// the helper \`ghostHelper\` does the work"
    (cd "$repo" && git add doc.js && git commit -qm one) >/dev/null 2>&1
    # Untracked on purpose: git grep does not see it, which is the declared limit of
    # the check, and the finding it produces is that false positive.
    gatesWrite "$repo/lib.js" "function ghostHelper() { return 1; }"
    out=$(cd "$repo" && sh "$DEVLOOP_GATES_BIN" doc.js 2>/dev/null)
    assertEquals "one finding, and it is missing-name" "1" "$(gatesCountLines "$out")"
    assertEquals "git grep only sees tracked files" "missing-name" "$(gatesField3 "$out")"
}

test_base_reports_only_the_comments_that_changed() {
    repo=$(newTestRepo gatesbase)
    gatesWrite "$repo/x.js" \
        "// after the review this one stays" \
        "" \
        "// after the review this one changes"
    (cd "$repo" && git add x.js && git commit -qm one) >/dev/null 2>&1
    gatesWrite "$repo/x.js" \
        "// after the review this one stays" \
        "" \
        "// after the review this one moved on"
    out=$(cd "$repo" && sh "$DEVLOOP_GATES_BIN" --base HEAD x.js 2>/dev/null)
    assertEquals "an untouched comment is out of scope" "1" "$(gatesCountLines "$out")"
    assertEquals "the finding is the comment that changed" "3" "$(gatesField2 "$out")"
    assertTrue "and it carries the new text" \
        "case \"\$out\" in *'moved on'*) true ;; *) false ;; esac"
}

test_lost_fact_names_the_line_of_the_base_version() {
    repo=$(newTestRepo gateslostfact)
    gatesWrite "$repo/r.js" "// the retry limit is 42 attempts"
    (cd "$repo" && git add r.js && git commit -qm one) >/dev/null 2>&1
    gatesWrite "$repo/r.js" "// the retry limit is now smaller"
    out=$(cd "$repo" && sh "$DEVLOOP_GATES_BIN" --base HEAD r.js 2>/dev/null)
    assertEquals "one number dropped, one finding" "1" "$(gatesCountLines "$out")"
    assertEquals "a number the rewrite dropped is a lost fact" "lost-fact" "$(gatesField3 "$out")"
    assertEquals "the line is the one of the base version, with an @" "base@1" "$(gatesField2 "$out")"
    assertTrue "the text names what was dropped" \
        "case \"\$out\" in *42*) true ;; *) false ;; esac"
}

test_a_number_put_back_elsewhere_is_not_lost() {
    repo=$(newTestRepo gateskeptfact)
    gatesWrite "$repo/r.js" "// the retry limit is 42 attempts"
    (cd "$repo" && git add r.js && git commit -qm one) >/dev/null 2>&1
    gatesWrite "$repo/r.js" "// the caller retries 42 times"
    out=$(cd "$repo" && sh "$DEVLOOP_GATES_BIN" --base HEAD r.js 2>/dev/null)
    assertEquals "a fact the rewrite kept is not lost" "" "$out"
}

test_an_unresolvable_base_ref_exits_three() {
    repo=$(newTestRepo gatesbadref)
    gatesWrite "$repo/a.js" "// a plain comment"
    (cd "$repo" && git add a.js && git commit -qm one) >/dev/null 2>&1
    out=$(cd "$repo" && sh "$DEVLOOP_GATES_BIN" --base nosuchref a.js 2>/dev/null)
    status=$?
    assertEquals "a ref git cannot resolve is not a bad argument" "3" "$status"
    assertEquals "stdout stays empty" "" "$out"
}

test_outside_a_repository_two_checks_are_skipped_and_said_so() {
    dir=$(newTestDir gatesnorepo)
    gatesWrite "$dir/a.js" \
        "// this was needed by \`ghostHelper\`"
    out=$(cd "$dir" && sh "$DEVLOOP_GATES_BIN" a.js 2>/dev/null)
    status=$?
    err=$(cd "$dir" && sh "$DEVLOOP_GATES_BIN" a.js 2>&1 >/dev/null)
    assertEquals "a complete run, two checks short" "0" "$status"
    assertEquals "the checks that need no repository still run" "1" "$(gatesCountLines "$out")"
    assertEquals "and the one that fires is tense" "tense" "$(gatesField3 "$out")"
    assertTrue "missing-name is declared skipped" \
        "case \"\$err\" in *missing-name*) true ;; *) false ;; esac"
    assertTrue "lost-fact is declared skipped" \
        "case \"\$err\" in *lost-fact*) true ;; *) false ;; esac"
}

test_base_outside_a_repository_is_a_bad_argument() {
    dir=$(newTestDir gatesnorepobase)
    gatesWrite "$dir/a.js" "// a plain comment"
    out=$(cd "$dir" && sh "$DEVLOOP_GATES_BIN" --base HEAD a.js 2>/dev/null)
    status=$?
    assertEquals "there is no repository to resolve the ref against" "2" "$status"
    assertEquals "stdout stays empty" "" "$out"
}

test_no_findings_leaves_stdout_empty() {
    repo=$(newTestRepo gatesclean)
    gatesWrite "$repo/a.js" "// the caller owns the buffer"
    (cd "$repo" && git add a.js && git commit -qm one) >/dev/null 2>&1
    out=$(cd "$repo" && sh "$DEVLOOP_GATES_BIN" a.js 2>/dev/null)
    status=$?
    assertEquals "no findings is an empty stdout, not a word about it" "" "$out"
    assertEquals "and a complete run" "0" "$status"
}

test_without_a_path_it_is_a_bad_argument() {
    dir=$(newTestDir gatesnopath)
    out=$(cd "$dir" && sh "$DEVLOOP_GATES_BIN" 2>/dev/null)
    status=$?
    assertEquals "there is nothing to read" "2" "$status"
    assertEquals "stdout stays empty" "" "$out"
}
