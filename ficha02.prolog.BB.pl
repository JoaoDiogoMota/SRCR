%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% SIST. REPR. CONHECIMENTO E RACIOCINIO - MiEI/3

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Base de Conhecimento com informacao genealogica.

:- set_prolog_flag( discontiguous_warnings,off ).
:- set_prolog_flag( single_var_warnings,off ).
:- set_prolog_flag( unknown,fail ).

% 1
somaDois(X,Y,R) :-
	R is X+Y.

% 2
somaTres(X,Y,Z,R) :-
	R is X+Y+Z.

% 3 
somaLista([],0).
somaLista([H|T],R) :-
	 somaLista(T,P),
	 R is H+P.

% 4
operacao(adicao,X,Y,R) 
	:- R is X+Y.

operacao(subtracao,X,Y,R) 
	:- R is X-Y.

operacao(multiplicacao,X,Y,R) 
	:- R is X*Y.

operacao(divisao,X,Y,R) 
	:- R is X/Y.

% 5 
operacaoLista(adicao,[],0).
operacaoLista(adicao,[H|T],R) :-
	operacaoLista(adicao,T,P),
	R is H+P.


operacaoLista(multiplicacao,[],1).
operacaoLista(multiplicacao,[H|T],R) :-
	operacaoLista(multiplicacao,T,P),
	R is H*P.

% 6
maior(X,Y,R) :-
	X=<Y -> R is Y; R is X. 

/*	%ou
maior2(X,Y,X) :- X>Y.
maior2(X,Y,Y) :- Y=>X.
*/
% 7
maiorTres(X,Y,Z,R) :-
	maior(X,Y,T),
	maior(T,Z,S),
	R is S.


% 8
maiorLista([A],A).
maiorLista([H|T],R) :-
	maiorLista(T,P),
	maior(P,H,R).


% 9
menor(X,Y,R) :- 
	X=<Y -> R is X; R is Y.

% 10
menorTres(X,Y,Z,R) :-
	menor(X,Y,P),
	menor(P,Z,R).

% 11
menorLista([A],A).
menorLista([H|T],R) :-
	menorLista(T,P),
	menor(P,H,R).

% 12
nTotal([X],1).
nTotal([H|T],R) :-
	nTotal(T,P),
	R is P+1.


mediaA(X,R) :-
	somaLista(X,T),
	nTotal(X,N),
	R is T/N.

% 13
acrescenta(Num,[],[Num]).
acrescenta(Num,[H|T],R) :-
	Num=<H -> R = [Num,H|T]; acrescenta(Num,T,P),
							R=[H|P].


ordena([X],[X]).
ordena([H|T],R) :-
	ordena(T,P),
	acrescenta(H,P,R).


% 14 Ainda nao esta bem 
acrescenta2(Num,[],[Num]).
acrescenta2(Num,[H|T],R) :-
	H=<Num -> R = [Num,H|T]; acrescenta2(Num,T,P),
							R=[H|P].







