#!/usr/bin/env bash
# ============================================================================
# Run every test suite for Group 16, Assignment 2.
#
#     cd tests && ./run_tests.sh
#
# Prolog tests consult the solution file and print PASS/FAIL per assertion.
# Scheme tests are run the way the grader runs them: the call block in
# test_qN.rkt is appended to the solution file and the output is diffed
# against the recorded expected output.
# ============================================================================
set -u
cd "$(dirname "$0")"

CODE=../code
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

fails=0

banner() { printf '\n=== %s ===\n' "$1"; }

# ---------------------------------------------------------------- P1
banner "P1  Department Assignment Puzzle  (16_q1.pl)"
swipl -q -f test_q1.pl -g run_tests -t halt
swipl -q -f test_q1.pl -g run_tests -t halt 2>/dev/null | grep -q FAIL && fails=$((fails+1))

# ---------------------------------------------------------------- P2
banner "P2  Arithmetic Equation  (16_q2.pl)"
swipl -q -f test_q2.pl -g run_tests -t halt
swipl -q -f test_q2.pl -g run_tests -t halt 2>/dev/null | grep -q FAIL && fails=$((fails+1))

# ---------------------------------------------------------------- P1 main
banner "P1  main/0 output"
swipl -q -f "$CODE/16_q1.pl" -g main -t halt

# ---------------------------------------------------------------- S1
banner "S1  Binary Tree Traversals  (16_q3.rkt)"
cat "$CODE/16_q3.rkt" test_q3.rkt > "$TMP/s1.rkt"
racket "$TMP/s1.rkt" > "$TMP/s1.out" 2>&1
if diff -q expected_q3.txt "$TMP/s1.out" >/dev/null; then
    echo "PASS  output matches expected_q3.txt"
else
    echo "FAIL  output differs from expected_q3.txt"
    diff expected_q3.txt "$TMP/s1.out"
    fails=$((fails+1))
fi

# ---------------------------------------------------------------- S2
banner "S2  Conditional Insert  (16_q4.rkt)"
cat "$CODE/16_q4.rkt" test_q4.rkt > "$TMP/s2.rkt"
racket "$TMP/s2.rkt" > "$TMP/s2.out" 2>&1
if diff -q expected_q4.txt "$TMP/s2.out" >/dev/null; then
    echo "PASS  output matches expected_q4.txt"
else
    echo "FAIL  output differs from expected_q4.txt"
    diff expected_q4.txt "$TMP/s2.out"
    fails=$((fails+1))
fi

# ---------------------------------------------------------------- S2.a stdin
banner "S2.a  print-insert-result reading from standard input"
cat "$CODE/16_q4.rkt" > "$TMP/s2io.rkt"
echo '(print-insert-result)' >> "$TMP/s2io.rkt"
: > "$TMP/s2io.out"
for f in stdin_q4_case1.txt stdin_q4_case2.txt stdin_q4_case3.txt stdin_q4_case4.txt; do
    racket "$TMP/s2io.rkt" < "$f" >> "$TMP/s2io.out" 2>&1
done
if diff -q expected_q4_stdin.txt "$TMP/s2io.out" >/dev/null; then
    echo "PASS  stdin cases match expected_q4_stdin.txt"
else
    echo "FAIL  stdin cases differ"
    diff expected_q4_stdin.txt "$TMP/s2io.out"
    fails=$((fails+1))
fi

# ---------------------------------------------------------------- stress
banner "S2  stress: nesting depth 100 and a 10,000 element list"
python3 - > "$TMP/deep.txt" <<'PY'
d = '()'
for _ in range(100):
    d = '(' + d + ')'
print('q ' + d + ' 1')
PY
python3 - > "$TMP/wide.txt" <<'PY'
print('9 (' + ' '.join(str(i) for i in range(10000)) + ') 20000')
PY
racket "$TMP/s2io.rkt" < "$TMP/deep.txt" > "$TMP/deep.out" 2>&1 \
    && echo "PASS  depth 100 completed" || { echo "FAIL  depth 100"; fails=$((fails+1)); }
racket "$TMP/s2io.rkt" < "$TMP/wide.txt" > "$TMP/wide.out" 2>&1 \
    && echo "PASS  10,000 elements completed" || { echo "FAIL  10,000 elements"; fails=$((fails+1)); }

# ---------------------------------------------------------------- summary
banner "SUMMARY"
if [ "$fails" -eq 0 ]; then
    echo "All suites passed."
else
    echo "$fails suite(s) reported a failure."
fi
exit "$fails"
