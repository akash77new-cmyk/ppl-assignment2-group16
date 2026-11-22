% ============================================================================
% Tests for P2 (16_q2.pl) - Group 16
%
% Run from the tests/ directory:
%     swipl -q -f test_q2.pl -g run_tests -t halt
% ============================================================================

:- ['../code/16_q2.pl'].

check(Name, Goal) :-
    (   catch(Goal, E, (format("ERROR ~w: ~w~n", [Name, E]), fail))
    ->  format("PASS  ~w~n", [Name])
    ;   format("FAIL  ~w~n", [Name])
    ).

run_tests :-
    % --- the worked example from the assignment --------------------------
    check('all_equations([4,2,5,3]) gives the seven documented equations',
          all_equations([4,2,5,3],
              ["4*2-5=3","4*2=5+3","4-2=5-3","4/2=5-3",
               "4=2*(5-3)","4=2+(5-3)","4=2+5-3"])),
    check('generate_equation([4,2,5,3]) returns one of those seven',
          ( generate_equation([4,2,5,3], E1),
            all_equations([4,2,5,3], Es1),
            memberchk(E1, Es1) )),
    check('the result is a string, not an atom or code list',
          ( generate_equation([4,2,5,3], E2), string(E2) )),

    % --- no-solution cases -------------------------------------------------
    check('generate_equation([2,3,4]) fails',
          \+ generate_equation([2,3,4], _)),
    check('all_equations([2,3,4]) gives []',
          all_equations([2,3,4], [])),
    check('all_equations([2,4,8]) gives ["2*4=8"]',
          all_equations([2,4,8], ["2*4=8"])),

    % --- degenerate lists ---------------------------------------------------
    check('generate_equation([]) fails',      \+ generate_equation([], _)),
    check('generate_equation([5]) fails',     \+ generate_equation([5], _)),
    check('all_equations([]) gives []',       all_equations([], [])),
    check('all_equations([5]) gives []',      all_equations([5], [])),

    % --- division rules ------------------------------------------------------
    check('division by zero never raises an error',
          ( all_equations([1,0,0], Z), is_list(Z) )),
    check('inexact division is rejected: [7,2,3] has no equation',
          all_equations([7,2,3], [])),
    check('exact division is accepted: 6/3=2',
          ( all_equations([6,3,2], D), memberchk("6/3=2", D) )),

    % --- canonical parenthesisation ------------------------------------------
    check('left-associative chain prints without parentheses: 8/4*2',
          ( all_equations([8,4,2,4], P1), memberchk("8/4*2=4", P1) )),
    check('a right operand of equal precedence is parenthesised: 8/(4/2)',
          ( all_equations([8,4,2,4], P2), memberchk("8/(4/2)=4", P2) )),
    check('a left operand of lower precedence is parenthesised: (4-2)*4',
          ( all_equations([8,4,2,4], P3), memberchk("8=(4-2)*4", P3) )),
    check('1+(2+3) and 1+2+3 are counted as different trees',
          ( all_equations([1,2,3,6], P4),
            memberchk("1+(2+3)=6", P4),
            memberchk("1+2+3=6", P4) )),

    % --- result shape ----------------------------------------------------------
    check('all_equations output is sorted and duplicate-free',
          ( all_equations([4,2,5,3], Es2), sort(Es2, Es2) )),
    check('count_equations agrees with the length of all_equations',
          ( count_equations([4,2,5,3], N), N =:= 7 )),

    % --- bigger input finishes quickly -------------------------------------------
    check('a six-number list is handled without hanging',
          ( count_equations([1,2,3,4,5,6], N6), integer(N6) )).
