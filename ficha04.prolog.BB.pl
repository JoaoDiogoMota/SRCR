%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% SIST. REPR. CONHECIMENTO E RACIOCINIO - MiEI/3

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Base de Conhecimento com informacao genealogica.

:- set_prolog_flag( discontiguous_warnings,off ).
:- set_prolog_flag( single_var_warnings,off ).
:- set_prolog_flag( unknown,fail ).

%%%%%%%%%%%%AUXILIARES%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%8
init([X],[]).
init([H|T],R) :- init(T,P), R = [H|P].

last([X],X).
last([H|T],R) :- last(T,R).
	

inverte([],[]).
inverte([X],[X]).
inverte(L,R) :-
	last(L,P), init(L,T),inverte(T,W), R=[P|W].

not(Q) :- Q,!,fail.
not(Q).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 1
par(Num):- 
		0 is Num mod 2.

%2
impar(Num) :- 
		1 is Num mod 2.

%3
natural(Num) :-
		 naturalAux(Num,1).

naturalAux(Num,Num).
naturalAux(Num,R) :- 
		 Num<R -> !,fail; S is R+1, naturalAux(Num,S).

%4
inteiro(Num) :- Num>0 -> natural(Num); inteiroAux(Num,0).

inteiroAux(Num,Num).
inteiroAux(Num,R) :- Num>R -> !,fail; S is R-1, inteiroAux(Num,S).
		
%5 Está mal
divisores(Num,L) :- divisoresAux(Num,1,L).

divisoresAux(Num,R,L) :-
		Num>R -> divisoresAux2(Num,R,L).
			
divisoresAux2(Num,R,L) :- 
			(0 is Num mod R) -> (S is R+1),(T=[R|L]), divisoresAux(Num,S,T); (S is R+1), divisoresAux(Num,S,L).


%6 Está mal
primo(Num) :- primoAux(Num,0,1).

primoAux(Num,2,R) :- 
		(Num>R) -> primoAux2(Num,2,R).

primoAux(Num,N,R) :- 
		(Num>R) -> primoAux2(Num,N,R); !,fail.

primoAux2(Num,N,R) :-
		(0 is Num mod R) -> T is N+1,S is R+1, primoAux(Num,T,S); S is R+1, primoAux(Num,T,S).


/*
divisores(Num,L) :- divisoresAux(Num,L,1).

divisoresAux(Num,L,R) :-
		Num>R -> divisoresAux2(Num,L,R).
			
divisoresAux2(Num,L,R) :- 
			0 is Num mod R -> S is R+1, T=[R|L], divisoresAux(Num,T,S); S is R+1,divisoresAux(Num,L,S).




		divisores(Num,L) :- divisoresAux(Num,L,1).

divisoresAux(Num,L,R) :-
		Num>R -> divisoresAux2(Num,L,R).
			
divisoresAux2(Num,L,R) :- 
			0 is Num mod R -> S is R+1, T=[R|L], divisoresAux(Num,T,S); S is R+1,divisoresAux(Num,L,S).

		*/
		
%7
mdc(X,Y,R) :-
	X>Y,
	X1 is X-Y,
	mdc(X1,Y,R).
mdc(X,Y,R) :-
	Y>X,
	Y1 is Y-X,
	mdc(X,Y1,R).
mdc(X,X,X).

%8
fibonacci(0,0).
fibonacci(1,1).
fibonacci(N,R) :- N1 is N-1,
	N2 is N-2,
	fibonacci(N1,R1),
	fibonacci(N2,R2),
	R is R1+R2.












