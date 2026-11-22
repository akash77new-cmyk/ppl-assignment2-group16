---
name: scheme-dev
description: Conventions, run/test commands, review checklist and known AI failure modes for the Racket/Scheme work in CS F301 Assignment 2 (Group 16). Load before writing or reviewing any function in 16_q3.rkt or 16_q4.rkt.
---

# scheme-dev

Instruction pack for the Scheme half of CS F301 Assignment 2. Apply it to every
function before returning an answer.

## 1. Environment

- **Racket 8.x** (developed and tested against 8.10).
- Every file begins with `#lang racket/base` and contains **definitions only**.
  No top-level calls, no output at load time: the grader appends its own calls
  to the end of the file.

### The allowed list — nothing else from `racket/base`

`define`, `lambda`, `let`, `let*`, `letrec`, named `let`, `if`, `cond` (with
`else`), `and`, `or`, `not`, `begin`, `quote` (`'`), `cons`, `car`, `cdr`,
`list`, any composition of `car`/`cdr` up to four levels (`cadr`, `caddr`,
`cadddr`, …), `null?`, `pair?`, `eq?`, `assq`, `assoc`, `+ - * < > <= >= =`,
`max`, `display`, `newline`. **S2 only** additionally allows `read`.

### Explicitly forbidden

`set!` and relatives, vectors, hash tables, strings, `do`/`for` loops, and
`length`, `append`, `reverse`, `map`, `filter`, `member`, `memq`, `list-ref`,
`list-tail`. Where one of these is needed, write `my-length`, `my-reverse`,
`my-map` and so on from the allowed primitives.

**`quotient`, `remainder`, `modulo`, `abs`, `equal?`, `number?`, `symbol?`,
`list?` and `apply` are NOT on the allowed list.** They are ordinary
`racket/base` names, so the file still runs — which is exactly why their use
slips through unnoticed. Grep for them before submitting.

## 2. How code is run

```
racket 16_q3.rkt          # loads definitions, prints nothing
racket 16_q4.rkt
```

Because the solution files export nothing, tests are run the way the grader
runs them — by appending a block of calls:

```
cat ../code/16_q3.rkt test_q3.rkt > /tmp/s1.rkt && racket /tmp/s1.rkt
cd tests && ./run_tests.sh      # does this and diffs against expected output
```

## 3. Coding conventions

- **Naming:** `kebab-case`. Predicates end in `?` (`len-ok?`). Helpers that
  replace a forbidden built-in are prefixed `my-` (`my-length`).
- **Recursive reading.** Each function carries a comment giving its contract as
  a sentence about *values*, not steps — for example
  `(inorder tree acc) -> inorder values of tree, followed by acc`. For an
  accumulator-passing helper this sentence is what makes the definition
  obviously correct.
- **Accumulators instead of `append`.** `append` is forbidden, and building a
  traversal with it would be quadratic anyway. Pass the tail as an argument and
  grow the list right-to-left with `cons`.
- **Tail recursion where it is natural**, which means list walks (`my-length`,
  `my-reverse`, `my-map`). Tree recursion is not naturally tail recursive and
  should not be contorted into it.
- Comment the non-obvious invariant, not the obvious line. "Measuring before
  walking is what makes the rule *length of the original list* hold at every
  level" earns its place; "add one to count" does not.

## 4. Self-review checklist — apply before answering

1. **Allowed-list sweep.** Read the function back token by token against
   section 1. Any name not on the list is a defect even though Racket accepts
   it.
2. **Runs clean.** `racket <file>` loads with no output and no error.
3. **Empty input.** `'()` must be handled explicitly in every function. For S1
   the empty tree prints `()`, height `0`, leaf count `0`; for S2 the empty
   list has length `0` and is *not* special-cased away.
4. **`null?` before `pair?`.** `'()` is not a pair. A `cond` that tests
   `pair?` first will silently treat the empty list as an atom.
5. **Depth.** Does it survive nesting depth 100? Non-tail recursion over
   *structure* is fine; non-tail recursion over a 10,000-element *list* is not.
6. **Width.** Does it survive a 10,000-element list? Walk every list with a
   tail-recursive named `let`.
7. **Output shape.** `display` of a list prints `(1 2 3)` with no commas; check
   the exact expected text, including whether a trailing `newline` is required.
   Every printing function here ends with one.
8. **Order of evaluation.** `let` binds in parallel, `let*` in sequence. Reading
   `x`, `lst` and `n` with `read` in a fixed order requires `let*`.
9. **Run the documented examples verbatim** and diff the output, rather than
   reading it and deciding it looks right.

## 5. Known AI failure modes in Scheme

1. **Reaching for a forbidden built-in.** `length`, `append`, `map`, `reverse`
   and `member` are so idiomatic that they appear in generated code
   automatically. The file still runs, so nothing catches it except a
   deliberate sweep. This is the single highest-risk failure mode for this
   assignment.
2. **Silently allowed cousins.** Having avoided `length`, generated code
   reaches for `quotient`, `abs`, `equal?` or `list?` instead. These are not on
   the allowed list either.
3. **`append` smuggled into traversals.** The textbook inorder traversal is
   `(append (inorder left) (list v) (inorder right))`. It is forbidden here and
   quadratic; the accumulator form is required.
4. **`'()` treated as an atom.** Testing `(pair? item)` to decide "is this a
   list" misclassifies the empty list, which this problem specifically requires
   to be treated as a length-0 list.
5. **Length measured after insertion.** Inserting into sublists first and then
   measuring the parent gives the wrong answer whenever a child insertion
   changes the parent's length. Measure the original first, then recurse.
6. **Non-tail `my-map`.** A naive `(cons (f (car l)) (my-map f (cdr l)))` is
   the obvious definition and consumes a stack frame per element; the hidden
   tests use 10,000 elements. Accumulate and reverse instead.
7. **`display` versus `write`.** They differ on symbols and strings. The
   expected output here is `display` output; substituting `write` changes it.
8. **Inventing a `provide` line.** Adding `(provide ...)` to make a test file
   `require` the solution introduces a form outside the allowed list. Test by
   appending calls, the way the grader does.
9. **Stray top-level calls left in the file.** A call added while debugging
   makes the file print at load time, which the specification forbids.

## 6. Response rules for the assistant

- Answer **one unit of work at a time**: one function, one helper, one test
  block, or one review. Never return a whole problem in a single response.
- Before returning any function, run the allowed-list sweep in section 4.1 and
  state explicitly which built-ins the function uses.
- Show real run output, not a prediction of it.
