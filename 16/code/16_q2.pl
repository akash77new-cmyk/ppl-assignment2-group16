% ============================================================================
% CS F301 Principles of Programming Languages - Assignment 2
% P2: Form a Valid Arithmetic Equation
% Group 16
%
% Given a list of non-negative integers, insert + - * / and exactly one =
% between them (every number used once, in order, parentheses optional) so
% that both sides have the same integer value.
%
% Expression trees are represented as
%     n(Integer)          a single number (a leaf)
%     e(Op, Left, Right)  Op applied to two sub-expressions
%
% Run:  swipl -q -f 16_q2.pl -g "all_equations([4,2,5,3],Es),writeln(Es)" -t halt
% ============================================================================

:- use_module(library(lists)).

% ---------------------------------------------------------------------------
% Expression tree generation
% ---------------------------------------------------------------------------

% expr_tree(+Numbers, -Tree) is nondet.
%   Declaratively: Tree is an expression over exactly Numbers, in the given
%   order.  Recursively: a one-element list is a leaf; otherwise split the
%   list into a non-empty prefix and a non-empty suffix, build an expression
%   over each side, and join them with one of the four operators.
expr_tree([N], n(N)).
expr_tree(Numbers, e(Op, Left, Right)) :-
    append(Front, Back, Numbers),
    Front = [_|_],
    Back  = [_|_],
    member(Op, [+, -, *, /]),
    expr_tree(Front, Left),
    expr_tree(Back, Right).

% ---------------------------------------------------------------------------
% Evaluation
%
% Integer arithmetic only.  Division succeeds only when the divisor is
% non-zero and the division is exact; this is checked at every division
% inside the tree, not just at the top.
% ---------------------------------------------------------------------------

% eval(+Tree, -Value) is semidet.
eval(n(N), N).
eval(e(+, L, R), V) :- eval(L, A), eval(R, B), V is A + B.
eval(e(-, L, R), V) :- eval(L, A), eval(R, B), V is A - B.
eval(e(*, L, R), V) :- eval(L, A), eval(R, B), V is A * B.
eval(e(/, L, R), V) :-
    eval(L, A),
    eval(R, B),
    B =\= 0,
    A rem B =:= 0,        % exact division only
    V is A // B.

% ---------------------------------------------------------------------------
% Canonical printing
%
% Precedence: * and / bind tighter than + and -.  A number is given the
% highest precedence so that it is never parenthesised.
%
% A LEFT operand is parenthesised when its precedence is strictly lower than
% its parent's; a RIGHT operand when its precedence is lower than or equal to
% its parent's.  Those two rules together make the printed string a faithful
% encoding of the tree: different trees always print differently.
% ---------------------------------------------------------------------------

% op_prec(+Operator, -Precedence) is det.
op_prec(+, 1).
op_prec(-, 1).
op_prec(*, 2).
op_prec(/, 2).

% node_prec(+Tree, -Precedence) is det.
node_prec(n(_), 3).
node_prec(e(Op, _, _), P) :- op_prec(Op, P).

% tree_string(+Tree, -String) is det.
tree_string(n(N), S) :-
    number_string(N, S).
tree_string(e(Op, L, R), S) :-
    op_prec(Op, P),
    tree_string(L, LS0),
    node_prec(L, PL),
    ( PL < P  -> parenthesise(LS0, LS) ; LS = LS0 ),
    tree_string(R, RS0),
    node_prec(R, PR),
    ( PR =< P -> parenthesise(RS0, RS) ; RS = RS0 ),
    atom_string(Op, OpS),
    string_concat(LS, OpS, S0),
    string_concat(S0, RS, S).

% parenthesise(+String, -Parenthesised) is det.
parenthesise(S, P) :-
    string_concat("(", S, S0),
    string_concat(S0, ")", P).

% ---------------------------------------------------------------------------
% Equations
% ---------------------------------------------------------------------------

% equation(+Numbers, -Equation) is nondet.
%   Equation is a string "L=R" where L is an expression over a non-empty
%   prefix of Numbers, R is an expression over the remaining non-empty
%   suffix, and both evaluate to the same integer.
%
%   Both sides are required to be non-empty, so a list of length 0 or 1 has
%   no split point and the predicate simply fails.
equation(Numbers, Equation) :-
    append(LeftNums, RightNums, Numbers),
    LeftNums  = [_|_],
    RightNums = [_|_],
    expr_tree(LeftNums, LeftTree),
    eval(LeftTree, Value),
    expr_tree(RightNums, RightTree),
    eval(RightTree, Value),
    tree_string(LeftTree, LS),
    tree_string(RightTree, RS),
    string_concat(LS, "=", S0),
    string_concat(S0, RS, Equation).

% generate_equation(+List, -Equation) is semidet.
%   P2.a - one valid equation, or failure when none exists.
generate_equation(List, Equation) :-
    once(equation(List, Equation)).

% all_equations(+List, -Equations) is det.
%   P2.b - every valid equation, duplicates removed, in standard order.
all_equations(List, Equations) :-
    findall(E, equation(List, E), Raw),
    sort(Raw, Equations).

% count_equations(+List, -N) is det.
count_equations(List, N) :-
    all_equations(List, Equations),
    length(Equations, N).
