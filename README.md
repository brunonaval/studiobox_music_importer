# StudioBox Music Importer

StudioBox Music Importer e um app auxiliar para preparar musicas .mp4 para o Karaoke StudioBox.

Padrao final esperado:

`Autor - Musica - 00000.mp4`

## Padrao oficial de nomes

Formato esperado: `Autor - Musica - 00000.mp4`.

O codigo deve ter exatamente 5 digitos.

O separador oficial desta ferramenta e ` - `, o que evita ambiguidades com artistas como `A-ha`.

## Indexacao da biblioteca base

A biblioteca base e formada por arquivos que ja seguem o padrao oficial.

Nesta fase, o app calcula codigos usados, maior codigo, buracos disponiveis, duplicidades de codigo e artistas conhecidos.

Ainda nao ha selecao real de pasta nesta fase.

## Estrategias de codigo

O app permitira continuar apos o maior codigo existente ou preencher buracos disponiveis primeiro.

Em qualquer estrategia, codigos repetidos sao proibidos.

O limite natural dos codigos e 99999 e o codigo 00000 nunca sera usado.

## Analise de musicas novas

Arquivos novos podem chegar como Musica - Autor ou Autor - Musica.

O app usa artistas conhecidos da biblioteca base para decidir a ordem mais provavel.

Termos como Karaoke, HD e similares podem ser limpos automaticamente.

Casos ambiguos sao marcados com avisos para revisao manual.

Nesta fase ainda nao ha renomeio real.

## Plano de importacao

O app combina a analise dos nomes novos com a alocacao de codigos para montar sugestoes.

Cada item recebe sugestao de nome oficial quando possivel.

Itens confiaveis podem ser aprovados automaticamente.

Itens ambiguos, duplicados ou com informacao extra vao para revisao.

Nesta fase ainda nao ha renomeio real.

## Modos de saida

O app vai suportar renomear na propria pasta, copiar/mover para a biblioteca oficial e usar uma pasta de saida personalizada.

Nesta fase, ele apenas monta um plano em memoria para execucao futura.

Nenhuma operacao real de arquivo e executada ainda.

## Manifesto da operacao

O app montara um manifesto auditavel do plano de saida.

O manifesto registra origem, destino, acao, status e avisos.

Nesta fase, o manifesto existe apenas em memoria.

A gravacao em JSON sera adicionada depois.

## Organizacao do dominio

Os modulos de dominio agora possuem exports proprios para facilitar imports.

Isso simplifica o uso de parser, indexador, planners e manifesto nas proximas telas.

A Home mostra apenas um status visual de motor preparado.

Ainda nao ha integracao com pastas reais.

## Selecao da biblioteca oficial

O app agora permite selecionar a pasta da biblioteca oficial.

Nesta fase, o caminho selecionado e exibido na Home.

## Indexacao real da biblioteca oficial

Apos selecionar a pasta oficial, o app pode listar arquivos .mp4 reais da pasta.

O processo usa apenas os nomes dos arquivos para validar o padrao oficial e calcular estatisticas.

A Home exibe contadores de validos, invalidos, duplicados, maior codigo, buracos e artistas conhecidos.

Ainda nao ha cache/banco e nao ha renomeio nesta fase.

O app sera desenvolvido em fases.

O MVP inicial sera para Windows.

Android sera considerado depois.

Esta fase ainda nao implementa renomeio real.
