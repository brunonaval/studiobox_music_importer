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

## Auditoria da biblioteca oficial

Apos indexar, o app mostra auditoria visual com arquivos invalidos e codigos duplicados.

Arquivos invalidos exibem nome e motivo do problema.

Codigos duplicados mostram as musicas/arquivos associados.

Nesta fase, a auditoria e apenas visual e nenhuma correcao automatica e executada.

## Caminhos da biblioteca oficial

O scan da biblioteca agora preserva fileName, fullPath e relativePath para cada arquivo .mp4 encontrado.

A auditoria passa a priorizar o caminho relativo quando disponivel, mantendo a visualizacao limpa.

Isso prepara os proximos rounds para reparo seguro de invalidos e duplicados.

Nenhuma correcao automatica e executada nesta fase.

## Plano de reparo de codigos duplicados

O app agora monta um plano em memoria para reparo de codigos duplicados da biblioteca oficial.

Uma musica do grupo duplicado mantem o codigo original e as demais recebem sugestoes de novos codigos.

O plano preserva caminhos para futura execucao segura.

Nesta fase nada e renomeado.

## Previa do reparo de duplicados

Apos a auditoria, o app pode gerar uma previa visual do plano de reparo de codigos duplicados.

Uma musica mantem o codigo original e as demais recebem novos codigos sugeridos.

A previa mostra novo nome sugerido e caminho relativo quando disponivel.

Nesta fase nenhum arquivo e alterado.

## Dry-run do reparo de duplicados

O app tambem consegue validar em memoria quais arquivos seriam renomeados no reparo de duplicados.

O dry-run mostra origem e destino sugerido para cada item, sem executar operacoes reais.

Tambem detecta bloqueios basicos antes de qualquer execucao futura.

Nesta fase nenhum arquivo e alterado.

## Execucao segura do reparo de duplicados

Apos revisar o dry-run, o app pode executar o reparo real somente para itens prontos.

A execucao exige confirmacao explicita antes de renomear arquivos.

O app nao sobrescreve arquivos existentes e itens bloqueados nao sao executados.

Depois da execucao, o recomendado e reindexar a biblioteca oficial para atualizar os resultados.

## Seguranca na execucao real

Para liberar a execucao real do reparo de duplicados, o app exige:

- Marcar o checkbox de revisao do dry-run.
- Digitar RENOMEAR no campo de confirmacao.

A Home exibe claramente a pasta que sera alterada e quantos arquivos serao renomeados.

Um aviso informa que a acao nao possui desfazer automatico nesta fase.

O app recomenda testar primeiro em uma copia da biblioteca antes de executar na pasta oficial.

## Plano de reparo de arquivos invalidos

O app consegue montar sugestoes em memoria para arquivos invalidos da biblioteca oficial.

Ele usa artistas conhecidos da propria biblioteca para interpretar os nomes dos arquivos invalidos.

Codigos seguros sao alocados automaticamente para cada arquivo que possa ser identificado.

Itens ambiguos ou com baixa confianca ficam marcados para revisao manual.

Nesta fase nenhum arquivo e renomeado.

## Dry-run do reparo de arquivos invalidos

O app pode validar em memoria quais arquivos invalidos seriam renomeados no reparo.

O dry-run mostra origem e destino sugerido para cada item pronto.

Itens com revisao necessaria nao sao preparados para execucao automatica nesta fase.

Bloqueios sao exibidos antes de qualquer execucao real.

Nesta fase nenhum arquivo e alterado.

## Previa do reparo de arquivos invalidos

Apos a indexacao, o app pode gerar e exibir uma previa visual do plano de reparo de invalidos.

A previa mostra status, arquivo atual, motivo original, artista e musica detectados, novo nome sugerido e codigo sugerido para cada item.

Itens bloqueados exibem avisos explicando o impedimento.

A previa e limitada a 100 itens e pode ser ocultada ou revelada por alternancia.

Nesta fase nenhum arquivo e alterado.

## Sugestoes de importacao de musicas novas

Apos a pre-limpeza, o app gera sugestoes de importacao para os arquivos novos.

Usa o parser de nomes e os artistas conhecidos da biblioteca oficial para identificar artista e musica.

Aloca codigos seguros para cada item identificado usando a estrategia preencher buracos primeiro.

Cada candidato recebe status: aprovado automaticamente, revisao necessaria ou bloqueado.

Duplicidades com a biblioteca oficial sao detectadas e apontadas por aviso.

Nesta fase nada e renomeado.

## Pre-limpeza dos nomes novos

O app pode gerar uma previa de limpeza dos nomes de musicas baixadas.

Remove prefixos e sufixos comuns como Karaoke, Karaoke e Playback automaticamente.

Mostra o nome original e o nome limpo para cada arquivo escaneado.

Nesta fase nada e renomeado.

Analise inteligente e geracao de codigos virao depois.

## Scan da pasta de musicas novas

O app pode listar arquivos .mp4 da pasta de musicas novas selecionada.

O scan preserva nome do arquivo, caminho completo e caminho relativo para cada .mp4 encontrado.

Nesta fase ainda nao ha analise de nomes, geracao de codigos ou renomeio.

A analise inteligente dos nomes vira em rodada futura.

## Selecao da pasta de musicas novas

O app agora permite selecionar a pasta onde ficam os novos .mp4 baixados.

Nesta fase o app apenas exibe o caminho selecionado na Home.

Ainda nao ha leitura, analise ou renomeio das musicas novas.

A analise dos nomes vira em rodada futura.

## Execucao segura do reparo de arquivos invalidos

Apos revisar o dry-run dos invalidos, o app pode executar o reparo real somente para itens prontos.

A execucao exige marcar o checkbox de revisao e digitar RENOMEAR no campo de confirmacao.

O app nao sobrescreve arquivos existentes e somente permite renomear dentro do mesmo diretorio.

Itens marcados para revisao manual sao ignorados automaticamente na execucao.

Depois da execucao, o recomendado e reindexar a biblioteca oficial para atualizar os resultados.

O app sera desenvolvido em fases.

O MVP inicial sera para Windows.

Android sera considerado depois.
