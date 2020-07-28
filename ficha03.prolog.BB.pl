%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% SIST. REPR. CONHECIMENTO E RACIOCINIO - MiEI/3

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Base de Conhecimento com informacao genealogica.

:- set_prolog_flag( discontiguous_warnings,off ).
:- set_prolog_flag( single_var_warnings,off ).
:- set_prolog_flag( unknown,fail ).

% 1
elem(Num,[]) :- !,fail.
elem(Num,[H|T]) :- Num==H;
	elem(Num,T).

%2
size([X],1).
size([H|T],R) :- size(T,P),
		R is P+1.


% Predicado not
not(Q) :- Q,!,fail.
not(Q).

%3	
diferente([],0).
diferente([H|T],R) :- elem(H,T)->diferente(T,R).
diferente([H|T],R) :- not(elem(H,T)) -> diferente(T,P),
					R is P+1.

%4
apaga1(Num,[X],[]).
apaga1(Num,[H|T],R) :-
			Num==H -> R = T; apaga1(Num,T,P), R = [H|P].

%5 
apagaT(X,[],[]).
apagaT(X,[X],[]).
apagaT(Num,[H|T],R) :-
	Num==H -> apagaT(Num,T,P), R=P; apagaT(Num,T,P), R=[H|P].

%6
adicionar(X,[],[X]).
adicionar(Num,L,R) :-
	elem(Num,L) -> R = L; R= [Num|L].

%7
concatenar(X,[],X).
concatenar([],X,X).
concatenar([H|T],Y,R) :-
		concatenar(T,Y,P), R=[H|P].

%8
init([X],[]).
init([H|T],R) :- init(T,P), R = [H|P].

last([X],X).
last([H|T],R) :- last(T,R).
	

inverte([],[]).
inverte([X],[X]).
inverte(L,R) :-
	last(L,P), init(L,T),inverte(T,W), R=[P|W].

%9
sublista([X],[]) :- !,fail.
sublista([],X).
sublista([X|XS],[Y|YS]) :- 
	X==Y -> sublista(XS,YS); sublista([X|XS],YS). 

%10






