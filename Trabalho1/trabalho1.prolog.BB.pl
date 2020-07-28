%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% SIST. REPR. CONHECIMENTO E RACIOCIONIO - MiEI/3
%--------------------------------- - - - - - - - - - -  -  -  -  -   -

% SICStus PROLOG: Declaracoes iniciais
:- set_prolog_flag( discontiguous_warnings,off ).
:- set_prolog_flag( single_var_warnings,off ).
:- set_prolog_flag( unknown,fail ).

% Definições iniciais
:- op( 900,xfy,'::' ).
:- dynamic adjudicante/4.
:- dynamic adjudicataria/4.
:- dynamic contrato/10.

% Predicado solucoes:
% Termo, Predicado, Lista -> { V, F }
solucoes( T,P,L ) :- findall( T,P,L ).

% Predicado comprimento:
% Lista, Comprimento -> { V, F }
comprimento([],0).
comprimento([H|T],N) :-
	comprimento(T,S),
	N is S+1.

% Predicado pertence:
% Valor, Lista -> { V, F }
pertence( X,[X|L] ).
pertence( X,[Y|L] ) :- X \= Y, pertence( X,L ).

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Adicionar conhecimento a "base de dados"
%--------------------------------- - - - - - - - - - -  -  -  -  -   -

adiciona(T) :- solucoes(Invariante, +T::Invariante, S),
               insere(T),
               testa(S).

insere(T) :- assert(T).
insere(T) :- retract(T),!,fail.

testa([]).
testa([H|T]) :- H, testa(T).

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Remover conhecimento a "base de dados"
%--------------------------------- - - - - - - - - - -  -  -  -  -   -

remove(T) :- solucoes( Invariante, -T::Invariante, S),
    				 remocao(T),
    		 		 testa(S).

remocao(T) :- retract(T).
remocao(T) :- assert(T),!,fail.


%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Extensao do meta-predicado demo: Questao,Resposta -> {V,F}
%--------------------------------- - - - - - - - - - -  -  -  -  -   -

demo( Questao,verdadeiro ) :-
    Questao.
demo( Questao,falso ) :-
    -Questao.
demo( Questao,desconhecido ) :-
    nao( Questao ),
    nao( -Questao ).

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Extensao do meta-predicado nao: Questao -> {V,F}
%--------------------------------- - - - - - - - - - -  -  -  -  -   -

nao( Questao ) :-
    Questao, !, fail.
nao( Questao ).

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Predicados para permitir a representação correta de conhecimento falso e desconhecido
%--------------------------------- - - - - - - - - - -  -  -  -  -   -
-adjudicante(IdAd,Nome,Nif,Morada) :- nao(adjudicante(IdAd,Nome,Nif,Morada)), nao(excecao(adjudicante(IdAd,Nome,Nif,Morada))).

-adjudicataria(IdAda,Nome,Nif,Morada) :- nao(adjudicataria(IdAda,Nome,Nif,Morada)), nao(excecao(adjudicataria(IdAda,Nome,Nif,Morada))).

-contrato(IdC,ID,IdAda,TipoDeCt,Procedimento,Descricao,Valor,Prazo,Local,Data) :-
				 nao(contrato(IdC,ID,IdAda,TipoDeCt,Procedimento,Descricao,Valor,Prazo,Local,Data)),
				 nao(excecao(contrato(IdC,ID,IdAda,TipoDeCt,Procedimento,Descricao,Valor,Prazo,Local,Data))).

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% FACTOS
%--------------------------------- - - - - - - - - - -  -  -  -  -   -

% adjudicante: #IdAd, Nome, NIF, Morada -> { V, F, D }
adjudicante(1,maria,123,rua_1_porto).
adjudicante(2,edp,987,rua_26_lisboa).
adjudicante(3,telecomunicacoes_X,135,travessa_45_braga).
adjudicante(4,empresa_Y,246,praca_X_lisboa).
excecao(adjudicante(11,romulus_gama,777,praceta_Z)).
excecao(adjudicante(11,romulus_gama,777,praceta_K)).
-adjudicante(5,ana,144, rua_yyz_caminha).
-adjudicante(6,trefl,222, rua_yyz_lisboa).

% adjudicatária: #IdAda, Nome, NIF, Morada -> { V, F, D }
adjudicataria(5,amelia,764,rua_992_porto).
adjudicataria(6,universidade_minho,967,rua_25_braga).
adjudicataria(7,hospital_X,762,rua_37_porto).
adjudicataria(8,manuel,016,travessa_123_lisboa).
adjudicataria(9,nobunaga,222,x666).
excecao(adjudicataria(IdAda,Nome,Nif,Morada)) :- adjudicataria(IdAda,Nome,Nif,x666).
-adjudicataria(10,antonio,922,rua_2340_viana).
-adjudicataria(11,morillo,113,travessa_9_lisboa).

% contrato: #IdC, #IdAd, #IdAda, TipoDeContrato, TipoDeProcedimento, Descrição, Valor, Prazo,Local, Data -> { V, F, D }
contrato(1,1,5,aquisicao_servicos,ajuste_direto,arrendamento_de_habitacao,4500,730,porto,02-03-2019).
contrato(2,2,6,lococao_bens_moveis,consulta_previa,aquisicao_paineis_solares,5000,200,braga,02-03-2018).
contrato(3,3,7,aquisicao_bens_moveis,ajuste_direto,estabelecimento_de_comunicacoes,1500,150,porto,02-03-2022).
contrato(4,4,8,lococao_bens_moveis,consulta_previa,contratacao_de_servicos,500,257,lisboa,02-03-2021).
contrato(5,1,8,aquisicao_servicos,ajuste_direto,prestacao_de_servicos,2690,360,lisboa,02-03-2020).
contrato(6,3,6,aquisicao_bens_moveis,ajuste_direto,estabelecimento_de_comunicacoes,3200,355,braga,02-03-2021).
contrato(7,2,8,aquisicao_servicos,concurso_publico,fornecimento_de_energia,5000,730,lisboa,02-03-2018).
contrato(8,3,5,aquisicao_bens_moveis,concurso_publico,fornecimento_de_energia,10000,365,porto,02-03-2019).
contrato(9,4,5,aquisicao_servicos,consulta_previa,contratato_de_trabalho,9100,200,porto,02-03-2017).
contrato(10,2,8,lococao_bens_moveis,ajuste_direto,fornecimento_de_energia,1140,100,lisboa,02-03-2020).
contrato(11,1,5,lococao_bens_moveis,concurso_publico,arrendamento_de_habitacao,2250,365,porto,02-03-2021).
contrato(12,11,9,aquisicao_servicos,concurso_publico,null1,8920,846,minho,03-04-2019).
nulo(null1).
+contrato(IdC,_,_,_,_,_,_,_,_,_) :: (solucoes(
									 (Descricao),
									 (contrato(IdC,X1,X2,X3,X4,X5,X6,X7,X8,X9), nao(nulo(X5))),
									 S),
									 comprimento(S,N),
									 N == 0).
%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Invariantes
%--------------------------------- - - - - - - - - - -  -  -  -  -   -

% Invariantes para não permitir inserção de conhecimento repetido.
+adjudicante(_,Nome,Nif,Morada) :: (solucoes( (Id,Nome,Nif,Morada),(adjudicante(Id,Nome,Nif,Morada)),S ),
                                    comprimento( S,N ),
                                    N == 1).

+adjudicataria(_,Nome,Nif,Morada) :: (solucoes( (Id,Nome,Nif,Morada),(adjudicataria(Id,Nome,Nif,Morada)),S),
                                      comprimento( S,N ),
                                      N == 1).

% Invariantes para não permitir inserção de adjudicantes/adjudicatarias com a mesma Identificação.
+adjudicante(Id,_,_,_) :: (solucoes( (Id,Nome,Nif,Morada),(adjudicante(Id,Nome,Nif,Morada)),S),
                          comprimento( S,N ),
                          N == 1).

+adjudicataria(Id,_,_,_) :: (solucoes( (Id,Nome,Nif,Morada),(adjudicataria(Id,Nome,Nif,Morada)),S),
                          comprimento( S,N ),
                          N == 1).

% Invariantes para não permitir a remoção de ajudicantes/adjudicatarias com contratos celebrados.
-adjudicante(ID,_,_,_) :: (allContratos_Adjudicante( ID, S ),
													comprimento( S,N ),
													N == 0).

-adjudicataria(ID,_,_,_) :: (allContratos_Adjudicataria( ID, S ),
													   comprimento( S,N ),
												    	N == 0).

% Invariante para não permitir inserção de contratos com a mesma identificação.
+contrato(IdC,_,_,_,_,_,_,_,_,_) :: (solucoes( (IdC,IdAd,IdAda,TipoDeCt,Procedimento,Descricao,Valor,Prazo,Local,Data),
																		(contrato(IdC,IdAd,IdAda,TipoDeCt,Procedimento,Descricao,Valor,Prazo,Local,Data)),S),
																	  comprimento( S, N),
																	  N == 1).

% Invariante para não permitir inserção de contratos onde pelo menos um dos numeros de Identificação nao pertence a base de conhecimento.
+contrato(IdC,IdAd,IdAda,_,_,_,_,_,_,_) :: (solucoes( (IdAd),(adjudicante(IdAd,Nome,Nif,Morada)),S1 ),
                                            solucoes( (IdAda),(adjudicataria(IdAda,Nom,Nf,Rua)),S2 ),
                                            comprimento( S1,N1 ),comprimento( S2,N2 ),
                                            N1 == 1, N2 == 1).

% Invariantes para controlar o tipo de contratos que são estabelecidos.
+contrato(_,_,_,_,Procedimento,_,_,_,_,_) :: pertence(Procedimento,[ajuste_direto,consulta_previa,concurso_publico]).

+contrato(_,_,_,TipoDeCt,ajuste_direto,_,Valor,Prazo,_,_) :: (Valor =< 5000,
                                                             Prazo =< 365,
                                                             pertence(TipoDeCt,[aquisicao_bens_moveis,lococao_bens_moveis,aquisicao_servicos])).

% Invariante para não permitir a remoção de contratos onde as entidades pertençam à base de conhecimento.
-contrato(_,IdAd,IdAda,_,_,_,_,_,_,_) :: (solucoes( (IdAd),(adjudicante(IdAd,Nome,Nif,Morada)),S1 ),
                                          solucoes( (IdAda),(adjudicataria(IdAda,Nom,Nf,Rua)),S2 ),
                                          comprimento( S1,N1 ),comprimento( S2,N2 ),
                                          N1 == 0, N2 == 0).

% Invariante para controlo da regra de 3 anos
+contrato(_,IdAd,IdAda,_,_,_,Valor,_,_,Data) :: (preco(IdAd,IdAda,P,Data), R is P - Valor, R =< 74999).

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Predicados
%--------------------------------- - - - - - - - - - -  -  -  -  -   -

% Predicado que soma os valores de uma lista
soma([],0).
soma([H|T], R) :- soma(T,P),
									R is H + P.

% Predicado para obter os preços contratuais de contratos celebrados
custoTotal(IdAd,IdAda, S) :- solucoes((Valor,Data),(contrato(_,IdAd,IdAda,_,_,_,Valor,_,_,Data)), S).


within2Years((D1-M1-Y1),(D2-M2-Y2)) :- (Y1 =:= (Y2 + 2), M2 =:= M1, D2 >= D1 ;
                                        Y1 =:= (Y2 + 2), M2 >= M1 ;
																			  Y1 =:= (Y2+1) ;
                                        Y1 =:= Y2, M2 =< M1 ;
																			  Y1 =:= Y2, M2 =:= M1, D2 =< D1).

% Predicado que verifica se um contrato foi realizado num período máximo de 3 anos
withinTime(Data,[],S) :- S is 0.
withinTime(Data,[(Val,Dt)|T],S) :- (within2Years(Data,Dt) -> withinTime(Data,T,R), S is R + Val;
															 withinTime(Data,T,S)).

% Predicado para obter os preços contratuais acumulados de contratos celebrados num período de 3 anos
preco( IdAd, IdAda, R, Data) :- custoTotal(IdAd,IdAda, S), withinTime(Data,S,R).

% Predicado para obter todos os adjudicantes
allAdjudicantes( S ) :- solucoes( (Id,Nome,Nif,Morada),(adjudicante(Id,Nome,Nif,Morada)),S ).

% Predicado para obter todas as adjudicatarias
allAdjudicatarias( S ) :- solucoes( (Id,Nome,Nif,Morada),(adjudicataria(Id,Nome,Nif,Morada)),S ).

% Predicado para obter todos os contratos
allContratos( S ) :- solucoes(
                             (IdC,IdAd,IdAda,TipoDeCt,Procedimento,Descricao,Valor,Prazo,Local,Data),
                             (contrato(IdC,IdAd,IdAda,TipoDeCt,Procedimento,Descricao,Valor,Prazo,Local,Data)),
                             S
														 ).

%-------------------------------------- - - - - - - - - - -  -  -  -  -   -
% IDENTIFICAÇÃO DE ADJUDICANTE/ADJUDICATARIA POR DETERMINADA CARACTERÍSTICA
%-------------------------------------- - - - - - - - - - -  -  -  -  -   -

% Predicado para identificar um adjudicante por ID.
adjudicante_ID( ID, S ) :- solucoes(
								   ( Nome, NIF, Morada ),
								   (adjudicante(ID, Nome, NIF, Morada)),
								   S
								   ).

% Predicado para identificar um adjudicante por Nome.
adjudicante_NOME( Nome, S ) :- solucoes(
									   ( ID, NIF, Morada ),
									   (adjudicante(ID, Nome, NIF, Morada)),
									   S
									   ).

% Predicado para identificar um adjudicante por NIF.
adjudicante_NIF( NIF, S ) :- solucoes(
									 ( ID, Nome, Morada ),
									 (adjudicante(ID, Nome, NIF, Morada)),
									 S
									 ).

% Predicado para identificar adjudicantes por Morada.
adjudicante_MORADA( Morada, S ) :- solucoes(
 										   ( ID, Nome, NIF ),
 										   (adjudicante(ID, Nome, NIF, Morada)),
 										   S
 										   ).

% Predicado para identificar uma adjudicataria por ID.
adjudicataria_ID( ID, S ) :- solucoes(
									 ( Nome, NIF, Morada ),
									 (adjudicataria(ID, Nome, NIF, Morada)),
									 S
									 ).

% Predicado para identificar um adjudicataria por Nome.
adjudicataria_NOME( Nome, S ) :- solucoes(
										 ( ID, NIF, Morada ),
										 (adjudicataria(ID, Nome, NIF, Morada)),
										 S
										 ).

% Predicado para identificar um adjudicataria por NIF.
adjudicataria_NIF( NIF, S ) :- solucoes(
									   ( ID, Nome, Morada ),
									   (adjudicataria(ID, Nome, NIF, Morada)),
									   S
									   ).

% Predicado para identificar adjudicatarias por Morada.
adjudicataria_MORADA( Morada, S ) :- solucoes(
 											 ( ID, Nome, NIF ),
 											 (adjudicataria(ID, Nome, NIF, Morada)),
 											 S
 											 ).

%------------------- - - - - - - - - - -  -  -  -  -   -
% IDENTIFICAÇÃO DE CONTRATOS
%------------------- - - - - - - - - - -  -  -  -  -   -

% Predicado para obter todos os contratos celebrados pelo adjudicante com id ID.
allContratos_Adjudicante( ID, S ) :- solucoes(
											 (IdC,ID,IdAda,TipoDeCt,Procedimento,Descricao,Valor,Prazo,Local,Data),
											 contrato(IdC,ID,IdAda,TipoDeCt,Procedimento,Descricao,Valor,Prazo,Local,Data),
											 S
											 ).

% Predicado para obter todos os contratos celebrados pela adjudicatária com id ID.
allContratos_Adjudicataria( ID, S ) :- solucoes(
											   (IdC,IdAd,ID,TipoDeCt,Procedimento,Descricao,Valor,Prazo,Local,Data),
											   contrato(IdC,IdAd,ID,TipoDeCt,Procedimento,Descricao,Valor,Prazo,Local,Data),
											   S
											   ).

% Predicado para obter todos os contratos celebrados entre o adjudicante IdAd e a adjudicataria IdAda.
contratos_partilhados( IdAd,IdAda,S ) :- solucoes(
												 (IdC,TipoDeCt,Procedimento,Descricao,Valor,Prazo,Local,Data),
												 contrato(IdC,IdAd,IdAda,TipoDeCt,Procedimento,Descricao,Valor,Prazo,Local,Data),
												 S
												 ).

% Predicado para obter um contrato pela sua identificação.
contrato_ID( ID, S ) :- solucoes(
								(IdAd,IdAda,TipoDeCt,Procedimento,Descricao,Valor,Prazo,Local,Data),
								contrato(ID,IdAd,IdAda,TipoDeCt,Procedimento,Descricao,Valor,Prazo,Local,Data),
								S
								).

% Predicado para obter todos os contratos de um determinado tipo celebrados por um adjudicante.
contratos_tipo_adjudicante( IdAd, TipoDeCt, S) :- solucoes(
														  (IdC,IdAda,Procedimento,Descricao,Valor,Prazo,Local,Data),
														  contrato(IdC,IdAd,IdAda,TipoDeCt,Procedimento,Descricao,Valor,Prazo,Local,Data),
														  S
														  ).

% Predicado para obter todos os contratos de um determinado tipo celebrados por uma determinada adjudicataria.
contratos_tipo_adjudicataria( IdAda, TipoDeCt, S) :- solucoes(
															 (IdC,IdAd,Procedimento,Descricao,Valor,Prazo,Local,Data),
															 contrato(IdC,IdAd,IdAda,TipoDeCt,Procedimento,Descricao,Valor,Prazo,Local,Data),
															 S
															 ).

% Predicado para obter todos os contratos de um determinado tipo celebrados.
contratos_tipo(TipoDeCt, S) :- 	solucoes(
										(IdC,IdAd,IdAda,TipoDeCt,Procedimento,Descricao,Valor,Prazo,Local,Data),
										contrato(IdC,IdAd,IdAda,TipoDeCt,Procedimento,Descricao,Valor,Prazo,Local,Data),
										S
										).

% Predicado para obter todos os contratos de um determinado valor celebrados.
contratos_valor(Valor, S) :- solucoes(
									 (IdC,IdAd,IdAda,TipoDeCt,Procedimento,Descricao,Valor,Prazo,Local,Data),
									 contrato(IdC,IdAd,IdAda,TipoDeCt,Procedimento,Descricao,Valor,Prazo,Local,Data),
									 S
                                     ).

% Predicado para obter todos os contratos celebrados numa determinada morada.
contratos_morada(Morada, S) :- solucoes(
										(IdC,IdAd,IdAda,Procedimento,Descricao,Valor,Prazo,Data),
										contrato(IdC,IdAd,IdAda,TipoDeCt,Procedimento,Descricao,Valor,Prazo,Morada,Data),
										S
										).

% Predicado para obter todos os contratos de um determinado procedimento celebrados.
contratos_procedimento(Procedimento, S) :- solucoes(
													(IdC,IdAd,IdAda,TipoDeCt,Descricao,Valor,Prazo,Data),
													contrato(IdC,IdAd,IdAda,TipoDeCt,Procedimento,Descricao,Valor,Prazo,Morada,Data),
													S
													).

% Predicado para obter o valor total em contratos de um certo tipo celebrados.
valor_contratos_tipo(TipoDeCt, S) :- custoTotalTipo(TipoDeCt, R), soma(R,S).

% Predicado para obter os valores contratuais para contratos de um certo tipo celebrados.
custoTotalTipo(TipoDeCt, S) :- solucoes(
									   (Valor),
									   (contrato(_,_,_,TipoDeCt,_,_,Valor,_,_,_)),
									   S
									   ).

% Predicado para obter o valor total em contratos de um certo tipo celebrados por um adjudicante.
valor_contratos_adjudicante_tipo(IdAd, TipoDeCt, S) :- custoTotalAdjudicante(IdAd, TipoDeCt, R), soma(R,S).

% Predicado para obter os valores contratuais para contratos de um certo tipo celebrados por um adjudicante.
custoTotalAdjudicante(IdAd, TipoDeCt, S) :- solucoes(
													(Valor),
													(contrato(_,IdAd,_,TipoDeCt,_,_,Valor,_,_,_)),
													S
													).

% Predicado para obter o valor total em contratos de um certo tipo celebrados por uma adjudicataria.
valor_contratos_adjudicataria_tipo(IdAda, TipoDeCt, S) :- custoTotalAdjudicataria(IdAda, TipoDeCt, R), soma(R,S).

% Predicado para obter os valores contratuais para contratos de um certo tipo celebrados por uma adjudicataria.
custoTotalAdjudicataria(IdAda, TipoDeCt, S) :- solucoes(
														(Valor),
														(contrato(_,_,IdAda,TipoDeCt,_,_,Valor,_,_,_)),
														S
														).

%Predicado para obter o valor total em contratos celebrados
valor_contratos(R) :- solucoes(
							  (Valor),
							  (contrato(_,_,_,_,_,_,Valor,_,_,_)),
							  S),
							  soma(S,R).


% Predicado para obter o valor total em contratos celebrados por um adjudicante.
valor_contratos_adjudicante(IdAd, R) :- solucoes(
												(Valor),
												(contrato(_,IdAd,_,_,_,_,Valor,_,_,_)),
												S),
												soma(S,R).

% Predicado para obter o valor total em contratos celebrados por uma adjudicataria.
valor_contratos_adjudicataria(IdAda, R) :- solucoes(
													(Valor),
													(contrato(_,_,IdAda,_,_,_,Valor,_,_,_)),
													S),
													soma(S,R).

% Predicado que calcula o valor médio de uma lista.
media([],0).
media(Lista,Media) :-
    soma(Lista,X),
    comprimento(Lista,L),
    Media is (div(X,L)).

% Predicado para obter o valor médio dos contratos celebrados.
valor_contratos_media(S) :- solucoes(
									(Valor),
									(contrato(_,_,_,_,_,_,Valor,_,_,_)),
									R),
									media(R,S).

% Predicado para obter o valor médio dos contratos celebrados por um adjudicante.
valor_contratos_media_adjudicante(ID, S) :- solucoes(
													(Valor),
													(contrato(_,ID,_,_,_,_,Valor,_,_,_)),
													R),
													media(R,S).

% Predicado para obter o valor médio dos contratos celebrados por uma adjudicataria.
valor_contratos_media_adjudicataria(ID, S) :- solucoes(
													  (Valor),
													  (contrato(_,_,ID,_,_,_,Valor,_,_,_)),
													  R),
													  media(R,S).

% Predicado que obtém as datas de celebração de todos os contratos.
getDatas(S) :- solucoes(
                       (Y-M-D),
                       (contrato(IdC,IdAd,IdAda,TipoDeCt,Procedimento,Descricao,Valor,Prazo,Local,Y-M-D)),
											 S
					   			 		 ).

% Predicado que obtém o ano em que um contrato foi celebrado.
getYear((IdC,IdAd,IdAda,TipoDeCt,Procedimento,Descricao,Valor,Prazo,Local,D-M-Y),Y).

% Predicado que obtém o tipo de um contrato.
getTipo((IdC,IdAd,IdAda,TipoDeCt,Procedimento,Descricao,Valor,Prazo,Local,D-M-Y),TipoDeCt).

% Predicado que permite obter todos os contratos celebrados desde um certo ano.
allContratosSince(Ano,R) :- allContratos(Lista), allContratosSinceAux(Ano,Lista,R).

allContratosSinceAux(Ano,[],[]).
allContratosSinceAux(Ano,[H|T],R) :- getYear(H,X), Ano=<X -> allContratosSinceAux(Ano,T,Sub), R = [H|Sub]; allContratosSinceAux(Ano,T,R).

%Predicado que permite obter todos os contratos celebrados por um adjudicante desde um certo ano.
allContratosSinceAdj(Ano,IdA,R) :- allContratos_Adjudicante(IdA,Lista), allContratosSinceAux(Ano,Lista,R).

%Predicado que permite obter todos os contratos celebrados por uma adjudicataria desde um certo ano.
allContratosSinceAdja(Ano,IdA,R) :- allContratos_Adjudicataria(IdA,Lista), allContratosSinceAux(Ano,Lista,R).

%Predicado que permite obter os três contratos com maior valor de determinado tipo.
maisFaturou3(Tipo,R) :- solucoes(
															  (IdC,Valor),
																(contrato(IdC,_,_,Tipo,_,_,Valor,_,_,_)),
																S
																),
																maisFaturou3Aux(S,P),
																ordena(P,R).

%Predicado auxiliar para a obtenção dos três contratos com maior valor de determinado tipo.
maisFaturou3Aux(L,R) :- comprimento(L,X), X > 3 -> removeMenor(L,P), maisFaturou3Aux(P,R); R = L.

%Predicado que remove o menor duplo de uma lista
removeMenor([H|T],P) :- menorLista([H|T],R), R == H -> P = T; removeMenor(T,Y), P = [H|Y].

%Predicado que devolve o menor duplo de uma lista.
menorLista([A],A).
menorLista([H|T],R) :-
	menorLista(T,P),
	menor(P,H,R).

%Predicado que devolve o menor duplo entre dois duplos.
menor((X,X1),(Y,Y1),(R,R1)) :-
	X1 =< Y1 -> R is X, R1 is X1; R is Y,R1 is Y1.

%Predicado que ordena uma lista por ordem crescente.
ordena([X],[X]).
ordena([H|T],R) :-
ordena(T,P),
	acrescenta(H,P,R).

%Predicado que acrescenta um duplo a uma lista.
acrescenta(Num,[],[Num]).
acrescenta((A,B),[(X,Y)|T],R) :-
		B =< Y -> R = [(A,B),(X,Y)|T];
		acrescenta((A,B),T,P),
		R=[(X,Y)|P].

%Predicado que obtém, para cada tipo de contrato, o contrato com maior valor contratual.
getMaioresTipo(R) :- allContratos(S), getAllTipos(S,[],Tipos), getMaioresTipo(Tipos,[],R).
getMaioresTipo([],Aux,R) :- R = Aux.
getMaioresTipo([H|T],[],R) :- getMaxTipo(H,Max), getMaioresTipo(T,[Max],R).
getMaioresTipo([H|T],[Ha|Ta],R) :- getMaxTipo(H,Max), getMaioresTipo(T,[Max,Ha|Ta],R).

%Predicado que obtém o contrato com maior valor contratual, de um determinado tipo.
getMaxTipo(Tipo,Solution) :- contratos_tipo(Tipo,List), max(List,(_,_,_,_,_,_,0,_,_,_),0,Solution).

%Predicado que calcula o maior valor contratual de uma lista de contratos.
max([],ContratoMaximo,Maximo,Solution) :- Solution = ContratoMaximo.
max([(IdC,IdA,IdAc,TipoC,TipoP,Desc,ValorC,Prazo,Local,Data)|T],ContratoMaximo,Maximo,Solution) :-
																		( ValorC >= Maximo -> max(T,(IdC,IdA,IdAc,TipoC,TipoP,Desc,ValorC,Prazo,Local,Data),ValorC,Solution);
                              			max(T,ContratoMaximo,Maximo,Solution) ).

%Predicado que obtém todos os tipos de contratos celebrados.
getAllTipos([],Aux,R) :- R = Aux.
getAllTipos([(_,_,_,TipoC,_,_,_,_,_,_)|T],[],R) :- getAllTipos(T,[TipoC],R).
getAllTipos([(_,_,_,TipoC,_,_,_,_,_,_)|T],[H|Tl],R) :- ( pertence(TipoC,[H|Tl]) -> getAllTipos(T,[H|Tl],R);
																																								 	 getAllTipos(T,[TipoC,H|Tl],R)).
