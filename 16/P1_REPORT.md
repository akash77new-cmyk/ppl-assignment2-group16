# P1_REPORT — Department Assignment Puzzle, Reloaded

**Course:** CS F301 Principles of Programming Languages — Assignment 2
**Group:** 16
**Member:** Akash Srivastava (2024A7PS0142H)

---

## P1.b — the value of N

```
?- count_solutions([1,2,3,4,5,6,7,8], N).
N = 3.
```

Reproduce with:

```
swipl -q -f code/16_q1.pl \
      -g "count_solutions([1,2,3,4,5,6,7,8],N),writeln(N)" -t halt
```

For reference, with no clues active the search space is
`count_solutions([], N)` giving `N = 13824`, which is 24³ — one permutation of
each of the three attribute domains. The eight clues cut 13824 candidates down
to 3.

## What N = 3 tells us about the puzzle

**The puzzle as stated is under-constrained: it does not have a unique
solution.** Eight clues sound like plenty, but they remove only 13821 of the
13824 candidates and leave three survivors standing.

The three solutions are:

| | Alex | Ben | Carla | Dana |
|---|---|---|---|---|
| **A** | design, java, AI | development, javascript, web | research, c++, data | testing, python, embedded |
| **B** | design, java, embedded | development, javascript, web | testing, python, AI | research, c++, data |
| **C** | testing, python, embedded | development, javascript, web | design, java, AI | research, c++, data |

Two structural facts stand out.

**First, Ben is fully determined but nobody else is.** Ben is
`development, javascript, web` in all three solutions. Clue 4 pins his project
directly, and clues 3, 5 and 8 between them force his department and language.
The remaining three friends are the only genuinely open part of the puzzle.

**Second — and this is the fact that governs P1.c — solutions A and C use the
identical set of attribute triples.** Both consist of exactly

```
(research, c++,        data)
(design,   java,       AI)
(testing,  python,     embedded)
(development, javascript, web)
```

They differ *only* in which friend holds which triple: in A the triples go to
Carla, Alex, Dana, Ben respectively, and in C they go to Dana, Carla, Alex,
Ben. Solution B is genuinely different — it pairs `java` with `embedded` and
`python` with `AI`, a combination that occurs in neither A nor C.

So the clue set fails in two different ways at once. It leaves an attribute
combination undecided (B versus A/C), and on top of that it fails to pin names
to triples (A versus C).

## P1.c — the ninth clue, and why it has to keep solution B

P1.c requires a ninth clue that **must not mention any friend by name** and
may refer to friends only through attribute values, in the manner of clue 5.

That requirement interacts with the structure above in a way that decides the
answer for us. A clue which only speaks about attribute values cannot
distinguish A from C, because A and C present exactly the same multiset of
attribute triples — any attribute-only statement is either true in both or
false in both. Relabelling who holds which triple is invisible to such a clue.

Therefore:

- Keeping A would also keep C, giving N = 2. Not allowed.
- Keeping C would also keep A, giving N = 2. Not allowed.
- **Keeping B is the only possibility**, and it works precisely because B's
  triples differ from those shared by A and C.

The clue added is:

```prolog
% CLUE 9: The friend whose favorite language is Java prefers the embedded project.
clue(9, S) :-
    memberchk(p(_, _, java, Proj), S),
    Proj == embedded.
```

It names no friend; it links two attribute values, exactly as clue 5 links
`java` to `design`. It is true in B, where java and embedded belong to the same
person, and false in A and C, where the java friend prefers AI.

```
?- count_solutions([1,2,3,4,5,6,7,8,9], N).
N = 1.
```

`tests/test_q1.pl` checks this three ways: that clue 9 holds in B, that it
fails in both A and C, and — the semantic version of "mentions no friend by
name" — that its truth value is unchanged under all 24 relabellings of the
names onto B's four attribute triples.

## A note on P1.a

`main/0` prints a solution of clues **1 to 8**, as the task specifies. Since
N = 3 at that point, three different outputs would each be correct; `main/0`
uses `once/1` and prints the first that the generator reaches, which is
solution A:

```
Alex = [design, java, AI]
Ben = [development, javascript, web]
Carla = [research, c++, data]
Dana = [testing, python, embedded]
```

With clue 9 active the answer is forced to be solution B, and
`solve([1,2,3,4,5,6,7,8,9], S)` returns it as the only answer.

## How the count is computed

`count_solutions/2` carries no special machinery: it enumerates candidates with
`solution/1` and filters them, then counts with `findall/3` and `length/2`.

```prolog
count_solutions(Active, N) :-
    findall(S, solve(Active, S), Solutions),
    length(Solutions, N).
```

`Active` is interpreted strictly — clues whose numbers do not appear in the
list are not tested at all — which is what allows `count_solutions([], N)` to
report the full 13824-candidate space and makes it easy to measure how much
each individual clue contributes.
