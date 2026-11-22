---
name: prolog-dev
description: Conventions, run/test commands, review checklist and known AI failure modes for the SWI-Prolog work in CS F301 Assignment 2 (Group 16). Load before writing or reviewing any predicate in 16_q1.pl or 16_q2.pl.
---

# prolog-dev

Instruction pack for the Prolog half of CS F301 Assignment 2. Apply it to every
predicate before returning an answer.

## 1. Environment

- **SWI-Prolog 9.x** (developed and tested against 9.0.4).
- Allowed libraries only: `lists`, `apply`, `yall`, `aggregate`. Load with
  `:- use_module(library(...))`; do not rely on autoloading, because the grader
  may run with autoloading restricted.
- **Forbidden:** `assert/1`, `asserta/1`, `assertz/1`, `retract/1`, `b_setval/2`,
  `nb_setval/2`, and any other global mutable state. All state travels through
  predicate arguments.
- **Forbidden:** `halt/0` anywhere in the file, and any `:- initialization(...)`
  directive. The grader supplies `-t halt` itself; a stray `halt` truncates its
  run.
- Files contain **definitions only**. Nothing executes and nothing prints at
  load time.

## 2. How code is run

```
swipl -q -f 16_q1.pl -g main -t halt
swipl -q -f 16_q1.pl -g "count_solutions([1,2,3,4,5,6,7,8],N),writeln(N)" -t halt
swipl -q -f 16_q2.pl -g "all_equations([4,2,5,3],Es),writeln(Es)" -t halt
```

Test suites live in `tests/` and consult the solution by relative path:

```
cd tests && swipl -q -f test_q1.pl -g run_tests -t halt
cd tests && ./run_tests.sh
```

## 3. Coding conventions

- **Naming:** `snake_case` predicates; `CamelCase` variables. Name a variable
  for the thing it holds (`Solution`, `LeftTree`), never `X1`, `X2`.
- **Mode comments.** Every exported predicate carries a header line
  `% name(+In, -Out) is det|semidet|nondet.` followed by a one-sentence
  description.
- **Declarative reading.** Under the mode line, state what the predicate *means*
  ("Tree is an expression over exactly Numbers, in the given order"), not the
  steps the engine takes. Where recursion is the clearer explanation, give the
  recursive reading instead ("a one-element list is a leaf; otherwise split
  into a non-empty prefix and suffix and join them with an operator").
- **One clause, one case.** Prefer separate clauses with distinct heads over a
  single clause full of `;`. Reserve `->`/`;` for genuinely local choices, such
  as deciding whether to wrap a string in parentheses.
- **Comparison operators are load-bearing.** Use `==`/`\==` for ground identity
  checks, `=:=`/`=\=` for arithmetic, `=`/`\=` for unification. Writing `\=`
  where `\==` is meant silently changes the meaning.
- Keep lines under 80 characters so diffs stay readable.

## 4. Self-review checklist — apply before answering

1. **Does it load clean?** Run the file; zero warnings. Singleton-variable
   warnings mean a typo in a variable name until proven otherwise.
2. **Does it terminate?** For every recursive predicate, name the argument that
   strictly decreases. If none does, it will loop on backtracking even when the
   first solution looks right.
3. **Failure vs error.** A predicate that is specified to *fail* on bad input
   must fail, not throw. Test the degenerate cases explicitly: `[]`, a
   one-element list, a zero divisor.
4. **Steadfastness.** Re-run each predicate with its output argument already
   bound. `generate_equation([4,2,5,3], "4*2=5+3")` must succeed, not fail.
5. **Determinism.** If a predicate is meant to be `det` or `semidet`, confirm it
   leaves no choice point: run the goal and check it does not offer a second
   answer. Wrap with `once/1` where the specification says "one solution".
6. **Ground before testing.** Any clue or guard that uses `==`, `\==` or
   `memberchk/2` assumes a ground term. Confirm the caller has grounded it.
7. **Types.** `string` vs `atom` vs code list are different in SWI. If the
   specification says string, verify with `string/1` in a test, not by eye.
8. **Forbidden-construct sweep.** Grep for `assert`, `retract`, `nb_setval`,
   `b_setval`, `halt`, `initialization` before declaring the file finished.
9. **Run the documented examples verbatim.** Not paraphrases of them — the exact
   goals printed in the assignment, compared character by character.

## 5. Known AI failure modes in Prolog

Checked against the output of this assistant during this assignment; the first
one actually occurred and had to be fixed.

1. **`yall` lambdas silently rename free variables.** `maplist([N]>>clue(N,
   Solution), Active)` does **not** share `Solution`: yall copies the lambda
   body on each call, so the clues are tested against a fresh unbound variable.
   Worse, this often *succeeds* spuriously, because `\==` against an unbound
   variable is true. It must be written `{Solution}/[N]>>clue(N, Solution)`, or
   avoided entirely with `forall(member(N, Active), clue(N, Solution))`.
   **This bug appeared in the first draft of `satisfies/2`.**
2. **`\=` substituted for `\==`.** These read almost identically and differ
   completely: `\=` asks whether two terms *can* unify, `\==` whether they are
   identical right now. On a partially instantiated puzzle, `\=` quietly prunes
   valid candidates.
3. **Integer division assumed exact.** `V is A / B` may yield a float or a
   rational depending on SWI's flags, and `//` truncates silently. Exact
   division must be guarded explicitly: `B =\= 0, A rem B =:= 0, V is A // B`.
4. **Left recursion in generators.** A generated clause such as
   `expr(L) :- expr(L), ...` looks plausible and loops forever. Every recursive
   call must consume part of the input.
5. **`findall/3` with a bound template.** If the template variable is already
   bound earlier in the clause, `findall` collects N copies of that one value
   instead of the solutions. **This bug appeared in the first draft of
   `test_q1.pl`.**
6. **`sub_term/2` unifies with variables.** `sub_term(foo, Body)` succeeds
   whenever `Body` contains *any* unbound variable, because the variable
   unifies with `foo`. Useless as a "does this term mention X" test.
   **This bug also appeared in the first draft of `test_q1.pl`.**
7. **Invented built-ins.** Plausible-looking predicates that do not exist
   (`atomics_to_string/2` has a sibling that does not, `list_to_set/2` lives in
   `lists` but `subtract/3` does not behave as expected on unbound terms).
   Every built-in used must be confirmed by running it.
8. **Printing with the wrong predicate.** `write/1`, `print/1`, `writeln/1` and
   `format/2` quote atoms differently. `'c++'` and `'AI'` must appear unquoted,
   which `~w` gives and `~q` does not.
9. **Cut placed for convenience.** A `!` inserted to stop unwanted answers often
   also removes wanted ones on later backtracking. Prefer `once/1` at the call
   site, where the intent is visible.

## 6. Response rules for the assistant

- Answer **one unit of work at a time**: one predicate, one test file, or one
  review. Never return a whole problem in a single response.
- Show the run output that demonstrates the unit works, not a claim that it does.
- If a documented example does not reproduce, say so plainly and stop; do not
  adjust the example to match the code.
