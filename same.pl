% vim: set ft=prolog:

% Neste arquivo estão especificados os predicados que devem ser implementados
% para que o resolvedor-prolog funcione. O predicado principal e os predicados
% de entrada e saída já estão implementados em resolverdor.pl. Não é necessário
% implementar mais nada em prolog além dos predicados descritos neste arquivo.
%
% No arquivo same_testes.pl estão os testes para cada predicado.
%
% Para implementar cada predicado, primeiro você deve ler e entender a
% especificação e o teste. Para alguns predicados, existem dicas de
% implementação.
%
% A especificação dos parâmetros dos predicados segue o formato descrito em
% http://www.swi-prolog.org/pldoc/doc_for?object=section%282,%274.1%27,swi%28%27/doc/Manual/preddesc.html%27%29%29
%
% Um Jogo same é representado por uma lista de colunas, sem os elementos nulos
% (zeros).
% Por exemplo, o jogo
% 2 | 3 0 0 0
% 1 | 2 2 2 0
% 0 | 2 3 3 1
% --+--------
%   | 0 1 2 3
% é representado como [[2, 2, 3], [3, 2], [3, 2], [1]].
% O tamanho deste jogo é 3x4 (linhas x colunas).
% Esta representação facilita a implementação de alguns predicados.
%
% Uma posição no jogo é representado por um tupla com dois valores (lin, col),
% lin é o número da linha e col é o número da coluna.
% No exemplo anterior, a posição (0, 1) tem cor 3, e a posição (1, 2) tem cor 2.

%% vizinhos(+Lin, +Col, ?V).
% V é uma lista com as posições vizinhas de (Lin, Col), isto é, as posições
% adjacentes na vertical e horizontal.
% Este predicado será utilizado no predicado grupo.
vizinhos(Lin, Col, V) :-
        %retornar lista de tuplas das posições possíveis
        LinA is Lin - 1,
        LinB is Lin + 1,
        ColA is Col - 1,
        ColB is Col + 1,
        %nao valida as posicoes negativas pois falha no teste unitario
        V = [(LinA, Col), (Lin, ColA), (Lin, ColB), (LinB, Col)].

%% cor(+Jogo, ?Lin, ?Col, ?Cor)
% Cor é a cor na posicao (Lin, Col) de Jogo.
% Este predicado é utilizado no predicado grupo.
% Dicas:
%   - veja o predicado nth0 <<< "True when Elem is the Index'th element of List. Counting starts at 0." >>>
%   - lembre-se que jogo é uma lista das colunas do jogo
cor(Jogo, Lin, Col, Cor) :-
        %retorna a coluna para a variavel Coluna passando o indice Col
        nth0(Col, Jogo, Coluna),
        %retorna o elemento do indice Lin na coluna selecionada
        nth0(Lin, Coluna, Cor).

%% grupo(+Jogo, ?Grupo)
% Grupo é um grupo do Jogo de tamanho > 1.
% Este predicado deve ser capaz de gerar todos os grupos de um jogo, idealmente sem
% gerar grupos repetidos.
% Este predicado será utilizado no predicado jogar/3 
% Dicas:
%   - esta predicado é um gerador, procure sobre a estratégia generate and test
%   em prolog
%   - primeiro se preocupe em fazer o teste passar, depois em gerar grupos não
%   repetidos (que é uma otimização).
grupo(Jogo, Grupo) :-
        %montar lista com todas as posicoes do jogo
        retorna_todas_posicoes(Jogo, 0, Posicoes),!, %corte aqui, pois soh eh necessario gerar as posicoes uma vez (backtrack)
        %percorrer todas as posicoes, retornando o grupo de cada posicao
	grupo_posicoes(Jogo, Posicoes, Grupo).

grupo_posicoes(Jogo, Posicoes, Grupo) :-
        [(Lin,Col)|_] = Posicoes,
        %write('posicao atual' - Lin|Col),nl,
        grupo(Jogo, Lin, Col, Grupo),
        length(Grupo,G),
        G > 1.

grupo_posicoes(Jogo, Posicoes, Grupo) :-
        [(Lin,Col)|_] = Posicoes,
        %write('posicao 2' - Lin|Col),nl,
        grupo(Jogo, Lin, Col, GrupoX),
        %write('grupox' - GrupoX),nl,
        subtract(Posicoes, GrupoX, PosicoesSemOGrupo),
        %write('PosicoesSemOGrupo' - PosicoesSemOGrupo),nl,
        grupo_posicoes(Jogo, PosicoesSemOGrupo, Grupo).

retorna_todas_posicoes(Jogo, Coluna, []) :-
	length(Jogo, Coluna).

retorna_todas_posicoes(Jogo, Coluna, Posicoes) :-
        nth0(Coluna, Jogo, Col),
        length(Col, Qtde_linhas),
	retorna_posicoes_coluna(0, Qtde_linhas, Coluna, PosicoesColuna),
	ColunaX is Coluna + 1,
	retorna_todas_posicoes(Jogo, ColunaX, PosicoesX),
	append(PosicoesColuna, PosicoesX, Posicoes).
        %Posicoes = [(0,0),(0,1),(0,2),(0,3),(1,0),(1,1),(1,2),(1,3),(2,0),(2,1),(2,2),(2,3)].

retorna_posicoes_coluna(Linha, Linha, _, []).

retorna_posicoes_coluna(Linha, TotalLinhas, Coluna, Posicoes) :-
	Linha < TotalLinhas,
	LinX is Linha + 1,
	retorna_posicoes_coluna(LinX, TotalLinhas, Coluna, Posicoes2),
	Posicoes = [(Linha,Coluna)|Posicoes2].

%% grupo(+Jogo, +Lin, +Col, -Grupo)
% Grupo é um grupo do jogo que contém a posição (Lin, Col).
% Este predicado é utilizado no arquivo resolvedor.pl
% Dica:
%   - este predicado e o predicado grupo/2 podem ser implementados usando os
%   mesmos predicados auxiliares.
grupo(Jogo, Lin, Col, Grupo) :-
        %pegar a cor da posição atual
        cor(Jogo, Lin, Col, Cor_grupo),
        %write('cor do grupo' - Cor_grupo),nl,
        %chama o predicadp grupo que recebe cor
        grupo_cor(Jogo, Lin, Col, Cor_grupo, [], Grupo),!.

grupo_cor(Jogo, Lin, Col, Cor, GrupoEntrada, GrupoSaida) :-
        append(GrupoEntrada, [(Lin,Col)], GrupoTemp),
        %write('novo grupo' - GrupoTemp),nl,
        %as possíveis posições para o grupo sao os vizinhos da posição atual (generate)
        vizinhos(Lin, Col, Candidatos),
        %write(candidatos - Candidatos),nl,
        remove_posicoes_invalidas(Jogo, Candidatos, CandidatosValidos),
        %write('candidatos validos' - CandidatosValidos),nl,
        grupo_candidatos(Jogo, CandidatosValidos, Cor, GrupoTemp, GrupoSaida).

grupo_candidatos(Jogo, Candidatos, Cor, GrupoAnterior, Grupo) :-
        [(Lin,Col)|Resto] = Candidatos,
        %write('posicao candidato' - Lin|Col),nl,
        cor(Jogo, Lin, Col, Cor_candidato),
        %write('cor do parametro' - Cor),nl,
        %write('cor do candidato' - Cor_candidato),nl,
        Cor == Cor_candidato,
        \+member((Lin,Col),GrupoAnterior),
        grupo_cor(Jogo, Lin, Col, Cor_candidato, GrupoAnterior, GrupoTemp),
        grupo_candidatos(Jogo, Resto, Cor_candidato, GrupoTemp, Grupo).

grupo_candidatos(Jogo, Candidatos, Cor, GrupoAnterior, Grupo) :-
        [_|Resto] = Candidatos,
        grupo_candidatos(Jogo, Resto, Cor, GrupoAnterior, Grupo).

%fato que recebe lista de candidatos vazia e retorna grupo vazio
grupo_candidatos(_, [], _, GrupoAnterior, GrupoAnterior).

%fato para caso base - lista vazia
remove_posicoes_invalidas(_, [], []).

%predicado para o caso de posicao valida
remove_posicoes_invalidas(Jogo, Lista, NovaLista) :-
        [(Lin,Col)|Resto] = Lista,
        posicao_valida(Lin, Col, Jogo),
        remove_posicoes_invalidas(Jogo, Resto, NovaListaX),
        NovaLista = [(Lin, Col)|NovaListaX].

%precicado para o caso de posicao invalida
remove_posicoes_invalidas(Jogo, Lista, NovaLista) :-
        [_|Resto] = Lista,
        remove_posicoes_invalidas(Jogo, Resto, NovaLista).

%% remover_grupo(+Grupo, +Jogo, -NovoJogo)
% NovoJogo é obtido de Jogo removendo os elemento especificados em Grupo. A
% remoção é feita de acordo com as regras do jogo same.
% Dica:
%   - crie um predicado auxiliar remover_grupo_coluna, que remove os elementos
%   do grupo de uma coluna específica
remover_grupo(Grupo, Jogo, NovoJogo) :-
        %Grupo eh uma lista de posicoes
        %[(Lin,Col)|Resto] = Grupo,
        %write('primeira posicao::'-Lin-Col),nl,
        %nth0(Col, Jogo, Coluna),
        %write('primeira coluna::'-Coluna),nl,
        %remover_grupo_coluna(Resto, Jogo, Coluna, NovoJogoX).
        remover_grupo(Grupo, Jogo, 0, NovoJogoX),
	delete(NovoJogoX, [], NovoJogo),!.
        %remover_grupo(Resto, NovoJogoX, NovoJogo).

remover_grupo(_, Jogo, IndiceColuna, []) :-
	length(Jogo, TamJogo),
	TamJogo == IndiceColuna.

remover_grupo(Grupo, Jogo, IndiceColuna, NovoJogo) :-
        nth0(IndiceColuna, Jogo, Coluna),
	remover_grupo_coluna(Grupo, Coluna, IndiceColuna, 0, NovaColuna),
	IndiceX is IndiceColuna + 1,
	remover_grupo(Grupo, Jogo, IndiceX, NovoJogoX),
	NovoJogo = [NovaColuna|NovoJogoX].

remover_grupo_coluna(_, Coluna, _, IndiceLinha, []) :-
	length(Coluna, TamColuna),
	IndiceLinha == TamColuna.

remover_grupo_coluna(Grupo, Coluna, IndiceColuna, IndiceLinha, NovaColuna) :-
	length(Coluna, TamColuna),
	IndiceLinha < TamColuna,
	\+member((IndiceLinha, IndiceColuna),Grupo),
	IndiceLinhaX is IndiceLinha + 1,
	nth0(IndiceLinha, Coluna, Elemento),
	remover_grupo_coluna(Grupo, Coluna, IndiceColuna, IndiceLinhaX, NovaColunaX),
	NovaColuna = [Elemento|NovaColunaX].
	
remover_grupo_coluna(Grupo, Coluna, IndiceColuna, IndiceLinha, NovaColuna) :-
	IndiceLinhaX is IndiceLinha + 1,
	remover_grupo_coluna(Grupo, Coluna, IndiceColuna, IndiceLinhaX, NovaColuna).
	
%% resolver(+Jogo, -Jogadas)
% Jogadas é um lista de posições que quando "clicadas" resolvem o Jogo.
% Este predicado não tem teste de unidade por que ele é o predicado principal.
% Este predicado é testado pelo testador.
% Este predicado deve encontrar apenas uma solução (se o jogo tiver solução).
% Este predicado é utilizando em resolvedor.pl
resolver([], []).

resolver(Jogo, [Jogada|RestoJogadas]) :-
        grupo(Jogo, Grupo),
        remover_grupo(Grupo, Jogo, NovoJogo),
        [Jogada|_] = Grupo,
        resolver(NovoJogo, RestoJogadas), !.

%% verifica se a posição eh valida considerando o tamanho do jogo.
posicao_valida(Lin, Col, Jogo) :-
        nth0(Col, Jogo, Coluna),
        length(Coluna, Ll),
        Lin >= 0,
        Col >= 0,
        Lin =< Ll-1.
