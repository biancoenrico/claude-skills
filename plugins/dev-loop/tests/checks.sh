# The dev-loop budget and hygiene checks. One command runs them all:
#
#     sh plugins/dev-loop/tests/checks.sh [plugin-root]
#
# Without an argument the plugin root is the parent of this directory, so the script can
# be run from anywhere. The argument exists for checks_test.sh, which builds a small tree
# of its own and points the checks at it.
#
# The script reads and never writes. Every check prints one outcome line; a finding is a
# line starting with "!" and any finding makes the whole run exit 1. An empty set - no
# skills yet, no scripts yet - is green, and the outcome line says so rather than
# pretending a check ran.
#
# ---------------------------------------------------------------------------
# The checks
#
#   C1      every SKILL.md under the character cap
#   C2      every SKILL.md under the line cap
#   C3      per skill, description + when_to_use under their cap; per agent, description
#   C5      no GEMELLA marker, and no section heading of a references/ file repeated in
#           a SKILL.md, an agent file or a skill consultation file
#   C6      no Italian prose and no private identifier, outside the declared exemptions
#   limits  no figure declared in references/limits.md written out again in a SKILL.md
#   shell   source hygiene of the scripts: banned tokens, no sh -c and no exec, the
#           mutation sequence outside any subshell, and a closed list of allowed tools
#
# C4 and C8 are not here: `claude plugin validate . --strict` already compares the two
# versions and says how to fix them, and it is one of the closing commands anyway.
#
# ---------------------------------------------------------------------------
# Two things this script cannot see by construction, declared rather than hidden
#
#   * The write ban on the reviewer agent is behaviour, not text. The counterpart is a
#     clean `git status` in the trial project after a fan-out of reviewers.
#   * The shell checks read the source as text. A banned token quoted inside a string is
#     reported all the same, and a subshell built in a way the anchors below do not
#     recognise is not reported at all.
# ---------------------------------------------------------------------------

set -u

# Every cap this script enforces. The figures live here and nowhere else in the file.
CHECKS_SKILL_CHAR_CAP=17500
CHECKS_SKILL_LINE_CAP=500
CHECKS_SKILL_DESC_CAP=600
CHECKS_AGENT_DESC_CAP=200

# C5 ignores a heading shorter than this. Without a floor the check drowns in "Tasks",
# "Input" and "State": generic headings recur everywhere for reasons that have nothing
# to do with a shared block being copied, and a check nobody can keep green is a check
# nobody reads.
CHECKS_C5_MIN_TITLE=24

checks_dir=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)
root=${1:-$(dirname -- "$checks_dir")}

if [ ! -d "$root" ]; then
    echo "checks: $root is not a directory" >&2
    exit 2
fi

checks_findings=0

# The list of private terms lives outside the plugin, under docs/, and is not published.
# It is found by climbing from the plugin root to the repository root. With the plugin
# installed neither the file nor docs/ exists: C6 says so and carries on with the prose
# markers alone, because a plugin that cannot verify itself once installed is worse than
# one that verifies itself only partly.
terms_file=''
climb=$root
while [ "$climb" != "/" ] && [ -n "$climb" ]; do
    if [ -f "$climb/docs/dev-loop-private-terms.txt" ]; then
        terms_file="$climb/docs/dev-loop-private-terms.txt"
        break
    fi
    climb=$(dirname -- "$climb")
done

# run_check <name> <function> - runs one check, prints what it says, counts its findings.
# A check writes findings as "! ..." and notes as "- ...", so a note can explain an empty
# set without being counted as a failure.
run_check() {
    _name=$1
    _fn=$2
    _out=$($_fn)
    _n=0
    if [ -n "$_out" ]; then
        printf '%s\n' "$_out"
        _n=$(printf '%s\n' "$_out" | grep -c '^!' || :)
    fi
    if [ "$_n" -gt 0 ]; then
        printf '%s: %s finding(s)\n' "$_name" "$_n"
        checks_findings=$((checks_findings + _n))
    else
        printf '%s: ok\n' "$_name"
    fi
}

skill_files() {
    find "$root" -type f -name SKILL.md 2>/dev/null | sort
}

agent_files() {
    find "$root/agents" -type f -name '*.md' 2>/dev/null | sort
}

# The files where a block copied out of references/ would surface: the skills, the
# agents, and the consultation files the skills hand to a reviewer.
c5_target_files() {
    agent_files
    find "$root/skills" -type f \( -name SKILL.md -o -name criteria.md -o -name smells.md \
        -o -name patterns.md -o -name catalog.md -o -name gates.md -o -name audit.md \) \
        2>/dev/null | sort
}

relative_to_root() {
    printf '%s' "${1#"$root"/}"
}

# ---------------------------------------------------------------------------
# C1 and C2 - the size of a skill file
# ---------------------------------------------------------------------------

check_c1() {
    _seen=0
    for _f in $(skill_files); do
        _seen=$((_seen + 1))
        _chars=$(wc -m < "$_f" | tr -d ' ')
        if [ "$_chars" -ge "$CHECKS_SKILL_CHAR_CAP" ]; then
            printf '! C1 %s is %s characters, the cap is %s\n' \
                "$(relative_to_root "$_f")" "$_chars" "$CHECKS_SKILL_CHAR_CAP"
        fi
    done
    [ "$_seen" -gt 0 ] || printf -- '- C1 no SKILL.md under %s yet\n' "$(relative_to_root "$root")"
}

check_c2() {
    _seen=0
    for _f in $(skill_files); do
        _seen=$((_seen + 1))
        _lines=$(wc -l < "$_f" | tr -d ' ')
        if [ "$_lines" -ge "$CHECKS_SKILL_LINE_CAP" ]; then
            printf '! C2 %s is %s lines, the cap is %s\n' \
                "$(relative_to_root "$_f")" "$_lines" "$CHECKS_SKILL_LINE_CAP"
        fi
    done
    [ "$_seen" -gt 0 ] || printf -- '- C2 no SKILL.md to measure\n'
}

# ---------------------------------------------------------------------------
# C3 - the budget of what the model reads before choosing a skill or an agent
# ---------------------------------------------------------------------------

# frontmatter_length <file> <key> [<key>...] - total length of those frontmatter values.
# A value may sit on its key line or be folded over the indented lines below it; the
# surrounding quotes and a block scalar marker are not part of the text.
frontmatter_length() {
    _file=$1
    shift
    LC_ALL=C awk -v keys="$*" '
        BEGIN { nk = split(keys, wanted, " ") }
        NR == 1 { if ($0 ~ /^---[ \t]*$/) { inside = 1 } ; next }
        inside && /^---[ \t]*$/ { inside = 0 ; next }
        inside {
            if ($0 ~ /^[A-Za-z_][A-Za-z0-9_-]*:/) {
                cur = $0
                sub(/:.*/, "", cur)
                v = $0
                sub(/^[^:]*:[ \t]*/, "", v)
                val[cur] = v
            } else if (cur != "" && $0 ~ /^[ \t]+[^ \t]/) {
                v = $0
                sub(/^[ \t]+/, "", v)
                val[cur] = val[cur] " " v
            }
        }
        END {
            q = sprintf("%c", 39)
            total = 0
            for (i = 1; i <= nk; i++) {
                v = val[wanted[i]]
                sub(/^[>|][-+]?[ \t]*/, "", v)
                sub(/[ \t]+$/, "", v)
                n = length(v)
                if (n >= 2) {
                    a = substr(v, 1, 1)
                    b = substr(v, n, 1)
                    if ((a == q && b == q) || (a == "\"" && b == "\"")) {
                        v = substr(v, 2, n - 2)
                    }
                }
                total = total + length(v)
            }
            print total
        }
    ' "$_file"
}

check_c3() {
    _seen=0
    for _f in $(skill_files); do
        _seen=$((_seen + 1))
        _len=$(frontmatter_length "$_f" description when_to_use)
        if [ "$_len" -gt "$CHECKS_SKILL_DESC_CAP" ]; then
            printf '! C3 %s has description + when_to_use at %s characters, the cap is %s\n' \
                "$(relative_to_root "$_f")" "$_len" "$CHECKS_SKILL_DESC_CAP"
        fi
    done
    for _f in $(agent_files); do
        _seen=$((_seen + 1))
        _len=$(frontmatter_length "$_f" description)
        if [ "$_len" -gt "$CHECKS_AGENT_DESC_CAP" ]; then
            printf '! C3 %s has a description of %s characters, the cap is %s\n' \
                "$(relative_to_root "$_f")" "$_len" "$CHECKS_AGENT_DESC_CAP"
        fi
    done
    [ "$_seen" -gt 0 ] || printf -- '- C3 no skill and no agent to measure\n'
}

# ---------------------------------------------------------------------------
# C5 - one block, one home
# ---------------------------------------------------------------------------

check_c5() {
    # The two files of this check pair are left out of the sweep: they have to name the
    # marker in order to look for it, and a check that reports itself is never green.
    for _f in $(find "$root" -type f 2>/dev/null | sort); do
        case "$_f" in
            */tests/checks.sh|*/tests/checks_test.sh) continue ;;
        esac
        if grep -q 'GEMELLA' "$_f" 2>/dev/null; then
            printf '! C5 %s carries a GEMELLA marker\n' "$(relative_to_root "$_f")"
        fi
    done

    _refs=$(find "$root/references" -type f -name '*.md' 2>/dev/null | sort)
    if [ -z "$_refs" ]; then
        printf -- '- C5 no references/ file to take headings from\n'
        return 0
    fi
    _targets=$(c5_target_files)
    if [ -z "$_targets" ]; then
        printf -- '- C5 no skill, agent or consultation file to search yet\n'
        return 0
    fi

    # references/limits.md is deliberately not a source. Its headings are the names of
    # the declared numbers, and the whole point of that file is that a skill cites an
    # entry by name instead of writing the figure. The limits check below is what keeps
    # that file honest.
    LC_ALL=C awk -v srcdir="$root/references/" -v minlen="$CHECKS_C5_MIN_TITLE" \
        -v rootpfx="$root/" '
        function rel(p) {
            if (index(p, rootpfx) == 1) { return substr(p, length(rootpfx) + 1) }
            return p
        }
        index(FILENAME, srcdir) == 1 {
            if (FILENAME ~ /limits\.md$/) { next }
            if ($0 ~ /^#+[ \t]+/) {
                t = $0
                sub(/^#+[ \t]+/, "", t)
                sub(/[ \t]+$/, "", t)
                if (length(t) >= minlen + 0) {
                    k = tolower(t)
                    if (!(k in owner)) {
                        nt = nt + 1
                        order[nt] = k
                        title[k] = t
                        owner[k] = FILENAME
                    }
                }
            }
            next
        }
        {
            low = tolower($0)
            for (i = 1; i <= nt; i++) {
                k = order[i]
                if (index(low, k) > 0) {
                    printf "! C5 %s:%d repeats the heading \"%s\" of %s\n", \
                        rel(FILENAME), FNR, title[k], rel(owner[k])
                }
            }
        }
    ' $_refs $_targets < /dev/null
}

# ---------------------------------------------------------------------------
# C6 - the plugin is public and speaks English
# ---------------------------------------------------------------------------

check_c6() {
    _files=$(find "$root" -type f 2>/dev/null | sort)
    if [ -z "$_files" ]; then
        printf -- '- C6 no file under the plugin root\n'
        return 0
    fi
    if [ -z "$terms_file" ]; then
        printf -- '- C6 the private-terms list is absent: only the prose markers were searched\n'
    fi
    LC_ALL=C awk -v termsfile="$terms_file" -v rootpfx="$root/" '
        function rel(p) {
            if (index(p, rootpfx) == 1) { return substr(p, length(rootpfx) + 1) }
            return p
        }
        function report(kind, what) {
            printf "! C6 %s:%d %s: %s\n", rel(FILENAME), FNR, kind, what
        }
        BEGIN {
# c6-exempt:start
            nw = split("che della dello delle degli nella nelle nello quindi perche questo questa questi queste anche senza sempre soltanto invece oppure niente qualcosa essere viene sono stato stata deve devono nessun nessuna", word, " ")
            ns = split("perché più già", sub_marker, " ")
# c6-exempt:end
            nt = 0
            if (termsfile != "") {
                while ((getline ln < termsfile) > 0) {
                    sub(/[ \t\r]+$/, "", ln)
                    if (ln == "" || substr(ln, 1, 1) == "#") { continue }
                    nt = nt + 1
                    term[nt] = tolower(ln)
                }
                close(termsfile)
            }
        }
        FNR == 1 { exempt = 0; author = 0 }
        /^[ \t]*# c6-exempt:start[ \t]*$/ { exempt = 1; next }
        /^[ \t]*# c6-exempt:end[ \t]*$/ { exempt = 0; next }
        exempt { next }
        # The author of the plugin, and the addresses built out of the author name, are
        # the declared exemption of a public manifest. They are excluded by position:
        # the author block and the two address fields, not the terms themselves.
        FILENAME ~ /(plugin|marketplace)\.json$/ {
            if (author) { if ($0 ~ /}/) { author = 0 } ; next }
            if ($0 ~ /"author"/) { author = 1; next }
            if ($0 ~ /"(homepage|repository|source)"/) { next }
        }
        {
            low = tolower($0)
            for (i = 1; i <= nt; i++) {
                if (index(low, term[i]) > 0) { report("private term", term[i]) }
            }
            for (i = 1; i <= nw; i++) {
                if (match(low, "(^|[^a-z])" word[i] "([^a-z]|$)")) {
                    report("Italian prose", word[i])
                }
            }
            for (i = 1; i <= ns; i++) {
                if (index($0, sub_marker[i]) > 0) { report("Italian prose", sub_marker[i]) }
            }
        }
    ' $_files < /dev/null
}

# ---------------------------------------------------------------------------
# limits - a declared number lives in one place
# ---------------------------------------------------------------------------

check_limits() {
    _limits="$root/references/limits.md"
    if [ ! -f "$_limits" ]; then
        printf -- '- limits references/limits.md is absent: nothing to look for\n'
        return 0
    fi
    _targets=$(skill_files)
    LC_ALL=C awk -v limitsfile="$_limits" -v rootpfx="$root/" '
        function rel(p) {
            if (index(p, rootpfx) == 1) { return substr(p, length(rootpfx) + 1) }
            return p
        }
        BEGIN {
            nf = 0
            while ((getline ln < limitsfile) > 0) {
                if (match(ln, /\*\*Searchable form:\*\*/)) {
                    rest = substr(ln, RSTART + RLENGTH)
                    if (match(rest, /`[^`]+`/)) {
                        nf = nf + 1
                        form[nf] = substr(rest, RSTART + 1, RLENGTH - 2)
                    }
                }
            }
            close(limitsfile)
            if (nf == 0) {
                print "- limits references/limits.md declares no searchable form: the check has nothing to look for, and the shape it declares is what has to carry this search"
            }
        }
        {
            for (i = 1; i <= nf; i++) {
                if (index($0, form[i]) > 0) {
                    printf "! limits %s:%d writes out the declared number \"%s\" instead of citing its entry\n", \
                        rel(FILENAME), FNR, form[i]
                }
            }
        }
    ' $_targets < /dev/null
    if [ -z "$_targets" ]; then
        printf -- '- limits no SKILL.md to search yet\n'
    fi
}

# ---------------------------------------------------------------------------
# shell - the source hygiene of the scripts
#
# These are assertions about the text of the scripts, not about their behaviour, so they
# have no production line to mutate and would be deleted as pointless if they lived
# among the real tests. They belong here.
# ---------------------------------------------------------------------------

shell_sources() {
    for _s in "$root"/scripts/*; do
        [ -f "$_s" ] && printf '%s\n' "$_s"
    done
    [ -f "$root/hooks/session-map.sh" ] && printf '%s\n' "$root/hooks/session-map.sh"
    return 0
}

check_shell() {
    _sources=$(shell_sources)
    if [ -z "$_sources" ]; then
        printf -- '- shell no script to read yet\n'
        return 0
    fi
    for _s in $_sources; do
        shell_banned_tokens "$_s"
        shell_allowed_tools "$_s"
    done
    shell_mutation_region
}

# The banned tokens. The four from the specification - mktemp, sha256sum, process
# substitution and the \s escape - plus the ones the scripts gave up for the same
# reason: they exist in bash and not in dash, so half the shells would take on trust
# what the other half cannot run.
shell_banned_tokens() {
    LC_ALL=C awk -v src="$1" -v rootpfx="$root/" '
        function rel(p) {
            if (index(p, rootpfx) == 1) { return substr(p, length(rootpfx) + 1) }
            return p
        }
        function report(what) { printf "! shell %s:%d uses %s\n", rel(src), FNR, what }
        /mktemp/                                  { report("mktemp") }
        /sha256sum/                               { report("sha256sum") }
        /<\(/                                     { report("process substitution") }
        /\\s/                                     { report("the \\s escape") }
        /trap/ && /[ \t]ERR([ \t;]|$)/            { report("trap on ERR") }
        /(^|[^A-Za-z_])local[ \t]/                { report("local") }
        /\[\[[^:]/                                { report("[[ ]]") }
        /echo[ \t]+-e/                            { report("echo -e") }
        /(^|[^A-Za-z_$])[A-Za-z_][A-Za-z0-9_]*=\(/ { report("an array assignment") }
        /\$\{[A-Za-z_][A-Za-z0-9_]*\[/            { report("an array expansion") }
        /sh[ \t]+-c/                              { report("sh -c") }
        /(^|[^A-Za-z_.\/-])exec[ \t]/             { report("the exec builtin") }
    ' "$1"
}

# The closed list of tools. A blacklist lets a new tool in and nobody notices; a
# whitelist stops on its own until somebody adds the tool on purpose.
shell_allowed_tools() {
    LC_ALL=C awk -v src="$1" -v rootpfx="$root/" '
        function rel(p) {
            if (index(p, rootpfx) == 1) { return substr(p, length(rootpfx) + 1) }
            return p
        }
        BEGIN {
            na = split("git awk cmp sort head wc cat rm mkdir cp kill ps sh dash bash", tool, " ")
            for (i = 1; i <= na; i++) { allowed[tool[i]] = 1 }
            nk = split("if then else elif fi for while until do done case esac in " \
                       "function return exit shift set trap read printf echo cd eval " \
                       "unset export break continue true false command wait umask " \
                       "getopts hash times ulimit .", key, " ")
            for (i = 1; i <= nk; i++) { keyword[key[i]] = 1 }
            q = sprintf("%c", 39)
            # The names defined in the file itself are calls, not tools.
            while ((getline ln < src) > 0) {
                if (match(ln, /^[ \t]*[A-Za-z_][A-Za-z0-9_]*[ \t]*\(\)/)) {
                    fn = ln
                    sub(/^[ \t]*/, "", fn)
                    sub(/[ \t]*\(\).*/, "", fn)
                    defined[fn] = 1
                }
            }
            close(src)
        }
        {
            line = $0
            # A single-quoted string can run over many lines - every awk program in
            # these scripts is one - and nothing inside it is a command.
            if (inq) {
                a = index(line, q)
                if (a == 0) { next }
                line = substr(line, a + 1)
                inq = 0
            }
            # A whole-line comment is dropped before the quotes are counted: an
            # apostrophe in English prose would otherwise open a string that never
            # closes, and every command below it would go unread.
            if (line ~ /^[ \t]*#/) { next }
            gsub(/"[^"]*"/, "~", line)
            # Complete single-quoted strings become the same placeholder; one that does
            # not close on this line carries over to the next.
            out = ""
            rest = line
            while ((a = index(rest, q)) > 0) {
                head = substr(rest, 1, a - 1)
                tail = substr(rest, a + 1)
                b = index(tail, q)
                if (b == 0) {
                    out = out head
                    rest = ""
                    inq = 1
                    break
                }
                out = out head "~"
                rest = substr(tail, b + 1)
            }
            line = out rest
            np = split(line, part, /(\|\||&&|;;|\$\(|[;|(])/)
            for (i = 1; i <= np; i++) {
                s = part[i]
                sub(/^[ \t]*/, "", s)
                # Leading environment assignments are not the command.
                while (match(s, /^[A-Za-z_][A-Za-z0-9_]*=[^ \t]*[ \t]+/)) {
                    s = substr(s, RSTART + RLENGTH)
                    sub(/^[ \t]*/, "", s)
                }
                sub(/[ \t].*/, "", s)
                if (s == "" || s in keyword || s in defined || s in allowed) { continue }
                if (s ~ /[^A-Za-z0-9_.\/-]/) { continue }
                if (s ~ /^-/) { continue }
                printf "! shell %s:%d calls %s, which is not on the list of allowed tools\n", \
                    rel(src), FNR, s
            }
        }
    ' "$1"
}

# The mutate/run/restore sequence must not sit inside a subshell: a non-ignored trap is
# reset there, and the file would never be put back by the process that mutated it.
# The region is recognised by the two anchors below, which are the first line that
# copies the file aside and the last line of the run.
shell_mutation_region() {
    _script="$root/scripts/devloop-mutate"
    if [ ! -f "$_script" ]; then
        printf -- '- shell scripts/devloop-mutate is absent: the subshell check did not run\n'
        return 0
    fi
    LC_ALL=C awk -v src="$_script" -v rootpfx="$root/" '
        function rel(p) {
            if (index(p, rootpfx) == 1) { return substr(p, length(rootpfx) + 1) }
            return p
        }
        /cp "\$DM_FILE_ABS" "\$DM_RESTORE_ORIG"/ { inside = 1; seen = 1 }
        inside && /dm_quit "\$DM_EXIT_CODE"/ { inside = 0 }
        inside {
            if ($0 ~ /\$\(/) {
                printf "! shell %s:%d puts a command substitution inside the mutation sequence\n", \
                    rel(src), FNR
            }
            if ($0 ~ /^[ \t]*[()][ \t]*$/) {
                printf "! shell %s:%d opens or closes a subshell inside the mutation sequence\n", \
                    rel(src), FNR
            }
        }
        END {
            if (!seen) {
                printf "! shell %s has no recognisable mutation sequence: the subshell check found neither of its anchors\n", \
                    rel(src)
            }
        }
    ' "$_script"
}

# ---------------------------------------------------------------------------

printf 'checks: %s\n' "$root"
run_check C1 check_c1
run_check C2 check_c2
run_check C3 check_c3
run_check C5 check_c5
run_check C6 check_c6
run_check limits check_limits
run_check shell check_shell

if [ "$checks_findings" -gt 0 ]; then
    printf 'FAILED: %s finding(s)\n' "$checks_findings"
    exit 1
fi
printf 'all checks passed\n'
exit 0
