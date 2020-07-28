%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% SIST. REPR. CONHECIMENTO E RACIOCINIO - MiEI/3

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Base de Conhecimento com informacao genealogica.

% 1
filho(joao,jose).

%2
filho(jose,manuel).

% 3
filho(carlos,jose).

% 4
pai(paulo,filipe).

% 5
pai(paulo,maria).

% 6
avo(antonio,nadia).

% 7
neto(nuno,ana).

% 8
masculino(joao).

% 9
masculino(jose).

% 10
feminino(maria).


% 11
feminino(joana).

% Outros
filho(rui,carlos).
filho(joana,rui).
filho(mariana,joana).

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% SICStus PROLOG: Declaracoes iniciais

:- set_prolog_flag( discontiguous_warnings,off ).
:- set_prolog_flag( single_var_warnings,off ).
:- set_prolog_flag( unknown,fail ).

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Extensao do predicado filho: Filho,Pai -> {V,F}

filho( joao,jose ).
filho( jose,manuel ).
filho( carlos,jose ).

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Extensao do predicado pai: Pai,Filho -> {V,F}

pai( P,F ) :-
    filho( F,P ).


% 12
% filho(F,P) :- pai(P,F).

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Extensao do predicado avo: Avo,Neto -> {V,F}

% 13
avo(A,N) :- 
	filho(N,X),pai(A,X) .

% 14
neto(A,N) :- 
	avo(N,A).

% 17
eAvo(A,N) :-
	grau(N,A,2).

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Extensao do predicado bisavo: Bisavo,Bisneto -> {V,F}

% 18
bisavo(X,Y) :-
	pai(P,Y),avo(X,P).

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Extensao do predicado trisavo: trisavo,trisneto -> {V,F}

% 19
trisavo(X,Y) :-
	pai(P,Y),bisavo(X,P).

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Extensao do predicado tetraneto: tetraneto,tetravo -> {V,F}

% 20
tetraneto(X,Y) :- 
	pai(P,X),trisavo(Y,P).

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Extensao do predicado descendente: Descendente,Ascendente -> {V,F}

% 15 Algo está mal!
descendente(X,Y) :- 
	pai(P,X),descendente(P,Y).


%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Extensao do predicado descendente: Descendente,Ascendente,Grau -> {V,F}

% 16
grau( D,A,1 ) :-
    pai( A,D ).

grau( D,A,N ) :-
    pai( B,D ),
    grau( B,A,G ),
    N is G+1.












