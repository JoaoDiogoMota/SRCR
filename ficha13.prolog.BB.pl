%OProblema 1

emprestimo(V,H,A,CC,sim) :- 
	P1 is (H/V)*100,
	P2 is ((H+A+CC))*100,
	P1<30,
	P2<40.
emprestimo(V,H,A,CC,nao) :- 
	P1 is (H/V)*100,
	P2 is ((H+A+CC)/V)*100,
	nao((P1<30,P2<40)).

nao(Questao) :-
	Questao,!,fail.
nao(Questao).