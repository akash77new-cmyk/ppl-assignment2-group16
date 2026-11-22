% ============================================================================
% Tests for P1 (16_q1.pl) - Group 16
%
% Run from the tests/ directory:
%     swipl -q -f test_q1.pl -g run_tests -t halt
% ============================================================================

:- ['../code/16_q1.pl'].

% The three solutions of clues 1..8, and the unique solution of clues 1..9.
sol_a([p('Alex',design,java,'AI'), p('Ben',development,javascript,web),
       p('Carla',research,'c++',data), p('Dana',testing,python,embedded)]).
sol_b([p('Alex',design,java,embedded), p('Ben',development,javascript,web),
       p('Carla',testing,python,'AI'), p('Dana',research,'c++',data)]).
sol_c([p('Alex',testing,python,embedded), p('Ben',development,javascript,web),
       p('Carla',design,java,'AI'), p('Dana',research,'c++',data)]).

% relabel(+Names, +Triples, -People) is det.
%   Attach the given names, in order, to the given attribute triples.
relabel([], [], []).
relabel([N|Ns], [t(D,L,P)|Ts], [p(N,D,L,P)|Rest]) :-
    relabel(Ns, Ts, Rest).

check(Name, Goal) :-
    (   catch(Goal, E, (format("ERROR ~w: ~w~n", [Name, E]), fail))
    ->  format("PASS  ~w~n", [Name])
    ;   format("FAIL  ~w~n", [Name])
    ).

run_tests :-
    % --- candidate space -----------------------------------------------
    check('no clues active -> 24^3 = 13824 candidates',
          count_solutions([], 13824)),

    % --- each clue holds in the kept solution ---------------------------
    check('clues 1..9 all hold in the unique solution',
          ( sol_b(Sb), forall(between(1,9,N), clue(N,Sb)) )),

    % --- P1.b counting --------------------------------------------------
    check('count_solutions([1..8], N) gives N = 3',
          count_solutions([1,2,3,4,5,6,7,8], 3)),
    check('count_solutions([1..9], N) gives N = 1  (P1.c repair works)',
          count_solutions([1,2,3,4,5,6,7,8,9], 1)),
    check('a single clue leaves more than one solution',
          ( count_solutions([5], N5), N5 > 1 )),

    % --- the three solutions are exactly the expected ones ---------------
    check('clues 1..8 yield exactly solutions A, B and C',
          ( findall(X, solve([1,2,3,4,5,6,7,8], X), Got),
            sol_a(Sa), sol_b(Sb2), sol_c(Sc),
            msort([Sa,Sb2,Sc], Expected),
            msort(Got, Expected) )),
    check('clues 1..9 yield exactly solution B',
          ( findall(Y, solve([1,2,3,4,5,6,7,8,9], Y), [Only]),
            sol_b(Only) )),

    % --- clue 9 discriminates correctly ----------------------------------
    check('clue 9 is true in B',        ( sol_b(B9), clue(9, B9) )),
    check('clue 9 is false in A',       ( sol_a(A9), \+ clue(9, A9) )),
    check('clue 9 is false in C',       ( sol_c(C9), \+ clue(9, C9) )),

    % --- clue 9 must not name a friend -----------------------------------
    % Semantic check, stronger than grepping the source: if clue 9 referred
    % to a friend by name, relabelling who holds which attribute triple
    % could change its truth value.  Here we keep the four triples of
    % solution B fixed and try all 24 relabellings; clue 9 must hold in
    % every one of them.
    check('clue 9 is invariant under renaming the friends (names not used)',
          ( sol_b(Sb3),
            findall(t(D,L,P), member(p(_,D,L,P), Sb3), Triples),
            forall(permutation(['Alex','Ben','Carla','Dana'], Perm),
                   ( relabel(Perm, Triples, Relabelled),
                     clue(9, Relabelled) )) )),

    % --- a wrong solution is rejected -------------------------------------
    check('a scrambled assignment fails clues 1..8',
          \+ satisfies([1,2,3,4,5,6,7,8],
                 [p('Alex',research,python,'AI'), p('Ben',development,java,web),
                  p('Carla',design,'c++',embedded), p('Dana',testing,javascript,data)])),

    % --- P1.a output shape -----------------------------------------------
    check('main prints exactly four lines',
          ( with_output_to(string(Out), main),
            split_string(Out, "\n", "", Parts),
            exclude(==(""), Parts, Lines),
            length(Lines, 4) )),
    check('main prints the friends in the order Alex, Ben, Carla, Dana',
          ( with_output_to(string(Out2), main),
            split_string(Out2, "\n", "", Parts2),
            exclude(==(""), Parts2, [L1,L2,L3,L4]),
            string_concat("Alex = [",  _, L1),
            string_concat("Ben = [",   _, L2),
            string_concat("Carla = [", _, L3),
            string_concat("Dana = [",  _, L4) )).
