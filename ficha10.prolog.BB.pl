%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% SIST. REPR. CONHECIMENTO E RACIOCINIO - MiEI/3

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Programacao em logica 
% Grafos (Ficha 10)

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% SICStus PROLOG: Declaracoes iniciais

:- set_prolog_flag( discontiguous_warnings,off ).
:- set_prolog_flag( single_var_warnings,off ).
:- set_prolog_flag( unknown,fail ).

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
g( grafo([madrid, cordoba, sevilla, jaen, granada, huelva, cadiz],
  [aresta(huelva, sevilla, a49, 94),
   aresta(sevilla, cadiz,ap4, 125),
   aresta(sevilla, granada, a92, 256),
   aresta(granada, jaen,a44, 97),
   aresta(sevilla, cordoba, a4, 138),
   aresta(jaen,madrid, a4, 335),
   aresta(cordoba, madrid, a4, 400)]
 )).
%--------------------------------- - - - - - - - - - -  -  -  -  -   - 
%1
adjacente(X,Y,grafo(_,Es)) :- member(aresta(X,Y),Es).
adjacente(X,Y,grafo(_,Es)) :- member(aresta(Y,X),Es).

%2
caminho(G,A,B,P,Km,Es) :- caminho1(G,A,[B],P,Km,Es).

caminho1(_,A,[A|P1],[A|P1]).
caminho1(G,A,[Y|P1],P) :- 
    adjacente(X,Y,G), \+ memberchk(X,[Y|P1]),    %\+ = not 
    caminho1(G,A,[X,Y|P1],P).

%3
ciclo(G,A,P) :- adjacente(B,A,G), caminho(G,A,B,P1),
                length(P1,L), L>2,append(P1,[A],P).







