%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Programacao em logica estendida
% Representacao de conhecimento imperfeito

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% SICStus PROLOG: Declaracoes iniciais

:- set_prolog_flag( discontiguous_warnings,off ).
:- set_prolog_flag( single_var_warnings,off ).
:- set_prolog_flag( unknown,fail ).

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% SICStus PROLOG: definicoes iniciais

:- op( 900,xfy,'::' ).
:- dynamic jogo/3.

%---------------------------------- ---- - - - -- - -  -
%demo

demo( Questao,verdadeiro ) :-
    Questao.
demo( Questao,falso ) :-
    -Questao.
demo( Questao,desconhecido ) :-
    nao( Questao ),
    nao( -Questao ).

 %-------------------------------------- - - - - - - - - -
 %nao

nao( Questao ) :-
    Questao, !, fail.
nao( Questao ).

%------------------------------------------ --- - - - - - - -

solucoes( X,Y,Z ) :-
    findall( X,Y,Z ).

comprimento( S,N ) :-
    length( S,N ).

%------------------------------------ -- - - - - -- - - - - -
-jogo(J,A,AC) :- nao(jogo(J,A,AC)), nao(excecao(jogo(J,A,AC))).
%--------------------------------- - - - - - - - - - -  -  questão i
jogo( 1,aa,500 ).  

%--------------------------------- - - - - - - - - - -  -  questão ii

%Valor nulo tipo 1 - Desconhecido
jogo( 2,bb,xpto0123 ).
excecao( jogo( Jogo,Arbitro,Ajudas ) ) :-
    jogo( Jogo,Arbitro,xpto0123 ).

%3
excecao(jogo(3,cc,500)).
excecao(jogo(3,cc,2500)).

%4
excecao(jogo(4,dd,X)) :- X>=250, X=<750.

%5
jogo(5,ee,xpto765).
excecao(jogo(Jogo,Arbitro,Ajudas)) :-
	jogo(Jogo,Arbitro,xpto765).

nulo(xpto765).

+jogo(J,A,C) :: (solucoes(Ajudas,(jogo(5,ee,Ajudas),
	nao(nulo(Ajudas))),
S),
comprimento(S,N),N==0).


%6
jogo(6,ff,250).
excecao(jogo(6,ff,X)) :- X>=5000.

%7
-jogo(7,gg,2500).
jogo(7,gg,valor).
excecao(jogo(Jogo,Arbitro,Ajudas)) :- jogo(Jogo,Arbitro,valor).

%8
jogo(8,hh,X) :- 
		X =<1250, X >= 750.

%9
jogo(9,ii,X) :- 
		X =<3500, X >= 2500.
excecao(jogo(Jogo,Arbitro,Ajudas)) :- jogo(Jogo,Arbitro,valor).




%10
+jogo(N,Arbitro,Ajudas) :: (solucoes((Arb),(jogo(N,Arb,Ajudas)),s),
							comprimento(S,R),
							N=<1).

%11
+jogo(N,Arbitro,Ajudas) :: (solucoes(Arbitro,jogo(NN,Arbitro,NValor)),S,
						comprimento(S,R),
						N=<3).

%12
+jogo(N,Arbitro,Ajudas) :: (solucoes)




