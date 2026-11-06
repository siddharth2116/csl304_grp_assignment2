:- encoding(utf8).
/*  ======================================================================
    PROBLEM 3: ROYAL ARCHIVE ACCESS VERIFICATION USING RESOLUTION REFUTATION
    ======================================================================
    Group members:
        Siddharth  B24EC017
        Parveen    B24EC013
        Rakesh     B24EC023
        Jnaneswar  B24ME027

    Goal: prove  trusted(mira)  from the facts and rules, by adding the
    negated goal to the knowledge base and deriving the empty clause [].

    Run (SWI-Prolog):   swipl royal_archive_access.pl
              or:       swipl -q -g run -t halt royal_archive_access.pl

    Formula syntax used in this file
        all(X, F)     universal quantifier    (printed as  ∀X)
        exists(X, F)  existential quantifier  (printed as  ∃X)
        imp(A, B)     implication             (printed as  A → B)
        and(A, B)     conjunction             (printed as  A ∧ B)
        or(A, B)      disjunction             (printed as  A ∨ B)
        neg(A)        negation                (printed as  ¬A)
        v(Name)       a logical variable  (e.g. v(x)), everything else is a constant

    PREDICATES
        archivist(X)                 X is an archivist
        verifies(X, R)               X verifies record R
        trusted(X)                   X is trusted
        has_access(X, R)             X has access to record R
        sealed(R)                    record R is sealed
        permitted_to_inspect(X, R)   X is permitted to inspect R
        inspects(X, R)               X (actually) inspects R
        finds_hidden_mark(X, R)      X finds a hidden mark in R
        stored_in_archive(R)         R is stored in the royal archive
    CONSTANTS:  mira, scroll_7
    VARIABLES:  x, r  (renamed x1, r1, x2, ... during standardisation)
    ====================================================================== */

:- initialization(main, main).


/* ======================================================================
   % Step 1: Predicate logic representation
   ====================================================================== */

% kb(Id, EnglishSentence, FOLFormula)
kb(1, 'Every archivist who verifies a record is trusted.',
   all(x, imp(and(archivist(v(x)), exists(r, verifies(v(x), v(r)))),
              trusted(v(x))))).

kb(2, 'Every trusted person who has access to a sealed record is permitted to inspect that record.',
   all(x, all(r, imp(and(trusted(v(x)), and(has_access(v(x), v(r)), sealed(v(r)))),
                     permitted_to_inspect(v(x), v(r)))))).

kb(3, 'Anyone who inspects a record and finds a hidden mark in it verifies that record.',
   all(x, all(r, imp(and(inspects(v(x), v(r)), finds_hidden_mark(v(x), v(r))),
                     verifies(v(x), v(r)))))).

kb(4, 'Every record stored in the royal archive is sealed.',
   all(r, imp(stored_in_archive(v(r)), sealed(v(r))))).

kb(5, 'scroll_7 is stored in the royal archive.',
   stored_in_archive(scroll_7)).

kb(6, 'Mira has access to scroll_7.',
   has_access(mira, scroll_7)).

kb(7, 'Mira inspects scroll_7 and finds a hidden mark in it.',
   and(inspects(mira, scroll_7), finds_hidden_mark(mira, scroll_7))).

kb(8, 'Mira is an archivist.',
   archivist(mira)).

goal(trusted(mira)).


/* ======================================================================
   % Step 2: Negation of goal
   ====================================================================== */

% The negated goal is added to the knowledge base as formula 9.
negated_goal(neg(G)) :- goal(G).

all_formulas(Fs) :-
    findall(I-F, kb(I, _, F), Fs0),
    negated_goal(NG),
    append(Fs0, [9-NG], Fs).


/* ======================================================================
   % Step 3: Implication removal       A → B   becomes   ¬A ∨ B
   ====================================================================== */

remove_imp(imp(A, B), or(neg(A1), B1)) :- !, remove_imp(A, A1), remove_imp(B, B1).
remove_imp(and(A, B), and(A1, B1))     :- !, remove_imp(A, A1), remove_imp(B, B1).
remove_imp(or(A, B),  or(A1, B1))      :- !, remove_imp(A, A1), remove_imp(B, B1).
remove_imp(neg(A),    neg(A1))         :- !, remove_imp(A, A1).
remove_imp(all(X, A),    all(X, A1))    :- !, remove_imp(A, A1).
remove_imp(exists(X, A), exists(X, A1)) :- !, remove_imp(A, A1).
remove_imp(A, A).


/* ======================================================================
   % Step 4: Negation movement (negations moved inward to the atoms)
       ¬¬A ⇒ A,   ¬(A ∧ B) ⇒ ¬A ∨ ¬B,   ¬(A ∨ B) ⇒ ¬A ∧ ¬B,
       ¬∀x A ⇒ ∃x ¬A,   ¬∃x A ⇒ ∀x ¬A
   ====================================================================== */

move_neg(neg(neg(A)), B)          :- !, move_neg(A, B).
move_neg(neg(and(A, B)), or(A1, B1))  :- !, move_neg(neg(A), A1), move_neg(neg(B), B1).
move_neg(neg(or(A, B)),  and(A1, B1)) :- !, move_neg(neg(A), A1), move_neg(neg(B), B1).
move_neg(neg(all(X, A)),    exists(X, A1)) :- !, move_neg(neg(A), A1).
move_neg(neg(exists(X, A)), all(X, A1))    :- !, move_neg(neg(A), A1).
move_neg(and(A, B), and(A1, B1)) :- !, move_neg(A, A1), move_neg(B, B1).
move_neg(or(A, B),  or(A1, B1))  :- !, move_neg(A, A1), move_neg(B, B1).
move_neg(all(X, A),    all(X, A1))    :- !, move_neg(A, A1).
move_neg(exists(X, A), exists(X, A1)) :- !, move_neg(A, A1).
move_neg(A, A).


/* ======================================================================
   % Step 5: Standardization (every quantified variable gets a unique name)
       Variables in formula N are renamed  x -> xN,  r -> rN
   ====================================================================== */

standardize(N, all(X, A), all(X1, A1)) :- !,
    new_name(X, N, X1), rename(A, X, X1, A2), standardize(N, A2, A1).
standardize(N, exists(X, A), exists(X1, A1)) :- !,
    new_name(X, N, X1), rename(A, X, X1, A2), standardize(N, A2, A1).
standardize(N, and(A, B), and(A1, B1)) :- !, standardize(N, A, A1), standardize(N, B, B1).
standardize(N, or(A, B),  or(A1, B1))  :- !, standardize(N, A, A1), standardize(N, B, B1).
standardize(N, neg(A), neg(A1))        :- !, standardize(N, A, A1).
standardize(_, A, A).

new_name(X, N, X1) :- atom_concat(X, N, X1).

% rename(Term, Old, New, Result): replace v(Old) by v(New)
rename(v(X), X, Y, v(Y)) :- !.
rename(T, _, _, T) :- atomic(T), !.
rename(T, X, Y, T1) :-
    T =.. [F | Args], maplist([A, B]>>rename(A, X, Y, B), Args, Args1), T1 =.. [F | Args1].


/* ======================================================================
   % Step 6: Skolemization
       ∃y inside the scope of ∀x1..xn  ->  y replaced by sk_N(x1..xn)
       (a Skolem constant if there is no enclosing ∀).
       Then the universal quantifiers are dropped (all variables are
       implicitly universally quantified in clause form).
   ====================================================================== */

skolemize(F, S) :- skolem(F, [], S).

skolem(all(X, A), Univ, B) :- !, skolem(A, [v(X) | Univ], B).          % drop ∀
skolem(exists(X, A), Univ, B) :- !,
    reverse(Univ, U), atom_concat(sk_, X, SkName),
    ( U == [] -> Sk = SkName ; Sk =.. [SkName | U] ),
    replace(A, v(X), Sk, A1), skolem(A1, Univ, B).
skolem(and(A, B), U, and(A1, B1)) :- !, skolem(A, U, A1), skolem(B, U, B1).
skolem(or(A, B),  U, or(A1, B1))  :- !, skolem(A, U, A1), skolem(B, U, B1).
skolem(A, _, A).

replace(T, Old, New, New) :- T == Old, !.
replace(T, _, _, T) :- atomic(T), !.
replace(T, O, N, T1) :-
    T =.. [F | Args], maplist([A, B]>>replace(A, O, N, B), Args, Args1), T1 =.. [F | Args1].


/* ======================================================================
   % Step 7: CNF clauses
       Distribute ∨ over ∧, then split each conjunction into separate
       clauses. A clause is written as a list of literals.
   ====================================================================== */

cnf(and(A, B), and(A1, B1)) :- !, cnf(A, A1), cnf(B, B1).
cnf(or(A, B), C) :- !, cnf(A, A1), cnf(B, B1), distribute(A1, B1, C).
cnf(A, A).

distribute(and(A, B), C, and(D1, D2)) :- !, distribute(A, C, D1), distribute(B, C, D2).
distribute(A, and(B, C), and(D1, D2)) :- !, distribute(A, B, D1), distribute(A, C, D2).
distribute(A, B, or(A, B)).

to_clauses(and(A, B), Cs) :- !, to_clauses(A, C1), to_clauses(B, C2), append(C1, C2, Cs).
to_clauses(F, [Lits]) :- disjuncts(F, Lits).

disjuncts(or(A, B), L) :- !, disjuncts(A, L1), disjuncts(B, L2), append(L1, L2, L).
disjuncts(A, [A]).


/* ======================================================================
   % Step 8: Resolution implementation and execution
       - unification over our own variable terms v(Name)
       - linear input resolution starting from the negated goal
         (set of support), searched with iterative deepening
       - every resolvent is printed in order until [] is derived
   ====================================================================== */

% ---- unification ------------------------------------------------------
walk(v(N), S, T) :- memberchk(N = V, S), !, walk(V, S, T).
walk(T, _, T).

unify(A, B, S0, S) :-
    walk(A, S0, A1), walk(B, S0, B1),
    (   A1 == B1 -> S = S0
    ;   A1 = v(N) -> S = [N = B1 | S0]
    ;   B1 = v(N) -> S = [N = A1 | S0]
    ;   compound(A1), compound(B1),
        A1 =.. [F | As], B1 =.. [F | Bs], length(As, L), length(Bs, L),
        foldl(unify, As, Bs, S0, S)
    ).

subst(v(N), S, T) :- memberchk(N = V, S), !, subst(V, S, T).
subst(T, _, T) :- atomic(T), !.
subst(T, _, T) :- T = v(_), !.
subst(T, S, T1) :- T =.. [F | As], maplist([A, B]>>subst(A, S, B), As, Bs), T1 =.. [F | Bs].

complement(neg(A), A) :- !.
complement(A, neg(A)).

% resolve(+C1, +C2, -Resolvent, -Theta, -ResolvedLiteral)
resolve(C1, C2, R, Theta, L1) :-
    select(L1, C1, Rest1),
    complement(L1, L1c),
    select(L2, C2, Rest2),
    unify(L1c, L2, [], Theta),
    append(Rest1, Rest2, R0),
    maplist([A, B]>>subst(A, Theta, B), R0, R1),
    remove_dups(R1, R).

remove_dups([], []).
remove_dups([H | T], R) :- ( memberchk(H, T) -> R = R1 ; R = [H | R1] ), remove_dups(T, R1).

% linear input resolution with iterative deepening
refute(Start, Inputs, Proof) :-
    between(1, 15, Max),
    refute(Start, Inputs, [], Max, Proof), !.

refute(_-[], _, _, _, []) :- !.
refute(Id-C, Inputs, Used, Max, [step(Id, IId, Theta, Lit, R) | Rest]) :-
    Max > 0,
    member(IId-IC, Inputs),
    \+ memberchk(IId, Used),
    resolve(C, IC, R, Theta, Lit),
    M1 is Max - 1,
    refute(new-R, Inputs, [IId | Used], M1, Rest).


/* ======================================================================
   Driver: runs Steps 1–8 and prints every stage
   ====================================================================== */

main :- run.

run :-
    set_stream(user_output, encoding(utf8)),
    all_formulas(Fs),

    banner('Step 1: Predicate logic representation'),
    forall(kb(I, Eng, F), ( format('~w. ~w~n   ', [I, Eng]), pp(F), nl )),
    goal(G), format('~nGoal to prove: '), pp(G), nl,

    banner('Step 2: Negation of goal'),
    negated_goal(NG), format('9. (negated goal)  '), pp(NG), nl,

    banner('Step 3: Implication removal'),
    maplist([I-F, I-F1]>>remove_imp(F, F1), Fs, S3), show(S3),

    banner('Step 4: Negation movement'),
    maplist([I-F, I-F1]>>move_neg(F, F1), S3, S4), show(S4),

    banner('Step 5: Standardization of variables'),
    maplist([I-F, I-F1]>>standardize(I, F, F1), S4, S5), show(S5),

    banner('Step 6: Skolemization (and dropping universal quantifiers)'),
    maplist([I-F, I-F1]>>skolemize(F, F1), S5, S6), show(S6),
    format('Note: no existential quantifier is left in positive position, so no~n'),
    format('Skolem function is needed. In formula 1, ∃r became ∀r after the~n'),
    format('negation moved inward, so r1 is simply a universal variable.~n'),

    banner('Step 7: CNF clauses'),
    findall(Id-C, ( member(I-F, S6), cnf(F, CF), to_clauses(CF, Cs),
                    nth1(K, Cs, C), clause_id(I, K, Cs, Id) ), Clauses),
    forall(member(Id-C, Clauses), ( format('~w~t~6|', [Id]), pp_clause(C), nl )),

    banner('Step 8: Resolution refutation'),
    select(c9-NGc, Clauses, Inputs),
    format('Start with the negated goal  C9: '), pp_clause(NGc), nl, nl,
    (   refute(c9-NGc, Inputs, Proof)
    ->  print_proof(Proof, c9, 1),
        nl, format('The empty clause [] was derived.~n'),
        format('So the negated goal contradicts the knowledge base, which proves: '),
        pp(G), nl,
        used_clauses(Proof, U),
        format('~nInput clauses used: ~w~n', [U]),
        findall(I, ( member(I-_, Inputs), \+ memberchk(I, U) ), NotUsed),
        format('Clauses not needed: ~w~n', [NotUsed])
    ;   format('No refutation found.~n')
    ).

clause_id(I, _, [_], Id) :- !, atom_concat(c, I, Id).
clause_id(I, K, _, Id)  :- nth1(K, [a, b, c, d], L), format(atom(Id), 'c~w~w', [I, L]).

print_proof([], _, _).
print_proof([step(_, IId, Theta, Lit, R) | T], Prev, N) :-
    format(atom(RId), 'R~w', [N]),
    format('~w = resolve(~w, ~w) on ', [RId, Prev, IId]), pp(Lit), nl,
    format('     unifier θ = '), pp_theta(Theta), nl,
    format('     resolvent: '), pp_clause(R), nl,
    N1 is N + 1, print_proof(T, RId, N1).

used_clauses(P, U) :- findall(I, member(step(_, I, _, _, _), P), U).

% ---- pretty printing ----------------------------------------------------
banner(T) :- nl, format('% ~`=t~70|~n% ~w~n% ~`=t~70|~n', [T]).

show(L) :- forall(member(I-F, L), ( format('~w. ', [I]), pp(F), nl )).

pp(all(X, F))    :- !, format('∀~w ', [X]), pp(F).
pp(exists(X, F)) :- !, format('∃~w ', [X]), pp(F).
pp(imp(A, B))    :- !, format('('), pp(A), format(' → '), pp(B), format(')').
pp(and(A, B))    :- !, format('('), pp(A), format(' ∧ '), pp(B), format(')').
pp(or(A, B))     :- !, format('('), pp(A), format(' ∨ '), pp(B), format(')').
pp(neg(A))       :- !, format('¬'), pp(A).
pp(A)            :- pp_term(A).

pp_term(v(X)) :- !, format('~w', [X]).
pp_term(T) :- atomic(T), !, format('~w', [T]).
pp_term(T) :- T =.. [F | Args], format('~w(', [F]), pp_args(Args), format(')').
pp_args([A]) :- !, pp_term(A).
pp_args([A | As]) :- pp_term(A), format(', '), pp_args(As).

pp_clause([]) :- !, format('[]   (empty clause)').
pp_clause([L]) :- !, format('{ '), pp(L), format(' }').
pp_clause([L | Ls]) :- format('{ '), pp(L), forall(member(X, Ls), (format(' ∨ '), pp(X))), format(' }').

pp_theta([]) :- !, format('{ }').
pp_theta(S) :- format('{ '), pp_pairs(S), format(' }').
pp_pairs([N = V]) :- !, format('~w/', [N]), pp_term(V).
pp_pairs([N = V | T]) :- format('~w/', [N]), pp_term(V), format(', '), pp_pairs(T).
