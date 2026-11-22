% ============================================================================
% CS F301 Principles of Programming Languages - Assignment 2
% P1: Department Assignment Puzzle, Reloaded
% Group 16
%
% A solution is a list of four terms p(Name, Dept, Lang, Project) in the
% fixed order Alex, Ben, Carla, Dana.  Every attribute is a permutation of
% its four allowed values, so each value is used exactly once.
%
% Run:  swipl -q -f 16_q1.pl -g main -t halt
%       swipl -q -f 16_q1.pl -g "count_solutions([1,2,3,4,5,6,7,8],N),writeln(N)" -t halt
% ============================================================================

:- use_module(library(lists)).
:- use_module(library(apply)).

% ---------------------------------------------------------------------------
% Domains
% ---------------------------------------------------------------------------

% names(-Names) is det.
%   The four friends, in the fixed reporting order.
names(['Alex', 'Ben', 'Carla', 'Dana']).

% depts(-Depts) is det.
depts([research, development, design, testing]).

% langs(-Langs) is det.
langs([python, java, 'c++', javascript]).

% projs(-Projs) is det.
projs(['AI', web, embedded, data]).

% ---------------------------------------------------------------------------
% Candidate generation
%
% Declaratively: solution(S) holds when S pairs the four names, in order,
% with one permutation of each attribute domain.  24^3 = 13824 candidates,
% which is small enough to enumerate exhaustively.
% ---------------------------------------------------------------------------

% solution(-Solution) is nondet.
%   Solution is a fully filled-in assignment of all three attributes.
solution(Solution) :-
    names(Names),
    depts(Depts0), permutation(Depts0, Ds),
    langs(Langs0), permutation(Langs0, Ls),
    projs(Projs0), permutation(Projs0, Ps),
    zip4(Names, Ds, Ls, Ps, Solution).

% zip4(+Names, +Depts, +Langs, +Projs, -People) is det.
%   Recursively: the i-th person carries the i-th value of each list.
zip4([], [], [], [], []).
zip4([N|Ns], [D|Ds], [L|Ls], [P|Ps], [p(N, D, L, P)|Rest]) :-
    zip4(Ns, Ds, Ls, Ps, Rest).

% ---------------------------------------------------------------------------
% Clues
%
% Each clue(N, Solution) succeeds exactly when clue number N holds in a
% fully filled-in Solution.  Because Solution is ground when a clue is
% tested, memberchk/2 selects the single person the clue speaks about.
% ---------------------------------------------------------------------------

% CLUE 1: The friend who prefers the AI project does not work in research
%         and is not Dana.
clue(1, S) :-
    memberchk(p(Name, Dept, _, 'AI'), S),
    Dept \== research,
    Name \== 'Dana'.

% CLUE 2: Alex does not work in development and does not prefer C++.
clue(2, S) :-
    memberchk(p('Alex', Dept, Lang, _), S),
    Dept \== development,
    Lang \== 'c++'.

% CLUE 3: The friend working in the testing department likes Python.
clue(3, S) :-
    memberchk(p(_, testing, Lang, _), S),
    Lang == python.

% CLUE 4: Ben prefers web projects and does not work in testing.
clue(4, S) :-
    memberchk(p('Ben', Dept, _, Proj), S),
    Proj == web,
    Dept \== testing.

% CLUE 5: The friend whose favorite language is Java works in the design
%         department.
clue(5, S) :-
    memberchk(p(_, Dept, java, _), S),
    Dept == design.

% CLUE 6: Carla's project preference is not embedded, and her department is
%         not development.
clue(6, S) :-
    memberchk(p('Carla', Dept, _, Proj), S),
    Proj \== embedded,
    Dept \== development.

% CLUE 7: Dana's favorite language is not Java, and she works in research or
%         testing.
clue(7, S) :-
    memberchk(p('Dana', Dept, Lang, _), S),
    Lang \== java,
    memberchk(Dept, [research, testing]).

% CLUE 8: The friend who prefers data projects works in research and does not
%         use JavaScript.
clue(8, S) :-
    memberchk(p(_, Dept, Lang, data), S),
    Dept == research,
    Lang \== javascript.

% CLUE 9: The friend whose favorite language is Java prefers the embedded project.
clue(9, S) :-
    memberchk(p(_, _, java, Proj), S),
    Proj == embedded.

% ---------------------------------------------------------------------------
% Solving and counting
% ---------------------------------------------------------------------------

% satisfies(+Active, +Solution) is semidet.
%   Solution satisfies every clue whose number appears in Active.  Clues not
%   listed in Active are ignored entirely.
%
%   NOTE: forall/2 is used rather than maplist/2 with a yall lambda.  Writing
%   maplist([N]>>clue(N, Solution), Active) is wrong here: yall copies the
%   lambda body on every call, so the free variable Solution is renamed to a
%   fresh variable and the clues are tested against an unbound term instead
%   of the candidate.  (It would need {Solution}/[N]>>clue(N, Solution).)
satisfies(Active, Solution) :-
    forall(member(N, Active), clue(N, Solution)).

% solve(+Active, -Solution) is nondet.
%   Solution is a candidate that satisfies exactly the clues in Active.
solve(Active, Solution) :-
    solution(Solution),
    satisfies(Active, Solution).

% count_solutions(+Active, -N) is det.
%   N is how many complete assignments satisfy exactly the clues in Active.
count_solutions(Active, N) :-
    findall(S, solve(Active, S), Solutions),
    length(Solutions, N).

% ---------------------------------------------------------------------------
% P1.a - printing
% ---------------------------------------------------------------------------

% main is det.
%   Prints one solution of clues 1..8, one line per friend, in the order
%   Alex, Ben, Carla, Dana.
main :-
    once(solve([1,2,3,4,5,6,7,8], Solution)),
    print_solution(Solution).

% print_solution(+Solution) is det.
print_solution(Solution) :-
    forall(member(p(Name, Dept, Lang, Proj), Solution),
           format("~w = [~w, ~w, ~w]~n", [Name, Dept, Lang, Proj])).
