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


avo(A,N) :- 
	filho(N,X),pai(A,X) .
	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%assert-> inserir conhecimento 
%retract  -> remover conhecimento 
%listing -> mostrar todos
%em prolog a competencia de manter a coerencia 

%Invariante estrutural: nao permite a inserçao de conhecimento repetido

%1



%4
+avo( F,P ) :: (solucoes( (Ps),(filho( F,Ps )),S ),
                  comprimento( S,N ), 
                  N =< 2  ).












