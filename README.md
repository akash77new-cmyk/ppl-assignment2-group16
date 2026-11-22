# CS F301 Principles of Programming Languages — Assignment 2

**Logic and Functional Programming** · Group **16**

| Name | ID |
|---|---|
| Akash Srivastava | 2024A7PS0142H |

All deliverables are under [`16/`](16/), in the layout required by the
assignment.

```
16/
  code/        16_q1.pl  16_q2.pl  16_q3.rkt  16_q4.rkt
  tests/       test_q1.pl  test_q2.pl  test_q3.rkt  test_q4.rkt
               run_tests.sh  expected_*.txt  stdin_q4_*.txt
  skills/      prolog-dev/SKILL.md   scheme-dev/SKILL.md
  prompts/     P1.md  P2.md  S1.md  S2.md
  P1_REPORT.md
```

## Environment

Developed and tested against **SWI-Prolog 9.0.4** and **Racket 8.10**.

## Running the solutions

```bash
cd 16/code

# P1 - prints one solution of clues 1..8
swipl -q -f 16_q1.pl -g main -t halt

# P1.b / P1.c
swipl -q -f 16_q1.pl -g "count_solutions([1,2,3,4,5,6,7,8],N),writeln(N)"   -t halt   # 3
swipl -q -f 16_q1.pl -g "count_solutions([1,2,3,4,5,6,7,8,9],N),writeln(N)" -t halt   # 1

# P2
swipl -q -f 16_q2.pl -g "all_equations([4,2,5,3],Es),writeln(Es)" -t halt

# S1 and S2 define only; the grader appends its own calls
racket 16_q3.rkt
racket 16_q4.rkt
```

## Running the tests

```bash
cd 16/tests && ./run_tests.sh
```

The script runs the two Prolog suites, then builds each Racket file the way
the grader does — by appending the call block in `test_qN.rkt` to the solution
file — and diffs the result against the recorded expected output. It finishes
with the two hidden-test shapes for S2: nesting depth 100 and a list of 10,000
elements.

Current status: **all suites pass** (14 assertions for P1, 20 for P2, output
diffs for S1 and S2, plus the stdin and stress cases).

## Headline result

`count_solutions([1,2,3,4,5,6,7,8], N)` gives **N = 3**: the puzzle as stated
is under-constrained. Two of those three solutions use the *identical* set of
attribute triples and differ only in which friend holds which, which is what
forces the choice of the ninth clue. The argument is in
[`16/P1_REPORT.md`](16/P1_REPORT.md).
