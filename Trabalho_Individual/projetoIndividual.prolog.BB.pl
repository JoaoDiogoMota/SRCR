
% SICStus PROLOG: Declaracoes iniciais
:- set_prolog_flag(toplevel_print_options, [quoted(true), portrayed(true), max_depth(0)]).
:- set_prolog_flag( discontiguous_warnings,off ).
:- set_prolog_flag( single_var_warnings,off ).
:- set_prolog_flag( unknown,fail ).

%Predicado solucoes: Ex: solucoes((Carreira,Origem,Destino),adjacencia(Carreira,Origem,Destino),S).
solucoes(T,P,L) 
			:- findall(T,P,L).

%Predicado para obter todas as adjacencias de uma paragem
adjacenciasParagem(P,R) 
			:- solucoes((Destino),adjacencia(_,P,Destino),T),sort(T,R).

%Predicado para verificar se uma paragem é adjacente a outra
eAdjacente(Origem,Destino) :- adjacencia(_,Origem,Destino).

%Predicado para verificar se um elemento existe numa lista
elem(X,[]) :- !,fail.
elem(X,[L]) :- X==L.
elem(X,[H|T]) :- X == H; elem(X,T).

%Predicado para verificar se uma lista se encontra presente noutra
elemLista([X],[]) :- !,fail.
elemLista([],X).
elemLista([X|XS],[Y|YS]) :- X==Y -> elemLista(XS,YS); elemLista([X|XS],YS).

%Predicado que elimina todas as ocorrencias de um elemento de uma lista
delT(X,[],[]).
delT(X,[X],[]).
delT(X,[H|T],R) :- X == H -> delT(X,T,R); delT(X,T,P), R = [H|P].


%Predicado de negação
not( Questao ) :-
    Questao, !, fail.
not( Questao ).


%Predicado que inverte uma lista 
init([X],[]).
init([H|T],R) :- init(T,P), R = [H|P].

last([X],X).
last([H|T],R) :- last(T,R).
	

inverte([],[]).
inverte([X],[X]).
inverte(L,R) :-
	last(L,P), init(L,T),inverte(T,W), R=[P|W].


%Predicado que devolve o tamanho de uma lista
size([],0).
size([H|T],R) :- size(T,P), R is P+1.


%Predicado que devolve o primeiro elemento de um paragem
getFirst((X,Y),X).


%-----------------------
%Predicado que calcula um trajeto entre dois pontos 
procura(Origem,Destino, Caminho) :- procuraAux([Origem],[], Origem,Destino,Tmp,[]),inverte(Tmp,Caminho). 

procuraAux([Destino|_],Visitados,Origem,Destino,Resposta,[Destino|Visitados]) :- Resposta = [Destino|Visitados].
procuraAux([Primeiro|T],Visitados,Origem,Destino,Resposta,L) :- 
					adjacenciasParagem(Primeiro,Adj), 
					testaAdjacentes(Adj,Visitados,Origem,Destino,[Primeiro|T],Resposta,L).


testaAdjacentes([],Visitados,Origem,Destino,[H|ListaEspera],Caminho,L) :- 
							inverte(ListaEspera,Lista),
							 procuraAux(Lista,[H|Visitados],Origem,Destino,Caminho,L).
testaAdjacentes([Destino|AdT],Visitados,Origem,Destino,[Primeiro|T],Caminho,L) :- 
							 procuraAux([Destino|AdT],[Primeiro|Visitados],Origem,Destino,Caminho,[Destino,Primeiro|Visitados]).
testaAdjacentes([Ad|AdT],Visitados,Origem,Destino,[Primeiro|T],Caminho,L) :- 
					not(elem(Ad,Visitados)),not(elem(Ad,[Primeiro|T])) -> testaAdjacentes(AdT,Visitados,Origem,Destino,[Primeiro,Ad|T],Caminho,L); 
					testaAdjacentes(AdT,Visitados,Origem,Destino,[Primeiro|T],Caminho,L).			

%------------------------------
%Predicado que seleciona apenas algumas das operadoras de transporte para um determinado percurso

procuraOperador(Origem,Destino,Operadoras, Caminho) :- procuraAuxOperador([Origem],[], Origem,Destino,Operadoras, Tmp, []), inverte(Tmp,Caminho).

procuraAuxOperador([Destino|_],Visitados,Origem,Destino,Operadoras,Resposta,[Destino|Visitados]) :- Resposta = [Destino|Visitados].
procuraAuxOperador([Primeiro|T],Visitados,Origem,Destino,Operadoras,Resposta,L) :- 
					adjacenciasParagem(Primeiro,Adj), 
					testaAdjacentesOperador(Adj,Visitados,Origem,Destino,Operadoras,[Primeiro|T],Resposta,L).

testaAdjacentesOperador([],Visitados,Origem,Destino,Operadoras,[H|ListaEspera],Caminho,L) :- 
							inverte(ListaEspera,Lista),
							 procuraAuxOperador(Lista,[H|Visitados],Origem,Destino,Operadoras,Caminho,L).
testaAdjacentesOperador([Destino|AdT],Visitados,Origem,Destino,Operadoras,[Primeiro|T],Caminho,L) :- 
							 procuraAuxOperador([Destino|AdT],[Primeiro|Visitados],Origem,Destino,Operadoras,Caminho,[Destino,Primeiro|Visitados]).
testaAdjacentesOperador([Ad|AdT],Visitados,Origem,Destino,Operadoras,[Primeiro|T],Caminho,L) :- 
					not(elem(Ad,Visitados)),not(elem(Ad,[Primeiro|T])),getOperador(Ad,Op),elemLista(Op,Operadoras) -> testaAdjacentesOperador(AdT,Visitados,Origem,Destino,Operadoras,[Primeiro,Ad|T],Caminho,L); 
					testaAdjacentesOperador(AdT,Visitados,Origem,Destino,Operadoras,[Primeiro|T],Caminho,L).	



%Predicado que obtem o operador de uma Carreira
getOperador(Paragem,Op) :- 
			solucoes(Operador,(paragem(Paragem,_,_,_,_,_,Operador,_,_,_,_)),Op).

%---------------------------------------
%Predicado que exclui um ou mais operadores de transporte para o percurso.
procuraExcOperador(Origem,Destino,Operadoras, Caminho) :- procuraAuxExcOperador([Origem],[], Origem,Destino,Operadoras, Tmp, []), inverte(Tmp,Caminho).

procuraAuxExcOperador([Destino|_],Visitados,Origem,Destino,Operadoras,Resposta, [Destino|Visitados]) :- Resposta = [Destino|Visitados].
procuraAuxExcOperador([Primeiro|T],Visitados,Origem,Destino,Operadoras,Resposta,L) :- 
					adjacenciasParagem(Primeiro,Adj), 
					testaAdjacentesExcOperador(Adj,Visitados,Origem,Destino,Operadoras,[Primeiro|T],Resposta,L).

testaAdjacentesExcOperador([],Visitados,Origem,Destino,Operadoras,[H|ListaEspera],Caminho,L) :- 
							inverte(ListaEspera,Lista),
							 procuraAuxExcOperador(Lista,[H|Visitados],Origem,Destino,Operadoras,Caminho,L).
testaAdjacentesExcOperador([Destino|AdT],Visitados,Origem,Destino,Operadoras,[Primeiro|T],Caminho,L) :- 
							 procuraAuxExcOperador([Destino|AdT],[Primeiro|Visitados],Origem,Destino,Operadoras,Caminho,[Destino,Primeiro|Visitados]).
testaAdjacentesExcOperador([Ad|AdT],Visitados,Origem,Destino,Operadoras,[Primeiro|T],Caminho,L) :- 
					not(elem(Ad,Visitados)),not(elem(Ad,[Primeiro|T])),getOperador(Ad,Op),not(elemLista(Op,Operadoras)) -> testaAdjacentesExcOperador(AdT,Visitados,Origem,Destino,Operadoras,[Primeiro,Ad|T],Caminho,L); 
					testaAdjacentesExcOperador(AdT,Visitados,Origem,Destino,Operadoras,[Primeiro|T],Caminho,L).	

%---------------------------------------------------------------
%Predicado para identificar quais as paragens com o maior número de carreiras num determinado percurso.

getNCarreiras(Paragem,NCarreiras) :- paragem(Paragem,_,_,_,_,_,_,Carreira,_,_,_), size(Carreira,NCarreiras).

numeroCarreiras(Origem,Destino,R) :-
			procura(Origem, Destino, Caminho), getAllNCarreiras(Caminho,[],N), sortDecres(N,R).

getAllNCarreiras([],L,R) :- R=L.
getAllNCarreiras([H|T],L,R) :-
			getNCarreiras(H,P), getAllNCarreiras(T,[(H,P)|L],R).


%Predicado para ordenar uma lista de forma decrescente
sortDecres(List,Sorted):-i_sort(List,[],Sorted).
i_sort([],Acc,Acc).
i_sort([(A,B)|T],Acc,Sorted):-insert((A,B),Acc,NAcc),i_sort(T,NAcc,Sorted).
   
insert((A,B),[(C,D)|T],[(C,D)|NT]):-B<D,insert((A,B),T,NT).
insert((A,B),[(C,D)|T],[(A,B),(C,D)|T]):-B>=D.
insert((A,B),[],[(A,B)]).
%-----------------------------------------------------------
%Predicado que permite escolher o menor percurso (usando critério menor número de paragens)

procuraMenorParagens(Origem,Destino,Caminho) :- procuraMenorParagensAux(Origem,Destino,[],Lista), inverte(Lista, Invertida), Caminho = [Origem|Invertida].

procuraMenorParagensAux(Origem,Origem,Caminho,Caminho).
procuraMenorParagensAux(Origem,Destino,Caminho, CaminhoFinal) :- 
				adjacenciasParagem(Origem,Adj), testeAdjs(Adj,Destino,[],Caminho,AdAtual),procuraMenorParagensAux(AdAtual,Destino,[AdAtual|Caminho], CaminhoFinal).


testeAdjs([],Destino,Caminhos,CaminhoFinal, El) :- escolheMenor(Caminhos, Tmp), getFirst(Tmp,El).
testeAdjs([H|T],Destino,Caminhos,CaminhoFinal,El) :- 
		 elem(Destino, [H|T]) -> procuraMenorParagensAux(Destino, Destino, [Destino|CaminhoFinal], _); contaProcura(H,Destino,P), testeAdjs(T,Destino,[(H,P)|Caminhos],El).

escolheMenor([X],X).
escolheMenor([(X1,P1),(X2,P2)|T],Adjacente)  :- P1=<P2 -> escolheMenor([(X1,P1)|T],Adjacente); escolheMenor([(X2,P2)|T],Adjacente).
	
contaProcura(Origem,Destino,Conta) :- procura(Origem,Destino,Caminho), size(Caminho,Conta).
%-----------------------------------------------------------
%Predicado que permite escolher o percurso mais rápido (usando critério da distância).

procuraMenor(Origem, Destino, Caminho/Custo) :-
	getLatitude(Origem,La1), getLongitude(Origem,Lo1), getLatitude(Destino,La2), getLongitude(Destino,Lo2), 
	latitudeLongitudeToKm(La1,Lo1,La2,Lo2,Estima),
	aestrela([[Origem]/0/EstimaDistancia], Destino ,InvCaminho/Custo/_),inverte(InvCaminho, Caminho).



aestrela(Caminhos, Destino,Caminho) :-
	obtem_melhor(Caminhos, Destino, Caminho), Caminho = [Destino|_]/_/_.

aestrela(Caminhos,Destino,SolucaoCaminho) :-
	obtem_melhor(Caminhos,Destino, MelhorCaminho), seleciona(MelhorCaminho, Caminhos, OutrosCaminhos),
	expande_aestrela(MelhorCaminho,Destino, ExpCaminhos),append(OutrosCaminhos, ExpCaminhos, NovoCaminhos),
    aestrela(NovoCaminhos,Destino, SolucaoCaminho).



seleciona(E, [E|Xs], Xs).

seleciona(E, [X|Xs], [X|Ys]) :- seleciona(E, Xs, Ys).



obtem_melhor([Caminho], Destino,Caminho) :- !.

obtem_melhor([Origem/Custo1/Est1,_/Custo2/Est2|Caminhos], Destino,MelhorCaminho) :-
	Custo1 + Est1 =< Custo2 + Est2, !,
	obtem_melhor([Origem/Custo1/Est1|Caminhos],Destino,MelhorCaminho).

obtem_melhor([_|Caminhos], Destino,MelhorCaminho) :-
	obtem_melhor(Caminhos,Destino, MelhorCaminho).


expande_aestrela(Caminho, Destino,ExpCaminhos) :-
	findall(NovoCaminho, adjacente(Caminho,Destino,NovoCaminho), ExpCaminhos).


adjacente([Origem|Caminho]/Custo/_,Destino, [ProxNodo,Origem|Caminho]/NovoCusto/Est) :-
	eAdjacente(Origem, ProxNodo),\+ member(ProxNodo, Caminho),
	getLatitude(Origem,La1),getLongitude(Origem,Lo1),getLatitude(ProxNodo,La2),getLongitude(ProxNodo,Lo2),
	latitudeLongitudeToKm(La1,Lo1,La2,Lo2,PassoCusto),
	NovoCusto is Custo + PassoCusto,
	getLatitude(Destino,LaD),getLongitude(Destino,LoD),
	latitudeLongitudeToKm(La2,Lo2,LaD,LoD,Est).



%Predicado para obter a latitude de uma paragem
getLatitude(Paragem,La) :- 
			solucoes(Latitude,(paragem(Paragem,Latitude,_,_,_,_,_,_,_,_,_)),La).


%predicado para obter a longitude de uma paragem
getLongitude(Paragem,Lo) :- 
			solucoes(Longitude,(paragem(Paragem,_,Longitude,_,_,_,_,_,_,_,_)),Lo).

%Predicado para calcular a distancia entre dois pares (Latitude,Longitude) para km
latitudeLongitudeToKm(L1, Lo1, L2, Lo2, R):-
    Tmp is 0.017453292519943295,
    X is (0.5 - cos((L2 - L1) * Tmp) / 2 + cos(L1 * Tmp) * cos(L2 * Tmp) * (1 - cos((Lo2 - Lo1) * Tmp)) / 2),
    R is (12742 * asin(sqrt(X))/1000).


%------------------------------------------------------------
%Predicado para escolher o percurso que passe apenas por abrigos com publicidade.

procuraPublicidade(Origem,Destino, Caminho) :- procuraAuxPublicidade([Origem],[], Origem,Destino,Tmp,[]),inverte(Tmp,Caminho). 

procuraAuxPublicidade([Destino|_],Visitados,Origem,Destino,Resposta,[Destino|Visitados]) :- Resposta = [Destino|Visitados].
procuraAuxPublicidade([Primeiro|T],Visitados,Origem,Destino,Resposta,L) :- 
					adjacenciasParagem(Primeiro,Adj), 
					testaAdjacentesPublicidade(Adj,Visitados,Origem,Destino,[Primeiro|T],Resposta,L).


testaAdjacentesPublicidade([],Visitados,Origem,Destino,[H|ListaEspera],Caminho,L) :- 
							inverte(ListaEspera,Lista),
							 procuraAuxPublicidade(Lista,[H|Visitados],Origem,Destino,Caminho,L).
testaAdjacentesPublicidade([Destino|AdT],Visitados,Origem,Destino,[Primeiro|T],Caminho,L) :- 
							 procuraAuxPublicidade([Destino|AdT],[Primeiro|Visitados],Origem,Destino,Caminho,[Destino,Primeiro|Visitados]).
testaAdjacentesPublicidade([Ad|AdT],Visitados,Origem,Destino,[Primeiro|T],Caminho,L) :- 
					not(elem(Ad,Visitados)),not(elem(Ad,[Primeiro|T])),getPublicidade(Ad) 
					-> testaAdjacentesPublicidade(AdT,Visitados,Origem,Destino,[Primeiro,Ad|T],Caminho,L); 
					testaAdjacentesPublicidade(AdT,Visitados,Origem,Destino,[Primeiro|T],Caminho,L).			

getPublicidade(Paragem) :- paragem(Paragem,_,_,_,_,yes,_,_,_,_,_).


%---------------------------------------------------------
%Predicado para escolher o percurso que passe apenas por paragens abrigadas.
procuraAbrigada(Origem,Destino, Caminho) :- procuraAuxAbrigada([Origem],[], Origem,Destino,Tmp,[]),inverte(Tmp,Caminho). 

procuraAuxAbrigada([Destino|_],Visitados,Origem,Destino,Resposta,[Destino|Visitados]) :- Resposta = [Destino|Visitados].
procuraAuxAbrigada([Primeiro|T],Visitados,Origem,Destino,Resposta,L) :- 
					adjacenciasParagem(Primeiro,Adj), 
					testaAdjacentesAbrigada(Adj,Visitados,Origem,Destino,[Primeiro|T],Resposta,L).


testaAdjacentesAbrigada([],Visitados,Origem,Destino,[H|ListaEspera],Caminho,L) :- 
							inverte(ListaEspera,Lista),
							 procuraAuxAbrigada(Lista,[H|Visitados],Origem,Destino,Caminho,L).
testaAdjacentesAbrigada([Destino|AdT],Visitados,Origem,Destino,[Primeiro|T],Caminho,L) :- 
							 procuraAuxAbrigada([Destino|AdT],[Primeiro|Visitados],Origem,Destino,Caminho,[Destino,Primeiro|Visitados]).
testaAdjacentesAbrigada([Ad|AdT],Visitados,Origem,Destino,[Primeiro|T],Caminho,L) :- 
					not(elem(Ad,Visitados)),not(elem(Ad,[Primeiro|T])),getAbrigada(Ad) 
					-> testaAdjacentesAbrigada(AdT,Visitados,Origem,Destino,[Primeiro,Ad|T],Caminho,L); 
					testaAdjacentesAbrigada(AdT,Visitados,Origem,Destino,[Primeiro|T],Caminho,L).


getAbrigada(Paragem) :- paragem(Paragem,_,_,_,"fechado dos lados",_,_,_,_,_,_) ; paragem(Paragem,_,_,_,"aberto dos lados",_,_,_,_,_,_).

%-----------------------------------------------------------
%Predicado que permite escolher um ou mais pontos intermédios por onde o percurso deverá passar.

procuraIntermedios(Origem,Destino,Intermedios,R) :- procuraIntermediosAux(Origem,Destino,Intermedios,[],Tmp),R=[Origem|Tmp].

procuraIntermediosAux(Origem,Destino,[],L,L).
procuraIntermediosAux(Origem,Destino,[Intermedio],L,R) 
				:-procura(Origem,Intermedio,L1), removePrimeiro(L1,X),procura(Intermedio,Destino,L2),
				 removePrimeiro(L2,Y),append(X,Y,Temp),append(L,Temp,Nova), procuraIntermediosAux(Origem,Destino,[],Nova,R).
procuraIntermediosAux(Origem,Destino,[H|T],L,R) :- 
				procura(Origem,H,L1),removePrimeiro(L1,Nova), append(L,Nova,Temp),procuraIntermediosAux(H,Destino,T,Temp,R).

removePrimeiro([X],[]).
removePrimeiro([H|T],T).

%-----------------------------------------------------------
%Predicado que seleciona apenas algumas das operadoras de transporte para um determinado percurso - A*

procuraMenorOperadora(Origem, Destino,Operadoras,Caminho/Custo) :-
	getLatitude(Origem,La1), getLongitude(Origem,Lo1), getLatitude(Destino,La2), getLongitude(Destino,Lo2), 
	latitudeLongitudeToKm(La1,Lo1,La2,Lo2,Estima),
	aestrelaOperadora([[Origem]/0/EstimaDistancia], Destino,Operadoras ,InvCaminho/Custo/_),inverte(InvCaminho, Caminho).


aestrelaOperadora(Caminhos, Destino,Operadoras,Caminho) :-
	obtem_melhor(Caminhos, Destino, Caminho), Caminho = [Destino|_]/_/_.

aestrelaOperadora(Caminhos,Destino,Operadoras,SolucaoCaminho) :-
	obtem_melhor(Caminhos,Destino, MelhorCaminho), seleciona(MelhorCaminho, Caminhos, OutrosCaminhos),
	expande_aestrelaOperadora(MelhorCaminho,Destino,Operadoras, ExpCaminhos),append(OutrosCaminhos, ExpCaminhos, NovoCaminhos),
    aestrelaOperadora(NovoCaminhos,Destino,Operadoras, SolucaoCaminho).

expande_aestrelaOperadora(Caminho, Destino,Operadoras,ExpCaminhos) :-
	findall(NovoCaminho, adjacenteOperadora(Caminho,Destino,Operadoras,NovoCaminho), ExpCaminhos).


adjacenteOperadora([Origem|Caminho]/Custo/_,Destino,Operadoras, [ProxNodo,Origem|Caminho]/NovoCusto/Est) :-
	eAdjacente(Origem, ProxNodo),\+ member(ProxNodo, Caminho),getOperador(ProxNodo,Op),elemLista(Op,Operadoras),
	getLatitude(Origem,La1),getLongitude(Origem,Lo1),getLatitude(ProxNodo,La2),getLongitude(ProxNodo,Lo2),
	latitudeLongitudeToKm(La1,Lo1,La2,Lo2,PassoCusto),
	NovoCusto is Custo + PassoCusto,
	getLatitude(Destino,LaD),getLongitude(Destino,LoD),
	latitudeLongitudeToKm(La2,Lo2,LaD,LoD,Est).



%----------------------------------------------------------
%Predicado que exclui um ou mais operadores de transporte para o percurso - A*

procuraMenorExcOperadora(Origem, Destino,Operadoras,Caminho/Custo) :-
	getLatitude(Origem,La1), getLongitude(Origem,Lo1), getLatitude(Destino,La2), getLongitude(Destino,Lo2), 
	latitudeLongitudeToKm(La1,Lo1,La2,Lo2,Estima),
	aestrelaExcOperadora([[Origem]/0/EstimaDistancia], Destino,Operadoras ,InvCaminho/Custo/_),inverte(InvCaminho, Caminho).


aestrelaExcOperadora(Caminhos, Destino,Operadoras,Caminho) :-
	obtem_melhor(Caminhos, Destino, Caminho), Caminho = [Destino|_]/_/_.

aestrelaExcOperadora(Caminhos,Destino,Operadoras,SolucaoCaminho) :-
	obtem_melhor(Caminhos,Destino, MelhorCaminho), seleciona(MelhorCaminho, Caminhos, OutrosCaminhos),
	expande_aestrelaExcOperadora(MelhorCaminho,Destino,Operadoras, ExpCaminhos),append(OutrosCaminhos, ExpCaminhos, NovoCaminhos),
    aestrelaExcOperadora(NovoCaminhos,Destino,Operadoras, SolucaoCaminho).

expande_aestrelaExcOperadora(Caminho, Destino,Operadoras,ExpCaminhos) :-
	findall(NovoCaminho, adjacenteExcOperadora(Caminho,Destino,Operadoras,NovoCaminho), ExpCaminhos).


adjacenteExcOperadora([Origem|Caminho]/Custo/_,Destino,Operadoras, [ProxNodo,Origem|Caminho]/NovoCusto/Est) :-
	eAdjacente(Origem, ProxNodo),\+ member(ProxNodo, Caminho),getOperador(ProxNodo,Op),not(elemLista(Op,Operadoras)),
	getLatitude(Origem,La1),getLongitude(Origem,Lo1),getLatitude(ProxNodo,La2),getLongitude(ProxNodo,Lo2),
	latitudeLongitudeToKm(La1,Lo1,La2,Lo2,PassoCusto),
	NovoCusto is Custo + PassoCusto,
	getLatitude(Destino,LaD),getLongitude(Destino,LoD),
	latitudeLongitudeToKm(La2,Lo2,LaD,LoD,Est).

%-----------------------------------------------------------
%Predicado para identificar quais as paragens com o maior número de carreiras num determinado percurso - A*

numeroCarreirasAEstrela(Origem,Destino,R) :-
			procuraMenor2(Origem, Destino, Caminho), getAllNCarreiras(Caminho,[],N), sortDecres(N,R).


%----------------------------------------------------------
%Predicado para escolher o percurso que passe apenas por paragens abrigadas - A*

procuraMenorAbrigos(Origem, Destino,Caminho/Custo) :-
	getLatitude(Origem,La1), getLongitude(Origem,Lo1), getLatitude(Destino,La2), getLongitude(Destino,Lo2), 
	latitudeLongitudeToKm(La1,Lo1,La2,Lo2,Estima),
	aestrelaAbrigos([[Origem]/0/EstimaDistancia], Destino ,InvCaminho/Custo/_),inverte(InvCaminho, Caminho).


aestrelaAbrigos(Caminhos, Destino,Caminho) :-
	obtem_melhor(Caminhos, Destino, Caminho), Caminho = [Destino|_]/_/_.

aestrelaAbrigos(Caminhos,Destino,SolucaoCaminho) :-
	obtem_melhor(Caminhos,Destino, MelhorCaminho), seleciona(MelhorCaminho, Caminhos, OutrosCaminhos),
	expande_aestrelaAbrigos(MelhorCaminho,Destino, ExpCaminhos),append(OutrosCaminhos, ExpCaminhos, NovoCaminhos),
    aestrelaAbrigos(NovoCaminhos,Destino, SolucaoCaminho).

expande_aestrelaAbrigos(Caminho, Destino,ExpCaminhos) :-
	findall(NovoCaminho, adjacenteAbrigos(Caminho,Destino,NovoCaminho), ExpCaminhos).


adjacenteAbrigos([Origem|Caminho]/Custo/_,Destino, [ProxNodo,Origem|Caminho]/NovoCusto/Est) :-
	eAdjacente(Origem, ProxNodo),\+ member(ProxNodo, Caminho), getAbrigada(ProxNodo),
	getLatitude(Origem,La1),getLongitude(Origem,Lo1),getLatitude(ProxNodo,La2),getLongitude(ProxNodo,Lo2),
	latitudeLongitudeToKm(La1,Lo1,La2,Lo2,PassoCusto),
	NovoCusto is Custo + PassoCusto,
	getLatitude(Destino,LaD),getLongitude(Destino,LoD),
	latitudeLongitudeToKm(La2,Lo2,LaD,LoD,Est).

%----------------------------------------------------------
%Predicado para escolher o percurso que passe apenas por abrigos com publicidade - A*.

procuraMenorPublicidade(Origem, Destino,Caminho/Custo) :-
	getLatitude(Origem,La1), getLongitude(Origem,Lo1), getLatitude(Destino,La2), getLongitude(Destino,Lo2), 
	latitudeLongitudeToKm(La1,Lo1,La2,Lo2,Estima),
	aestrelaPublicidade([[Origem]/0/EstimaDistancia], Destino ,InvCaminho/Custo/_),inverte(InvCaminho, Caminho).


aestrelaPublicidade(Caminhos, Destino,Caminho) :-
	obtem_melhor(Caminhos, Destino, Caminho), Caminho = [Destino|_]/_/_.

aestrelaPublicidade(Caminhos,Destino,SolucaoCaminho) :-
	obtem_melhor(Caminhos,Destino, MelhorCaminho), seleciona(MelhorCaminho, Caminhos, OutrosCaminhos),
	expande_aestrelaPublicidade(MelhorCaminho,Destino, ExpCaminhos),append(OutrosCaminhos, ExpCaminhos, NovoCaminhos),
    aestrelaPublicidade(NovoCaminhos,Destino, SolucaoCaminho).

expande_aestrelaPublicidade(Caminho, Destino,ExpCaminhos) :-
	findall(NovoCaminho, adjacentePublicidade(Caminho,Destino,NovoCaminho), ExpCaminhos).


adjacentePublicidade([Origem|Caminho]/Custo/_,Destino, [ProxNodo,Origem|Caminho]/NovoCusto/Est) :-
	eAdjacente(Origem, ProxNodo),\+ member(ProxNodo, Caminho), getPublicidade(ProxNodo),
	getLatitude(Origem,La1),getLongitude(Origem,Lo1),getLatitude(ProxNodo,La2),getLongitude(ProxNodo,Lo2),
	latitudeLongitudeToKm(La1,Lo1,La2,Lo2,PassoCusto),
	NovoCusto is Custo + PassoCusto,
	getLatitude(Destino,LaD),getLongitude(Destino,LoD),
	latitudeLongitudeToKm(La2,Lo2,LaD,LoD,Est).

%----------------------------------------------------------
%Predicado que permite escolher um ou mais pontos intermédios por onde o percurso deverá passar - A*
procuraMenor2(Origem, Destino, Caminho) :-
	getLatitude(Origem,La1), getLongitude(Origem,Lo1), getLatitude(Destino,La2), getLongitude(Destino,Lo2), 
	latitudeLongitudeToKm(La1,Lo1,La2,Lo2,Estima),
	aestrela([[Origem]/0/EstimaDistancia], Destino ,InvCaminho/Custo/_),inverte(InvCaminho, Caminho).



procuraIntermediosAEstrela(Origem,Destino,Intermedios,R) :- procuraIntermediosAuxAEstrela(Origem,Destino,Intermedios,[],Tmp),R=[Origem|Tmp].

procuraIntermediosAuxAEstrela(Origem,Destino,[],L,L).
procuraIntermediosAuxAEstrela(Origem,Destino,[Intermedio],L,R) :-procuraMenor2(Origem,Intermedio,L1), removePrimeiro(L1,X),procuraMenor2(Intermedio,Destino,L2), removePrimeiro(L2,Y),append(X,Y,Temp),append(L,Temp,Nova), procuraIntermediosAuxAEstrela(Origem,Destino,[],Nova,R).
procuraIntermediosAuxAEstrela(Origem,Destino,[H|T],L,R) :- procuraMenor2(Origem,H,L1),removePrimeiro(L1,Nova), append(L,Nova,Temp),procuraIntermediosAuxAEstrela(H,Destino,T,Temp,R).

%--------------------------------------------------------
%Predicado que calcula o tempo de viagem entre duas paragens tendo em conta um tempo de espera médio

getTempoViagem(Origem,Destino,Espera,Tempo) :- 
			contaProcura(Origem,Destino,R), Tempo is (((R-1)*(Espera+5))).

%-------------------------------------------------------
%Predicado que indica qual a paragem dentro de uma freguesia que tem um percurso mais rápido para um determinado Destino

melhorParagem(Freguesia,Destino,Paragem) :- getParagensFreguesia(Freguesia,Par), write(Par), melhorParagemAux(Par,Destino,[],Paragem).

melhorParagemAux([],Destino,MelhorPar, Paragem) :- escolheMenor(MelhorPar,Tmp), getFirst(Tmp,Paragem).
melhorParagemAux([H|N],Destino,MelhorPar, Paragem) :- contaProcura(H,Destino,NParagens),melhorParagemAux(T,Destino,[(H,NParagens)|MelhorPar], Paragem).

getParagensFreguesia(Freguesia,Paragens) :- solucoes(Par,(paragem(Par,_,_,_,_,_,_,_,_,_,Freguesia)),Paragens).

%------------------------------------------------------
%Predicado que devolve todas as paragens com abrigo de uma determinada rua
getParagensAbrigoRua(CodRua,Paragens) :-
				solucoes(Par,(paragem(Par,_,_,_,"fechado dos lados",_,_,_,_,_,_)),Tmp),
				solucoes(Par,(paragem(Par,_,_,_,"aberto dos lados",_,_,_,_,_,_)),Tmp2),append(Tmp,Tmp2,Paragens).

%---------------------------------------------------------


paragem(79,-107011.55,-95214.57,bom,"fechado dos lados",yes,vimeca,[1],103,"rua damião de góis","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(593,-103777.02,-94637.67,bom,"sem abrigo",no,vimeca,[1],300,"avenida dos cavaleiros","carnaxide e queijas").
paragem(499,-103758.44,-94393.36,bom,"fechado dos lados",yes,vimeca,[1],300,"avenida dos cavaleiros","carnaxide e queijas").
paragem(494,-106803.2,-96265.84,bom,"sem abrigo",no,vimeca,[1],389,"rua são joão de deus","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(480,-106757.3,-96240.22,bom,"sem abrigo",no,vimeca,[1],389,"rua são joão de deus","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(957,-106911.18264993647,-96261.15727273725,bom,"sem abrigo",no,vimeca,[1],399,"escadinhas da fonte da maruja","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(366,-106021.37,-96684.5,bom,"fechado dos lados",yes,vimeca,[1],411,"avenida dom pedro v","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(365,-106016.12,-96673.87,bom,"fechado dos lados",yes,vimeca,[1],411,"avenida dom pedro v","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(357,-105236.99,-96664.4,bom,"fechado dos lados",yes,vimeca,[1],1279,"avenida tomás ribeiro","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(336,-105143.57,-96690.32,bom,"fechado dos lados",yes,vimeca,[1],1279,"avenida tomás ribeiro","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(334,-105336.07,-96668.68,bom,"fechado dos lados",yes,vimeca,[1],1279,"avenida tomás ribeiro","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(251,-104487.69,-96548.01,bom,"fechado dos lados",yes,vimeca,[1],1279,"avenida tomás ribeiro","carnaxide e queijas").
paragem(469,-106613.44,-96288.0,bom,"fechado dos lados",yes,vimeca,[1],1288,"rua rodrigo albuquerque e melo","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(462,-106636.23,-96302.04,bom,"sem abrigo",no,vimeca,[1],1288,"rua rodrigo albuquerque e melo","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(44,-104458.52,-94926.22,bom,"fechado dos lados",yes,vimeca,[1, 13, 15],1134,"largo sete de junho de 1759","carnaxide e queijas").
paragem(78,-107008.56,-95490.23,bom,"fechado dos lados",yes,vimeca,[1, 2, 6, 14],118,"alameda hermano patrone","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(609,-104226.49,-95797.22,bom,"fechado dos lados",yes,vimeca,[1, 2, 7, 10, 12, 13, 15],327,"avenida do forte","carnaxide e queijas").
paragem(599,-104296.72,-95828.26,bom,"fechado dos lados",yes,vimeca,[1, 2, 7, 10, 12, 13, 15],327,"avenida do forte","carnaxide e queijas").
paragem(595,-103725.69,-95975.2,bom,"fechado dos lados",yes,vimeca,[1, 2, 7, 10, 12, 13, 15],354,"rua manuel teixeira gomes","carnaxide e queijas").
paragem(185,-103922.82,-96235.62,bom,"fechado dos lados",yes,scotturb,[1, 2, 7, 10, 12, 13, 15],354,"rua manuel teixeira gomes","carnaxide e queijas").
paragem(250,-104031.08,-96173.83,bom,"fechado dos lados",yes,vimeca,[1, 2, 7, 10, 12, 13, 15],1113,"avenida de portugal","carnaxide e queijas").
paragem(107,-103972.32,-95981.88,bom,"fechado dos lados",yes,vimeca,[1, 2, 7, 10, 12, 13, 15],1113,"avenida de portugal","carnaxide e queijas").
paragem(953,-104075.89,-95771.82,bom,"fechado dos lados",yes,vimeca,[1, 2, 7, 10, 12, 13, 15],1116,"avenida professor dr. reinaldo dos santos","carnaxide e queijas").
paragem(594,-103879.91,-95751.23,bom,"fechado dos lados",no,vimeca,[1, 2, 7, 10, 12, 13, 15],1116,"avenida professor dr. reinaldo dos santos","carnaxide e queijas").
paragem(597,-104058.98,-95839.14,bom,"fechado dos lados",yes,vimeca,[1, 2, 7, 10, 12, 13, 15],1137,"rua tenente-general zeferino sequeira","carnaxide e queijas").
paragem(261,-104032.88,-96536.98,bom,"fechado dos lados",yes,vimeca,[1, 2, 10],1113,"avenida de portugal","carnaxide e queijas").
paragem(341,-105797.42,-96746.57,bom,"fechado dos lados",yes,vimeca,[1, 2, 11],411,"avenida dom pedro v","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(85,-105653.28,-96814.42,bom,"fechado dos lados",yes,vimeca,[1, 2, 11],411,"avenida dom pedro v","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(347,-105493.13,-96785.72,bom,"fechado dos lados",yes,vimeca,[1, 2, 11],432,"calçada do chafariz","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(342,-105815.99,-96725.14,bom,"fechado dos lados",yes,vimeca,[1, 2, 11, 13],411,"avenida dom pedro v","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(86,-105637.56,-96808.45,bom,"fechado dos lados",yes,vimeca,[1, 2, 11, 13],411,"avenida dom pedro v","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(339,-105452.81,-96732.86,bom,"fechado dos lados",yes,vimeca,[1, 2, 11, 13],432,"calçada do chafariz","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(186,-106975.22,-95602.61,bom,"fechado dos lados",no,vimeca,[1, 6],118,"alameda hermano patrone","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(467,-107004.52,-96080.98,bom,"fechado dos lados",no,vimeca,[1, 6],369,"rua direita do dafundo","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(466,-106999.08,-96066.1,bom,"fechado dos lados",no,vimeca,[1, 6],369,"rua direita do dafundo","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(465,-106915.82,-96269.57,bom,"sem abrigo",no,vimeca,[1, 6],369,"rua direita do dafundo","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(791,-103705.46,-96673.6,bom,"aberto dos lados",yes,vimeca,[1, 7, 10, 12, 13, 15],286,"rua aquilino ribeiro","carnaxide e queijas").
paragem(183,-103678.36,-96590.26,bom,"fechado dos lados",yes,vimeca,[1, 7, 10, 12, 13, 15],286,"rua aquilino ribeiro","carnaxide e queijas").
paragem(182,-103746.76,-96396.66,bom,"fechado dos lados",yes,scotturb,[1, 7, 10, 12, 13, 15],286,"rua aquilino ribeiro","carnaxide e queijas").
paragem(181,-103780.59,-96372.2,bom,"aberto dos lados",yes,vimeca,[1, 7, 10, 12, 13, 15],286,"rua aquilino ribeiro","carnaxide e queijas").
paragem(180,-103842.39,-96260.96,bom,"fechado dos lados",yes,vimeca,[1, 7, 10, 12, 13, 15],286,"rua aquilino ribeiro","carnaxide e queijas").
paragem(89,-103934.24,-96642.56,bom,"fechado dos lados",yes,vimeca,[1, 7, 10, 12, 13, 15],1113,"avenida de portugal","carnaxide e queijas").
paragem(604,-104256.82,-95173.34,bom,"fechado dos lados",no,vimeca,[1, 10, 13, 15],306,"rua dos cravos de abril","carnaxide e queijas").
paragem(40,-104302.13,-95043.86,bom,"fechado dos lados",yes,vimeca,[1, 10, 13, 15],306,"rua dos cravos de abril","carnaxide e queijas").
paragem(39,-104282.32,-95055.6,bom,"fechado dos lados",yes,vimeca,[1, 10, 13, 15],306,"rua dos cravos de abril","carnaxide e queijas").
paragem(620,-104565.8832899218,-94653.67859291832,bom,"sem abrigo",no,vimeca,[1, 10, 13, 15],365,"estrada da portela","carnaxide e queijas").
paragem(45,-104578.88,-94652.12,bom,"sem abrigo",no,vimeca,[1, 10, 13, 15],365,"estrada da portela","carnaxide e queijas").
paragem(51,-104458.04,-94329.86,bom,"fechado dos lados",no,vimeca,[1, 10, 13, 15],1123,"rua da quinta do paizinho","carnaxide e queijas").
paragem(628,-104278.88666597521,-94122.56603635015,bom,"sem abrigo",no,vimeca,[1, 10, 13, 15],1123,"rua da quinta do paizinho","carnaxide e queijas").
paragem(50,-104287.85,-94105.37,bom,"fechado dos lados",yes,vimeca,[1, 10, 13, 15],1123,"rua da quinta do paizinho","carnaxide e queijas").
paragem(38,-104497.842173306,-94358.908881103,bom,"fechado dos lados",yes,vimeca,[1, 10, 13, 15],1123,"rua da quinta do paizinho","carnaxide e queijas").
paragem(622,-104445.64,-94921.33,bom,"fechado dos lados",no,vimeca,[1, 10, 13, 15],1134,"largo sete de junho de 1759","carnaxide e queijas").
paragem(602,-104677.06,-94473.47,bom,"fechado dos lados",no,vimeca,[1, 10, 13, 15],1160,"rua cincinato da costa","carnaxide e queijas").
paragem(601,-104683.1,-94486.15,bom,"fechado dos lados",no,vimeca,[1, 10, 13, 15],1160,"rua cincinato da costa","carnaxide e queijas").
paragem(485,-106315.88,-96307.18,bom,"fechado dos lados",yes,vimeca,[1, 11],1289,"rua castro soromenho","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(488,-106492.31,-96447.01,bom,"sem abrigo",no,vimeca,[1, 11],1292,"rua manuel ferreira","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(486,-106325.58,-96320.92,bom,"fechado dos lados",yes,vimeca,[1, 11, 13],1289,"rua castro soromenho","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(487,-106449.51,-96435.13,bom,"sem abrigo",no,vimeca,[1, 11, 13],1292,"rua manuel ferreira","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(468,-106270.67,-96457.19,bom,"fechado dos lados",yes,vimeca,[1, 11, 13],1292,"rua manuel ferreira","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(460,-106247.39,-96517.97,bom,"fechado dos lados",yes,vimeca,[1, 13],1292,"rua manuel ferreira","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(249,-104397.14,-96680.46,bom,"fechado dos lados",yes,vimeca,[1, 13, 15],297,"rua carlos wallenstein","carnaxide e queijas").
paragem(600,-104631.8,-95630.5,bom,"fechado dos lados",no,vimeca,[1, 13, 15],351,"rua manuel antónio rodrigues","carnaxide e queijas").
paragem(42,-104624.97,-95613.11,bom,"sem abrigo",no,vimeca,[1, 13, 15],351,"rua manuel antónio rodrigues","carnaxide e queijas").
paragem(614,-104594.97,-95684.18,bom,"fechado dos lados",no,vimeca,[1, 13, 15],359,"rua nossa senhora da conceição","carnaxide e queijas").
paragem(46,-104609.99,-95693.01,bom,"fechado dos lados",yes,vimeca,[1, 13, 15],359,"rua nossa senhora da conceição","carnaxide e queijas").
paragem(611,-104989.68,-95554.55,bom,"fechado dos lados",no,vimeca,[1, 13, 15],1196,"rua carlos belo morais","carnaxide e queijas").
paragem(610,-104998.77,-95557.54,bom,"sem abrigo",no,vimeca,[1, 13, 15],1196,"rua carlos belo morais","carnaxide e queijas").
paragem(49,-104758.56,-95206.97,bom,"fechado dos lados",yes,vimeca,[1, 13, 15],1196,"rua carlos belo morais","carnaxide e queijas").
paragem(48,-104710.71,-95177.32,bom,"fechado dos lados",no,vimeca,[1, 13, 15],1196,"rua carlos belo morais","carnaxide e queijas").
paragem(613,-104817.75,-95640.29,bom,"fechado dos lados",no,vimeca,[1, 13, 15],1197,"rua mário moreira","carnaxide e queijas").
paragem(612,-104807.71,-95652.96,bom,"sem abrigo",no,vimeca,[1, 13, 15],1197,"rua mário moreira","carnaxide e queijas").
paragem(985,-104367.95010080478,-95373.18330437147,bom,"sem abrigo",no,vimeca,[1, 13, 15],1237,"avenida professor dr. bernardino machado","carnaxide e queijas").
paragem(608,-104373.51,-95357.73,bom,"fechado dos lados",yes,vimeca,[1, 13, 15],1237,"avenida professor dr. bernardino machado","carnaxide e queijas").
paragem(255,-104240.6,-96543.14,bom,"fechado dos lados",yes,vimeca,[1, 13, 15],1279,"avenida tomás ribeiro","carnaxide e queijas").
paragem(254,-104407.0,-96522.21,bom,"fechado dos lados",yes,vimeca,[1, 13, 15],1279,"avenida tomás ribeiro","carnaxide e queijas").
paragem(242,-104235.94,-96573.14,bom,"fechado dos lados",yes,vimeca,[1, 13, 15],1279,"avenida tomás ribeiro","carnaxide e queijas").
paragem(80,-107020.11,-95212.99,bom,"fechado dos lados",yes,vimeca,[2],103,"rua damião de góis","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(655,-106885.28346821875,-95700.604683315,bom,"sem abrigo",no,vimeca,[2],121,"rua joão chagas","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(491,-106752.7,-95980.67,bom,"fechado dos lados",yes,vimeca,[2],121,"rua joão chagas","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(490,-106724.64,-96023.19,bom,"fechado dos lados",yes,vimeca,[2],121,"rua joão chagas","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(458,-106344.84,-96171.5,bom,"fechado dos lados",yes,vimeca,[2],121,"rua joão chagas","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(457,-106251.29,-96169.58,bom,"fechado dos lados",yes,vimeca,[2],121,"rua joão chagas","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(56,-106877.17,-95698.23,bom,"sem abrigo",no,vimeca,[2],121,"rua joão chagas","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(343,-105860.11,-96563.44,bom,"fechado dos lados",yes,vimeca,[2],457,"rua francisco josé victorino","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(237,-104003.78,-96559.17,bom,"fechado dos lados",yes,vimeca,[2],1113,"avenida de portugal","carnaxide e queijas").
paragem(245,-104114.84,-97401.12,bom,"fechado dos lados",yes,vimeca,[2],1214,"estrada de queluz","carnaxide e queijas").
paragem(244,-104101.68,-97408.6,bom,"fechado dos lados",yes,vimeca,[2],1214,"estrada de queluz","carnaxide e queijas").
paragem(734,-102676.09,-98810.3,bom,"sem abrigo",no,vimeca,[2, 2, 12, 13],950,"estrada das palmeiras","barcarena").
paragem(745,-102136.13485160771,-98663.30880207638,bom,"fechado dos lados",no,vimeca,[2, 6, 12, 13],216,"estrada consiglieri pedroso","barcarena").
paragem(736,-102231.41,-98789.31,bom,"fechado dos lados",yes,vimeca,[2, 6, 12, 13],216,"estrada consiglieri pedroso","barcarena").
paragem(147,-102381.73,-98965.83,bom,"sem abrigo",no,vimeca,[2, 6, 12, 13],950,"estrada das palmeiras","barcarena").
paragem(227,-104412.8,-98632.87,bom,"sem abrigo",no,vimeca,[2, 6, 13],805,"rua ilha de são jorge","carnaxide e queijas").
paragem(172,-103411.08,-99046.23,bom,"sem abrigo",no,scotturb,[2, 6, 13],830,"estrada militar","barcarena").
paragem(171,-103417.17,-99041.11,bom,"sem abrigo",no,vimeca,[2, 6, 13],830,"estrada militar","barcarena").
paragem(162,-102962.16,-98672.14,bom,"sem abrigo",no,vimeca,[2, 6, 13],830,"estrada militar","barcarena").
paragem(161,-102932.36,-98676.69,bom,"fechado dos lados",yes,vimeca,[2, 6, 13],830,"estrada militar","barcarena").
paragem(156,-102400.99,-98945.23,bom,"sem abrigo",no,vimeca,[2, 6, 13],950,"estrada das palmeiras","barcarena").
paragem(1010,-104303.63612383853,-98554.77838335252,bom,"sem abrigo",no,vimeca,[2, 6, 13, 15],79,"rua dos açores","carnaxide e queijas").
paragem(224,-104563.77,-98320.53,bom,"sem abrigo",no,vimeca,[2, 6, 13, 15],833,"rua mouzinho da silveira","carnaxide e queijas").
paragem(234,-104471.99,-98565.73,bom,"fechado dos lados",no,vimeca,[2, 6, 13, 15],83,"rua angra do heroí­smo","carnaxide e queijas").
paragem(233,-104935.73,-98290.43,bom,"fechado dos lados",yes,vimeca,[2, 6, 13, 15],813,"rua joão xxi","carnaxide e queijas").
paragem(232,-104768.69,-98266.88,bom,"fechado dos lados",no,scotturb,[2, 6, 13, 15],813,"rua joão xxi","carnaxide e queijas").
paragem(231,-104942.78,-98303.15,bom,"fechado dos lados",yes,vimeca,[2, 6, 13, 15],813,"rua joão xxi","carnaxide e queijas").
paragem(52,-104801.2,-98279.24,bom,"fechado dos lados",yes,vimeca,[2, 6, 13, 15],813,"rua joão xxi","carnaxide e queijas").
paragem(230,-104447.68,-98306.88,bom,"sem abrigo",no,vimeca,[2, 6, 13, 15],833,"rua mouzinho da silveira","carnaxide e queijas").
paragem(226,-104618.82,-98507.86,bom,"fechado dos lados",no,vimeca,[2, 6, 13, 15],846,"rua da quinta do bonfim","carnaxide e queijas").
paragem(799,-104280.83,-98312.61,bom,"fechado dos lados",no,vimeca,[2, 6, 13, 15],1766,"praceta antonio leal de oliveira","carnaxide e queijas").
paragem(1001,-104675.71,-95821.42,bom,"fechado dos lados",yes,vimeca,[2, 7, 10, 12],327,"avenida do forte","carnaxide e queijas").
paragem(607,-104700.62,-95803.69,bom,"fechado dos lados",yes,vimeca,[2, 7, 10, 12],327,"avenida do forte","carnaxide e queijas").
paragem(335,-106015.21,-96351.32,bom,"fechado dos lados",yes,vimeca,[2, 11],121,"rua joão chagas","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(346,-105840.49,-96519.72,bom,"fechado dos lados",yes,vimeca,[2, 11],457,"rua francisco josé victorino","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(344,-105906.64,-96635.59,bom,"fechado dos lados",yes,vimeca,[2, 11],457,"rua francisco josé victorino","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(360,-105210.86,-96382.34,bom,"fechado dos lados",yes,vimeca,[2, 11],1283,"avenida vinte e cinco de abril de 1974","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(352,-105326.62,-96569.43,bom,"fechado dos lados",yes,vimeca,[2, 11],1283,"avenida vinte e cinco de abril de 1974","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(363,-106012.76,-96367.98,bom,"fechado dos lados",yes,vimeca,[2, 11, 13],121,"rua joão chagas","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(345,-105900.6,-96673.99,bom,"fechado dos lados",yes,vimeca,[2, 11, 13],457,"rua francisco josé victorino","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(859,-105043.39,-96109.56,bom,"fechado dos lados",yes,vimeca,[2, 11, 13],1283,"avenida vinte e cinco de abril de 1974","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(858,-105062.32,-96107.23,bom,"fechado dos lados",yes,vimeca,[2, 11, 13],1283,"avenida vinte e cinco de abril de 1974","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(351,-105287.42,-96454.4,bom,"fechado dos lados",yes,vimeca,[2, 11, 13],1283,"avenida vinte e cinco de abril de 1974","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(654,-106946.7,-95556.57,bom,"aberto dos lados",no,vimeca,[2, 114],121,"rua joão chagas","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(243,-104117.95,-97049.09,bom,"fechado dos lados",yes,vimeca,[2, 12, 13, 15],303,"rua cinco de outubro","carnaxide e queijas").
paragem(248,-104091.69,-96778.69,bom,"fechado dos lados",no,vimeca,[2, 12, 13, 15],362,"largo da pátria nova","carnaxide e queijas").
paragem(247,-104200.64,-96833.39,bom,"fechado dos lados",yes,vimeca,[2, 12, 13, 15],1279,"avenida tomás ribeiro","carnaxide e queijas").
paragem(332,-105119.12,-97474.49,bom,"fechado dos lados",yes,vimeca,[2, 13, 15],1279,"avenida tomás ribeiro","carnaxide e queijas").
paragem(331,-105122.88,-97490.88,bom,"fechado dos lados",yes,vimeca,[2, 13, 15],1279,"avenida tomás ribeiro","carnaxide e queijas").
paragem(323,-105277.7,-97707.8,bom,"fechado dos lados",yes,vimeca,[2, 13, 15],1279,"avenida tomás ribeiro","carnaxide e queijas").
paragem(315,-105155.04,-98252.49,bom,"fechado dos lados",yes,vimeca,[2, 13, 15],1279,"avenida tomás ribeiro","carnaxide e queijas").
paragem(312,-105181.29,-98229.14,bom,"fechado dos lados",no,scotturb,[2, 13, 15],1279,"avenida tomás ribeiro","carnaxide e queijas").
paragem(241,-104957.37,-97342.73,bom,"fechado dos lados",yes,vimeca,[2, 13, 15],1279,"avenida tomás ribeiro","carnaxide e queijas").
paragem(240,-104965.93,-97337.63,bom,"sem abrigo",no,vimeca,[2, 13, 15],1279,"avenida tomás ribeiro","carnaxide e queijas").
paragem(239,-104604.14,-97197.81,bom,"fechado dos lados",yes,vimeca,[2, 13, 15],1279,"avenida tomás ribeiro","carnaxide e queijas").
paragem(238,-104609.35,-97210.07,bom,"sem abrigo",no,scotturb,[2, 13, 15],1279,"avenida tomás ribeiro","carnaxide e queijas").
paragem(313,-105254.68,-97686.43,bom,"sem abrigo",no,vimeca,[2, 13, 15],1763,"rua visconde moreira de rey","carnaxide e queijas").
paragem(260,-104345.95,-97003.12,bom,"sem abrigo",no,vimeca,[2, 15, 13],1279,"avenida tomás ribeiro","carnaxide e queijas").
paragem(246,-104328.14,-96988.84,bom,"sem abrigo",no,vimeca,[2, 15, 13],1279,"avenida tomás ribeiro","carnaxide e queijas").
paragem(652,-106975.62,-95277.76,bom,"sem abrigo",no,vimeca,[6],103,"rua damião de góis","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(9,-107003.0,-95216.21,bom,"fechado dos lados",yes,vimeca,[6],103,"rua damião de góis","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(6,-106992.24,-95299.38,bom,"sem abrigo",no,vimeca,[6],103,"rua damião de góis","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(886,-106634.688238017,-97653.97896394921,bom,"sem abrigo",no,vimeca,[6],382,"avenida pierre de coubertin","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(473,-106717.49,-97337.39,bom,"sem abrigo",no,vimeca,[6],382,"avenida pierre de coubertin","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(470,-106725.59,-97317.38,bom,"sem abrigo",no,vimeca,[6],382,"avenida pierre de coubertin","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(904,-106835.46,-96672.9,bom,"fechado dos lados",yes,vimeca,[6],386,"rua sacadura cabral","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(902,-106880.68662292237,-96852.54363954351,bom,"sem abrigo",no,vimeca,[6],386,"rua sacadura cabral","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(893,-106886.01,-96347.3,bom,"sem abrigo",no,vimeca,[6],386,"rua sacadura cabral","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(483,-106784.91,-97126.09,bom,"sem abrigo",no,vimeca,[6],386,"rua sacadura cabral","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(482,-106791.2,-97137.51,bom,"fechado dos lados",yes,scotturb,[6],386,"rua sacadura cabral","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(476,-106826.81,-96686.93,bom,"sem abrigo",no,vimeca,[6],386,"rua sacadura cabral","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(472,-106866.01,-96904.64,bom,"sem abrigo",no,vimeca,[6],386,"rua sacadura cabral","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(90,-103960.0,-96640.32,bom,"fechado dos lados",yes,vimeca,[7, 12, 13, 15],1113,"avenida de portugal","carnaxide e queijas").
paragem(30,-105300.44,-95336.46,bom,"fechado dos lados",yes,vimeca,[10],113,"alameda ferno lopes","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(29,-105256.47,-95349.66,bom,"fechado dos lados",yes,vimeca,[10],113,"alameda ferno lopes","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(20,-105353.27,-95172.19,bom,"fechado dos lados",yes,vimeca,[10],113,"alameda ferno lopes","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(646,-105261.03,-95520.31,bom,"sem abrigo",no,vimeca,[10],124,"avenida josé gomes ferreira","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(642,-105268.05,-95547.68,bom,"fechado dos lados",yes,vimeca,[10],124,"avenida josé gomes ferreira","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(606,-104223.76,-95501.56,bom,"fechado dos lados",yes,vimeca,[10],361,"estrada de outurela","carnaxide e queijas").
paragem(605,-104199.74,-95517.44,bom,"fechado dos lados",yes,vimeca,[10],361,"estrada de outurela","carnaxide e queijas").
paragem(36,-105377.78526436003,-95633.40710368946,bom,"sem abrigo",no,vimeca,[10],416,"alameda antónio sérgio","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(17,-105324.76833309476,-95632.26166661376,bom,"sem abrigo",no,vimeca,[10],416,"alameda antónio sérgio","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(362,-105538.35,-96008.83,bom,"fechado dos lados",yes,vimeca,[10, 11, 12],430,"avenida carolina michaelis","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(28,-105593.51,-95907.44,bom,"aberto dos lados",no,vimeca,[10, 11, 12],430,"avenida carolina michaelis","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(27,-105587.02,-95875.21,bom,"fechado dos lados",yes,vimeca,[10, 11, 12, 13],430,"avenida carolina michaelis","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(26,-105556.0408335595,-95684.40583339432,bom,"sem abrigo",no,vimeca,[10, 11, 12, 13],430,"avenida carolina michaelis","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(688,-106112.34689956294,-95027.73434321095,bom,"fechado dos lados",yes,vimeca,[10, 12],10,"avenida dos bombeiros voluntários de algés","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(679,-106071.42513405527,-95039.14634930693,bom,"fechado dos lados",yes,vimeca,[10, 12],10,"avenida dos bombeiros voluntários de algés","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(675,-106288.85,-95136.57,bom,"fechado dos lados",yes,vimeca,[10, 12],10,"avenida dos bombeiros voluntários de algés","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(671,-106568.5,-95165.9,bom,"fechado dos lados",yes,vimeca,[10, 12],10,"avenida dos bombeiros voluntários de algés","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(75,-106560.62,-95186.03,bom,"aberto dos lados",yes,vimeca,[10, 12],10,"avenida dos bombeiros voluntários de algés","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(72,-106342.5,-95131.58,bom,"fechado dos lados",yes,vimeca,[10, 12],10,"avenida dos bombeiros voluntários de algés","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(526,-107061.05,-95215.0,bom,"fechado dos lados",yes,vimeca,[10, 12],102,"largo dom manuel i","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(643,-105325.87,-95135.44,bom,"fechado dos lados",yes,vimeca,[10, 12],113,"alameda ferno lopes","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(641,-105655.76,-95028.52,bom,"fechado dos lados",yes,vimeca,[10, 12],116,"avenida general norton de matos","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(638,-105456.01,-94993.65,bom,"fechado dos lados",yes,vimeca,[10, 12],116,"avenida general norton de matos","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(637,-105462.27,-94976.17,bom,"fechado dos lados",yes,vimeca,[10, 12],116,"avenida general norton de matos","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(635,-105696.83,-95075.27,bom,"fechado dos lados",yes,vimeca,[10, 12],116,"avenida general norton de matos","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(657,-106786.85846811837,-95149.7421827531,bom,"fechado dos lados",yes,vimeca,[10, 12],155,"praça doutor manuel martins","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(70,-106799.63,-95251.22,bom,"sem abrigo",no,vimeca,[10, 12],155,"praça doutor manuel martins","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(349,-105225.66,-96048.66,bom,"fechado dos lados",yes,vimeca,[10, 12],407,"rua amaro monteiro","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(860,-105051.07,-96033.67,bom,"fechado dos lados",yes,vimeca,[10, 12],416,"alameda antónio sérgio","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(361,-105510.18,-96017.31,bom,"fechado dos lados",no,vimeca,[10, 12],430,"avenida carolina michaelis","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(359,-105204.46,-96026.88,bom,"fechado dos lados",yes,vimeca,[10, 12],430,"avenida carolina michaelis","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(37,-105549.20067076161,-95690.84269383312,bom,"fechado dos lados",yes,vimeca,[10, 12],430,"avenida carolina michaelis","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(861,-105093.87,-96039.61,bom,"fechado dos lados",yes,vimeca,[10, 12, 13],416,"alameda antónio sérgio","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(82,-104255.84,-95234.54,bom,"fechado dos lados",no,vimeca,[10, 13, 15],306,"rua dos cravos de abril","carnaxide e queijas").
paragem(1013,-101793.68162303536,-99832.30867120415,bom,"sem abrigo",no,lt,[101],217,"rua da constituição","barcarena").
paragem(102,-101969.18,-99801.53,bom,"sem abrigo",no,lt,[101],217,"rua da constituição","barcarena").
paragem(101,-101994.64,-99805.01,bom,"sem abrigo",no,lt,[101],217,"rua da constituição","barcarena").
paragem(106,-101762.99,-99819.05,bom,"sem abrigo",no,lt,[101],261,"rua da juventude","barcarena").
paragem(103,-101939.71,-99689.6,bom,"sem abrigo",no,lt,[101],1003,"rua odette de saint-maurice","barcarena").
paragem(737,-102409.39,-98701.67,bom,"fechado dos lados",yes,lt,[101, 101, 171],269,"rua mário castelhano","barcarena").
paragem(744,-102136.13485160771,-98663.30880207638,bom,"fechado dos lados",no,lt,[101, 102, 106, 171],216,"estrada consiglieri pedroso","barcarena").
paragem(715,-101966.52,-98573.78,bom,"fechado dos lados",yes,lt,[101, 102, 106, 171],216,"estrada consiglieri pedroso","barcarena").
paragem(711,-101764.30649856283,-98424.15159847475,bom,"sem abrigo",no,lt,[101, 102, 106, 171],216,"estrada consiglieri pedroso","barcarena").
paragem(152,-102231.41,-98789.31,bom,"fechado dos lados",yes,lt,[101, 102, 106, 171],216,"estrada consiglieri pedroso","barcarena").
paragem(127,-101949.9,-98542.91,bom,"fechado dos lados",yes,lt,[101, 102, 106, 171],216,"estrada consiglieri pedroso","barcarena").
paragem(125,-101787.42,-98423.54,bom,"fechado dos lados",yes,lt,[101, 102, 106, 171],216,"estrada consiglieri pedroso","barcarena").
paragem(732,-102381.73,-98965.83,bom,"sem abrigo",no,lt,[101, 102, 106, 171],950,"estrada das palmeiras","barcarena").
paragem(733,-102638.72,-98781.31,bom,"sem abrigo",no,lt,[101, 102, 171],993,"rua do trabalho","barcarena").
paragem(146,-102407.34,-99102.68,bom,"sem abrigo",no,lt,[101, 106, 171],216,"estrada consiglieri pedroso","barcarena").
paragem(145,-102412.85,-99137.94,bom,"fechado dos lados",yes,lt,[101, 106, 171],216,"estrada consiglieri pedroso","barcarena").
paragem(136,-102207.02,-99467.54,bom,"sem abrigo",no,lt,[101, 171],219,"estrada da cruz dos cavalinhos","barcarena").
paragem(135,-102185.42,-99474.62,bom,"sem abrigo",no,lt,[101, 171],219,"estrada da cruz dos cavalinhos","barcarena").
paragem(134,-102017.79,-99652.24,bom,"fechado dos lados",yes,lt,[101, 171],219,"estrada da cruz dos cavalinhos","barcarena").
paragem(160,-102467.21,-98683.45,bom,"sem abrigo",no,lt,[101, 171],269,"rua mário castelhano","barcarena").
paragem(740,-102400.99,-98945.23,bom,"sem abrigo",no,lt,[101, 171],950,"estrada das palmeiras","barcarena").
paragem(148,-102630.81,-98782.18,bom,"sem abrigo",no,lt,[101, 171],993,"rua do trabalho","barcarena").
paragem(235,-104169.05,-97108.82,bom,"sem abrigo",no,lt,[102],308,"estrada do desvio","carnaxide e queijas").
paragem(455,-106763.54,-97467.84,bom,"sem abrigo",no,lt,[102],373,"avenida ferreira godinho","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(454,-106758.19,-97475.72,bom,"sem abrigo",no,lt,[102],373,"avenida ferreira godinho","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(453,-106891.39,-97351.44,bom,"fechado dos lados",no,lt,[102],373,"avenida ferreira godinho","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(739,-102735.06,-98272.9,mau,"fechado dos lados",no,carris,[102],830,"estrada militar","barcarena").
paragem(738,-103016.79,-98428.89,bom,"fechado dos lados",yes,lt,[102],830,"estrada militar","barcarena").
paragem(690,-103002.83,-98398.75,bom,"aberto dos lados",no,lt,[102],830,"estrada militar","barcarena").
paragem(84,-102931.23,-98622.69,bom,"sem abrigo",no,lt,[102],830,"estrada militar","barcarena").
paragem(83,-102942.61,-98628.76,bom,"fechado dos lados",yes,carris,[102],830,"estrada militar","barcarena").
paragem(151,-102676.09,-98810.3,bom,"sem abrigo",no,lt,[102],950,"estrada das palmeiras","barcarena").
paragem(743,-102708.54,-98296.07,bom,"sem abrigo",no,lt,[102],1099,"rua quinta da bica do sargento","barcarena").
paragem(708,-103166.65231804183,-97987.56576748956,bom,"sem abrigo",no,lt,[102],1200,"rua actor carlos césar","carnaxide e queijas").
paragem(1016,-103193.05176985393,-97956.32085163088,bom,"sem abrigo",no,lt,[102],1214,"estrada de queluz","carnaxide e queijas").
paragem(1015,-103181.82,-97967.06,bom,"sem abrigo",no,lt,[102],1214,"estrada de queluz","carnaxide e queijas").
paragem(815,-104101.68,-97408.6,bom,"fechado dos lados",yes,lt,[102],1214,"estrada de queluz","carnaxide e queijas").
paragem(814,-104114.84,-97401.12,bom,"fechado dos lados",yes,lt,[102],1214,"estrada de queluz","carnaxide e queijas").
paragem(789,-103478.11,-97851.67,bom,"sem abrigo",no,lt,[102],1214,"estrada de queluz","carnaxide e queijas").
paragem(169,-103468.05,-97872.21,bom,"fechado dos lados",yes,lt,[102],1214,"estrada de queluz","carnaxide e queijas").
paragem(158,-102845.12,-97961.08,bom,"sem abrigo",no,lt,[102],1214,"estrada de queluz","carnaxide e queijas").
paragem(157,-102859.54,-97965.24,bom,"fechado dos lados",yes,lt,[102],1214,"estrada de queluz","carnaxide e queijas").
paragem(223,-104280.83,-98312.61,bom,"fechado dos lados",no,lt,[102, 103],1766,"praceta antonio leal de oliveira","carnaxide e queijas").
paragem(1009,-104303.63612383851,-98554.7783833525,bom,"sem abrigo",no,lt,[102, 108],79,"rua dos açores","carnaxide e queijas").
paragem(813,-104117.95,-97049.09,bom,"fechado dos lados",yes,lt,[102, 108],303,"rua cinco de outubro","carnaxide e queijas").
paragem(236,-104266.39,-96923.24,bom,"sem abrigo",no,lt,[102, 108],308,"estrada do desvio","carnaxide e queijas").
paragem(817,-104091.69,-96778.69,bom,"fechado dos lados",no,lt,[102, 108],362,"largo da pátria nova","carnaxide e queijas").
paragem(804,-104935.73,-98290.43,bom,"fechado dos lados",yes,lt,[102, 108],813,"rua joão xxi","carnaxide e queijas").
paragem(803,-104768.69,-98266.88,bom,"fechado dos lados",yes,lt,[102, 108],813,"rua joão xxi","carnaxide e queijas").
paragem(802,-104942.78,-98303.15,bom,"fechado dos lados",yes,lt,[102, 108],813,"rua joão xxi","carnaxide e queijas").
paragem(632,-104801.2,-98279.24,bom,"fechado dos lados",yes,lt,[102, 108],813,"rua joão xxi","carnaxide e queijas").
paragem(801,-104447.68,-98306.88,bom,"sem abrigo",no,lt,[102, 108],833,"rua mouzinho da silveira","carnaxide e queijas").
paragem(842,-105122.88,-97490.88,bom,"fechado dos lados",yes,lt,[102, 108],1279,"avenida tomás ribeiro","carnaxide e queijas").
paragem(841,-105119.12,-97474.49,bom,"fechado dos lados",yes,lt,[102, 108],1279,"avenida tomás ribeiro","carnaxide e queijas").
paragem(838,-105277.7,-97707.8,bom,"fechado dos lados",yes,lt,[102, 108],1279,"avenida tomás ribeiro","carnaxide e queijas").
paragem(837,-105155.04,-98252.49,bom,"fechado dos lados",yes,lt,[102, 108],1279,"avenida tomás ribeiro","carnaxide e queijas").
paragem(835,-105181.29,-98229.14,bom,"fechado dos lados",yes,lt,[102, 108],1279,"avenida tomás ribeiro","carnaxide e queijas").
paragem(816,-104200.64,-96833.39,bom,"fechado dos lados",yes,lt,[102, 108],1279,"avenida tomás ribeiro","carnaxide e queijas").
paragem(811,-104957.37,-97342.73,bom,"fechado dos lados",no,lt,[102, 108],1279,"avenida tomás ribeiro","carnaxide e queijas").
paragem(810,-104965.93,-97337.63,bom,"sem abrigo",no,lt,[102, 108],1279,"avenida tomás ribeiro","carnaxide e queijas").
paragem(809,-104609.35,-97210.07,bom,"sem abrigo",no,lt,[102, 108],1279,"avenida tomás ribeiro","carnaxide e queijas").
paragem(808,-104604.14,-97197.81,bom,"fechado dos lados",yes,lt,[102, 108],1279,"avenida tomás ribeiro","carnaxide e queijas").
paragem(836,-105254.68,-97686.43,bom,"sem abrigo",no,lt,[102, 108],1763,"rua visconde moreira de rey","carnaxide e queijas").
paragem(805,-104471.99,-98565.73,bom,"fechado dos lados",no,lt,[102, 108, 171],83,"rua angra do heroí­smo","carnaxide e queijas").
paragem(800,-104618.82,-98507.86,bom,"fechado dos lados",no,lt,[102, 108, 171],846,"rua da quinta do bonfim","carnaxide e queijas").
paragem(229,-104718.77,-97838.97,bom,"fechado dos lados",no,lt,[102, 171],1767,"rua augusto fraga","carnaxide e queijas").
paragem(581,-108611.0,-103212.55,bom,"fechado dos lados",yes,lt,[106],556,"avenida dom joão i","oeiras e são julião da barra, paço de arcos e caxias").
paragem(576,-108633.94,-103087.73,bom,"fechado dos lados",yes,lt,[106],556,"avenida dom joão i","oeiras e são julião da barra, paço de arcos e caxias").
paragem(941,-108629.88,-103387.36,bom,"fechado dos lados",yes,lt,[106],561,"rua dona filipa de lencastre","oeiras e são julião da barra, paço de arcos e caxias").
paragem(585,-108680.61,-103239.46,razoavel,"fechado dos lados",yes,lt,[106],561,"rua dona filipa de lencastre","oeiras e são julião da barra, paço de arcos e caxias").
paragem(780,-103217.78,-99786.02,bom,"fechado dos lados",no,lt,[106],985,"rua sete de junho","barcarena").
paragem(967,-108145.87,-103052.15,bom,"fechado dos lados",yes,lt,[106],1332,"rua da fundição de oeiras","oeiras e são julião da barra, paço de arcos e caxias").
paragem(944,-108324.30768595074,-103189.2291270085,bom,"sem abrigo",no,lt,[106],1344,"avenida infante dom henrique","oeiras e são julião da barra, paço de arcos e caxias").
paragem(579,-108585.23,-103414.87,bom,"sem abrigo",no,lt,[106],1344,"avenida infante dom henrique","oeiras e são julião da barra, paço de arcos e caxias").
paragem(969,-108450.51,-102954.49,bom,"fechado dos lados",yes,lt,[106],1346,"rua infanta dona isabel","oeiras e são julião da barra, paço de arcos e caxias").
paragem(913,-108219.95,-102975.3,bom,"aberto dos lados",no,lt,[106],1346,"rua infanta dona isabel","oeiras e são julião da barra, paço de arcos e caxias").
paragem(584,-108725.34,-103548.2,bom,"fechado dos lados",no,lt,[106],1392,"rua da medrosa","oeiras e são julião da barra, paço de arcos e caxias").
paragem(583,-108734.22,-103555.55,bom,"fechado dos lados",no,lt,[106],1392,"rua da medrosa","oeiras e são julião da barra, paço de arcos e caxias").
paragem(285,-105368.2,-101892.7,bom,"sem abrigo",no,lt,[106],1497,"avenida dos bombeiros voluntários de oeiras","porto salvo").
paragem(284,-105349.84,-101863.8,bom,"sem abrigo",no,lt,[106],1497,"avenida dos bombeiros voluntários de oeiras","porto salvo").
paragem(751,-103269.77,-101294.22,bom,"sem abrigo",no,lt,[106, 112, 119],262,"estrada de leceia","porto salvo").
paragem(310,-107559.62,-102708.32,bom,"fechado dos lados",yes,lt,[106, 111, 112, 115, 122],514,"largo avião lusitânia","oeiras e são julião da barra, paço de arcos e caxias").
paragem(505,-107655.06,-102500.24,bom,"fechado dos lados",yes,lt,[106, 111, 112, 115, 122],533,"rua cândido dos reis","oeiras e são julião da barra, paço de arcos e caxias").
paragem(501,-107752.93,-102745.45,bom,"fechado dos lados",yes,lt,[106, 111, 112, 115, 122],559,"rua desembargador faria","oeiras e são julião da barra, paço de arcos e caxias").
paragem(540,-107146.31,-102052.84,bom,"fechado dos lados",yes,lt,[106, 111, 112, 115, 122],1325,"rua da figueirinha","oeiras e são julião da barra, paço de arcos e caxias").
paragem(521,-107653.99,-103018.24,bom,"fechado dos lados",yes,lt,[106, 111, 112, 115, 122],1372,"rua dos lagares da quinta","oeiras e são julião da barra, paço de arcos e caxias").
paragem(208,-104277.99,-101693.69,bom,"fechado dos lados",yes,lt,[106, 112],735,"estrada de leião","porto salvo").
paragem(577,-108251.01,-102833.68,bom,"fechado dos lados",yes,lt,[106, 112, 115],494,"largo almirante gago coutinho","oeiras e são julião da barra, paço de arcos e caxias").
paragem(518,-107301.29,-102385.38,bom,"fechado dos lados",yes,lt,[106, 112, 115, 122],578,"avenida embaixador augusto de castro","oeiras e são julião da barra, paço de arcos e caxias").
paragem(762,-103544.73,-101579.29,bom,"fechado dos lados",yes,lt,[106, 112, 119],735,"estrada de leião","porto salvo").
paragem(756,-103586.35,-101579.63,bom,"fechado dos lados",yes,lt,[106, 112, 119],735,"estrada de leião","porto salvo").
paragem(543,-107125.25,-102350.86,bom,"fechado dos lados",yes,lt,[106, 112, 122],545,"praça comandante henrique moreira rato","oeiras e são julião da barra, paço de arcos e caxias").
paragem(10,-107129.12,-102327.55,bom,"fechado dos lados",yes,lt,[106, 112, 122],545,"praça comandante henrique moreira rato","oeiras e são julião da barra, paço de arcos e caxias").
paragem(538,-107524.55,-102219.24,bom,"fechado dos lados",yes,lt,[106, 112, 122],1325,"rua da figueirinha","oeiras e são julião da barra, paço de arcos e caxias").
paragem(869,-106637.67595501819,-102220.03308837875,bom,"sem abrigo",no,lt,[106, 112, 122],1407,"estrada de oeiras","oeiras e são julião da barra, paço de arcos e caxias").
paragem(542,-107049.08,-102098.31,bom,"fechado dos lados",yes,lt,[106, 112, 122],1427,"avenida rio de janeiro","oeiras e são julião da barra, paço de arcos e caxias").
paragem(541,-107041.47,-102109.11,bom,"fechado dos lados",yes,lt,[106, 112, 122],1427,"avenida rio de janeiro","oeiras e são julião da barra, paço de arcos e caxias").
paragem(516,-107095.35,-102502.91,bom,"fechado dos lados",yes,lt,[106, 112, 122],1427,"avenida rio de janeiro","oeiras e são julião da barra, paço de arcos e caxias").
paragem(503,-107081.63,-102504.58,bom,"fechado dos lados",yes,lt,[106, 112, 122],1427,"avenida rio de janeiro","oeiras e são julião da barra, paço de arcos e caxias").
paragem(828,-105046.86,-101627.86,bom,"fechado dos lados",yes,lt,[106, 112, 125, 129],1540,"estrada de paço de arcos","porto salvo").
paragem(797,-104431.06,-101723.48,bom,"fechado dos lados",yes,lt,[106, 112, 125, 129, 184],692,"rua conde de rio maior","porto salvo").
paragem(796,-104911.86,-101688.38,bom,"fechado dos lados",yes,lt,[106, 112, 125, 129, 184],692,"rua conde de rio maior","porto salvo").
paragem(795,-104741.4,-101691.52,bom,"fechado dos lados",yes,lt,[106, 112, 125, 129, 184],692,"rua conde de rio maior","porto salvo").
paragem(191,-104731.0,-101677.86,bom,"sem abrigo",no,lt,[106, 112, 125, 129, 184],692,"rua conde de rio maior","porto salvo").
paragem(785,-103715.97,-100117.58,bom,"fechado dos lados",yes,lt,[106, 117],242,"largo general humberto delgado","barcarena").
paragem(781,-103703.89,-100125.35,bom,"sem abrigo",no,lt,[106, 117],262,"estrada de leceia","barcarena").
paragem(779,-103283.29,-99818.83,bom,"fechado dos lados",no,carris,[106, 117],985,"rua sete de junho","barcarena").
paragem(774,-103410.59,-99904.77,bom,"fechado dos lados",yes,lt,[106, 117],985,"rua sete de junho","barcarena").
paragem(773,-103414.27,-99913.2,bom,"sem abrigo",no,lt,[106, 117],985,"rua sete de junho","barcarena").
paragem(419,-106722.41,-99402.9,bom,"fechado dos lados",no,lt,[106, 117, 158],849,"avenida antónio florêncio dos santos","oeiras e são julião da barra, paço de arcos e caxias").
paragem(88,-106688.11,-99381.79,bom,"fechado dos lados",yes,lt,[106, 117, 158],849,"avenida antónio florêncio dos santos","oeiras e são julião da barra, paço de arcos e caxias").
paragem(752,-103260.70410270982,-101287.68122082386,bom,"",no,lt,[106, 119],262,"estrada de leceia","porto salvo").
paragem(778,-103467.02,-100463.6,bom,"sem abrigo",no,lt,[106, 119],262,"estrada de leceia","barcarena").
paragem(777,-103456.31,-100462.21,bom,"fechado dos lados",no,lt,[106, 119],262,"estrada de leceia","barcarena").
paragem(776,-103364.8,-100773.19,bom,"sem abrigo",no,lt,[106, 119],262,"estrada de leceia","barcarena").
paragem(775,-103358.57,-100763.83,bom,"fechado dos lados",yes,lt,[106, 119],262,"estrada de leceia","barcarena").
paragem(379,-106252.84,-102027.92,bom,"fechado dos lados",yes,lt,[106, 122],1497,"avenida dos bombeiros voluntários de oeiras","oeiras e são julião da barra, paço de arcos e caxias").
paragem(378,-106228.95,-102033.94,bom,"sem abrigo",yes,lt,[106, 122],1497,"avenida dos bombeiros voluntários de oeiras","oeiras e são julião da barra, paço de arcos e caxias").
paragem(294,-105880.9,-101989.75,bom,"fechado dos lados",yes,lt,[106, 122],1497,"avenida dos bombeiros voluntários de oeiras","oeiras e são julião da barra, paço de arcos e caxias").
paragem(283,-105571.85,-101959.97,bom,"fechado dos lados",yes,lt,[106, 122],1497,"avenida dos bombeiros voluntários de oeiras","oeiras e são julião da barra, paço de arcos e caxias").
paragem(282,-105530.56,-101934.24,bom,"fechado dos lados",yes,lt,[106, 122],1497,"avenida dos bombeiros voluntários de oeiras","oeiras e são julião da barra, paço de arcos e caxias").
paragem(281,-105866.86,-101977.3,bom,"fechado dos lados",yes,lt,[106, 122],1497,"avenida dos bombeiros voluntários de oeiras","oeiras e são julião da barra, paço de arcos e caxias").
paragem(693,-103934.24,-96642.56,bom,"fechado dos lados",yes,lt,[108],1113,"avenida de portugal","carnaxide e queijas").
paragem(692,-103960.0,-96640.32,bom,"fechado dos lados",yes,carris,[108],1113,"avenida de portugal","carnaxide e queijas").
paragem(946,-103055.33836526402,-95462.37048401365,bom,"fechado dos lados",no,carris,[108, 114],25,"estrada de alfragide","alfragide").
paragem(592,-103100.09,-95100.64,razoavel,"fechado dos lados",yes,lt,[108, 114],25,"estrada de alfragide","carnaxide e queijas").
paragem(591,-103097.89,-95148.46,razoavel,"fechado dos lados",yes,lt,[108, 114],25,"estrada de alfragide","carnaxide e queijas").
paragem(590,-103055.84,-95605.42,bom,"sem abrigo",no,lt,[108, 114],25,"estrada de alfragide","carnaxide e queijas").
paragem(176,-103550.21,-96609.89,bom,"aberto dos lados",yes,lt,[108, 114],276,"estrada da amadora","carnaxide e queijas").
paragem(175,-103543.27,-96685.43,bom,"fechado dos lados",yes,lt,[108, 114],276,"estrada da amadora","carnaxide e queijas").
paragem(174,-103456.83,-96098.84,bom,"fechado dos lados",no,lt,[108, 114],276,"estrada da amadora","carnaxide e queijas").
paragem(173,-103441.79,-96114.45,bom,"fechado dos lados",no,lt,[108, 114],276,"estrada da amadora","carnaxide e queijas").
paragem(178,-103793.26,-96821.2,bom,"fechado dos lados",yes,lt,[108, 114],1113,"avenida de portugal","carnaxide e queijas").
paragem(177,-103782.94,-96828.11,bom,"sem abrigo",no,lt,[108, 114],1113,"avenida de portugal","carnaxide e queijas").
paragem(327,-105824.71,-98610.29,bom,"sem abrigo",no,lt,[108, 115],830,"estrada militar","oeiras e são julião da barra, paço de arcos e caxias").
paragem(326,-105971.01,-98597.24,bom,"sem abrigo",no,lt,[108, 115],830,"estrada militar","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(325,-105660.54,-98769.86,bom,"fechado dos lados",no,lt,[108, 115],1796,"rua das tí­lias","oeiras e são julião da barra, paço de arcos e caxias").
paragem(324,-105658.22,-98790.53,bom,"fechado dos lados",yes,lt,[108, 115],1796,"rua das tí­lias","oeiras e são julião da barra, paço de arcos e caxias").
paragem(431,-106095.33,-99310.37,bom,"fechado dos lados",yes,lt,[108, 115, 117],867,"avenida conselheiro ferreira lobo","oeiras e são julião da barra, paço de arcos e caxias").
paragem(274,-106013.52,-99221.37,bom,"fechado dos lados",no,lt,[108, 115, 117, 158],858,"rua calvet de magalhães","oeiras e são julião da barra, paço de arcos e caxias").
paragem(273,-106004.77,-99221.99,bom,"sem abrigo",no,lt,[108, 115, 117, 158],858,"rua calvet de magalhães","oeiras e são julião da barra, paço de arcos e caxias").
paragem(439,-106462.23,-99301.85,bom,"fechado dos lados",no,lt,[108, 115, 117, 158],867,"avenida conselheiro ferreira lobo","oeiras e são julião da barra, paço de arcos e caxias").
paragem(437,-106124.25,-99314.68,bom,"sem abrigo",no,lt,[108, 115, 117, 158],867,"avenida conselheiro ferreira lobo","oeiras e são julião da barra, paço de arcos e caxias").
paragem(409,-106998.97,-99255.62,bom,"fechado dos lados",yes,lt,[108, 117],898,"estrada da gibalta","oeiras e são julião da barra, paço de arcos e caxias").
paragem(319,-105790.91,-99107.05,bom,"fechado dos lados",yes,lt,[108, 117, 115, 158],909,"avenida joão de freitas branco","oeiras e são julião da barra, paço de arcos e caxias").
paragem(318,-105817.33,-99103.07,bom,"fechado dos lados",yes,lt,[108, 117, 115, 158],909,"avenida joão de freitas branco","oeiras e são julião da barra, paço de arcos e caxias").
paragem(317,-105682.17,-99043.27,bom,"fechado dos lados",yes,lt,[108, 117, 115, 158],909,"avenida joão de freitas branco","oeiras e são julião da barra, paço de arcos e caxias").
paragem(320,-105649.56,-98984.75,bom,"fechado dos lados",yes,lt,[108, 117, 115, 158],936,"largo da quinta do jardim","oeiras e são julião da barra, paço de arcos e caxias").
paragem(423,-106402.8,-99289.78,bom,"fechado dos lados",yes,lt,[108, 117, 158],1786,"rua de são joão de deus","oeiras e são julião da barra, paço de arcos e caxias").
paragem(370,-105284.38,-95991.59,bom,"fechado dos lados",yes,scotturb,[11],431,"rua de ceuta","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(348,-105643.02,-96045.85,bom,"aberto dos lados",no,vimeca,[11],442,"rua domingos fernandes","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(18,-105326.04,-95824.84,bom,"fechado dos lados",no,vimeca,[11],443,"rua doutor agostinho de campos","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(340,-106068.28,-96585.41,bom,"sem abrigo",no,vimeca,[11],477,"rua luz soriano","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(337,-105713.9,-96309.68,bom,"aberto dos lados",no,vimeca,[11],1251,"rua pedro álvares cabral","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(371,-105299.61,-95995.91,bom,"sem abrigo",no,vimeca,[11, 13],431,"rua de ceuta","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(19,-105294.01,-95844.02,bom,"sem abrigo",no,vimeca,[11, 13],431,"rua de ceuta","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(16,-105373.94,-95734.72,bom,"sem abrigo",no,vimeca,[11, 13],431,"rua de ceuta","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(492,-106048.05,-96569.91,bom,"sem abrigo",no,vimeca,[11, 13],477,"rua luz soriano","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(338,-105719.88,-96325.39,bom,"aberto dos lados",no,vimeca,[11, 13],1251,"rua pedro álvares cabral","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(875,-106837.97523209226,-101312.81293258877,bom,"fechado dos lados",yes,lt,[111],51,"rua a gazeta d'oeiras","oeiras e são julião da barra, paço de arcos e caxias").
paragem(874,-106828.30282704088,-101321.74130648235,bom,"fechado dos lados",yes,lt,[111],51,"rua a gazeta d'oeiras","oeiras e são julião da barra, paço de arcos e caxias").
paragem(549,-107045.27,-101540.24,bom,"fechado dos lados",yes,lt,[111],51,"rua a gazeta d'oeiras","oeiras e são julião da barra, paço de arcos e caxias").
paragem(548,-107036.05,-101530.9,bom,"fechado dos lados",yes,lt,[111],51,"rua a gazeta d'oeiras","oeiras e são julião da barra, paço de arcos e caxias").
paragem(404,-106707.27,-101357.94,bom,"sem abrigo",no,lt,[111],51,"rua a gazeta d'oeiras","oeiras e são julião da barra, paço de arcos e caxias").
paragem(403,-106688.88,-101392.42,bom,"fechado dos lados",yes,lt,[111],51,"rua a gazeta d'oeiras","oeiras e são julião da barra, paço de arcos e caxias").
paragem(399,-106862.17,-101462.2,bom,"sem abrigo",no,lt,[111],51,"rua a gazeta d'oeiras","oeiras e são julião da barra, paço de arcos e caxias").
paragem(398,-106850.3,-101488.95,bom,"sem abrigo",no,lt,[111],51,"rua a gazeta d'oeiras","oeiras e são julião da barra, paço de arcos e caxias").
paragem(534,-107422.35,-102089.51,bom,"fechado dos lados",no,carris,[111],499,"avenida de angola","oeiras e são julião da barra, paço de arcos e caxias").
paragem(533,-107409.14,-102099.37,bom,"fechado dos lados",no,lt,[111],499,"avenida de angola","oeiras e são julião da barra, paço de arcos e caxias").
paragem(532,-107471.58,-102018.18,bom,"aberto dos lados",no,lt,[111],499,"avenida de angola","oeiras e são julião da barra, paço de arcos e caxias").
paragem(566,-107420.54,-102241.23,bom,"fechado dos lados",yes,lt,[111],547,"rua comandante germano dias","oeiras e são julião da barra, paço de arcos e caxias").
paragem(531,-107429.2,-102210.53,bom,"fechado dos lados",yes,lt,[111],547,"rua comandante germano dias","oeiras e são julião da barra, paço de arcos e caxias").
paragem(504,-107503.48,-102420.75,bom,"fechado dos lados",yes,lt,[111],547,"rua comandante germano dias","oeiras e são julião da barra, paço de arcos e caxias").
paragem(920,-107409.66,-102471.79,bom,"fechado dos lados",yes,lt,[111],551,"avenida copacabana","oeiras e são julião da barra, paço de arcos e caxias").
paragem(517,-107532.34,-102429.36,bom,"fechado dos lados",yes,lt,[111],551,"avenida copacabana","oeiras e são julião da barra, paço de arcos e caxias").
paragem(919,-107319.63,-102563.55,bom,"fechado dos lados",yes,lt,[111],578,"avenida embaixador augusto de castro","oeiras e são julião da barra, paço de arcos e caxias").
paragem(871,-106541.47,-101422.66,bom,"fechado dos lados",yes,lt,[111],587,"avenida antónio bernardo cabral de macedo","oeiras e são julião da barra, paço de arcos e caxias").
paragem(408,-106741.29,-101198.09,bom,"fechado dos lados",yes,lt,[111],587,"avenida antónio bernardo cabral de macedo","oeiras e são julião da barra, paço de arcos e caxias").
paragem(407,-106584.03,-101407.23,bom,"sem abrigo",no,lt,[111],587,"avenida antónio bernardo cabral de macedo","oeiras e são julião da barra, paço de arcos e caxias").
paragem(390,-106769.62,-101182.57,bom,"sem abrigo",no,lt,[111],587,"avenida antónio bernardo cabral de macedo","oeiras e são julião da barra, paço de arcos e caxias").
paragem(570,-107050.23,-100723.54,bom,"fechado dos lados",yes,lt,[111],605,"rua conde das alcáçovas","oeiras e são julião da barra, paço de arcos e caxias").
paragem(530,-107482.01,-102338.02,bom,"fechado dos lados",yes,lt,[111],1321,"rua fernando pessoa","oeiras e são julião da barra, paço de arcos e caxias").
paragem(873,-106648.75190204488,-101501.00032816519,bom,"sem abrigo",no,lt,[111],1359,"rua josé de azambuja proença","oeiras e são julião da barra, paço de arcos e caxias").
paragem(394,-106663.26,-101486.4,bom,"sem abrigo",no,lt,[111],1359,"rua josé de azambuja proença","oeiras e são julião da barra, paço de arcos e caxias").
paragem(567,-107279.28,-102025.92,bom,"fechado dos lados",yes,lt,[111],1455,"avenida do ultramar","oeiras e são julião da barra, paço de arcos e caxias").
paragem(539,-107434.4,-101991.91,bom,"fechado dos lados",yes,lt,[111],1455,"avenida do ultramar","oeiras e são julião da barra, paço de arcos e caxias").
paragem(1025,-108102.81093469674,-103074.8246594517,bom,"sem abrigo",no,lt,[111, 122],1342,"rua henrique de paiva couceiro","oeiras e são julião da barra, paço de arcos e caxias").
paragem(554,-107124.01,-101962.87,bom,"fechado dos lados",yes,lt,[111, 115],527,"avenida de brasí­lia","oeiras e são julião da barra, paço de arcos e caxias").
paragem(553,-107113.59,-101968.28,bom,"fechado dos lados",yes,lt,[111, 115],527,"avenida de brasí­lia","oeiras e são julião da barra, paço de arcos e caxias").
paragem(552,-107114.28,-101783.86,bom,"fechado dos lados",yes,lt,[111, 115],527,"avenida de brasí­lia","oeiras e são julião da barra, paço de arcos e caxias").
paragem(551,-107102.8,-101781.42,bom,"fechado dos lados",yes,lt,[111, 115],527,"avenida de brasí­lia","oeiras e são julião da barra, paço de arcos e caxias").
paragem(565,-107105.26,-101627.34,bom,"sem abrigo",no,lt,[111, 115],601,"rua carlos vieira ramos","oeiras e são julião da barra, paço de arcos e caxias").
paragem(564,-107094.68,-101630.41,bom,"sem abrigo",no,lt,[111, 115],601,"rua carlos vieira ramos","oeiras e são julião da barra, paço de arcos e caxias").
paragem(925,-107625.08,-103117.77,bom,"fechado dos lados",no,lt,[111, 122],1431,"avenida salvador allende","oeiras e são julião da barra, paço de arcos e caxias").
paragem(872,-106368.26,-101705.73,bom,"sem abrigo",yes,lt,[111, 158],587,"avenida antónio bernardo cabral de macedo","oeiras e são julião da barra, paço de arcos e caxias").
paragem(391,-106420.98,-101611.2,bom,"fechado dos lados",yes,lt,[111, 158],587,"avenida antónio bernardo cabral de macedo","oeiras e são julião da barra, paço de arcos e caxias").
paragem(705,-101884.93,-101826.65,bom,"fechado dos lados",yes,lt,[112],1667,"avenida professor dr. cavaco silva","porto salvo").
paragem(704,-101856.51,-101822.02,bom,"fechado dos lados",yes,lt,[112],1667,"avenida professor dr. cavaco silva","porto salvo").
paragem(272,-105722.56,-102581.2,bom,"sem abrigo",no,lt,[112],1680,"rua encosta das lagoas","porto salvo").
paragem(271,-105742.74,-102575.8,bom,"fechado dos lados",no,lt,[112],1680,"rua encosta das lagoas","porto salvo").
paragem(727,-102515.87,-101878.09,bom,"fechado dos lados",yes,lt,[112, 119, 125],1667,"avenida professor dr. cavaco silva","porto salvo").
paragem(726,-102509.72,-101859.8,bom,"fechado dos lados",yes,lt,[112, 119, 125],1667,"avenida professor dr. cavaco silva","porto salvo").
paragem(723,-102865.58,-101399.39,bom,"fechado dos lados",yes,lt,[112, 119, 125],1667,"avenida professor dr. cavaco silva","porto salvo").
paragem(722,-102849.51,-101421.76,bom,"fechado dos lados",yes,lt,[112, 119, 125],1667,"avenida professor dr. cavaco silva","porto salvo").
paragem(717,-102227.22,-101894.71,bom,"fechado dos lados",yes,lt,[112, 119, 125],1667,"avenida professor dr. cavaco silva","porto salvo").
paragem(716,-102227.55,-101920.36,bom,"fechado dos lados",yes,lt,[112, 119, 125],1667,"avenida professor dr. cavaco silva","porto salvo").
paragem(832,-105236.25,-102190.54,bom,"fechado dos lados",yes,lt,[112, 122],1682,"avenida santa casa da misericordia de oeiras","porto salvo").
paragem(831,-105274.84,-101913.18,bom,"fechado dos lados",yes,lt,[112, 122],1682,"avenida santa casa da misericordia de oeiras","porto salvo").
paragem(830,-105227.47,-102176.58,bom,"fechado dos lados",yes,lt,[112, 122],1682,"avenida santa casa da misericordia de oeiras","porto salvo").
paragem(829,-105291.98,-101912.29,bom,"fechado dos lados",yes,lt,[112, 122],1682,"avenida santa casa da misericordia de oeiras","porto salvo").
paragem(989,-106533.85390436777,-102159.09374561995,bom,"aberto dos lados",no,lt,[112, 122, 106],1407,"estrada de oeiras","oeiras e são julião da barra, paço de arcos e caxias").
paragem(827,-105268.41,-102428.49,bom,"fechado dos lados",yes,lt,[112, 122, 129],1680,"rua encosta das lagoas","porto salvo").
paragem(266,-105280.44,-102478.21,bom,"fechado dos lados",yes,lt,[112, 122, 129],1680,"rua encosta das lagoas","porto salvo").
paragem(381,-106248.58,-102114.98,razoavel,"sem abrigo",no,lt,[112, 158],1521,"estrada da ribeira da laje","oeiras e são julião da barra, paço de arcos e caxias").
paragem(380,-106217.2,-102161.99,bom,"fechado dos lados",yes,lt,[112, 158],1521,"estrada da ribeira da laje","oeiras e são julião da barra, paço de arcos e caxias").
paragem(81,-107028.61,-95211.28,bom,"fechado dos lados",yes,lt,[114],103,"rua damião de góis","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(64,-106263.4,-95432.65,bom,"fechado dos lados",yes,lt,[114],142,"avenida da república","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(63,-106281.59,-95428.61,bom,"sem abrigo",no,lt,[114],142,"avenida da república","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(62,-106448.94,-95449.29,bom,"fechado dos lados",yes,lt,[114],142,"avenida da república","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(59,-106702.76,-95584.31,bom,"sem abrigo",no,lt,[114],142,"avenida da república","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(58,-106491.0,-95464.18,bom,"fechado dos lados",yes,lt,[114],142,"avenida da república","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(57,-106676.23,-95569.51,bom,"fechado dos lados",no,lt,[114],142,"avenida da república","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(364,-105749.92,-96128.02,bom,"fechado dos lados",yes,lt,[114],150,"rua victor duarte pedroso","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(61,-106056.3,-95443.94,bom,"fechado dos lados",no,lt,[114],150,"rua victor duarte pedroso","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(60,-106031.48,-95429.88,bom,"sem abrigo",no,lt,[114],150,"rua victor duarte pedroso","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(33,-105923.57,-95719.27,bom,"fechado dos lados",no,lt,[114],150,"rua victor duarte pedroso","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(32,-105942.11,-95669.45,bom,"fechado dos lados",no,lt,[114],150,"rua victor duarte pedroso","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(1002,-104226.49,-95797.22,bom,"fechado dos lados",yes,lt,[114],327,"avenida do forte","carnaxide e queijas").
paragem(986,-104675.71,-95821.42,bom,"fechado dos lados",yes,lt,[114],327,"avenida do forte","carnaxide e queijas").
paragem(983,-104700.62,-95803.69,bom,"fechado dos lados",yes,lt,[114],327,"avenida do forte","carnaxide e queijas").
paragem(977,-104296.72,-95828.26,bom,"fechado dos lados",yes,lt,[114],327,"avenida do forte","carnaxide e queijas").
paragem(950,-103725.69,-95975.2,bom,"fechado dos lados",yes,lt,[114],354,"rua manuel teixeira gomes","carnaxide e queijas").
paragem(792,-103922.82,-96235.62,bom,"fechado dos lados",yes,lt,[114],354,"rua manuel teixeira gomes","carnaxide e queijas").
paragem(333,-105712.14,-96154.74,bom,"fechado dos lados",yes,lt,[114],450,"rua engenheiro josé frederico ulrich","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(823,-104032.88,-96536.98,bom,"fechado dos lados",yes,lt,[114],1113,"avenida de portugal","carnaxide e queijas").
paragem(818,-104031.08,-96173.83,bom,"fechado dos lados",yes,lt,[114],1113,"avenida de portugal","carnaxide e queijas").
paragem(807,-104003.78,-96559.17,bom,"fechado dos lados",yes,lt,[114],1113,"avenida de portugal","carnaxide e queijas").
paragem(710,-103972.32,-95981.88,bom,"fechado dos lados",yes,lt,[114],1113,"avenida de portugal","carnaxide e queijas").
paragem(954,-104075.89,-95771.82,bom,"fechado dos lados",yes,lt,[114],1116,"avenida professor dr. reinaldo dos santos","carnaxide e queijas").
paragem(947,-103879.91,-95751.23,bom,"fechado dos lados",no,lt,[114],1116,"avenida professor dr. reinaldo dos santos","carnaxide e queijas").
paragem(952,-104058.98,-95839.14,bom,"fechado dos lados",yes,lt,[114],1137,"rua tenente-general zeferino sequeira","carnaxide e queijas").
paragem(846,-105713.9,-96309.68,bom,"aberto dos lados",no,lt,[114],1251,"rua pedro álvares cabral","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(845,-105719.88,-96325.39,bom,"aberto dos lados",no,lt,[114],1251,"rua pedro álvares cabral","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(367,-105679.92,-96534.6,bom,"fechado dos lados",yes,lt,[114],1279,"avenida tomás ribeiro","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(330,-105744.42,-96527.5,bom,"fechado dos lados",yes,lt,[114],1279,"avenida tomás ribeiro","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(863,-105210.86,-96382.34,bom,"fechado dos lados",yes,lt,[114],1283,"avenida vinte e cinco de abril de 1974","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(857,-105326.62,-96569.43,bom,"fechado dos lados",yes,lt,[114],1283,"avenida vinte e cinco de abril de 1974","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(856,-105287.42,-96454.4,bom,"fechado dos lados",yes,lt,[114],1283,"avenida vinte e cinco de abril de 1974","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(354,-105043.39,-96109.56,bom,"fechado dos lados",yes,lt,[114],1283,"avenida vinte e cinco de abril de 1974","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(353,-105062.32,-96107.23,bom,"fechado dos lados",yes,lt,[114],1283,"avenida vinte e cinco de abril de 1974","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(535,-107581.42,-102198.59,bom,"fechado dos lados",yes,lt,[115],533,"rua cândido dos reis","oeiras e são julião da barra, paço de arcos e caxias").
paragem(1006,-107164.33866025771,-101426.22549078583,bom,"fechado dos lados",yes,lt,[115],601,"rua carlos vieira ramos","oeiras e são julião da barra, paço de arcos e caxias").
paragem(563,-107141.23,-101485.07,bom,"fechado dos lados",yes,lt,[115],601,"rua carlos vieira ramos","oeiras e são julião da barra, paço de arcos e caxias").
paragem(425,-106665.8,-99468.51,bom,"fechado dos lados",no,lt,[115],856,"rua bernardim ribeiro","oeiras e são julião da barra, paço de arcos e caxias").
paragem(432,-106389.99,-99441.49,bom,"aberto dos lados",no,lt,[115],899,"rua de goa","oeiras e são julião da barra, paço de arcos e caxias").
paragem(424,-106482.29,-99626.9,bom,"aberto dos lados",no,lt,[115],899,"rua de goa","oeiras e são julião da barra, paço de arcos e caxias").
paragem(934,-107286.31,-102095.09,bom,"fechado dos lados",yes,lt,[115],1325,"rua da figueirinha","oeiras e são julião da barra, paço de arcos e caxias").
paragem(568,-107459.5,-101976.24,bom,"fechado dos lados",yes,lt,[115],1455,"avenida do ultramar","oeiras e são julião da barra, paço de arcos e caxias").
paragem(562,-107112.0,-101075.39,bom,"fechado dos lados",no,lt,[115],1527,"rua manuel pinhanços","oeiras e são julião da barra, paço de arcos e caxias").
paragem(429,-106431.59,-99785.79,bom,"sem abrigo",no,lt,[115],1769,"rua vasco da gama","oeiras e são julião da barra, paço de arcos e caxias").
paragem(428,-106433.33,-99804.88,bom,"sem abrigo",no,lt,[115],1769,"rua vasco da gama","oeiras e são julião da barra, paço de arcos e caxias").
paragem(1008,-106840.5909766439,-100709.59335706284,bom,"sem abrigo",no,lt,[115, 158],585,"rua de angola","oeiras e são julião da barra, paço de arcos e caxias").
paragem(436,-106547.04,-100175.4,bom,"fechado dos lados",yes,lt,[115, 158],592,"rua augusto sousa lobo","oeiras e são julião da barra, paço de arcos e caxias").
paragem(435,-106550.9,-100185.96,bom,"aberto dos lados",no,lt,[115, 158],592,"rua augusto sousa lobo","oeiras e são julião da barra, paço de arcos e caxias").
paragem(421,-106355.98,-100328.5,bom,"fechado dos lados",no,lt,[115, 158],592,"rua augusto sousa lobo","oeiras e são julião da barra, paço de arcos e caxias").
paragem(420,-106369.82,-100337.94,bom,"fechado dos lados",no,lt,[115, 158],592,"rua augusto sousa lobo","oeiras e são julião da barra, paço de arcos e caxias").
paragem(413,-106399.4,-100625.78,bom,"fechado dos lados",no,lt,[115, 158],609,"rua conde de rio maior","oeiras e são julião da barra, paço de arcos e caxias").
paragem(442,-106329.69,-100480.44,bom,"fechado dos lados",yes,lt,[115, 158],610,"avenida conde de são januário","oeiras e são julião da barra, paço de arcos e caxias").
paragem(412,-106824.4,-100718.89,bom,"fechado dos lados",no,lt,[115, 158],610,"avenida conde de são januário","oeiras e são julião da barra, paço de arcos e caxias").
paragem(411,-106318.44,-100465.14,bom,"aberto dos lados",no,lt,[115, 158],610,"avenida conde de são januário","oeiras e são julião da barra, paço de arcos e caxias").
paragem(402,-106864.28,-101108.52,bom,"fechado dos lados",yes,lt,[115, 158],620,"avenida elvira velez","oeiras e são julião da barra, paço de arcos e caxias").
paragem(401,-106863.16,-101122.04,bom,"fechado dos lados",no,lt,[115, 158],620,"avenida elvira velez","oeiras e são julião da barra, paço de arcos e caxias").
paragem(418,-106441.72,-100682.43,bom,"aberto dos lados",no,lt,[115, 158],645,"rua instituto conde de agrolongo","oeiras e são julião da barra, paço de arcos e caxias").
paragem(415,-106605.36,-100689.48,bom,"sem abrigo",no,lt,[115, 158],645,"rua instituto conde de agrolongo","oeiras e são julião da barra, paço de arcos e caxias").
paragem(414,-106613.41,-100706.91,bom,"fechado dos lados",no,lt,[115, 158],645,"rua instituto conde de agrolongo","oeiras e são julião da barra, paço de arcos e caxias").
paragem(427,-106642.38,-99930.18,bom,"aberto dos lados",no,lt,[115, 158],1785,"rua de são gabriel","oeiras e são julião da barra, paço de arcos e caxias").
paragem(426,-106638.34,-99940.41,bom,"aberto dos lados",no,lt,[115, 158],1785,"rua de são gabriel","oeiras e são julião da barra, paço de arcos e caxias").
paragem(1011,-107442.97396256146,-100964.28382638063,bom,"fechado dos lados",yes,lt,[116],611,"rua costa pinto","oeiras e são julião da barra, paço de arcos e caxias").
paragem(555,-107479.04447916782,-101162.71630208207,bom,"sem abrigo",no,lt,[116],611,"rua costa pinto","oeiras e são julião da barra, paço de arcos e caxias").
paragem(525,-107487.42,-101137.8,bom,"fechado dos lados",yes,lt,[116],611,"rua costa pinto","oeiras e são julião da barra, paço de arcos e caxias").
paragem(569,-107425.69,-101005.38,bom,"fechado dos lados",yes,lt,[116],614,"praceta dioní­sio matias","oeiras e são julião da barra, paço de arcos e caxias").
paragem(935,-107842.63,-101657.47,bom,"sem abrigo",no,lt,[116],622,"avenida engenheiro bonneville franco","oeiras e são julião da barra, paço de arcos e caxias").
paragem(547,-107742.46,-101446.79,bom,"fechado dos lados",yes,lt,[116],622,"avenida engenheiro bonneville franco","oeiras e são julião da barra, paço de arcos e caxias").
paragem(546,-107715.55,-101440.41,bom,"sem abrigo",no,lt,[116],622,"avenida engenheiro bonneville franco","oeiras e são julião da barra, paço de arcos e caxias").
paragem(545,-107855.7,-101644.74,bom,"fechado dos lados",yes,lt,[116],622,"avenida engenheiro bonneville franco","oeiras e são julião da barra, paço de arcos e caxias").
paragem(987,-107154.05859701223,-100851.89900138501,bom,"fechado dos lados",yes,lt,[116],1569,"avenida senhor jesus dos navegantes","oeiras e são julião da barra, paço de arcos e caxias").
paragem(524,-107115.55,-100887.65,bom,"fechado dos lados",yes,lt,[116],1569,"avenida senhor jesus dos navegantes","oeiras e são julião da barra, paço de arcos e caxias").
paragem(787,-103931.57,-99415.05,bom,"sem abrigo",no,lt,[117],201,"estrada do cacém","barcarena").
paragem(218,-104375.85,-99328.0,bom,"sem abrigo",no,lt,[117],201,"estrada do cacém","barcarena").
paragem(217,-104361.42,-99334.49,bom,"sem abrigo",no,lt,[117],201,"estrada do cacém","barcarena").
paragem(216,-104587.38,-99431.91,bom,"sem abrigo",no,lt,[117],201,"estrada do cacém","barcarena").
paragem(215,-104638.85,-99443.96,bom,"sem abrigo",no,lt,[117],201,"estrada do cacém","barcarena").
paragem(124,-101302.34,-99804.3,bom,"fechado dos lados",no,lt,[117],252,"avenida infante dom henrique","barcarena").
paragem(123,-101315.5,-99829.06,bom,"fechado dos lados",no,lt,[117],252,"avenida infante dom henrique","barcarena").
paragem(117,-101493.79,-99968.88,bom,"fechado dos lados",yes,lt,[117],252,"avenida infante dom henrique","barcarena").
paragem(771,-103918.36,-99410.5,bom,"fechado dos lados",no,lt,[117],256,"rua joaquim sabino de sousa","barcarena").
paragem(769,-103650.67,-99459.31,bom,"fechado dos lados",no,lt,[117],256,"rua joaquim sabino de sousa","barcarena").
paragem(768,-103643.5,-99453.56,bom,"sem abrigo",no,lt,[117],256,"rua joaquim sabino de sousa","barcarena").
paragem(448,-106045.74,-98590.38,bom,"sem abrigo",no,lt,[117],830,"estrada militar","oeiras e são julião da barra, paço de arcos e caxias").
paragem(447,-106415.98,-98591.36,bom,"sem abrigo",no,lt,[117],830,"estrada militar","oeiras e são julião da barra, paço de arcos e caxias").
paragem(446,-106025.83,-98604.24,bom,"sem abrigo",no,lt,[117],830,"estrada militar","oeiras e são julião da barra, paço de arcos e caxias").
paragem(452,-105233.04,-99103.06,bom,"sem abrigo",no,lt,[117],925,"estrada do murganhal","oeiras e são julião da barra, paço de arcos e caxias").
paragem(445,-106027.77,-98850.69,bom,"fechado dos lados",yes,lt,[117],925,"estrada do murganhal","oeiras e são julião da barra, paço de arcos e caxias").
paragem(444,-106017.28,-98852.36,bom,"sem abrigo",no,lt,[117],925,"estrada do murganhal","oeiras e são julião da barra, paço de arcos e caxias").
paragem(322,-105424.33,-99044.64,bom,"fechado dos lados",yes,lt,[117],925,"estrada do murganhal","oeiras e são julião da barra, paço de arcos e caxias").
paragem(321,-105462.35,-99002.28,bom,"fechado dos lados",no,lt,[117],925,"estrada do murganhal","oeiras e são julião da barra, paço de arcos e caxias").
paragem(214,-104907.67,-99367.84,bom,"sem abrigo",no,lt,[117],925,"estrada do murganhal","barcarena").
paragem(450,-106594.42,-99048.6,bom,"sem abrigo",no,lt,[117, 158],882,"rua doutor jorge rivotti","oeiras e são julião da barra, paço de arcos e caxias").
paragem(449,-106581.18,-99035.41,bom,"fechado dos lados",no,lt,[117, 158],882,"rua doutor jorge rivotti","oeiras e são julião da barra, paço de arcos e caxias").
paragem(299,-105855.31,-99342.8,bom,"fechado dos lados",no,lt,[117, 158],1805,"rua dona yesoa godinho","oeiras e são julião da barra, paço de arcos e caxias").
paragem(770,-103163.15,-99786.4,bom,"fechado dos lados",yes,lt,[117, 171],201,"estrada do cacém","barcarena").
paragem(138,-102814.25,-99907.47,mau,"fechado dos lados",no,lt,[117, 171],201,"estrada do cacém","barcarena").
paragem(137,-102792.58,-99921.93,bom,"sem abrigo",no,lt,[117, 171],201,"estrada do cacém","barcarena").
paragem(766,-103346.29,-99565.78,bom,"fechado dos lados",yes,lt,[117, 171],210,"largo cinco de outubro","barcarena").
paragem(767,-103244.97,-99729.51,bom,"fechado dos lados",yes,lt,[117, 171],235,"rua felner duarte","barcarena").
paragem(143,-102122.63,-99975.95,bom,"sem abrigo",no,lt,[117, 171],241,"estrada das fontainhas","barcarena").
paragem(142,-102137.2,-99979.69,bom,"sem abrigo",no,lt,[117, 171],241,"estrada das fontainhas","barcarena").
paragem(140,-102285.58,-100095.76,bom,"sem abrigo",no,lt,[117, 171],241,"estrada das fontainhas","barcarena").
paragem(139,-102277.41,-100088.41,bom,"sem abrigo",no,lt,[117, 171],241,"estrada das fontainhas","barcarena").
paragem(116,-101520.29,-100001.26,bom,"fechado dos lados",yes,carris,[117, 171],252,"avenida infante dom henrique","barcarena").
paragem(691,-103349.27,-99588.57,bom,"sem abrigo",no,lt,[117, 171],964,"jardim público","barcarena").
paragem(141,-102028.47,-99961.71,bom,"sem abrigo",no,lt,[117, 171],978,"avenida de santo antónio de tercena","barcarena").
paragem(122,-102021.07,-99964.5,bom,"sem abrigo",no,lt,[117, 171],978,"avenida de santo antónio de tercena","barcarena").
paragem(121,-101894.85,-100053.16,bom,"sem abrigo",no,lt,[117, 171],978,"avenida de santo antónio de tercena","barcarena").
paragem(120,-101884.83,-100069.82,bom,"fechado dos lados",yes,lt,[117, 171],978,"avenida de santo antónio de tercena","barcarena").
paragem(119,-101709.63,-100014.88,bom,"fechado dos lados",yes,lt,[117, 171],978,"avenida de santo antónio de tercena","barcarena").
paragem(118,-101728.86,-100021.08,bom,"fechado dos lados",no,lt,[117, 171],978,"avenida de santo antónio de tercena","barcarena").
paragem(786,-103718.6,-100106.34,bom,"sem abrigo",no,lt,[119],242,"largo general humberto delgado","barcarena").
paragem(784,-103738.83,-100125.9,bom,"sem abrigo",no,lt,[119],242,"largo general humberto delgado","barcarena").
paragem(772,-103786.35,-100195.03,bom,"sem abrigo",no,lt,[119],244,"rua gil vicente","barcarena").
paragem(783,-103895.41,-100162.43,bom,"sem abrigo",no,lt,[119],274,"rua do moinho","barcarena").
paragem(1018,-107041.77476893747,-101229.91096074758,bom,"sem abrigo",no,lt,[119],620,"avenida elvira velez","oeiras e são julião da barra, paço de arcos e caxias").
paragem(694,-104519.7809297323,-100793.13013878663,bom,"sem abrigo",no,lt,[119],679,"rua artur moura","porto salvo").
paragem(731,-103012.13,-102009.23,bom,"sem abrigo",no,lt,[119],711,"rua fernando sabido","porto salvo").
paragem(782,-103699.86,-100194.78,bom,"fechado dos lados",yes,lt,[119],1001,"rua da fonte","barcarena").
paragem(222,-104759.2,-100697.28,bom,"sem abrigo",no,lt,[119],1640,"avenida vinte e cinco de abril","porto salvo").
paragem(213,-104589.54,-100696.1,bom,"fechado dos lados",no,lt,[119],1640,"avenida vinte e cinco de abril","porto salvo").
paragem(707,-102002.37,-102008.48,bom,"fechado dos lados",no,lt,[119],1668,"avenida engenheiro valente de oliveira","porto salvo").
paragem(132,-102642.99,-102233.26,bom,"sem abrigo",no,lt,[119],1668,"avenida engenheiro valente de oliveira","porto salvo").
paragem(99,-101995.52,-102016.59,bom,"fechado dos lados",no,lt,[119],1668,"avenida engenheiro valente de oliveira","porto salvo").
paragem(130,-102992.86,-102011.13,bom,"sem abrigo",no,lt,[119],1670,"avenida domingos vandelli","porto salvo").
paragem(725,-102556.6,-102172.39,bom,"sem abrigo",no,lt,[119],1671,"rua professor dr. josé pinto peixoto","porto salvo").
paragem(441,-107020.04,-100736.2,bom,"fechado dos lados",yes,lt,[119, 115],605,"rua conde das alcáçovas","oeiras e são julião da barra, paço de arcos e caxias").
paragem(750,-103210.92,-101837.0,bom,"fechado dos lados",no,lt,[119, 125],1634,"estrada de talaí­de","porto salvo").
paragem(749,-103174.51,-101870.25,bom,"sem abrigo",no,lt,[119, 125],1634,"estrada de talaí­de","porto salvo").
paragem(748,-103481.37,-101650.92,bom,"fechado dos lados",no,lt,[119, 125],1634,"estrada de talaí­de","porto salvo").
paragem(757,-103529.69,-101634.82,bom,"sem abrigo",no,lt,[119, 125],1661,"rua henrique marques","porto salvo").
paragem(98,-101970.18,-101783.3,bom,"sem abrigo",no,lt,[119, 125],1667,"avenida professor dr. cavaco silva","porto salvo").
paragem(97,-101959.47,-101795.46,bom,"sem abrigo",no,lt,[119, 125],1667,"avenida professor dr. cavaco silva","porto salvo").
paragem(389,-106757.03,-100945.88,bom,"fechado dos lados",yes,lt,[119, 125, 129, 158, 184],1540,"estrada de paço de arcos","oeiras e são julião da barra, paço de arcos e caxias").
paragem(388,-106176.2,-101085.06,bom,"fechado dos lados",yes,lt,[119, 125, 129, 158, 184],1540,"estrada de paço de arcos","oeiras e são julião da barra, paço de arcos e caxias").
paragem(387,-106378.14,-101089.06,bom,"fechado dos lados",yes,lt,[119, 125, 129, 158, 184],1540,"estrada de paço de arcos","oeiras e são julião da barra, paço de arcos e caxias").
paragem(386,-106385.21,-101073.57,bom,"sem abrigo",no,lt,[119, 125, 129, 158, 184],1540,"estrada de paço de arcos","oeiras e são julião da barra, paço de arcos e caxias").
paragem(385,-106674.29,-100994.88,bom,"fechado dos lados",yes,lt,[119, 125, 129, 158, 184],1540,"estrada de paço de arcos","oeiras e são julião da barra, paço de arcos e caxias").
paragem(1004,-105463.93407291333,-101208.08123805858,bom,"fechado dos lados",yes,lt,[119, 125, 129, 184],1540,"estrada de paço de arcos","oeiras e são julião da barra, paço de arcos e caxias").
paragem(290,-105761.18,-101097.27,bom,"fechado dos lados",yes,lt,[119, 125, 129, 184],1540,"estrada de paço de arcos","oeiras e são julião da barra, paço de arcos e caxias").
paragem(288,-106033.78,-101107.92,bom,"fechado dos lados",yes,lt,[119, 125, 129, 184],1540,"estrada de paço de arcos","oeiras e são julião da barra, paço de arcos e caxias").
paragem(287,-105447.82,-101232.23,bom,"fechado dos lados",yes,lt,[119, 125, 129, 184],1540,"estrada de paço de arcos","oeiras e são julião da barra, paço de arcos e caxias").
paragem(289,-105894.4,-101171.62,bom,"fechado dos lados",yes,lt,[119, 125, 129, 184],1596,"rua shegundo galarza","oeiras e são julião da barra, paço de arcos e caxias").
paragem(277,-105302.37,-101111.62,bom,"fechado dos lados",no,lt,[119, 184],70,"rua actor antónio pinheiro","porto salvo").
paragem(276,-105287.53,-101100.79,bom,"sem abrigo",no,lt,[119, 184],70,"rua actor antónio pinheiro","porto salvo").
paragem(259,-104635.54,-100919.19,bom,"fechado dos lados",yes,lt,[119, 184],685,"rua carlos paião","porto salvo").
paragem(258,-105092.32,-100957.4,bom,"sem abrigo",no,carris,[119, 184],1640,"avenida vinte e cinco de abril","porto salvo").
paragem(257,-105076.45,-100946.89,bom,"sem abrigo",no,lt,[119, 184],1640,"avenida vinte e cinco de abril","porto salvo").
paragem(109,-104899.42,-100859.7,bom,"fechado dos lados",no,lt,[119, 184],1640,"avenida vinte e cinco de abril","porto salvo").
paragem(108,-104913.48,-100837.78,bom,"fechado dos lados",no,lt,[119, 184],1640,"avenida vinte e cinco de abril","porto salvo").
paragem(34,-105634.78,-95513.74,bom,"fechado dos lados",yes,vimeca,[12],120,"avenida jaime cortesão","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(22,-105577.35,-95503.97,bom,"fechado dos lados",yes,vimeca,[12],120,"avenida jaime cortesão","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(25,-105539.98,-95177.67,bom,"sem abrigo",no,vimeca,[12],148,"avenida das túlipas","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(24,-105556.38,-95196.87,bom,"fechado dos lados",yes,vimeca,[12],148,"avenida das túlipas","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(714,-101949.9,-98542.91,bom,"fechado dos lados",yes,vimeca,[12],216,"estrada consiglieri pedroso","barcarena").
paragem(713,-101787.42,-98423.54,bom,"fechado dos lados",yes,vimeca,[12],216,"estrada consiglieri pedroso","barcarena").
paragem(712,-101764.30649856283,-98424.15159847475,bom,"sem abrigo",no,scotturb,[12],216,"estrada consiglieri pedroso","barcarena").
paragem(153,-102409.39,-98701.67,bom,"fechado dos lados",yes,vimeca,[12],269,"rua mário castelhano","barcarena").
paragem(806,-104169.05,-97108.82,bom,"sem abrigo",no,vimeca,[12],308,"estrada do desvio","carnaxide e queijas").
paragem(687,-102942.61,-98628.76,bom,"fechado dos lados",yes,vimeca,[12],830,"estrada militar","barcarena").
paragem(686,-102931.23,-98622.69,bom,"sem abrigo",no,vimeca,[12],830,"estrada militar","barcarena").
paragem(155,-102735.06,-98272.9,mau,"fechado dos lados",no,vimeca,[12],830,"estrada militar","barcarena").
paragem(154,-103016.79,-98428.89,bom,"fechado dos lados",yes,vimeca,[12],830,"estrada militar","barcarena").
paragem(87,-103002.83,-98398.75,bom,"aberto dos lados",no,vimeca,[12],830,"estrada militar","barcarena").
paragem(149,-102638.72,-98781.31,bom,"sem abrigo",no,vimeca,[12],993,"rua do trabalho","barcarena").
paragem(159,-102708.54,-98296.07,bom,"sem abrigo",no,vimeca,[12],1099,"rua quinta da bica do sargento","barcarena").
paragem(709,-103166.65231804183,-97987.56576748956,bom,"sem abrigo",no,vimeca,[12],1200,"rua actor carlos césar","carnaxide e queijas").
paragem(1014,-103181.82,-97967.06,bom,"sem abrigo",no,vimeca,[12],1214,"estrada de queluz","carnaxide e queijas").
paragem(788,-103468.05,-97872.21,bom,"fechado dos lados",yes,vimeca,[12],1214,"estrada de queluz","carnaxide e queijas").
paragem(742,-102859.54,-97965.24,bom,"fechado dos lados",yes,vimeca,[12],1214,"estrada de queluz","carnaxide e queijas").
paragem(741,-102845.12,-97961.08,bom,"sem abrigo",no,vimeca,[12],1214,"estrada de queluz","carnaxide e queijas").
paragem(170,-103478.11,-97851.67,bom,"sem abrigo",no,vimeca,[12],1214,"estrada de queluz","carnaxide e queijas").
paragem(68,-103193.0811132861,-97956.29135098259,bom,"sem abrigo",no,vimeca,[12],1214,"estrada de queluz","carnaxide e queijas").
paragem(128,-101966.52,-98573.78,bom,"fechado dos lados",yes,vimeca,[12, 2, 6, 13],216,"estrada consiglieri pedroso","barcarena").
paragem(212,-104337.69,-101982.34,bom,"sem abrigo",no,lt,[122],1631,"rua sete de junho","porto salvo").
paragem(201,-104367.8,-102011.46,bom,"sem abrigo",no,lt,[122],1631,"rua sete de junho","porto salvo").
paragem(746,-103402.21,-102780.0,bom,"sem abrigo",no,lt,[122],1652,"avenida diogo lopes de sequeira","porto salvo").
paragem(165,-103427.95,-102788.2,bom,"fechado dos lados",no,lt,[122],1652,"avenida diogo lopes de sequeira","porto salvo").
paragem(164,-103464.95,-102647.48,bom,"fechado dos lados",no,lt,[122],1652,"avenida diogo lopes de sequeira","porto salvo").
paragem(163,-103452.97,-102640.79,bom,"fechado dos lados",no,lt,[122],1652,"avenida diogo lopes de sequeira","porto salvo").
paragem(747,-103418.71,-102966.92,bom,"fechado dos lados",no,carris,[122],1653,"avenida gaspar corte real","porto salvo").
paragem(198,-104273.72,-102318.75,bom,"sem abrigo",no,lt,[122, 125, 129, 184],695,"avenida dom pedro v","porto salvo").
paragem(207,-104333.51,-102157.13,bom,"aberto dos lados",no,lt,[122, 125, 129, 184],705,"avenida engenheiro arantes e oliveira","porto salvo").
paragem(199,-104309.46,-102333.17,bom,"fechado dos lados",no,lt,[122, 125, 184],705,"avenida engenheiro arantes e oliveira","porto salvo").
paragem(761,-103589.75,-102328.21,bom,"sem abrigo",no,lt,[122, 125, 184],1651,"avenida lopo soares de albergaria","porto salvo").
paragem(760,-103595.2,-102342.08,bom,"fechado dos lados",no,lt,[122, 125, 184],1651,"avenida lopo soares de albergaria","porto salvo").
paragem(759,-103754.86,-102383.62,bom,"sem abrigo",no,lt,[122, 125, 184],1692,"rua augusta","porto salvo").
paragem(758,-103782.6,-102354.54,bom,"fechado dos lados",no,lt,[122, 125, 184],1692,"rua augusta","porto salvo").
paragem(204,-104054.48,-102333.36,bom,"fechado dos lados",no,lt,[122, 125, 184],1692,"rua augusta","porto salvo").
paragem(203,-104060.31,-102343.26,bom,"sem abrigo",no,lt,[122, 125, 184],1692,"rua augusta","porto salvo").
paragem(166,-104013.89,-102412.58,bom,"sem abrigo",no,lt,[122, 125, 184],1698,"rua de são josé","porto salvo").
paragem(197,-104911.17,-102075.08,bom,"sem abrigo",no,lt,[122, 129],687,"rua do casal do deserto","porto salvo").
paragem(196,-104948.14,-102024.5,bom,"sem abrigo",no,lt,[122, 129],687,"rua do casal do deserto","porto salvo").
paragem(269,-105203.57,-102507.02,bom,"sem abrigo",no,lt,[122, 129],755,"rua oliveira martins","porto salvo").
paragem(268,-105213.17,-102489.26,bom,"fechado dos lados",yes,lt,[122, 129],755,"rua oliveira martins","porto salvo").
paragem(189,-104980.0,-102444.39,bom,"sem abrigo",no,lt,[122, 129],755,"rua oliveira martins","porto salvo").
paragem(188,-104998.59,-102447.95,bom,"sem abrigo",no,lt,[122, 129],755,"rua oliveira martins","porto salvo").
paragem(211,-104613.4385006046,-102059.62741233375,bom,"sem abrigo",no,lt,[122, 129],1611,"rua das portelas","porto salvo").
paragem(202,-104559.73,-102074.01,bom,"fechado dos lados",no,lt,[122, 129],1611,"rua das portelas","porto salvo").
paragem(195,-104888.12,-101925.58,bom,"sem abrigo",no,lt,[122, 129],1611,"rua das portelas","porto salvo").
paragem(194,-104887.93,-101935.17,bom,"sem abrigo",no,lt,[122, 129],1611,"rua das portelas","porto salvo").
paragem(200,-104420.26,-102140.16,bom,"sem abrigo",no,lt,[122, 129],1631,"rua sete de junho","porto salvo").
paragem(206,-104352.88,-102155.61,bom,"fechado dos lados",no,lt,[122, 129, 184],690,"rua do comércio","porto salvo").
paragem(440,-106999.56,-100744.24,bom,"fechado dos lados",yes,lt,[125, 129, 158, 184],605,"rua conde das alcáçovas","oeiras e são julião da barra, paço de arcos e caxias").
paragem(210,-104329.45,-101849.83,bom,"sem abrigo",no,lt,[125, 129, 184],705,"avenida engenheiro arantes e oliveira","porto salvo").
paragem(209,-104318.74,-101876.43,bom,"aberto dos lados",no,lt,[125, 129, 184],705,"avenida engenheiro arantes e oliveira","porto salvo").
paragem(753,-103040.03,-102067.93,bom,"fechado dos lados",yes,lt,[125, 184],1634,"estrada de talaí­de","porto salvo").
paragem(730,-102764.70414054944,-102345.36371072767,bom,"sem abrigo",no,lt,[125, 184],1634,"estrada de talaí­de","porto salvo").
paragem(721,-103007.51,-102085.97,bom,"fechado dos lados",yes,lt,[125, 184],1634,"estrada de talaí­de","porto salvo").
paragem(133,-102770.03,-102362.19,bom,"fechado dos lados",no,lt,[125, 184],1634,"estrada de talaí­de","porto salvo").
paragem(558,-107118.74,-101197.15,bom,"fechado dos lados",no,lt,[129, 115, 125, 158],1527,"rua manuel pinhanços","oeiras e são julião da barra, paço de arcos e caxias").
paragem(279,-105866.72,-100896.59,bom,"fechado dos lados",yes,lt,[129, 184],858,"rua calvet de magalhães","oeiras e são julião da barra, paço de arcos e caxias").
paragem(205,-104431.06,-101723.48,bom,"fechado dos lados",yes,vimeca,[15],692,"rua conde de rio maior","porto salvo").
paragem(193,-104911.86,-101688.38,bom,"fechado dos lados",yes,vimeca,[15],692,"rua conde de rio maior","porto salvo").
paragem(192,-104730.80639856319,-101677.18184016421,bom,"sem abrigo",no,vimeca,[15],692,"rua conde de rio maior","porto salvo").
paragem(190,-104741.4,-101691.52,bom,"fechado dos lados",yes,scotturb,[15],692,"rua conde de rio maior","porto salvo").
paragem(798,-104277.99,-101693.69,bom,"fechado dos lados",yes,vimeca,[15],735,"estrada de leião","porto salvo").
paragem(763,-103544.73,-101579.29,bom,"fechado dos lados",no,vimeca,[15],735,"estrada de leião","porto salvo").
paragem(754,-103586.35,-101579.63,bom,"fechado dos lados",yes,vimeca,[15],735,"estrada de leião","porto salvo").
paragem(314,-105206.62,-98321.51,bom,"fechado dos lados",yes,vimeca,[15],830,"estrada militar","carnaxide e queijas").
paragem(280,-105520.95,-101295.9,bom,"fechado dos lados",yes,vimeca,[15],1488,"avenida conselho da europa","oeiras e são julião da barra, paço de arcos e caxias").
paragem(278,-105488.63,-101308.47,bom,"fechado dos lados",yes,vimeca,[15],1488,"avenida conselho da europa","oeiras e são julião da barra, paço de arcos e caxias").
paragem(286,-105046.86,-101627.86,bom,"fechado dos lados",yes,scotturb,[15],1540,"estrada de paço de arcos","porto salvo").
paragem(728,-102509.72,-101859.8,bom,"fechado dos lados",yes,vimeca,[15],1667,"avenida professor dr. cavaco silva","porto salvo").
paragem(724,-102849.51,-101421.76,bom,"fechado dos lados",yes,vimeca,[15],1667,"avenida professor dr. cavaco silva","porto salvo").
paragem(270,-105268.41,-102428.49,bom,"fechado dos lados",yes,vimeca,[15],1680,"rua encosta das lagoas","porto salvo").
paragem(295,-105236.25,-102190.54,bom,"fechado dos lados",yes,vimeca,[15],1682,"avenida santa casa da misericordia de oeiras","porto salvo").
paragem(293,-105274.84,-101913.18,bom,"fechado dos lados",yes,vimeca,[15],1682,"avenida santa casa da misericordia de oeiras","porto salvo").
paragem(292,-105227.47,-102176.58,bom,"fechado dos lados",yes,vimeca,[15],1682,"avenida santa casa da misericordia de oeiras","porto salvo").
paragem(291,-105291.98,-101912.29,bom,"fechado dos lados",yes,vimeca,[15],1682,"avenida santa casa da misericordia de oeiras","porto salvo").
paragem(719,-102227.22,-101894.71,bom,"fechado dos lados",yes,vimeca,[15],1667,"avenida professor dr. cavaco silva","porto salvo").
paragem(729,-102515.87,-101878.09,bom,"fechado dos lados",yes,vimeca,[15, 23],1667,"avenida professor dr. cavaco silva","porto salvo").
paragem(718,-102227.55,-101920.36,bom,"fechado dos lados",yes,vimeca,[15, 23],1667,"avenida professor dr. cavaco silva","porto salvo").
paragem(706,-101856.51,-101822.02,bom,"fechado dos lados",yes,vimeca,[15, 23],1667,"avenida professor dr. cavaco silva","porto salvo").
paragem(703,-101884.93,-101826.65,bom,"fechado dos lados",yes,vimeca,[15, 23],1667,"avenida professor dr. cavaco silva","porto salvo").
paragem(129,-102865.58,-101399.39,bom,"fechado dos lados",yes,vimeca,[15, 23],1667,"avenida professor dr. cavaco silva","porto salvo").
paragem(406,-106251.97,-101287.62,bom,"fechado dos lados",yes,lt,[158],637,"avenida dos fundadores","oeiras e são julião da barra, paço de arcos e caxias").
paragem(405,-106237.68,-101291.27,bom,"fechado dos lados",yes,lt,[158],637,"avenida dos fundadores","oeiras e são julião da barra, paço de arcos e caxias").
paragem(400,-106447.18,-101426.26,bom,"fechado dos lados",yes,lt,[158],637,"avenida dos fundadores","oeiras e são julião da barra, paço de arcos e caxias").
paragem(397,-106091.14,-101154.18,bom,"fechado dos lados",yes,lt,[158],637,"avenida dos fundadores","oeiras e são julião da barra, paço de arcos e caxias").
paragem(396,-106081.08,-101165.77,bom,"fechado dos lados",yes,lt,[158],637,"avenida dos fundadores","oeiras e são julião da barra, paço de arcos e caxias").
paragem(395,-106446.17,-101412.04,bom,"fechado dos lados",yes,lt,[158],637,"avenida dos fundadores","oeiras e são julião da barra, paço de arcos e caxias").
paragem(296,-105981.14,-99626.06,bom,"sem abrigo",no,lt,[158],850,"rua antónio pires","oeiras e são julião da barra, paço de arcos e caxias").
paragem(443,-106400.89,-99913.2,bom,"aberto dos lados",no,lt,[158],853,"rua bartolomeu dias","oeiras e são julião da barra, paço de arcos e caxias").
paragem(305,-105957.65,-99532.97,bom,"sem abrigo",no,lt,[158],858,"rua calvet de magalhães","oeiras e são julião da barra, paço de arcos e caxias").
paragem(304,-105812.82,-99920.11,bom,"sem abrigo",no,lt,[158],858,"rua calvet de magalhães","oeiras e são julião da barra, paço de arcos e caxias").
paragem(303,-105819.47,-99953.55,bom,"sem abrigo",no,lt,[158],858,"rua calvet de magalhães","oeiras e são julião da barra, paço de arcos e caxias").
paragem(433,-106203.75,-99942.88,bom,"aberto dos lados",no,lt,[158],863,"rua dos cedros","oeiras e são julião da barra, paço de arcos e caxias").
paragem(884,-106100.40608156208,-99324.93367751369,bom,"sem abrigo",no,lt,[158],871,"rua dom francisco de almeida","oeiras e são julião da barra, paço de arcos e caxias").
paragem(298,0.0,0.0,bom,"aberto dos lados",no,lt,[158],890,"rua fernando vaz","oeiras e são julião da barra, paço de arcos e caxias").
paragem(297,-105936.26,-99903.99,bom,"aberto dos lados",no,lt,[158],890,"rua fernando vaz","oeiras e são julião da barra, paço de arcos e caxias").
paragem(410,-106940.98,-99253.35,bom,"fechado dos lados",no,lt,[158],898,"estrada da gibalta","oeiras e são julião da barra, paço de arcos e caxias").
paragem(275,-106970.5,-99227.97,bom,"fechado dos lados",yes,lt,[158],898,"estrada da gibalta","oeiras e são julião da barra, paço de arcos e caxias").
paragem(316,-105973.13,-98916.25,bom,"fechado dos lados",yes,lt,[158],925,"estrada do murganhal","oeiras e são julião da barra, paço de arcos e caxias").
paragem(308,-105439.02,-99406.0,bom,"fechado dos lados",no,lt,[158],932,"rua da pedreira italiana","oeiras e são julião da barra, paço de arcos e caxias").
paragem(307,-105549.91,-99320.86,bom,"sem abrigo",no,lt,[158],932,"rua da pedreira italiana","oeiras e são julião da barra, paço de arcos e caxias").
paragem(434,-106212.36,-99846.22,bom,"aberto dos lados",no,lt,[158],933,"rua pêro de alenquer","oeiras e são julião da barra, paço de arcos e caxias").
paragem(430,-106489.64,-99992.66,bom,"aberto dos lados",no,lt,[158],933,"rua pêro de alenquer","oeiras e são julião da barra, paço de arcos e caxias").
paragem(219,-104719.91,-99745.14,bom,"sem abrigo",no,lt,[158],1013,"rua quinta da moura","barcarena").
paragem(221,-104939.44,-99815.59,bom,"sem abrigo",no,lt,[158],1014,"rua do castelo","barcarena").
paragem(220,-104914.0,-99807.09,bom,"sem abrigo",no,lt,[158],1014,"rua do castelo","barcarena").
paragem(301,-105137.41,-99828.18,bom,"sem abrigo",no,lt,[158],1018,"rua do alto da peça","barcarena").
paragem(300,-105118.79,-99818.36,bom,"sem abrigo",no,lt,[158],1018,"rua do alto da peça","barcarena").
paragem(826,-105726.06,-102732.3,bom,"fechado dos lados",yes,lt,[158],1521,"estrada da ribeira da laje","porto salvo").
paragem(1005,-105735.17290016402,-100578.1564002752,bom,"sem abrigo",no,lt,[158],1578,"rua manuel viegas guerreiro","oeiras e são julião da barra, paço de arcos e caxias").
paragem(306,-105860.41,-100520.47,bom,"sem abrigo",no,lt,[158],1578,"rua manuel viegas guerreiro","oeiras e são julião da barra, paço de arcos e caxias").
paragem(302,-105785.16,-100273.12,bom,"sem abrigo",no,lt,[158],1585,"avenida antónio sena da silva","oeiras e são julião da barra, paço de arcos e caxias").
paragem(833,-105686.35894762371,-100239.52088707738,bom,"sem abrigo",no,lt,[158],1605,"avenida professor antónio maria baptista fernandes","oeiras e são julião da barra, paço de arcos e caxias").
paragem(438,-106599.44,-99556.41,bom,"aberto dos lados",no,lt,[158],1769,"rua vasco da gama","oeiras e são julião da barra, paço de arcos e caxias").
paragem(311,-105814.63,-99290.4,bom,"fechado dos lados",yes,lt,[158],1801,"rua viscondessa de santo amaro","oeiras e são julião da barra, paço de arcos e caxias").
paragem(669,-106112.38652897865,-95027.7101712073,bom,"fechado dos lados",yes,lt,[162],10,"avenida dos bombeiros voluntários de algés","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(678,-106071.42513405527,-95039.14634930693,bom,"fechado dos lados",yes,lt,[162],10,"avenida dos bombeiros voluntários de algés","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(674,-106560.62,-95186.03,bom,"fechado dos lados",yes,lt,[162],10,"avenida dos bombeiros voluntários de algés","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(668,-106342.5,-95131.58,bom,"fechado dos lados",yes,lt,[162],10,"avenida dos bombeiros voluntários de algés","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(76,-106288.85,-95136.57,bom,"fechado dos lados",yes,lt,[162],10,"avenida dos bombeiros voluntários de algés","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(73,-106568.5,-95165.9,bom,"fechado dos lados",yes,lt,[162],10,"avenida dos bombeiros voluntários de algés","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(528,-107089.71,-95214.56,bom,"fechado dos lados",yes,lt,[162],102,"largo dom manuel i","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(639,-105456.01,-94993.65,bom,"fechado dos lados",yes,lt,[162],116,"avenida general norton de matos","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(636,-105462.27,-94976.17,bom,"fechado dos lados",yes,lt,[162],116,"avenida general norton de matos","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(634,-105696.83,-95075.27,bom,"fechado dos lados",yes,lt,[162],116,"avenida general norton de matos","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(12,-105655.76,-95028.52,bom,"fechado dos lados",yes,lt,[162],116,"avenida general norton de matos","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(666,-106799.63,-95251.22,bom,"sem abrigo",no,lt,[162],155,"praça doutor manuel martins","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(658,-106786.85846811837,-95149.7421827531,bom,"fechado dos lados",yes,lt,[162],155,"praça doutor manuel martins","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(630,-104458.04,-94329.86,bom,"fechado dos lados",no,lt,[162],1123,"rua da quinta do paizinho","carnaxide e queijas").
paragem(629,-104278.88666597521,-94122.56603635015,bom,"sem abrigo",no,lt,[162],1123,"rua da quinta do paizinho","carnaxide e queijas").
paragem(626,-104287.85,-94105.37,bom,"fechado dos lados",yes,lt,[162],1123,"rua da quinta do paizinho","carnaxide e queijas").
paragem(616,-104497.842173306,-94358.908881103,bom,"fechado dos lados",yes,lt,[162],1123,"rua da quinta do paizinho","carnaxide e queijas").
paragem(228,-104460.75,-98562.29,bom,"sem abrigo",no,lt,[171],83,"rua angra do heroí­smo","carnaxide e queijas").
paragem(105,-101764.82,-99761.18,bom,"fechado dos lados",yes,lt,[171],261,"rua da juventude","barcarena").
paragem(104,-101753.46,-99755.19,bom,"fechado dos lados",yes,lt,[171],261,"rua da juventude","barcarena").
paragem(225,-104591.62,-98511.89,bom,"sem abrigo",no,lt,[171],846,"rua da quinta do bonfim","carnaxide e queijas").
paragem(1012,-101927.83891266519,-99709.84354381096,bom,"sem abrigo",no,lt,[171],1006,"rua antónio quadros","barcarena").
paragem(115,-101877.84,-99707.56,bom,"sem abrigo",no,lt,[171],1006,"rua antónio quadros","barcarena").
paragem(765,-103522.68,-99425.21,bom,"fechado dos lados",yes,lt,[171, 117],230,"rua elias garcia","barcarena").
paragem(764,-103545.91,-99424.63,bom,"sem abrigo",no,lt,[171, 117],230,"rua elias garcia","barcarena").
paragem(110,-104942.33,-101650.59,bom,"sem abrigo",no,lt,[184],697,"avenida dos descobrimentos","porto salvo").
paragem(113,-104747.63,-101297.99,bom,"sem abrigo",no,lt,[184],703,"rua doutor josé filipe rodrigues","porto salvo").
paragem(112,-104759.55,-101277.77,bom,"sem abrigo",no,lt,[184],703,"rua doutor josé filipe rodrigues","porto salvo").
paragem(111,-104852.21,-101412.86,bom,"sem abrigo",no,lt,[184],703,"rua doutor josé filipe rodrigues","porto salvo").
paragem(114,-104842.95,-101406.66,bom,"sem abrigo",no,lt,[184],756,"pateo das padeiras","porto salvo").
paragem(633,-105696.83,-95075.27,bom,"fechado dos lados",yes,carris,[201, 748, 750, 751],116,"avenida general norton de matos","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(15,-105325.87,-95135.44,bom,"fechado dos lados",yes,carris,[201, 748, 751],113,"alameda ferno lopes","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(54,-105456.01,-94993.65,bom,"fechado dos lados",yes,carris,[201, 748, 750, 751],116,"avenida general norton de matos","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(645,-105353.27,-95172.19,bom,"fechado dos lados",yes,carris,[201, 748, 751],113,"alameda ferno lopes","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(651,-105300.44,-95336.46,bom,"fechado dos lados",yes,carris,[201, 748, 751],113,"alameda ferno lopes","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(650,-105259.11583333602,-95350.71833333441,bom,"sem abrigo",no,carris,[201, 748, 751],113,"alameda ferno lopes","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(13,-105268.05,-95547.68,bom,"fechado dos lados",yes,carris,[201, 748, 751],124,"avenida josé gomes ferreira","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(23,-105261.03,-95520.31,bom,"sem abrigo",no,carris,[201, 748, 751],124,"avenida josé gomes ferreira","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(11,-105158.82133137222,-95894.13861202101,bom,"fechado dos lados",yes,carris,[201, 748, 751],416,"alameda antónio sérgio","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(673,-106563.02096789006,-95186.78384945756,bom,"sem abrigo",no,carris,[201, 750, 751],10,"avenida dos bombeiros voluntários de algés","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(670,-106112.38652897863,-95027.71017120728,bom,"fechado dos lados",yes,carris,[201, 750, 751],10,"avenida dos bombeiros voluntários de algés","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(677,-106071.42513405527,-95039.14634930693,bom,"fechado dos lados",yes,carris,[201, 750, 751],10,"avenida dos bombeiros voluntários de algés","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(676,-106283.09180093784,-95136.51301607292,bom,"sem abrigo",yes,carris,[201, 750, 751],10,"avenida dos bombeiros voluntários de algés","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(667,-106342.5,-95131.58,bom,"fechado dos lados",yes,carris,[201, 750, 751],10,"avenida dos bombeiros voluntários de algés","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(656,-106786.85846811837,-95149.7421827531,bom,"fechado dos lados",yes,carris,[201, 750, 751],155,"praça doutor manuel martins","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(69,-106799.79,-95252.14,bom,"sem abrigo",no,carris,[201, 750, 751],155,"praça doutor manuel martins","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(640,-105655.76,-95028.52,bom,"fechado dos lados",yes,carris,[201, 751],116,"avenida general norton de matos","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(53,-105462.27,-94976.17,bom,"fechado dos lados",yes,carris,[201, 751],116,"avenida general norton de matos","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(100,-102002.37,-102008.48,bom,"fechado dos lados",no,vimeca,[23],1668,"avenida engenheiro valente de oliveira","porto salvo").
paragem(720,-103014.4,-101951.36,bom,"fechado dos lados",no,vimeca,[23],1670,"avenida domingos vandelli","porto salvo").
paragem(131,-102556.6,-102172.39,bom,"sem abrigo",no,vimeca,[23],1671,"rua professor dr. josé pinto peixoto","porto salvo").
paragem(393,-106368.26,-101705.73,bom,"sem abrigo",yes,vimeca,[30],587,"avenida antónio bernardo cabral de macedo","oeiras e são julião da barra, paço de arcos e caxias").
paragem(923,-107625.08,-103117.77,bom,"fechado dos lados",no,vimeca,[30],1431,"avenida salvador allende","oeiras e são julião da barra, paço de arcos e caxias").
paragem(921,-107096.82640151314,-103853.54646127204,bom,"sem abrigo",no,scotturb,[467],1404,"rua norton de matos","oeiras e são julião da barra, paço de arcos e caxias").
paragem(523,-107058.08,-103860.82,bom,"sem abrigo",no,scotturb,[467],1404,"rua norton de matos","oeiras e são julião da barra, paço de arcos e caxias").
paragem(513,-107854.63,-102915.29,bom,"fechado dos lados",yes,scotturb,[467, 468, 470, 479, 485, 489],1422,"rua da quinta grande","oeiras e são julião da barra, paço de arcos e caxias").
paragem(509,-107387.31,-103679.6,bom,"fechado dos lados",yes,scotturb,[467, 468, 479],1426,"avenida da república","oeiras e são julião da barra, paço de arcos e caxias").
paragem(508,-107491.16,-103120.89,bom,"fechado dos lados",yes,scotturb,[467, 468, 479],1426,"avenida da república","oeiras e são julião da barra, paço de arcos e caxias").
paragem(507,-107368.48,-103668.54,bom,"fechado dos lados",no,scotturb,[467, 468, 479],1426,"avenida da república","oeiras e são julião da barra, paço de arcos e caxias").
paragem(924,-107625.08,-103117.77,bom,"fechado dos lados",no,scotturb,[467, 468, 479, 471],1431,"avenida salvador allende","oeiras e são julião da barra, paço de arcos e caxias").
paragem(495,-107142.69,-103759.12,bom,"fechado dos lados",yes,scotturb,[467, 479],1421,"rotunda da quinta do marquês","oeiras e são julião da barra, paço de arcos e caxias").
paragem(263,-107314.88,-104013.15,bom,"fechado dos lados",yes,scotturb,[468, 470, 485, 489],1426,"avenida da república","oeiras e são julião da barra, paço de arcos e caxias").
paragem(262,-107284.78,-104045.09,bom,"fechado dos lados",yes,scotturb,[468, 470, 485, 489],1426,"avenida da república","oeiras e são julião da barra, paço de arcos e caxias").
paragem(372,-107025.86,-103844.74,bom,"sem abrigo",no,scotturb,[470, 479, 485, 489],1338,"avenida gonçalves zarco","carcavelos").
paragem(267,-105726.06,-102732.3,bom,"fechado dos lados",yes,scotturb,[470, 485],1521,"estrada da ribeira da laje","porto salvo").
paragem(927,-107720.8493590646,-103624.00113664303,bom,"sem abrigo",no,scotturb,[470, 485, 489],550,"alameda conde de oeiras","oeiras e são julião da barra, paço de arcos e caxias").
paragem(515,-107839.61,-103572.1,bom,"sem abrigo",no,scotturb,[470, 485, 489],550,"alameda conde de oeiras","oeiras e são julião da barra, paço de arcos e caxias").
paragem(520,-107795.85,-103878.54,bom,"fechado dos lados",yes,scotturb,[470, 485, 489],557,"avenida dom josé i","oeiras e são julião da barra, paço de arcos e caxias").
paragem(519,-107802.03,-103891.09,bom,"sem abrigo",no,scotturb,[470, 485, 489],557,"avenida dom josé i","oeiras e são julião da barra, paço de arcos e caxias").
paragem(265,-107430.38,-103996.06,bom,"fechado dos lados",yes,scotturb,[470, 485, 489],557,"avenida dom josé i","oeiras e são julião da barra, paço de arcos e caxias").
paragem(264,-107670.49,-103999.05,bom,"fechado dos lados",yes,scotturb,[470, 485, 489],557,"avenida dom josé i","oeiras e são julião da barra, paço de arcos e caxias").
paragem(512,-107836.26,-103714.18,bom,"fechado dos lados",yes,scotturb,[470, 485, 489],569,"rua doutor josé carlos moreira","oeiras e são julião da barra, paço de arcos e caxias").
paragem(511,-107822.87,-103711.43,bom,"sem abrigo",no,scotturb,[470, 485, 489],569,"rua doutor josé carlos moreira","oeiras e são julião da barra, paço de arcos e caxias").
paragem(556,-107825.00067489177,-103153.47411185557,bom,"sem abrigo",no,scotturb,[470, 485, 489],1422,"rua da quinta grande","oeiras e são julião da barra, paço de arcos e caxias").
paragem(522,-107811.57,-103173.61,bom,"fechado dos lados",yes,scotturb,[470, 485, 489],1422,"rua da quinta grande","oeiras e são julião da barra, paço de arcos e caxias").
paragem(500,-107558.36,-103601.65,bom,"fechado dos lados",yes,scotturb,[470, 485, 489],1516,"rua monsenhor ferreira de melo","oeiras e são julião da barra, paço de arcos e caxias").
paragem(825,-107055.50456594216,-104067.91249783144,bom,"sem abrigo",no,scotturb,[470, 485, 489, 467, 475, 479],1338,"avenida gonçalves zarco","carcavelos").
paragem(824,-107062.58,-104020.28,bom,"fechado dos lados",no,scotturb,[470, 485, 489, 467, 479],1338,"avenida gonçalves zarco","carcavelos").
paragem(587,-108937.83,-103208.76,razoavel,"fechado dos lados",yes,scotturb,[471],491,"rua de aljubarrota","oeiras e são julião da barra, paço de arcos e caxias").
paragem(834,-107559.62,-102708.32,bom,"fechado dos lados",yes,scotturb,[471],514,"largo avião lusitânia","oeiras e são julião da barra, paço de arcos e caxias").
paragem(960,-107102.8,-101781.42,bom,"fechado dos lados",yes,scotturb,[471],527,"avenida de brasí­lia","oeiras e são julião da barra, paço de arcos e caxias").
paragem(933,-107581.42,-102198.59,bom,"fechado dos lados",yes,scotturb,[471],533,"rua cândido dos reis","oeiras e são julião da barra, paço de arcos e caxias").
paragem(506,-107655.98,-102504.64,bom,"fechado dos lados",yes,scotturb,[471],533,"rua cândido dos reis","oeiras e são julião da barra, paço de arcos e caxias").
paragem(974,-108611.0,-103212.55,bom,"fechado dos lados",yes,scotturb,[471],556,"avenida dom joão i","oeiras e são julião da barra, paço de arcos e caxias").
paragem(971,-108633.94,-103087.73,bom,"fechado dos lados",yes,scotturb,[471],556,"avenida dom joão i","oeiras e são julião da barra, paço de arcos e caxias").
paragem(918,-107752.93,-102745.45,bom,"fechado dos lados",yes,scotturb,[471],559,"rua desembargador faria","oeiras e são julião da barra, paço de arcos e caxias").
paragem(939,-108680.61,-103239.46,razoavel,"fechado dos lados",yes,scotturb,[471],561,"rua dona filipa de lencastre","oeiras e são julião da barra, paço de arcos e caxias").
paragem(502,-107319.63,-102563.55,bom,"fechado dos lados",yes,scotturb,[471],578,"avenida embaixador augusto de castro","oeiras e são julião da barra, paço de arcos e caxias").
paragem(537,-107286.31,-102095.09,bom,"fechado dos lados",no,scotturb,[471],1325,"rua da figueirinha","oeiras e são julião da barra, paço de arcos e caxias").
paragem(574,-108145.87,-103052.15,bom,"fechado dos lados",yes,scotturb,[471],1332,"rua da fundição de oeiras","oeiras e são julião da barra, paço de arcos e caxias").
paragem(1026,-108103.16416368041,-103073.41174351703,bom,"sem abrigo",no,scotturb,[471],1342,"rua henrique de paiva couceiro","oeiras e são julião da barra, paço de arcos e caxias").
paragem(580,-108654.89,-103440.08,bom,"fechado dos lados",yes,scotturb,[471],1344,"avenida infante dom henrique","oeiras e são julião da barra, paço de arcos e caxias").
paragem(497,-108401.93,-103222.84,bom,"sem abrigo",no,scotturb,[471],1344,"avenida infante dom henrique","oeiras e são julião da barra, paço de arcos e caxias").
paragem(914,-108221.94694854727,-102975.10717631762,bom,"aberto dos lados",no,scotturb,[471],1346,"rua infanta dona isabel","oeiras e são julião da barra, paço de arcos e caxias").
paragem(575,-108450.51,-102954.49,bom,"fechado dos lados",yes,scotturb,[471],1346,"rua infanta dona isabel","oeiras e são julião da barra, paço de arcos e caxias").
paragem(928,-107653.99,-103018.24,bom,"fechado dos lados",yes,scotturb,[471],1372,"rua dos lagares da quinta","oeiras e são julião da barra, paço de arcos e caxias").
paragem(560,-107381.0,-101739.33,bom,"fechado dos lados",yes,scotturb,[471],1398,"avenida de moçambique","oeiras e são julião da barra, paço de arcos e caxias").
paragem(559,-107472.33,-101878.29,bom,"fechado dos lados",yes,scotturb,[471],1398,"avenida de moçambique","oeiras e são julião da barra, paço de arcos e caxias").
paragem(561,-107268.49,-101728.6,bom,"fechado dos lados",yes,scotturb,[471],1440,"rua são salvador da baí­a","oeiras e são julião da barra, paço de arcos e caxias").
paragem(376,-107047.8,-103631.28,bom,"sem abrigo",no,scotturb,[479],1315,"rua das escolas","oeiras e são julião da barra, paço de arcos e caxias").
paragem(375,-107044.63,-103620.23,bom,"fechado dos lados",yes,scotturb,[479],1315,"rua das escolas","oeiras e são julião da barra, paço de arcos e caxias").
paragem(980,-104256.82,-95173.34,bom,"fechado dos lados",yes,carris,[714],306,"rua dos cravos de abril","carnaxide e queijas").
paragem(685,-104174.54200948933,-95114.07850277536,bom,"sem abrigo",no,carris,[714],347,"rua da liberdade","carnaxide e queijas").
paragem(603,-104172.6851196953,-95216.43740152338,bom,"sem abrigo",no,carris,[714],347,"rua da liberdade","carnaxide e queijas").
paragem(623,-104578.88,-94652.12,bom,"sem abrigo",no,carris,[714],365,"estrada da portela","carnaxide e queijas").
paragem(1032,-104222.84172433561,-94001.25535769734,bom,"fechado dos lados",yes,carris,[714],1123,"rua da quinta do paizinho","carnaxide e queijas").
paragem(631,-104458.04,-94329.86,bom,"fechado dos lados",no,carris,[714],1123,"rua da quinta do paizinho","carnaxide e queijas").
paragem(627,-104278.88666597521,-94122.56603635015,bom,"sem abrigo",no,carris,[714],1123,"rua da quinta do paizinho","carnaxide e queijas").
paragem(615,-104497.842173306,-94358.908881103,bom,"fechado dos lados",yes,carris,[714],1123,"rua da quinta do paizinho","carnaxide e queijas").
paragem(619,-104458.52,-94926.22,bom,"fechado dos lados",yes,carris,[714],1134,"largo sete de junho de 1759","carnaxide e queijas").
paragem(43,-104445.64,-94921.33,bom,"fechado dos lados",no,carris,[714],1134,"largo sete de junho de 1759","carnaxide e queijas").
paragem(979,-104677.06,-94473.47,bom,"fechado dos lados",no,carris,[714],1160,"rua cincinato da costa","carnaxide e queijas").
paragem(978,-104683.1,-94486.15,bom,"fechado dos lados",no,carris,[714],1160,"rua cincinato da costa","carnaxide e queijas").
paragem(14,-105367.42,-95012.5,bom,"sem abrigo",no,carris,[748],113,"alameda ferno lopes","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(21,-105136.75,-95897.19,bom,"fechado dos lados",yes,carris,[748, 751],416,"alameda antónio sérgio","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(456,-107086.94,-95183.62,bom,"fechado dos lados",yes,carris,[750],102,"largo dom manuel i"," carcavelos").
paragem(672,-106566.19596789329,-95165.08801610209,bom,"sem abrigo",no,carris,[750, 751, 201],10,"avenida dos bombeiros voluntários de algés","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(1031,-107014.28376646667,-95156.66564817408,bom,"sem abrigo",no,carris,[751, 201],102,"largo dom manuel i","carcavelos").
paragem(168,-107095.22,-95206.35,bom,"fechado dos lados",yes,carris,[751, 201],102,"largo dom manuel i","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(144,-106979.51,-95226.45,bom,"fechado dos lados",yes,carris,[776],103,"rua damião de góis","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(794,-106975.22,-95602.61,bom,"sem abrigo",no,carris,[776],118,"alameda hermano patrone","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(681,-107008.56,-95490.23,bom,"fechado dos lados",no,carris,[776],118,"alameda hermano patrone","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(187,-106985.92,-95598.8,bom,"sem abrigo",no,carris,[776],118,"alameda hermano patrone","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(481,-106532.67,-97275.79,bom,"sem abrigo",no,carris,[776],367,"estrada da costa","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(459,-106331.99,-97379.59,bom,"fechado dos lados",yes,carris,[776],367,"estrada da costa","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(897,-107004.52,-96080.98,bom,"fechado dos lados",no,carris,[776],369,"rua direita do dafundo","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(895,-106999.08,-96066.1,bom,"fechado dos lados",no,carris,[776],369,"rua direita do dafundo","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(493,-106898.93,-96325.82,bom,"fechado dos lados",no,carris,[776],369,"rua direita do dafundo","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(471,-106865.6,-96906.59,bom,"sem abrigo",no,carris,[776],386,"rua sacadura cabral","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(906,-106791.2,-97137.51,bom,"fechado dos lados",yes,carris,[776],386,"rua sacadura cabral","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(484,-106790.95,-97111.1,bom,"sem abrigo",no,carris,[776],386,"rua sacadura cabral","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(479,-106688.65,-97277.31,bom,"sem abrigo",no,carris,[776],386,"rua sacadura cabral","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(478,-106680.98,-97288.83,bom,"fechado dos lados",yes,carris,[776],386,"rua sacadura cabral","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(477,-106835.46,-96672.9,bom,"fechado dos lados",yes,carris,[776],386,"rua sacadura cabral","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(475,-106826.16,-96699.81,bom,"sem abrigo",no,carris,[776],386,"rua sacadura cabral","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(474,-106880.09,-96852.94,bom,"sem abrigo",no,carris,[776],386,"rua sacadura cabral","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(463,-106886.32,-96345.37,bom,"sem abrigo",no,carris,[776],386,"rua sacadura cabral","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(8,-106980.35,-95289.3,bom,"sem abrigo",no,carris,[776],103,"rua damião de góis","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(5,-106997.31,-95311.49,bom,"sem abrigo",no,carris,[776],103,"rua damião de góis","algés, linda-a-velha e cruz quebrada-dafundo").
paragem(167,-107073.0,-95199.03,bom,"fechado dos lados",yes,carris,[98],102,"largo dom manuel i","carcavelos").
adjacencia(10,183,791).
adjacencia(10,791,595).
adjacencia(10,595,182).
adjacencia(10,182,181).
adjacencia(10,181,180).
adjacencia(10,180,594).
adjacencia(10,594,185).
adjacencia(10,185,89).
adjacencia(10,89,107).
adjacencia(10,107,250).
adjacencia(10,250,261).
adjacencia(10,261,597).
adjacencia(10,597,953).
adjacencia(10,953,605).
adjacencia(10,605,606).
adjacencia(10,606,609).
adjacencia(10,609,82).
adjacencia(10,82,604).
adjacencia(10,604,628).
adjacencia(10,628,39).
adjacencia(10,39,50).
adjacencia(10,50,599).
adjacencia(10,599,40).
adjacencia(10,40,622).
adjacencia(10,622,51).
adjacencia(10,51,38).
adjacencia(10,38,620).
adjacencia(10,620,45).
adjacencia(10,45,602).
adjacencia(10,602,601).
adjacencia(10,601,860).
adjacencia(10,860,861).
adjacencia(10,861,359).
adjacencia(10,359,349).
adjacencia(10,349,29).
adjacencia(10,29,646).
adjacencia(10,646,642).
adjacencia(10,642,30).
adjacencia(10,30,17).
adjacencia(10,17,643).
adjacencia(10,643,20).
adjacencia(10,20,36).
adjacencia(10,36,638).
adjacencia(10,638,637).
adjacencia(10,637,361).
adjacencia(10,361,362).
adjacencia(10,362,37).
adjacencia(10,37,26).
adjacencia(10,26,27).
adjacencia(10,27,28).
adjacencia(10,28,641).
adjacencia(10,641,635).
adjacencia(10,635,679).
adjacencia(10,679,688).
adjacencia(10,688,675).
adjacencia(10,675,72).
adjacencia(10,72,75).
adjacencia(10,75,671).
adjacencia(10,671,657).
adjacencia(10,657,70).
adjacencia(10,70,526).
adjacencia(184,730,133).
adjacencia(184,133,721).
adjacencia(184,721,753).
adjacencia(184,753,761).
adjacencia(184,761,760).
adjacencia(184,760,759).
adjacencia(184,759,758).
adjacencia(184,758,166).
adjacencia(184,166,204).
adjacencia(184,204,203).
adjacencia(184,203,198).
adjacencia(184,198,199).
adjacencia(184,199,209).
adjacencia(184,209,210).
adjacencia(184,210,207).
adjacencia(184,207,797).
adjacencia(184,797,259).
adjacencia(184,259,191).
adjacencia(184,191,795).
adjacencia(184,795,113).
adjacencia(184,113,112).
adjacencia(184,112,114).
adjacencia(184,114,111).
adjacencia(184,111,109).
adjacencia(184,109,796).
adjacencia(184,796,108).
adjacencia(184,108,110).
adjacencia(184,110,257).
adjacencia(184,257,258).
adjacencia(184,258,276).
adjacencia(184,276,277).
adjacencia(184,277,287).
adjacencia(184,287,1004).
adjacencia(184,1004,290).
adjacencia(184,290,279).
adjacencia(184,279,289).
adjacencia(184,289,288).
adjacencia(184,288,388).
adjacencia(184,388,387).
adjacencia(184,387,386).
adjacencia(184,386,385).
adjacencia(184,385,389).
adjacencia(184,389,440).
adjacencia(11,859,858).
adjacencia(11,858,360).
adjacencia(11,360,370).
adjacencia(11,370,351).
adjacencia(11,351,19).
adjacencia(11,19,371).
adjacencia(11,371,18).
adjacencia(11,18,352).
adjacencia(11,352,16).
adjacencia(11,16,339).
adjacencia(11,339,347).
adjacencia(11,347,362).
adjacencia(11,362,26).
adjacencia(11,26,27).
adjacencia(11,27,28).
adjacencia(11,28,86).
adjacencia(11,86,348).
adjacencia(11,348,85).
adjacencia(11,85,337).
adjacencia(11,337,338).
adjacencia(11,338,341).
adjacencia(11,341,342).
adjacencia(11,342,346).
adjacencia(11,346,345).
adjacencia(11,345,344).
adjacencia(11,344,363).
adjacencia(11,363,335).
adjacencia(11,335,492).
adjacencia(11,492,340).
adjacencia(11,340,468).
adjacencia(11,468,485).
adjacencia(11,485,486).
adjacencia(11,486,487).
adjacencia(11,487,488).
adjacencia(7,183,791).
adjacencia(7,791,595).
adjacencia(7,595,182).
adjacencia(7,182,181).
adjacencia(7,181,180).
adjacencia(7,180,594).
adjacencia(7,594,185).
adjacencia(7,185,89).
adjacencia(7,89,90).
adjacencia(7,90,107).
adjacencia(7,107,250).
adjacencia(7,250,597).
adjacencia(7,597,953).
adjacencia(7,953,609).
adjacencia(7,609,599).
adjacencia(7,599,1001).
adjacencia(7,1001,607).
adjacencia(13,128,745).
adjacencia(13,745,736).
adjacencia(13,736,147).
adjacencia(13,147,156).
adjacencia(13,156,734).
adjacencia(13,734,161).
adjacencia(13,161,162).
adjacencia(13,162,172).
adjacencia(13,172,171).
adjacencia(13,171,183).
adjacencia(13,183,791).
adjacencia(13,791,595).
adjacencia(13,595,182).
adjacencia(13,182,181).
adjacencia(13,181,180).
adjacencia(13,180,594).
adjacencia(13,594,185).
adjacencia(13,185,89).
adjacencia(13,89,90).
adjacencia(13,90,107).
adjacencia(13,107,250).
adjacencia(13,250,597).
adjacencia(13,597,953).
adjacencia(13,953,248).
adjacencia(13,248,243).
adjacencia(13,243,247).
adjacencia(13,247,609).
adjacencia(13,609,242).
adjacencia(13,242,255).
adjacencia(13,255,82).
adjacencia(13,82,604).
adjacencia(13,604,628).
adjacencia(13,628,799).
adjacencia(13,799,39).
adjacencia(13,39,50).
adjacencia(13,50,599).
adjacencia(13,599,40).
adjacencia(13,40,1010).
adjacencia(13,1010,246).
adjacencia(13,246,260).
adjacencia(13,260,985).
adjacencia(13,985,608).
adjacencia(13,608,249).
adjacencia(13,249,254).
adjacencia(13,254,227).
adjacencia(13,227,622).
adjacencia(13,622,230).
adjacencia(13,230,51).
adjacencia(13,51,44).
adjacencia(13,44,234).
adjacencia(13,234,38).
adjacencia(13,38,224).
adjacencia(13,224,620).
adjacencia(13,620,45).
adjacencia(13,45,614).
adjacencia(13,614,239).
adjacencia(13,239,238).
adjacencia(13,238,46).
adjacencia(13,46,226).
adjacencia(13,226,42).
adjacencia(13,42,600).
adjacencia(13,600,602).
adjacencia(13,602,601).
adjacencia(13,601,48).
adjacencia(13,48,49).
adjacencia(13,49,232).
adjacencia(13,232,52).
adjacencia(13,52,612).
adjacencia(13,612,613).
adjacencia(13,613,233).
adjacencia(13,233,231).
adjacencia(13,231,241).
adjacencia(13,241,240).
adjacencia(13,240,611).
adjacencia(13,611,610).
adjacencia(13,610,859).
adjacencia(13,859,858).
adjacencia(13,858,861).
adjacencia(13,861,332).
adjacencia(13,332,331).
adjacencia(13,331,315).
adjacencia(13,315,312).
adjacencia(13,312,313).
adjacencia(13,313,323).
adjacencia(13,323,351).
adjacencia(13,351,19).
adjacencia(13,19,371).
adjacencia(13,371,16).
adjacencia(13,16,339).
adjacencia(13,339,26).
adjacencia(13,26,27).
adjacencia(13,27,86).
adjacencia(13,86,338).
adjacencia(13,338,342).
adjacencia(13,342,345).
adjacencia(13,345,363).
adjacencia(13,363,492).
adjacencia(13,492,460).
adjacencia(13,460,468).
adjacencia(13,468,486).
adjacencia(13,486,487).
adjacencia(12,712,713).
adjacencia(12,713,714).
adjacencia(12,714,128).
adjacencia(12,128,745).
adjacencia(12,745,736).
adjacencia(12,736,147).
adjacencia(12,147,153).
adjacencia(12,153,149).
adjacencia(12,149,734).
adjacencia(12,734,159).
adjacencia(12,159,155).
adjacencia(12,155,741).
adjacencia(12,741,742).
adjacencia(12,742,686).
adjacencia(12,686,687).
adjacencia(12,687,87).
adjacencia(12,87,154).
adjacencia(12,154,709).
adjacencia(12,709,1014).
adjacencia(12,1014,68).
adjacencia(12,68,788).
adjacencia(12,788,170).
adjacencia(12,170,183).
adjacencia(12,183,791).
adjacencia(12,791,595).
adjacencia(12,595,182).
adjacencia(12,182,181).
adjacencia(12,181,180).
adjacencia(12,180,594).
adjacencia(12,594,185).
adjacencia(12,185,89).
adjacencia(12,89,90).
adjacencia(12,90,107).
adjacencia(12,107,250).
adjacencia(12,250,597).
adjacencia(12,597,953).
adjacencia(12,953,806).
adjacencia(12,806,609).
adjacencia(12,609,599).
adjacencia(12,599,860).
adjacencia(12,860,861).
adjacencia(12,861,359).
adjacencia(12,359,349).
adjacencia(12,349,643).
adjacencia(12,643,638).
adjacencia(12,638,637).
adjacencia(12,637,361).
adjacencia(12,361,362).
adjacencia(12,362,25).
adjacencia(12,25,37).
adjacencia(12,37,26).
adjacencia(12,26,24).
adjacencia(12,24,22).
adjacencia(12,22,27).
adjacencia(12,27,28).
adjacencia(12,28,34).
adjacencia(12,34,641).
adjacencia(12,641,635).
adjacencia(12,635,679).
adjacencia(12,679,688).
adjacencia(12,688,675).
adjacencia(12,675,72).
adjacencia(12,72,75).
adjacencia(12,75,671).
adjacencia(12,671,657).
adjacencia(12,657,70).
adjacencia(12,70,526).
adjacencia(6,745,736).
adjacencia(6,736,147).
adjacencia(6,147,156).
adjacencia(6,156,161).
adjacencia(6,161,162).
adjacencia(6,162,172).
adjacencia(6,172,171).
adjacencia(6,171,799).
adjacencia(6,799,1010).
adjacencia(6,1010,227).
adjacencia(6,227,230).
adjacencia(6,230,234).
adjacencia(6,234,224).
adjacencia(6,224,226).
adjacencia(6,226,232).
adjacencia(6,232,52).
adjacencia(6,52,233).
adjacencia(6,233,231).
adjacencia(6,231,886).
adjacencia(6,886,473).
adjacencia(6,473,470).
adjacencia(6,470,483).
adjacencia(6,483,482).
adjacencia(6,482,476).
adjacencia(6,476,904).
adjacencia(6,904,472).
adjacencia(6,472,902).
adjacencia(6,902,893).
adjacencia(6,893,465).
adjacencia(6,465,186).
adjacencia(6,186,652).
adjacencia(6,652,6).
adjacencia(6,6,466).
adjacencia(6,466,9).
adjacencia(6,9,467).
adjacencia(6,467,78).
adjacencia(2,745,736).
adjacencia(2,736,147).
adjacencia(2,147,156).
adjacencia(2,156,734).
adjacencia(2,734,161).
adjacencia(2,161,162).
adjacencia(2,162,172).
adjacencia(2,172,171).
adjacencia(2,171,595).
adjacencia(2,595,594).
adjacencia(2,594,185).
adjacencia(2,185,107).
adjacencia(2,107,237).
adjacencia(2,237,250).
adjacencia(2,250,261).
adjacencia(2,261,597).
adjacencia(2,597,953).
adjacencia(2,953,248).
adjacencia(2,248,244).
adjacencia(2,244,245).
adjacencia(2,245,243).
adjacencia(2,243,247).
adjacencia(2,247,609).
adjacencia(2,609,799).
adjacencia(2,799,599).
adjacencia(2,599,1010).
adjacencia(2,1010,246).
adjacencia(2,246,260).
adjacencia(2,260,227).
adjacencia(2,227,230).
adjacencia(2,230,234).
adjacencia(2,234,224).
adjacencia(2,224,239).
adjacencia(2,239,238).
adjacencia(2,238,226).
adjacencia(2,226,1001).
adjacencia(2,1001,607).
adjacencia(2,607,232).
adjacencia(2,232,52).
adjacencia(2,52,233).
adjacencia(2,233,231).
adjacencia(2,231,241).
adjacencia(2,241,240).
adjacencia(2,240,859).
adjacencia(2,859,858).
adjacencia(2,858,332).
adjacencia(2,332,331).
adjacencia(2,331,315).
adjacencia(2,315,312).
adjacencia(2,312,360).
adjacencia(2,360,313).
adjacencia(2,313,323).
adjacencia(2,323,351).
adjacencia(2,351,352).
adjacencia(2,352,339).
adjacencia(2,339,347).
adjacencia(2,347,86).
adjacencia(2,86,85).
adjacencia(2,85,341).
adjacencia(2,341,342).
adjacencia(2,342,346).
adjacencia(2,346,343).
adjacencia(2,343,345).
adjacencia(2,345,344).
adjacencia(2,344,363).
adjacencia(2,363,335).
adjacencia(2,335,457).
adjacencia(2,457,458).
adjacencia(2,458,490).
adjacencia(2,490,491).
adjacencia(2,491,56).
adjacencia(2,56,655).
adjacencia(2,655,654).
adjacencia(2,654,78).
adjacencia(2,78,80).
adjacencia(15,706,703).
adjacencia(15,703,719).
adjacencia(15,719,718).
adjacencia(15,718,728).
adjacencia(15,728,729).
adjacencia(15,729,724).
adjacencia(15,724,129).
adjacencia(15,129,763).
adjacencia(15,763,754).
adjacencia(15,754,183).
adjacencia(15,183,791).
adjacencia(15,791,595).
adjacencia(15,595,182).
adjacencia(15,182,181).
adjacencia(15,181,180).
adjacencia(15,180,594).
adjacencia(15,594,185).
adjacencia(15,185,89).
adjacencia(15,89,90).
adjacencia(15,90,107).
adjacencia(15,107,250).
adjacencia(15,250,597).
adjacencia(15,597,953).
adjacencia(15,953,248).
adjacencia(15,248,243).
adjacencia(15,243,247).
adjacencia(15,247,609).
adjacencia(15,609,242).
adjacencia(15,242,255).
adjacencia(15,255,82).
adjacencia(15,82,604).
adjacencia(15,604,798).
adjacencia(15,798,628).
adjacencia(15,628,799).
adjacencia(15,799,39).
adjacencia(15,39,50).
adjacencia(15,50,599).
adjacencia(15,599,40).
adjacencia(15,40,1010).
adjacencia(15,1010,246).
adjacencia(15,246,260).
adjacencia(15,260,985).
adjacencia(15,985,608).
adjacencia(15,608,249).
adjacencia(15,249,254).
adjacencia(15,254,205).
adjacencia(15,205,622).
adjacencia(15,622,230).
adjacencia(15,230,51).
adjacencia(15,51,44).
adjacencia(15,44,234).
adjacencia(15,234,38).
adjacencia(15,38,224).
adjacencia(15234,620).
adjacencia(15,620,45).
adjacencia(15,45,614).
adjacencia(15,614,239).
adjacencia(15,239,238).
adjacencia(15,238,46).
adjacencia(15,46,226).
adjacencia(15,226,42).
adjacencia(15,42,600).
adjacencia(15,600,602).
adjacencia(15,602,601).
adjacencia(15,601,48).
adjacencia(15,48,192).
adjacencia(15,192,190).
adjacencia(15,190,49).
adjacencia(15,49,232).
adjacencia(15,232,52).
adjacencia(15,52,612).
adjacencia(15,612,613).
adjacencia(15,613,193).
adjacencia(15,193,233).
adjacencia(15,233,231).
adjacencia(15,231,241).
adjacencia(15,241,240).
adjacencia(15,240,611).
adjacencia(15,611,610).
adjacencia(15,610,286).
adjacencia(15,286,332).
adjacencia(15,332,331).
adjacencia(15,331,315).
adjacencia(15,315,312).
adjacencia(15,312,314).
adjacencia(15,314,292).
adjacencia(15,292,295).
adjacencia(15,295,313).
adjacencia(15,313,270).
adjacencia(15,270,293).
adjacencia(15,293,323).
adjacencia(15,323,291).
adjacencia(15,291,278).
adjacencia(15,278,280).
adjacencia(1,183,791).
adjacencia(1,791,595).
adjacencia(1,595,182).
adjacencia(1,182,499).
adjacencia(1,499,593).
adjacencia(1,593,181).
adjacencia(1,181,180).
adjacencia(1,180,594).
adjacencia(1,594,185).
adjacencia(1,185,89).
adjacencia(1,89,107).
adjacencia(1,107,250).
adjacencia(1,250,261).
adjacencia(1,261,597).
adjacencia(1,597,953).
adjacencia(1,953,609).
adjacencia(1,609,242).
adjacencia(1,242,255).
adjacencia(1,255,604).
adjacencia(1,604,628).
adjacencia(1,628,39).
adjacencia(1,39,50).
adjacencia(1,50,599).
adjacencia(1,599,40).
adjacencia(1,40,985).
adjacencia(1,985,608).
adjacencia(1,608,249).
adjacencia(1,249,254).
adjacencia(1,254,622).
adjacencia(1,622,51).
adjacencia(1,51,44).
adjacencia(1,44,251).
adjacencia(1,251,38).
adjacencia(1,38,620).
adjacencia(1,620,45).
adjacencia(1,45,614).
adjacencia(1,614,46).
adjacencia(1,46,42).
adjacencia(1,42,600).
adjacencia(1,600,602).
adjacencia(1,602,601).
adjacencia(1,601,48).
adjacencia(1,48,49).
adjacencia(1,49,612).
adjacencia(1,612,613).
adjacencia(1,613,611).
adjacencia(1,611,610).
adjacencia(1,610,336).
adjacencia(1,336,357).
adjacencia(1,357,334).
adjacencia(1,334,339).
adjacencia(1,339,347).
adjacencia(1,347,86).
adjacencia(1,86,85).
adjacencia(1,85,341).
adjacencia(1,341,342).
adjacencia(1,342,365).
adjacencia(1,365,366).
adjacencia(1,366,460).
adjacencia(1,460,468).
adjacencia(1,468,485).
adjacencia(1,485,486).
adjacencia(1,486,487).
adjacencia(1,487,488).
adjacencia(1,488,469).
adjacencia(1,469,462).
adjacencia(1,462,480).
adjacencia(1,480,494).
adjacencia(1,494,957).
adjacencia(1,957,465).
adjacencia(1,465,186).
adjacencia(1,186,466).
adjacencia(1,466,467).
adjacencia(1,467,78).
adjacencia(1,78,79).
adjacencia(750,54,633).
adjacencia(750,633,677).
adjacencia(750,677,670).
adjacencia(750,670,676).
adjacencia(750,676,667).
adjacencia(750,667,673).
adjacencia(750,673,672).
adjacencia(750,672,656).
adjacencia(750,656,69).
adjacencia(750,69,456).
adjacencia(751,21,11).
adjacencia(751,11,650).
adjacencia(751,650,23).
adjacencia(751,23,13).
adjacencia(751,13,651).
adjacencia(751,651,15).
adjacencia(751,15,645).
adjacencia(751,645,54).
adjacencia(751,54,53).
adjacencia(751,53,640).
adjacencia(751,640,633).
adjacencia(751,633,677).
adjacencia(751,677,670).
adjacencia(751,670,676).
adjacencia(751,676,667).
adjacencia(751,667,673).
adjacencia(751,673,672).
adjacencia(751,672,656).
adjacencia(751,656,69).
adjacencia(751,69,1031).
adjacencia(751,1031,168).
adjacencia(468,262,263).
adjacencia(468,263,507).
adjacencia(468,507,509).
adjacencia(468,509,508).
adjacencia(468,508,924).
adjacencia(468,924,513).
adjacencia(125,97,98).
adjacencia(125,98,717).
adjacencia(125,717,716).
adjacencia(125,716,726).
adjacencia(125,726,727).
adjacencia(125,727,730).
adjacencia(125,730,133).
adjacencia(125,133,722).
adjacencia(125,722,723).
adjacencia(125,723,721).
adjacencia(125,721,753).
adjacencia(125,753,749).
adjacencia(125,749,750).
adjacencia(125,750,748).
adjacencia(125,748,757).
adjacencia(125,757,761).
adjacencia(125,761,760).
adjacencia(125,760,759).
adjacencia(125,759,758).
adjacencia(125,758,166).
adjacencia(125,166,204).
adjacencia(125,204,203).
adjacencia(125,203,198).
adjacencia(125,198,199).
adjacencia(125,199,209).
adjacencia(125,209,210).
adjacencia(125,210,207).
adjacencia(125,207,797).
adjacencia(125,797,191).
adjacencia(125,191,795).
adjacencia(125,795,796).
adjacencia(125,796,828).
adjacencia(125,828,287).
adjacencia(125,287,1004).
adjacencia(125,1004,290).
adjacencia(125,290,289).
adjacencia(125,289,288).
adjacencia(125,288,388).
adjacencia(125,388,387).
adjacencia(125,387,386).
adjacencia(125,386,385).
adjacencia(125,385,389).
adjacencia(125,389,440).
adjacencia(125,440,558).
adjacencia(119,97,98).
adjacencia(119,98,99).
adjacencia(119,99,707).
adjacencia(119,707,717).
adjacencia(119,717,716).
adjacencia(119,716,726).
adjacencia(119,726,727).
adjacencia(119,727,725).
adjacencia(119,725,132).
adjacencia(119,132,722).
adjacencia(119,722,723).
adjacencia(119,723,130).
adjacencia(119,130,731).
adjacencia(119,731,749).
adjacencia(119,749,750).
adjacencia(119,750,752).
adjacencia(119,752,751).
adjacencia(119,751,775).
adjacencia(119,775,776).
adjacencia(119,776,777).
adjacencia(119,777,778).
adjacencia(119,778,748).
adjacencia(119,748,757).
adjacencia(119,757,762).
adjacencia(119,762,756).
adjacencia(119,756,782).
adjacencia(119,782,786).
adjacencia(119,786,784).
adjacencia(119,784,772).
adjacencia(119,772,783).
adjacencia(119,783,694).
adjacencia(119,694,213).
adjacencia(119,213,259).
adjacencia(119,259,222).
adjacencia(119,222,109).
adjacencia(119,109,108).
adjacencia(119,108,257).
adjacencia(119,257,258).
adjacencia(119,258,276).
adjacencia(119,276,277).
adjacencia(119,277,287).
adjacencia(119,287,1004).
adjacencia(119,1004,290).
adjacencia(119,290,289).
adjacencia(119,289,288).
adjacencia(119,288,388).
adjacencia(119,388,387).
adjacencia(119,387,386).
adjacencia(119,386,385).
adjacencia(119,385,389).
adjacencia(119,389,441).
adjacencia(119,441,1018).
adjacencia(122,746,747).
adjacencia(122,747,165).
adjacencia(122,165,163).
adjacencia(122,163,164).
adjacencia(122,164,761).
adjacencia(122,761,760).
adjacencia(122,760,759).
adjacencia(122,759,758).
adjacencia(122,758,166).
adjacencia(122,166,204).
adjacencia(122,204,203).
adjacencia(122,203,198).
adjacencia(122,198,199).
adjacencia(122,199,207).
adjacencia(122,207,212).
adjacencia(122,212,206).
adjacencia(122,206,201).
adjacencia(122,201,200).
adjacencia(122,200,202).
adjacencia(122,202,211).
adjacencia(122,211,194).
adjacencia(122,194,195).
adjacencia(122,195,197).
adjacencia(122,197,196).
adjacencia(122,196,189).
adjacencia(122,189,188).
adjacencia(122,188,269).
adjacencia(122,269,268).
adjacencia(122,268,830).
adjacencia(122,830,832).
adjacencia(122,832,827).
adjacencia(122,827,831).
adjacencia(122,831,266).
adjacencia(122,266,829).
adjacencia(122,829,282).
adjacencia(122,282,283).
adjacencia(122,283,281).
adjacencia(122,281,294).
adjacencia(122,294,378).
adjacencia(122,378,989).
adjacencia(122,989,869).
adjacencia(122,869,541).
adjacencia(122,541,542).
adjacencia(122,542,503).
adjacencia(122,503,516).
adjacencia(122,516,543).
adjacencia(122,543,10).
adjacencia(122,10,540).
adjacencia(122,540,538).
adjacencia(122,538,310).
adjacencia(122,310,925).
adjacencia(122,925,521).
adjacencia(122,521,505).
adjacencia(122,505,501).
adjacencia(122,501,1025).
adjacencia(479,372,375).
adjacencia(479,375,376).
adjacencia(479,376,825).
adjacencia(479,825,824).
adjacencia(479,824,495).
adjacencia(479,495,507).
adjacencia(479,507,509).
adjacencia(479,509,508).
adjacencia(479,508,924).
adjacencia(479,924,513).
adjacencia(108,946,590).
adjacencia(108,590,591).
adjacencia(108,591,592).
adjacencia(108,592,173).
adjacencia(108,173,174).
adjacencia(108,174,175).
adjacencia(108,175,176).
adjacencia(108,176,177).
adjacencia(108,177,178).
adjacencia(108,178,693).
adjacencia(108,693,692).
adjacencia(108,692,817).
adjacencia(108,817,813).
adjacencia(108,813,816).
adjacencia(108,816,236).
adjacencia(108,236,1009).
adjacencia(108,1009,801).
adjacencia(108,801,805).
adjacencia(108,805,808).
adjacencia(108,808,809).
adjacencia(108,809,800).
adjacencia(108,800,803).
adjacencia(108,803,632).
adjacencia(108,632,804).
adjacencia(108,804,802).
adjacencia(108,802,811).
adjacencia(108,811,810).
adjacencia(108,810,841).
adjacencia(108,841,842).
adjacencia(108,842,837).
adjacencia(108,837,835).
adjacencia(108,835,836).
adjacencia(108,836,838).
adjacencia(108,838,320).
adjacencia(108,320,324).
adjacencia(108,324,325).
adjacencia(108,325,317).
adjacencia(108,317,319).
adjacencia(108,319,318).
adjacencia(108,318,327).
adjacencia(108,327,326).
adjacencia(108,326,273).
adjacencia(108,273,274).
adjacencia(108,274,431).
adjacencia(108,431,437).
adjacencia(108,437,423).
adjacencia(108,423,439).
adjacencia(108,439,409).
adjacencia(111,872,391).
adjacencia(111,391,871).
adjacencia(111,871,407).
adjacencia(111,407,873).
adjacencia(111,873,394).
adjacencia(111,394,403).
adjacencia(111,403,404).
adjacencia(111,404,408).
adjacencia(111,408,390).
adjacencia(111,390,874).
adjacencia(111,874,875).
adjacencia(111,875,398).
adjacencia(111,398,399).
adjacencia(111,399,548).
adjacencia(111,548,549).
adjacencia(111,549,570).
adjacencia(111,570,564).
adjacencia(111,564,551).
adjacencia(111,551,565).
adjacencia(111,565,553).
adjacencia(111,553,552).
adjacencia(111,552,554).
adjacencia(111,554,540).
adjacencia(111,540,567).
adjacencia(111,567,919).
adjacencia(111,919,533).
adjacencia(111,533,920).
adjacencia(111,920,566).
adjacencia(111,566,534).
adjacencia(111,534,531).
adjacencia(111,531,539).
adjacencia(111,539,532).
adjacencia(111,532,530).
adjacencia(111,530,504).
adjacencia(111,504,517).
adjacencia(111,517,310).
adjacencia(111,310,925).
adjacencia(111,925,521).
adjacencia(111,521,505).
adjacencia(111,505,501).
adjacencia(111,501,1025).
adjacencia(112,704,717).
adjacencia(112,717,716).
adjacencia(112,716,726).
adjacencia(112,726,727).
adjacencia(112,727,722).
adjacencia(112,722,723).
adjacencia(112,723,751).
adjacencia(112,751,762).
adjacencia(112,762,756).
adjacencia(112,756,208).
adjacencia(112,208,797).
adjacencia(112,797,191).
adjacencia(112,191,795).
adjacencia(112,795,796).
adjacencia(112,796,828).
adjacencia(112,828,830).
adjacencia(112,830,832).
adjacencia(112,832,827).
adjacencia(112,827,831).
adjacencia(112,831,266).
adjacencia(112,266,829).
adjacencia(112,829,272).
adjacencia(112,272,271).
adjacencia(112,271,380).
adjacencia(112,380,381).
adjacencia(112,381,989).
adjacencia(112,989,869).
adjacencia(112,869,541).
adjacencia(112,541,542).
adjacencia(112,542,503).
adjacencia(112,503,516).
adjacencia(112,516,543).
adjacencia(112,543,10).
adjacencia(112,10,540).
adjacencia(112,540,518).
adjacencia(112,518,538).
adjacencia(112,538,310).
adjacencia(112,310,521).
adjacencia(112,521,505).
adjacencia(112,505,501).
adjacencia(112,501,577).
adjacencia(106,711,125).
adjacencia(106,125,127).
adjacencia(106,127,715).
adjacencia(106,715,744).
adjacencia(106,744,152).
adjacencia(106,152,732).
adjacencia(106,732,780).
adjacencia(106,780,752).
adjacencia(106,752,751).
adjacencia(106,751,779).
adjacencia(106,779,775).
adjacencia(106,775,776).
adjacencia(106,776,774).
adjacencia(106,774,773).
adjacencia(106,773,777).
adjacencia(106,777,778).
adjacencia(106,778,762).
adjacencia(106,762,756).
adjacencia(106,756,781).
adjacencia(106,781,785).
adjacencia(106,785,208).
adjacencia(106,208,797).
adjacencia(106,797,191).
adjacencia(106,191,795).
adjacencia(106,795,796).
adjacencia(106,796,828).
adjacencia(106,828,284).
adjacencia(106,284,285).
adjacencia(106,285,282).
adjacencia(106,282,283).
adjacencia(106,283,281).
adjacencia(106,281,294).
adjacencia(106,294,378).
adjacencia(106,378,379).
adjacencia(106,379,989).
adjacencia(106,989,869).
adjacencia(106,869,88).
adjacencia(106,88,419).
adjacencia(106,419,541).
adjacencia(106,541,542).
adjacencia(106,542,503).
adjacencia(106,503,516).
adjacencia(106,516,543).
adjacencia(106,543,10).
adjacencia(106,10,540).
adjacencia(106,540,518).
adjacencia(106,518,538).
adjacencia(106,538,310).
adjacencia(106,310,521).
adjacencia(106,521,505).
adjacencia(106,505,501).
adjacencia(106,501,967).
adjacencia(106,967,913).
adjacencia(106,913,577).
adjacencia(106,577,944).
adjacencia(106,944,969).
adjacencia(106,969,579).
adjacencia(106,579,581).
adjacencia(106,581,941).
adjacencia(106,941,576).
adjacencia(106,576,585).
adjacencia(106,585,584).
adjacencia(106,584,583).
adjacencia(714,603,685).
adjacencia(714,685,1032).
adjacencia(714,1032,980).
adjacencia(714,980,627).
adjacencia(714,627,43).
adjacencia(714,43,631).
adjacencia(714,631,619).
adjacencia(714,619,615).
adjacencia(714,615,623).
adjacencia(714,623,979).
adjacencia(714,979,978).
adjacencia(467,825,523).
adjacencia(467,523,824).
adjacencia(467,824,921).
adjacencia(467,921,495).
adjacencia(467,495,507).
adjacencia(467,507,509).
adjacencia(467,509,508).
adjacencia(467,508,924).
adjacencia(467,924,513).
adjacencia(117,124,123).
adjacencia(117,123,117).
adjacencia(117,117,116).
adjacencia(117,116,119).
adjacencia(117,119,118).
adjacencia(117,118,120).
adjacencia(117,120,121).
adjacencia(117,121,122).
adjacencia(117,122,141).
adjacencia(117,141,143).
adjacencia(117,143,142).
adjacencia(117,142,139).
adjacencia(117,139,140).
adjacencia(117,140,137).
adjacencia(117,137,138).
adjacencia(117,138,770).
adjacencia(117,770,767).
adjacencia(117,767,779).
adjacencia(117,779,766).
adjacencia(117,766,691).
adjacencia(117,691,774).
adjacencia(117,774,773).
adjacencia(117,773,765).
adjacencia(117,765,764).
adjacencia(117,764,768).
adjacencia(117,768,769).
adjacencia(117,769,781).
adjacencia(117,781,785).
adjacencia(117,785,771).
adjacencia(117,771,787).
adjacencia(117,787,217).
adjacencia(117,217,218).
adjacencia(117,218,216).
adjacencia(117,216,215).
adjacencia(117,215,214).
adjacencia(117,214,452).
adjacencia(117,452,322).
adjacencia(117,322,321).
adjacencia(117,321,320).
adjacencia(117,320,317).
adjacencia(117,317,319).
adjacencia(117,319,318).
adjacencia(117,318,299).
adjacencia(117,299,273).
adjacencia(117,273,274).
adjacencia(117,274,444).
adjacencia(117,444,446).
adjacencia(117,446,445).
adjacencia(117,445,448).
adjacencia(117,448,431).
adjacencia(117,431,437).
adjacencia(117,437,423).
adjacencia(117,423,447).
adjacencia(117,447,439).
adjacencia(117,439,449).
adjacencia(117,449,450).
adjacencia(117,450,88).
adjacencia(117,88,419).
adjacencia(117,419,409).
adjacencia(102,711,125).
adjacencia(102,125,127).
adjacencia(102,127,715).
adjacencia(102,715,744).
adjacencia(102,744,152).
adjacencia(102,152,732).
adjacencia(102,732,733).
adjacencia(102,733,151).
adjacencia(102,151,743).
adjacencia(102,743,739).
adjacencia(102,739,158).
adjacencia(102,158,157).
adjacencia(102,157,84).
adjacencia(102,84,83).
adjacencia(102,83,690).
adjacencia(102,690,738).
adjacencia(102,738,708).
adjacencia(102,708,1015).
adjacencia(102,1015,1016).
adjacencia(102,1016,169).
adjacencia(102,169,789).
adjacencia(102,789,817).
adjacencia(102,817,815).
adjacencia(102,815,814).
adjacencia(102,814,813).
adjacencia(102,813,235).
adjacencia(102,235,816).
adjacencia(102,816,236).
adjacencia(102,236,223).
adjacencia(102,223,1009).
adjacencia(102,1009,801).
adjacencia(102,801,805).
adjacencia(102,805,808).
adjacencia(102,808,809).
adjacencia(102,809,800).
adjacencia(102,800,229).
adjacencia(102,229,803).
adjacencia(102,803,632).
adjacencia(102,632,804).
adjacencia(102,804,802).
adjacencia(102,802,811).
adjacencia(102,811,810).
adjacencia(102,810,841).
adjacencia(102,841,842).
adjacencia(102,842,837).
adjacencia(102,837,835).
adjacencia(102,835,836).
adjacencia(102,836,838).
adjacencia(102,838,454).
adjacencia(102,454,455).
adjacencia(102,455,453).
adjacencia(116,524,987).
adjacencia(116,987,569).
adjacencia(116,569,1011).
adjacencia(116,1011,555).
adjacencia(116,555,525).
adjacencia(116,525,546).
adjacencia(116,546,547).
adjacencia(116,547,935).
adjacencia(116,935,545).
adjacencia(470,267,513).
adjacencia(470,513,556).
adjacencia(470,556,522).
adjacencia(470,522,515).
adjacencia(470,515,500).
adjacencia(470,500,927).
adjacencia(470,927,511).
adjacencia(470,511,512).
adjacencia(470,512,372).
adjacencia(470,372,520).
adjacencia(470,520,519).
adjacencia(470,519,265).
adjacencia(470,265,264).
adjacencia(470,264,263).
adjacencia(470,263,824).
adjacencia(470,824,262).
adjacencia(470,262,825).
adjacencia(114,946,590).
adjacencia(114,590,591).
adjacencia(114,591,592).
adjacencia(114,592,173).
adjacencia(114,173,174).
adjacencia(114,174,175).
adjacencia(114,175,176).
adjacencia(114,176,950).
adjacencia(114,950,177).
adjacencia(114,177,178).
adjacencia(114,178,947).
adjacencia(114,947,792).
adjacencia(114,792,710).
adjacencia(114,710,807).
adjacencia(114,807,818).
adjacencia(114,818,823).
adjacencia(114,823,952).
adjacencia(114,952,954).
adjacencia(114,954,1002).
adjacencia(114,1002,977).
adjacencia(114,977,986).
adjacencia(114,986,983).
adjacencia(114,983,354).
adjacencia(114,354,353).
adjacencia(114,353,863).
adjacencia(114,863,856).
adjacencia(114,856,857).
adjacencia(114,857,367).
adjacencia(114,367,333).
adjacencia(114,333,846).
adjacencia(114,846,845).
adjacencia(114,845,330).
adjacencia(114,330,364).
adjacencia(114,364,33).
adjacencia(114,33,32).
adjacencia(114,32,60).
adjacencia(114,60,61).
adjacencia(114,61,64).
adjacencia(114,64,63).
adjacencia(114,63,62).
adjacencia(114,62,58).
adjacencia(114,58,57).
adjacencia(114,57,59).
adjacencia(114,59,654).
adjacencia(114,654,81).
adjacencia(129,198,209).
adjacencia(129,209,210).
adjacencia(129,210,207).
adjacencia(129,207,206).
adjacencia(129,206,200).
adjacencia(129,200,797).
adjacencia(129,797,202).
adjacencia(129,202,211).
adjacencia(129,211,191).
adjacencia(129,191,795).
adjacencia(129,795,194).
adjacencia(129,194,195).
adjacencia(129,195,197).
adjacencia(129,197,796).
adjacencia(129,796,196).
adjacencia(129,196,189).
adjacencia(129,189,188).
adjacencia(129,188,828).
adjacencia(129,828,269).
adjacencia(129,269,268).
adjacencia(129,268,827).
adjacencia(129,827,266).
adjacencia(129,266,287).
adjacencia(129,287,1004).
adjacencia(129,1004,290).
adjacencia(129,290,279).
adjacencia(129,279,289).
adjacencia(129,289,288).
adjacencia(129,288,388).
adjacencia(129,388,387).
adjacencia(129,387,386).
adjacencia(129,386,385).
adjacencia(129,385,389).
adjacencia(129,389,440).
adjacencia(129,440,558).
adjacencia(115,320,324).
adjacencia(115,324,325).
adjacencia(115,325,317).
adjacencia(115,317,319).
adjacencia(115,319,318).
adjacencia(115,318,327).
adjacencia(115,327,326).
adjacencia(115,326,273).
adjacencia(115,273,274).
adjacencia(115,274,431).
adjacencia(115,431,437).
adjacencia(115,437,411).
adjacencia(115,411,442).
adjacencia(115,442,421).
adjacencia(115,421,420).
adjacencia(115,420,432).
adjacencia(115,432,413).
adjacencia(115,413,429).
adjacencia(115,429,428).
adjacencia(115,428,418).
adjacencia(115,418,439).
adjacencia(115,439,424).
adjacencia(115,424,436).
adjacencia(115,436,435).
adjacencia(115,435,415).
adjacencia(115,415,414).
adjacencia(115,414,426).
adjacencia(115,426,427).
adjacencia(115,427,425).
adjacencia(115,425,412).
adjacencia(115,412,1008).
adjacencia(115,1008,401).
adjacencia(115,401,402).
adjacencia(115,402,441).
adjacencia(115,441,564).
adjacencia(115,564,551).
adjacencia(115,551,565).
adjacencia(115,565,562).
adjacencia(115,562,553).
adjacencia(115,553,552).
adjacencia(115,552,558).
adjacencia(115,558,554).
adjacencia(115,554,563).
adjacencia(115,563,540).
adjacencia(115,540,1006).
adjacencia(115,1006,934).
adjacencia(115,934,518).
adjacencia(115,518,568).
adjacencia(115,568,310).
adjacencia(115,310,535).
adjacencia(115,535,521).
adjacencia(115,521,505).
adjacencia(115,505,501).
adjacencia(115,501,577).
adjacencia(101,106,711).
adjacencia(101,711,125).
adjacencia(101,125,1013).
adjacencia(101,1013,103).
adjacencia(101,103,127).
adjacencia(101,127,715).
adjacencia(101,715,102).
adjacencia(101,102,101).
adjacencia(101,101,134).
adjacencia(101,134,744).
adjacencia(101,744,135).
adjacencia(101,135,136).
adjacencia(101,136,152).
adjacencia(101,152,732).
adjacencia(101,732,740).
adjacencia(101,740,146).
adjacencia(101,146,737).
adjacencia(101,737,145).
adjacencia(101,145,160).
adjacencia(101,160,148).
adjacencia(101,148,733).
adjacencia(471,960,561).
adjacencia(471,561,537).
adjacencia(471,537,502).
adjacencia(471,502,560).
adjacencia(471,560,559).
adjacencia(471,559,834).
adjacencia(471,834,933).
adjacencia(471,933,924).
adjacencia(471,924,928).
adjacencia(471,928,506).
adjacencia(471,506,918).
adjacencia(471,918,1026).
adjacencia(471,1026,574).
adjacencia(471,574,914).
adjacencia(471,914,497).
adjacencia(471,497,575).
adjacencia(471,575,974).
adjacencia(471,974,971).
adjacencia(471,971,580).
adjacencia(471,580,939).
adjacencia(471,939,587).
adjacencia(748,21,11).
adjacencia(748,11,650).
adjacencia(748,650,23).
adjacencia(748,23,13).
adjacencia(748,13,651).
adjacencia(748,651,15).
adjacencia(748,15,645).
adjacencia(748,645,14).
adjacencia(748,14,54).
adjacencia(748,54,633).
adjacencia(171,116,119).
adjacencia(171,119,118).
adjacencia(171,118,104).
adjacencia(171,104,711).
adjacencia(171,711,105).
adjacencia(171,105,125).
adjacencia(171,125,115).
adjacencia(171,115,120).
adjacencia(171,120,121).
adjacencia(171,121,1012).
adjacencia(171,1012,127).
adjacencia(171,127,715).
adjacencia(171,715,134).
adjacencia(171,134,122).
adjacencia(171,122,141).
adjacencia(171,141,143).
adjacencia(171,143,744).
adjacencia(171,744,142).
adjacencia(171,142,135).
adjacencia(171,135,136).
adjacencia(171,136,152).
adjacencia(171,152,139).
adjacencia(171,139,140).
adjacencia(171,140,732).
adjacencia(171,732,740).
adjacencia(171,740,146).
adjacencia(171,146,737).
adjacencia(171,737,145).
adjacencia(171,145,160).
adjacencia(171,160,148).
adjacencia(171,148,733).
adjacencia(171,733,137).
adjacencia(171,137,138).
adjacencia(171,138,770).
adjacencia(171,770,767).
adjacencia(171,767,766).
adjacencia(171,766,691).
adjacencia(171,691,765).
adjacencia(171,765,764).
adjacencia(171,764,228).
adjacencia(171,228,805).
adjacencia(171,805,225).
adjacencia(171,225,800).
adjacencia(171,800,229).
adjacencia(776,459,481).
adjacencia(776,481,478).
adjacencia(776,478,479).
adjacencia(776,479,484).
adjacencia(776,484,906).
adjacencia(776,906,475).
adjacencia(776,475,477).
adjacencia(776,477,471).
adjacencia(776,471,474).
adjacencia(776,474,463).
adjacencia(776,463,493).
adjacencia(776,493,794).
adjacencia(776,794,144).
adjacencia(776,144,8).
adjacencia(776,8,187).
adjacencia(776,187,5).
adjacencia(776,5,895).
adjacencia(776,895,897).
adjacencia(776,897,681).
adjacencia(158,219,220).
adjacencia(158,220,221).
adjacencia(158,221,300).
adjacencia(158,300,301).
adjacencia(158,301,308).
adjacencia(158,308,307).
adjacencia(158,307,320).
adjacencia(158,320,317).
adjacencia(158,317,833).
adjacencia(158,833,826).
adjacencia(158,826,1005).
adjacencia(158,1005,302).
adjacencia(158,302,319).
adjacencia(158,319,304).
adjacencia(158,304,311).
adjacencia(158,311,318).
adjacencia(158,318,303).
adjacencia(158,303,299).
adjacencia(158,299,306).
adjacencia(158,306,297).
adjacencia(158,297,305).
adjacencia(158,305,316).
adjacencia(158,316,296).
adjacencia(158,296,273).
adjacencia(158,273,274).
adjacencia(158,274,396).
adjacencia(158,396,397).
adjacencia(158,397,884).
adjacencia(158,884,437).
adjacencia(158,437,388).
adjacencia(158,388,433).
adjacencia(158,433,434).
adjacencia(158,434,380).
adjacencia(158,380,405).
adjacencia(158,405,381).
adjacencia(158,381,406).
adjacencia(158,406,411).
adjacencia(158,411,442).
adjacencia(158,442,421).
adjacencia(158,421,872).
adjacencia(158,872,420).
adjacencia(158,420,387).
adjacencia(158,387,386).
adjacencia(158,386,413).
adjacencia(158,413,443).
adjacencia(158,443,423).
adjacencia(158,423,391).
adjacencia(158,391,418).
adjacencia(158,418,395).
adjacencia(158,395,400).
adjacencia(158,400,439).
adjacencia(158,439,430).
adjacencia(158,430,436).
adjacencia(158,436,435).
adjacencia(158,435,449).
adjacencia(158,449,450).
adjacencia(158,450,438).
adjacencia(158,438,415).
adjacencia(158,415,414).
adjacencia(158,414,426).
adjacencia(158,426,427).
adjacencia(158,427,385).
adjacencia(158,385,88).
adjacencia(158,88,419).
adjacencia(158,419,389).
adjacencia(158,389,412).
adjacencia(158,412,1008).
adjacencia(158,1008,401).
adjacencia(158,401,402).
adjacencia(158,402,410).
adjacencia(158,410,275).
adjacencia(158,275,440).
adjacencia(158,440,558).
adjacencia(158,558,298).
adjacencia(23,706,703).
adjacencia(23,703,100).
adjacencia(23,100,718).
adjacencia(23,718,729).
adjacencia(23,729,131).
adjacencia(23,131,129).
adjacencia(23,129,720).
adjacencia(201,11,650).
adjacencia(201,650,23).
adjacencia(201,23,13).
adjacencia(201,13,651).
adjacencia(201,651,15).
adjacencia(201,15,645).
adjacencia(201,645,54).
adjacencia(201,54,53).
adjacencia(201,53,640).
adjacencia(201,640,633).
adjacencia(201,633,677).
adjacencia(201,677,670).
adjacencia(201,670,676).
adjacencia(201,676,667).
adjacencia(201,667,673).
adjacencia(201,673,672).
adjacencia(201,672,656).
adjacencia(201,656,69).
adjacencia(201,69,1031).
adjacencia(201,1031,168).
adjacencia(162,629,626).
adjacencia(162,626,630).
adjacencia(162,630,616).
adjacencia(162,616,639).
adjacencia(162,639,636).
adjacencia(162,636,12).
adjacencia(162,12,634).
adjacencia(162,634,678).
adjacencia(162,678,669).
adjacencia(162,669,76).
adjacencia(162,76,668).
adjacencia(162,668,674).
adjacencia(162,674,73).
adjacencia(162,73,658).
adjacencia(162,658,666).
adjacencia(162,666,528).
