%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% SIST. REPR. CONHECIMENTO E RACIOCINIO - MiEI/3

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Programacao em logica 
% Grafos (Ficha 9)

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% SICStus PROLOG: Declaracoes iniciais

:- set_prolog_flag( discontiguous_warnings,off ).
:- set_prolog_flag( single_var_warnings,off ).
:- set_prolog_flag( unknown,fail ).

%--------------------------------- - - - - - - - - - -  -  -  -  -   -

g(grafo([a,b,c,d,e,f,g], [aresta(a,b),aresta(c,d),aresta(c,f),aresta(d,f),aresta(f,g)])).   

g1(grafo([a,b,c,d,e,f,g], [aresta(a,b),aresta(c,d),aresta(c,f),aresta(d,f),aresta(f,g), aresta(f,e), aresta(e,d)])).    


%--------------------------------- - - - - - - - - - -  -  -  -  -   - 
%1
adjacente(X,Y,grafo(_,Es)) :- member(aresta(X,Y),Es).
adjacente(X,Y,grafo(_,Es)) :- member(aresta(Y,X),Es).

%2
caminho(G,A,B,P) :- caminho1(G,A,[B],P).

caminho1(_,A,[A|P1],[A|P1]).
caminho1(G,A,[Y|P1],P) :- 
    adjacente(X,Y,G), \+ memberchk(X,[Y|P1]),    %\+ = not 
    caminho1(G,A,[X,Y|P1],P).

%3
ciclo(G,A,P) :- adjacente(B,A,G), caminho(G,A,B,P1),
                length(P1,L), L>2,append(P1,[A],P).







